local ENERGY = {}
ENERGY.Name = "Health"

function ENERGY:Initialize()
    local owner = self:GetOwner()
    self:SetMaxValue(owner:GetMaxHealth())
    if SERVER then
        self:AddHook("EntityTakeDamage")
    end
end

function ENERGY:GetValue()
    return self:GetOwner():Health()
end

function ENERGY:Draw(x, y, w, h)
    local val, max = self:GetValue(), self:GetMaxValue()
    local perc = val / max

    surface.SetDrawColor(86, 217, 46)
    surface.DrawRect(x, y, w * perc, h)

    for k = 1, math.floor(max / 100) do
        surface.SetDrawColor(0, 0, 0)
        surface.DrawRect(x + (w / (max / 100)) * k, y, 1, (k % 10 == 0) and h or h - 4)
    end
end

function ENERGY:GetMaxValue()
    return self:GetOwner():GetMaxHealth()
end

function ENERGY:SetValue(val)
    self:GetOwner():SetHealth(val)
end

function ENERGY:Add(am)
    self:SetValue(self:GetValue() + am)
    if self:GetValue() > self:GetMaxValue() then
        self:GetOwner():SetArmor(self:GetValue() - self:GetMaxValue())
        self:SetValue(self:GetMaxValue())
    end
end

function ENERGY:EntityTakeDamage(owner, ent, dmg)
    if owner == ent and owner:Armor() > 0 then
        local damage = dmg:GetDamage()
        if damage > owner:Armor() then
            owner:SetArmor(0)
            dmg:SetDamage(damage - owner:Armor())
        else
            owner:SetArmor(owner:Armor() - damage)
            dmg:SetDamage(0)
        end
    end
end

function ENERGY:GetTickRate()
    return 1
end

League.Resources:Register("health", ENERGY)
