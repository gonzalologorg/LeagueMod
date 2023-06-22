AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("League.Abilities:Cast")
util.AddNetworkString("League.Champion:Setup")

function ENT:SpawnFunction(pl, tr, cs)
    if not tr.Hit then return end
    local ent = ents.Create(cs.ClassName)
    ent:SetPos(tr.HitPos + tr.HitNormal * 16)
    ent:SetOwner(pl)
    ent:Spawn()
    ent:Activate()

    pl.leagueChampion = ent
    timer.Simple(0, function()
        ent:SetupChampion(pl)
    end)
    return ent
end

function ENT:Initialize()
    self:SetModel(self.Model)
end

net.Receive("League.Champion:Setup", function(pl)
    local champ = net.ReadEntity()
    net.Start("League.Champion:Setup")
    net.WriteEntity(champ)
    net.WriteEntity(champ:GetOwner())
    net.Send(pl)
end)

net.Receive("League.Abilities:Cast", function(l, ply)
    local champ = ply.leagueChampion
    if not IsValid(champ) then
        return
    end

    local id = net.ReadUInt(3)
    local b = champ:CanPerformAttack(id)
    if b == false then return end
    champ:PerformAttack(id)
end)