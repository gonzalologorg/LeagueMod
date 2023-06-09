if SERVER then
    util.AddNetworkString("g_loadent")
end

local log_data = {}

function LogRegister(name, color)
    log_data[name] = color
end

LogRegister("Core", Color(255, 100, 0))
LogRegister("Champion", Color(125, 0, 255))
LogRegister("Items", Color(0, 255, 100))
LogRegister("Ability", Color(255, 255, 50))
LogRegister("Inventory", Color(0, 255, 255))

function Log(name, ...)
    local clr = log_data[name] or color_white
    MsgC(clr, "[" .. name .. "] ", color_white, unpack({...}), "\n")
end

function p(x)
    x = x or 1
    return (x == 1 and CLIENT) and LocalPlayer() or player.GetByID(x)
end

local waiting = false
local queue_slot = 0
local queue_ents = {}

function net.ReadEntityAsync(cb)
    local eid = net.ReadUInt(13)
    if (IsValid(Entity(eid))) then
        timer.Simple(0, function()
            cb(Entity(eid))
        end)
        return
    end

    if (not waiting) then
        hook.Add("OnEntityCreated", "ReadEntityQueue", function(ent)
            if (queue_ents[ent:EntIndex()]) then
                local func = queue_ents[ent:EntIndex()]
                timer.Simple(0, function()
                    func(ent)
                end)
                queue_slot = queue_slot - 1
                if (queue_slot <= 0) then
                    hook.Remove("OnEntityCreated", "ReadEntityQueue")
                    waiting = false
                end
            end
        end)
        waiting = true
    end

    queue_slot = queue_slot + 1
    queue_ents[eid] = cb
end

function SafeRemovePanel(panel)
    if (IsValid(panel)) then
        panel:Remove()
    end
end
