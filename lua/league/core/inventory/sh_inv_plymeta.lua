
local meta = FindMetaTable("Player")

function meta:GetLeagueInventory()
    return self._lolInventory or {}
end

function meta:GetLeagueItem(slot)
    return self:GetLeagueInventory():GetItem(slot)
end