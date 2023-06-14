util.AddNetworkString("League.Inventory:SyncSlot")
util.AddNetworkString("League.Inventory:SyncInfo")
util.AddNetworkString("League.Inventory:CreateInventory")
util.AddNetworkString("League.Inventory:UseItem")
util.AddNetworkString("League.Inventory:ItemMessage")
util.AddNetworkString("League.Inventory:NetworkVar")

local meta = FindMetaTable("Player")

function meta:AddLeagueItem(item, slot, amount, cooldown)
    return self:GetLeagueInventory():AddItem(item, slot, amount, cooldown)
end

function meta:RemoveLeagueItem(slot)
    return self:GetLeagueInventory():RemoveItem(slot)
end

hook.Add("PlayerInitialSpawn", "GenerateLeagueInventory", function(ply)
    net.Start("League.Inventory:CreateInventory")
    net.Send(ply)
end)