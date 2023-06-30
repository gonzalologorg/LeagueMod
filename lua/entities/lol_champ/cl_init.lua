include("shared.lua")
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
    self.Zoom = 0
    self:CreateHooks()
    self:CreateOutline()

    self.Collider = CreatePhysCollideBox( self:GetPos() - Vector(24, 24, 0), self:GetPos() + Vector(24, 24, 92))

    if LocalPlayer() == self:GetOwner() then
        self.Panel = vgui.Create("Panel")
        self.Panel:SetSize(ScrW(), ScrH())
        self.Panel:SetKeyboardInputEnabled(false)
        self.Panel.OnMouseWheeled = function(s, delta)
            self.Zoom = math.Clamp(self.Zoom + delta * 8, 0, 300)
        end
    end

    gui.EnableScreenClicker(true)
    local hasInit = self.champInit

    if not hasInit then
        self.champInit = true

        if IsValid(self:GetOwner()) then
            self:SetupChampion(self:GetOwner())

            return
        end

        net.Start("League.Champion:Setup")
        net.WriteEntity(self)
        net.SendToServer()
    end
end

function ENT:CreateHooks()
    hook.Add("CalcView", self, function(s, ply, origin, ang, fov, znear, zfar)
        if LocalPlayer() ~= self:GetOwner() and GetViewEntity() ~= self then return end
        local res = self:CalcView(origin, ang, fov, znear, zfar)
        if res then return res end
    end)

    hook.Add("PlayerButtonDown", self, function(s, ply, btn)
        if ply ~= self:GetOwner() then return end
        self:PlayerButtonDown(btn)
    end)

    hook.Add("HUDPaint", self, function(s)
        self:DrawHUD()
    end)

    hook.Add("VGUIMousePressAllowed", self, function(s, btn)
        self:IssueOrder(btn)
    end)
end

function ENT:CreateOutline()
    self.Outline = ClientsideModel(self:GetModel())
    self.Outline:SetNoDraw(true)
    self.Outline:SetMaterial("model_color")
    self.Outline:SetModelScale(self:GetModelScale() + 0.15, 0)
    self.Outline:SetColor(color_black)
    self.Outline:SetParent(self)
    self.Outline:SetLocalAngles(Angle(0, 0, 0))
end

function ENT:IssueOrder(btn)
    local dir = util.ScreenToWorld(gui.MouseX(), gui.MouseY())//util.AimVector( LocalViewAngles, 90, gui.MouseX(), gui.MouseY(), ScrW(), ScrH() )
    local start = self:GetPos() + LocalViewAngles:Forward() * -32
    local tr = util.TraceLine({
        start = self.ViewOrigin,
        endpos = self.ViewOrigin + LocalViewAngles:Forward() * -96 + dir * 32768,
        filter = {LocalPlayer(), self}
    })

    net.Start("League.Champion:SendOrder")
    net.WriteEntity(self)
    net.WriteBool(btn == MOUSE_LEFT)
    net.WriteVector(tr.HitPos)
    net.SendToServer()

    debugoverlay.Cross(tr.HitPos, 10, 0.1, Color(0, 255, 0), true)
end

function ENT:OnRemove()
    SafeRemoveEntity(self.Outline)
    if IsValid(self.Panel) then
        self.Panel:Remove()
    end
    if self.Collider:IsValid() then
        self.Collider:Destroy()
    end
    gui.EnableScreenClicker(false)
end

function ENT:CanPerformAttack(id)
    return true
end

function ENT:PlayerButtonDown(btn)
    if true then return end
    local id = self.InputKeys[btn]

    if id then
        local b, reason = self:CanPerformAttack(id)

        if b == false then
            chat.AddText(reason or "You cannot do that right now.")

            return
        end

        self:PerformAttackClient(id)
        net.Start("League.Abilities:Cast")
        net.WriteUInt(id, 3)
        net.SendToServer()
    end
end

LocalViewAngles = Angle(50, 180, 0)

function ENT:CalcView(origin, ang, fov, znear, zfar)
    local view = {}
    view.origin = self.ViewOrigin or self:GetPos() + Vector(350, 0, 480)
    if self.Zoom > 0 then
        view.origin = view.origin + LocalViewAngles:Forward() * self.Zoom
    end
    view.fov = 75
    view.angles = LocalViewAngles

    return view
end

function ENT:Draw()
    self.ViewOrigin = self:GetPos() + Vector(350, 0, 480)
    local diff = (self.ViewOrigin - self:GetPos()):GetNormalized():Angle()
    local outline_width = (.25 + self.Zoom / 500) * .125
    render.SetColorModulation(0, 0, 0)
    self.Outline:SetModelScale(self:GetModelScale() + outline_width, 0)
    self.Outline:SetPos(self:GetPos() - diff:Forward() * 128 * outline_width + diff:Up() * -outline_width * 24)
    self.Outline:SetSequence(self:GetSequence())
    self.Outline:SetCycle(self:GetCycle())
    render.CullMode(MATERIAL_CULLMODE_CW)
    self.Outline:DrawModel()
    render.CullMode(MATERIAL_CULLMODE_CCW)
    render.SetColorModulation(1, 1, 1)
    self:DrawModel()
    
    local dir = util.ScreenToWorld(gui.MouseX(), gui.MouseY())//util.AimVector( LocalViewAngles, 90, gui.MouseX(), gui.MouseY(), ScrW(), ScrH() )
    local tr = util.TraceLine({
        start = self.ViewOrigin,
        endpos = self.ViewOrigin + dir * 32768,
        filter = LocalPlayer()
    })
    debugoverlay.BoxAngles(self:GetPos(), Vector(-24, -24, 0), Vector(24, 24, 96), self:GetAngles(), FrameTime(), Color(255, 0, 0, 5))
    debugoverlay.Line(  self.ViewOrigin,
                        tr.HitPos,
                        FrameTime(),
                        Color(255, 0, 0, 5)
    , true)

    local hitpos, normal, frac = self.Collider:TraceBox(self:GetPos(),
    Angle(0, 0, 0),
    self.ViewOrigin,
    tr.HitPos,
    Vector(-1, -1, -1) * 32,
    Vector(1, 1, 1) * 32)

    MsgN(hitpos)

end

ENT.BarSize = {
    w = 128,
    h = 32
}

function ENT:DrawHUD()
    local owner = self:GetOwner()
    local pos = self:GetPos() + Vector(0, 0, self.Height or 96)
    local scr = pos:ToScreen()

    for k, v in pairs(owner.LeagueResources) do
        v:Draw(scr.x - self.BarSize.w / 2, scr.y - self.BarSize.h / 2, self.BarSize.w, self.BarSize.h)
    end

end

net.Receive("League.Champion:Setup", function()
    local ent, owner = net.ReadEntity(), net.ReadEntity()
    if not IsValid(ent) then return end
    timer.Simple(LocalPlayer():Ping() / 1000, function()
        if not IsValid(ent) then return end
        ent:SetupChampion(owner)
        ent.champInit = true
    end)
end)