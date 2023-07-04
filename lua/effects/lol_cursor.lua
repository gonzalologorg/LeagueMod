local circle = Material("lol/ui/circle.vmt")

function EFFECT:Init(data)
    self.Origin = data:GetOrigin()
    self.Normal = data:GetNormal()
    self:SetPos(self.Origin)
    self:SetModel("models/gonzo/league/cursor.mdl")
    self:SetCycle(0)
    self:SetModelScale(.5)
end

function EFFECT:Render()
    local progress = math.min(math.ease.OutBack(self:GetCycle()), 1)
    render.SetMaterial(circle)
    render.DrawQuadEasy(self.Origin + Vector(0, 0, 2), self.Normal, 96 * progress, 96 * progress, Color(255, 255, 255, 255 * (1 - progress)), 0)
    self:SetCycle(self:GetCycle() + FrameTime() * 2)
    self:DrawModel()
end

function EFFECT:Think()
    return self:GetCycle() < 1
end