local ENERGY = {}

function ENERGY:Initialize()
    local owner = self:GetOwner()
    self:SetMaxValue(100 + 50 * owner:GetLeagueLevel())

    if SERVER then
        self:AddHook("EntityTakeDamage")
    end
end

function ENERGY:EntityTakeDamage(owner, ent, dmg)
    if owner == ent then
        self:Add(dmg:GetDamage() * .15)
    end
end

function ENERGY:GetTickRate()
    return 0
end
