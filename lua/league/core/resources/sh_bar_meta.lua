local ENERGY = {}
AccessorFunc(ENERGY, "m_sID", "ID", FORCE_STRING)
AccessorFunc(ENERGY, "m_MaxValue", "MaxValue", FORCE_NUMBER)
AccessorFunc(ENERGY, "m_Value", "Value", FORCE_NUMBER)
AccessorFunc(ENERGY, "m_Owner", "Owner")

ENERGY.m_fTickRate = 1
ENERGY.m_fRecoverRate = 5
ENERGY.m_tHooks = {}

function ENERGY:Initialize()
end

function ENERGY:AddHook(name, cb)
    local tag = "League.Resources:" .. self:GetID() .. ":" .. self:GetOwner():EntIndex()
    self.m_tHooks[name] = tag
    hook.Add(name, tag, function(...)
        if not IsValid(self:GetOwner()) then
            hook.Remove(name, tag)
            return
        end

        if cb then
            local a, b, c = cb(self:GetOwner(), ...)
            if a then
                return a, b, c
            end

            return
        end

        local a, b, c, d = self[name]( self:GetOwner(), ...)
        if a then
            return a, b, c, d
        end
    end)
end

function ENERGY:Remove()
    for hk, cb in pairs(self.m_tHooks) do
        hook.Remove(hk, "League.Resources:" .. self:GetID() .. ":" .. self:GetOwner():EntIndex())
    end
end

function ENERGY:SetValue(val)
    self.m_Value = math.Clamp(val, 0, self:GetMaxValue())

    if SERVER then
        net.Start("League.Resources:SyncValue")
        net.WriteEntity(self:GetOwner())
        net.WriteString(self.ID)
        net.WriteUInt(val, 16)
        net.Broadcast()
    end
end

function ENERGY:Add(am)
    self:SetValue(self:GetValue() + am)
end

function ENERGY:Draw(x, y, w, h)
end

function ENERGY:Set(am)
    self:SetValue(am)
end

function ENERGY:GetTickRate()
    return 1
end

function ENERGY:GetTickRate()
    return self:GetMaxValue() / 100
end

function ENERGY:Think()
    if self:GetValue() >= self:GetMaxValue() then
        return
    end

    if not self._nextTick or self._nextTick < CurTime() then
        if self:GetTickRate() == 0 then
            return
        end
        self._nextTick = CurTime() + self:GetTickRate()
        self:Add(self:GetRecoverRate())
    end
end

ENERGY.__index = ENERGY
League.Resources.Meta = ENERGY
League.Resources.List = {}

function League.Resources:Register(type, meta)
    self.List[type] = setmetatable(meta, self.Meta)
end

function League.Resources:Initialize(ply)
    ply.LeagueResources = {}
end

function League.Resources:AddBar(ply, id)
    if not self.List[type] then
        ErrorNoHaltWithStack("Invalid resource type: " .. type)
        return false
    end

    local bar = setmetatable({}, self.List[type])
    bar:SetOwner(ply)
    bar:Initialize()

    ply.LeagueResources[id] = bar
    return bar
end

hook.Add("OnEntityCreated", "League.Resources", function(ent)
    if ent:IsPlayer() then
        League.Resources:Initialize(ent)
    end
end)

AddCSLuaFile("sub/health.lua")
AddCSLuaFile("sub/mana.lua")
AddCSLuaFile("sub/fury.lua")
include("sub/health.lua")
include("sub/mana.lua")
include("sub/fury.lua")