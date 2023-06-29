local ENERGY = {}

function ENERGY:Initialize()
    local owner = self:GetOwner()
    self:SetMaxValue(owner:GetMaxHealth())
end

function ENERGY:GetTickRate()
    return 1
end

League.Resources:Register("mana", ENERGY)
