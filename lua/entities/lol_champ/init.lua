AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
util.AddNetworkString("League.Champion:SendOrder")
util.AddNetworkString("League.Abilities:Cast")
util.AddNetworkString("League.Champion:Setup")

function ENT:SpawnFunction(pl, tr, cs)
    if not tr.Hit then return end
    local ent = ents.Create(cs)
    ent:SetPos(tr.HitPos)
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
    self.loco:SetDeceleration(200)
    self.loco:SetAcceleration(600)

    self:SetModel(self.Model)
    self:PhysicsInitBox(-Vector(12, 12, 0), Vector(12, 12, 72))
    self:ResetSequence("idle")
    self:SetNextIdle(CurTime() + self:SequenceDuration())
end

function ENT:MoveToTarget(pos, options)
    if IsValid(self.CurrentPath) then
        self.CurrentPath:Invalidate()
    end
    options = options or {}
    local path = Path("Follow")
    path:SetMinLookAheadDistance(300)
    path:SetGoalTolerance(16)
    path:Compute(self, pos)

    self.CurrentPath = path
    if not path:IsValid() then return "failed" end

    while path:IsValid() do
        if self.ShouldStop then
            self.ShouldStop = false
            path:Invalidate()

            return "ok"
        end
        -- Draw the path (only visible on listen servers or single player)
        if options.draw then
            path:Draw()
        end

        -- If we're stuck then call the HandleStuck function and abandon
        if self.loco:IsStuck() then
            self:HandleStuck()

            return "stuck"
        end

        //MsgN(path:)
        --
        -- If they set maxage on options then make sure the path is younger than it
        --
        if options.maxage and path:GetAge() > options.maxage then
            return "timeout"
        end

        --
        -- If they set repath then rebuild the path every x seconds
        --
        if options.repath and path:GetAge() > options.repath then
            path:Compute(self, pos)
        end

        path:Update(self)


        coroutine.yield()
    end

    return "ok"
end

function ENT:RunBehaviour()
    while true do
        if self.TargetMove then
            self.loco:SetDesiredSpeed(300) -- walk speeds
            self:StartActivity(ACT_WALK) -- walk anims
            self:MoveToTarget(self.TargetMove) -- walk to a random place within about 200 units (yielding)
            self.TargetMove = nil
            self:ResetSequence("idle")
            self:SetNextIdle(CurTime() + self:SequenceDuration())
        end
        coroutine.yield()
    end
end

function ENT:Think()
    self:NextThink(CurTime())

    return true
end

function ENT:DoMousePress(left, target)
    local angle = (target - self:GetPos()):Angle()
    self:SetAngles(Angle(0, angle.y, 0))

    if not left then
        self.TargetMove = target
        self.Shouldstop = true
        if self.CurrentPath then
            self.CurrentPath:Invalidate()
        end
    end
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
    if not IsValid(champ) then return end
    local id = net.ReadUInt(3)
    local b = champ:CanPerformAttack(id)
    if b == false then return end
    champ:PerformAttack(id)
end)

net.Receive("League.Champion:SendOrder", function(l, ply)
    local champ = net.ReadEntity()
    if champ:GetOwner() ~= ply then return end
    champ:DoMousePress(net.ReadBool(), net.ReadVector())
end)