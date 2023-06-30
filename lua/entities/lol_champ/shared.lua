
ENT.Base = "base_nextbot"
ENT.Type = "nextbot"

ENT.PrintName = "League Base"
ENT.Category = "League of Legends"

ENT.Spawnable = false
ENT.AutomaticFrameAdvance = true

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
    self:NetworkVar("Int", 0, "Level")
    self:NetworkVar("Int", 1, "Experience")
    self:NetworkVar("Int", 2, "Gold")
    self:NetworkVar("Float", 0, "NextIdle")

    self:SetLevel(1)
end

function ENT:BodyUpdate()
end

function ENT:Think()
    self:FrameAdvance()
    if SERVER then
        self:NextThink(CurTime())
        return true
    end
end

function ENT:SetupChampion(pl)
    League.Inventory:Initialize(pl)
    League.Resources:Initialize(pl)
    League.Resources:AddBar(pl, "health")
    League.Resources:AddBar(pl, "fury")

    if SERVER then
        net.Start("League.Champion:Setup")
        net.WriteEntity(self)
        net.WriteEntity(self:GetOwner())
        net.Broadcast()
    end
end

function util.ScaleFOVByAspectRatio(fovDegrees, ratio)
    local halfAngleRadians = fovDegrees * (0.5 * math.pi / 180.0)
    local halfTanScaled = math.tan(halfAngleRadians) * ratio

    return (180.0 / math.pi) * math.atan(halfTanScaled) * 2.0
end

-- returns a directional vector for a position on screen, corrects for mismatched fov
function util.ScreenToWorld(x, y)
    local view = render.GetViewSetup()
    local w, h = view.width, view.height
    local fov = view.fov_unscaled

    fov = util.ScaleFOVByAspectRatio(fov, (w / h) / (4 / 3))

    return util.AimVector(view.angles, fov, x, y, w, h)
end