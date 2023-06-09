if SERVER then
    util.AddNetworkString("NW.Set")
    util.AddNetworkString("NW.Sync")
end

TYPE_U8 = 1
TYPE_U16 = 2
TYPE_U32 = 3
TYPE_I8 = 4
TYPE_I16 = 5
TYPE_I32 = 6

local rw = {
    [TYPE_STRING] = {net.ReadString, net.WriteString},
    [TYPE_NUMBER] = {net.ReadFloat, net.WriteFloat},
    [TYPE_BOOL] = {net.ReadBool, net.WriteBool},
    [TYPE_U8] = {net.ReadUInt, net.WriteUInt, 8},
    [TYPE_U16] = {net.ReadUInt, net.WriteUInt, 16},
    [TYPE_U32] = {net.ReadUInt, net.WriteUInt, 32},
    [TYPE_I8] = {net.ReadInt, net.WriteInt, 8},
    [TYPE_I16] = {net.ReadInt, net.WriteInt, 16},
    [TYPE_I32] = {net.ReadInt, net.WriteInt, 32},
}

NWVars = NWVars or {
    Cache = {}
}

local meta = FindMetaTable("Player")
function NWVars:Register(name, type, default, private, proxy)
    meta.nw_vars = meta.nw_vars or {}
    meta.nw_vars[name] = {type = type, default = default, private = private, proxy = proxy}
    NWVars.Cache[name] = type

    meta["get" .. name] = function(s, def)
        return s.nw_vars[name].value or def or default
    end

    meta["set" .. name] = function(s, value)
        if proxy then
            local b = proxy(s, s.nw_vars[name].value or default, value)
            if b == false then return end
        end
        net.Start("NW.Set")
        net.WriteEntity(s)
        net.WriteString(name)
        rw[type][2](value, rw[type][3] or nil)
        if private then
            net.Send(s)
        else
            net.Broadcast()
        end

        s.nw_vars[name].value = value
        hook.Run("OnVarChanged", s, name, value)
    end
end

hook.Add("PlayerInitialSpawn", "NWVars.Sync", function(ply)
    local dv_table = {}
    for _, plys in pairs(player.GetAll()) do
        for id, val in pairs(plys.nw_vars) do
            if not val.value or val.value == val.default or val.private then continue end
            dv_table[plys] = dv_table[plys] or {}
            dv_table[plys][id] = val.value
        end
    end

    net.Start("NW.Sync")
    net.WriteUInt(table.Count(dv_table), 7)
    for pl, data in pairs(dv_table) do
        net.WriteEntity(pl)
        net.WriteUInt(table.Count(data), 8)
        for id, val in pairs(data) do
            net.WriteString(id)
            rw[pl.nw_vars[id].type][2](val, rw[pl.nw_vars[id].type][3] or nil)
        end
    end
    net.Send(ply)
end)

net.Receive("NW.Sync", function(l)
    Log("Core", "Reading NW vars...")
    local count = net.ReadUInt(7)
    local changed = 0
    for k = 1, count do
        local ply = net.ReadEntity()
        if not IsValid(ply) then
            ErrorNoHalt("Invalid player in NW.Sync, expect every other nw var to break")
            continue
        end
        for i = 1, net.ReadUInt(8) do
            ply.nw_vars[id].value = rw[ply.nw_vars[id].type][1](rw[ply.nw_vars[id].type][3] or nil)
            changed = changed + 1
        end
    end
    Log("Core", "Finished loading ", changed, " nw vars (", l / 1024, " kb)")
end)

net.Receive("NW.Set", function(l)
    local var, field
    net.ReadEntityAsync(function(ent)
        if not var or not ent.nw_vars[field] then
            print("Couldn't read var for ", field)
            return
        end

        if (ent.nw_vars[field].proxy) then
            local b = ent.nw_vars[field].proxy(ent, ent.nw_vars[field].value or ent.nw_vars[field].default, var)
            if b == false then return end
        end
        ent.nw_vars[field].value = var
        hook.Run("OnVarChanged", ent, field, var)
    end)

    field = net.ReadString()
    if not NWVars.Cache[field] then
        print("Invalid field " .. field)
        return
    end

    var = rw[NWVars.Cache[field]][1](rw[NWVars.Cache[field]][3] or nil)
end)