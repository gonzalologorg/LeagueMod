local PANEL = {}
AccessorFunc(PANEL, "m_eChampion", "Champion")
local gold = Color(227, 203, 66)
local w, h = 558 * .8, 170 * .8
function PANEL:Init()
    League.FramePanel = self

    self:SetSize(1024, h)
    self:AlignBottom(0)
    self:AlignRight(ScrW() / 2 - self:GetWide() / 2)

    self:ShowCloseButton(false)
    self:SetTitle("")
    self:SetDraggable(false)
    self:SetCursor("no")

    self.inventory = vgui.Create("DPanel", self)
    self.inventory:SetPos(self:GetWide() / 2 + w / 2 - 2, 0)
    self.inventory:SetSize(236 * .8, 168 * .8)
    self.inventory.Paint = function(s, w, h)
        League.Atlas.Frame.inventory(0, 0, w, h)
    end

    self.ShopButton = vgui.Create("DButton", self.inventory)
    self.ShopButton:Dock(BOTTOM)
    self.ShopButton:SetTall(36 * .8)
    self.ShopButton:DockMargin(8, 0, 8, 8)
    self.ShopButton:SetText("")
    self.ShopButton.Paint = function(s, w, h)
        League.Atlas.Frame.shop[s:IsHovered() and (input.IsMouseDown(MOUSE_LEFT) and 2 or 3) or 1](0, 0, w, h)
        draw.SimpleTextOutlined(IsValid(self:GetChampion()) and self:GetChampion():GetGold() or 400, League:Font(22), w / 2, h / 2, gold, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
    end
end

local icon = Material("lol/champions/sett/avatar")

function PANEL:Paint(rw, rh)
    //surface.SetDrawColor(255, 0, 0)
    //surface.DrawRect(0, 0, rw, rh)

    League.Atlas.Frame.base(rw / 2 - w / 2, 0, w, h)

    surface.SetMaterial(icon)
    surface.SetDrawColor(255, 255, 255)
    surface.DrawTexturedRectRotated(rw / 2 - w / 2 - 16, h / 2, h * .8, h * .8, 0)
    League.Atlas.Frame.avatar(rw / 2 - w / 2 - 76, 6, 166 * .8, h)

    local perc = math.Clamp(LocalPlayer():Health() / LocalPlayer():GetMaxHealth(), 0, 1)

    League.Atlas.Frame.bars[3](rw / 2 - w / 2 + 54, h - 46, 373, 16, perc)
    League.Atlas.Frame.animated(rw / 2 - w / 2 + 54, h - 46, 373, 16, perc)
    League.Atlas.Frame.bars[1](rw / 2 - w / 2 + 54, h - 46 + 18, 373, 16, 1)

    draw.SimpleTextOutlined(1, League:Font(22), rw / 2 - w / 2 + 12, h - 25, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
    draw.SimpleTextOutlined(LocalPlayer():Health() .. "/" .. LocalPlayer():GetMaxHealth(), League:Font(18), rw / 2, h - 38, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
end

vgui.Register("lol.hudpanel", PANEL, "DFrame")

if IsValid(League.FramePanel) then
    League.FramePanel:Remove()
end

//vgui.Create("lol.hudpanel")