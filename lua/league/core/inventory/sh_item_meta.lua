local ITEM = {}
ITEM.ID = ""
ITEM.Usable = false
ITEM.Hooks = {}
ITEM.Waiting = {}
ITEM.NetworkedVars = {}

AccessorFunc(ITEM, "m_eOwner", "Owner")
AccessorFunc(ITEM, "m_iPrice", "Price", FORCE_NUMBER)
AccessorFunc(ITEM, "m_iSlot", "Slot", FORCE_NUMBER)
AccessorFunc(ITEM, "m_iCount", "Count", FORCE_NUMBER)
AccessorFunc(ITEM, "m_iCooldown", "Cooldown", FORCE_NUMBER)

function ITEM:Initialize()
end

function ITEM:NetworkVar(type, name)
    self["Set" .. name] = function(self, val)
        self["m_" .. name] = val
        if SERVER then
            net.Start("League.Inventory:NetworkVar")
            net.WriteUInt(self:GetSlot(), 4)
            net.WriteString(name)
            net.WriteData(val)
            net.Send(self:GetOwner())
        end
    end

    self["Get" .. name] = function(self)
        return self["m_" .. name]
    end
end

function ITEM:OnEquip(ply)
end

function ITEM:OnUnequip(ply)
    self:Remove()
end

function ITEM:OnSell(ply)
    ply:AddLeagueMoney(self:GetPrice() * 0.5)
    self:Remove()
end

function ITEM:CanUse()
    if not self.Usable then return false end
    if self.Cooldown and self.Cooldown > CurTime() then
        return false
    end
    return true
end

ITEM.TimerCounter = 0
function ITEM:Wait(sec, cb)
    self.TimerCounter = self.TimerCounter + 1
    local id = self.TimerCounter
    local tag = "ITEM_WAIT_" .. id .. "_" .. self.ID .. "_" .. self:GetOwner():SteamID()
    self.Waiting[id] = {
        time = CurTime() + sec,
        cb = cb,
        tag = tag
    }

    timer.Create(tag, sec, 1, function()
        cb()
    end)
    return {
        id = id,
        Remove = function()
            timer.Remove(tag)
        end,
        Run = function()
            cb()
            timer.Remove(tag)
        end
    }
end

function ITEM:AddHook(hk, cb, time)
    local owner = self:GetOwner()
    local tagName = "ITEM_HOOK_" .. hk .. "_" .. self.ID .. "_" .. owner:SteamID()
    self.Hooks[hk] = {
        id = tagName,
        cb = cb,
        time = time
    }

    if time and time > 0 then
        self:Wait(time, function()
            self:RemoveHook(hk)
        end)
    end

    hook.Add(hk, tagName, function(...)
        if not IsValid(owner) then
            self:RemoveHook(hk)
            return
        end

        local a, b, c, d = cb(owner, unpack({...}))
        if a then
            return a, b, c, d
        end
    end)
end

function ITEM:RemoveHook(hk)
    hook.Remove(hk, self.Hooks[hk].id)
    self.Hooks[hk] = nil
end

function ITEM:Remove()
    for k, v in pairs(self.Hooks) do
        hook.Remove(k, v.id)
    end

    self:OnRemove()
end

function ITEM:OnRemove()
end

ITEM.__index = ITEM
League.Inventory.ItemMeta = ITEM

net.Receive("League.Inventory:NetworkVar", function()
    local slot, name = net.ReadUInt(4), net.ReadString()
    local item = LocalPlayer():GetItem(slot)
    if not item then return end

    item["Set" .. name] = net.ReadData(net.BytesLeft())
end)