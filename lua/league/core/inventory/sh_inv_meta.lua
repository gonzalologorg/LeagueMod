local INV = {}
INV.Slots = 6

function INV:GetOwner()
    return self.Owner
end

function INV:CreateInventory()
    local owner = self:GetOwner()
    owner._lolInventory = {}
end

function INV:AddItem(item, slot, amount, cooldown)
    local owner = self:GetOwner()
    amount = amount or 1
    cooldown = cooldown or 0

    if item == "" or amount == 0 then
        owner._lolInventory[slot] = nil
        return true        
    end

    local itemMeta = League.Inventory:GetMeta(item)
    if not itemMeta then return false end

    if not slot then
        for k = 1, self.Slots do
            local itemSlot = owner._lolInventory[k]
            if itemSlot and itemSlot.id == item then
                local meta = itemSlot.meta
                if meta.MaxStack and meta.MaxStack >= amount + meta:GetCount() then
                    slot = k
                    break                
                end
            elseif not itemSlot then
                slot = k
                break
            end
        end
    end

    local oldSlot = owner._lolInventory[slot]
    local mustCreate = true
    if oldSlot then
        local meta = oldSlot.meta
        if meta.MaxStack and meta.MaxStack >= amount + meta:GetCount() then
            mustCreate = false
            meta:SetCount(meta:GetCount() + amount)
        end
    else
        owner._lolInventory[slot] = {
            id = item,
            meta = mLeague.Inventory:BuildMeta(owner, item, slot)
        }    
    end

    if SERVER then
        net.Start("League.Inventory:SyncSlot")
        net.WriteUInt(slot, 4)
        net.WriteString(item)
        net.WriteUInt(self:GetItem(slot):GetCount(), 8)
        net.WriteFloat(self:GetItem(slot):GetCooldown(), 8)
        net.Send(owner)
    end

    return true
end

function INV:RemoveItem(slot, count)
    if isnumber(slot) then
        local itemSlot = self:GetSlot(slot)
        if not itemSlot then
            return false
        end

        local meta = itemSlot.meta
        meta:SetCount(meta:GetCount() - (count or meta:GetCount()))

        if SERVER then
            net.Start("League.Inventory:SyncInfo")
            net.WriteUInt(slot, 4)
            net.WriteUInt(meta:GetCount(), 8)
            net.WriteFloat(meta:GetCooldown(), 8)
            net.Send(owner)
        end

        if meta:GetCount() == 0 then
            meta:Remove()
        end

        return true
    end

    for k = 1, self.Slots do
        local item = self:GetSlot(k)
        if item and item.id == slot then
            return self:RemoveItem(k, count)
        end
    end
end

function INV:GetSlot(slot)
    return self:GetOwner():GetLeagueInventory()[slot]
end

function INV:GetItem(slot)
    return self:GetSlot(slot).meta
end

function INV:UseItem(slot)
    local owner = self:GetOwner()
    local item = self:GetSlot(slot)
    if not item then return false end

    local meta = self:GetItem(slot)
    if not meta.Usable then return false end

    if not meta:CanUse(owner) then
        return false
    end

    local b = meta:OnUse(owner)
    if b == false then return false end

    if SERVER then
        net.Start("League.Inventory:UseItem")
        net.WriteUInt(slot, 4)
        net.Send(owner)
    end

    if meta:GetCount() > 1 then
        meta:SetCount(meta:GetCount() - 1)
        if meta:GetCount() <= 0 then
            self:RemoveItem(slot)
        end
    end

    meta:SetCooldown(CurTime() + meta.Cooldown)
    return true
end

INV.__index = INV
League.Inventory.InvMeta = INV

function League.Inventory:Initialize(ply)
    ply._lolInventory = setmetatable({}, INV)
    ply._lolInventory.Owner = ply
    ply._lolInventory:CreateInventory()
    if SERVER then
        net.Start("League.Inventory:CreateInventory")
        net.Send(ply)
    end
end

function League.Inventory:BuildMeta(ply, item, slot)
    local itemMeta = self:GetMeta(item)
    if not itemMeta then return false end

    local meta = setmetatable({}, self.ItemMeta)
    meta:SetOwner(ply)
    meta:SetSlot(slot)
    meta:Instantiate(itemMeta)

    ply:Wait(0, function()
        meta:OnEquip(ply)
    end)

    return meta
end

net.Receive("League.Inventory:CreateInventory", function()
    WaitForLocalPlayer(function()
        League.Inventory:Initialize(LocalPlayer())
    end)
end)

net.Receive("League.Inventory:UseItem", function()
    local slot = net.ReadUInt(4)
    LocalPlayer():GetLeagueInventory():UseItem(slot)
end)

net.Receive("League.Inventory:SyncInfo", function()
    local slot, amount, cooldown = net.ReadUInt(4), net.ReadString(), net.ReadUInt(8), net.ReadFloat()
    local invSlot = LocalPlayer():GetLeagueInventory():GetSlot(slot)
    if not invSlot then return end

    if amount <= 0 then
        LocalPlayer():GetLeagueInventory()[slot] = nil
    else
        invSlot.meta:SetCount(amount)
        invSlot.meta:SetCooldown(cooldown)
    end
end)

net.Receive("League.Inventory:SyncSlot", function()
    local slot, item, amount, cooldown = net.ReadUInt(4), net.ReadString(), net.ReadUInt(8), net.ReadFloat()

    local inv = LocalPlayer():GetLeagueInventory()
    inv:AddItem(item, slot, amount, cooldown)
end)