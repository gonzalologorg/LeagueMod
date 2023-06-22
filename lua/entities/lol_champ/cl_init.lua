include("shared.lua")
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
    hook.Add("CalcView", self, function(s, ply, origin, ang, fov, znear, zfar)
        if LocalPlayer() != self:GetOwner() and GetViewEntity() != self then return end
        local res = self:CalcView(origin, ang, fov, znear, zfar)
        if res then
            return res
        end
    end)

    hook.Add("PlayerButtonDown", self, function(s, ply, btn)
        if ply != self:GetOwner() then return end
        self:PlayerButtonDown(btn)
    end)

    hook.Add("HUDPaint", self, function(s)
        self:DrawHUD()
    end)

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

function ENT:CanPerformAttack(id)
    return true
end

function ENT:PlayerButtonDown(btn)
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

function ENT:CalcView(origin, ang, fov, znear, zfar)
end

function ENT:Draw()
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

    ent:SetupChampion(owner)
    ent.champInit = true
end)