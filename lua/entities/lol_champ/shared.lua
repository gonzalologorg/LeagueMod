
ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.PrintName = "League Base"
ENT.Category = "League of Legends"

ENT.Spawnable = false

ENT.InputKeys = {
    [KEY_Q] = 1,
    [KEY_W] = 2,
    [KEY_E] = 3,
    [KEY_R] = 4,
}

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "Target")
    self:NetworkVar("Bool", 0, "Idle")
    self:NetworkVar("Bool", 1, "Attacking")
    self:NetworkVar("Bool", 2, "Dead")
    self:NetworkVar("Vector", 0, "Objective")
end

function ENT:SetupChampion(pl)
    League.Inventory:Initialize(pl)
    League.Resources:Initialize(pl)
    League.Resources:AddBar(pl, self.HealthResource)
    League.Resources:AddBar(pl, self.ManaResource)

    if SERVER then
        net.Start("League.Champion:Setup")
        net.WriteEntity(self)
        net.WriteEntity(self:GetOwner())
        net.Broadcast()
    end
end