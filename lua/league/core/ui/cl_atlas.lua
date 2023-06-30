League.Atlas = {
    HUD = {},
    Frame = {},
}
local header = Material("lol/ui/effects/hudbar")
local mainhud = Material("lol/ui/mainhud")
local animbars = Material("lol/ui/effects/bars")

local sizex, sizey = 183, 90
local curFrame = 1
for x = 0, 4 do
    for y = 0, 3 do
        League.Atlas.HUD[curFrame] = GWEN.CreateTextureNormal(x * sizex, y * sizey, sizex, sizey, header)
        curFrame = curFrame + 1
    end
end

League.Atlas.Frame = {
    base = GWEN.CreateTextureNormal(198, 656, 558, 170, mainhud),
    avatar = GWEN.CreateTextureNormal(0, 656, 166, 170, mainhud),
    inventory = GWEN.CreateTextureNormal(8, 416, 235, 160, mainhud),
    shop = {},
    bars = {},
    animated = {},
}

for k = 0, 2 do
    League.Atlas.Frame.shop[k + 1] = GWEN.CreateTextureNormal(2 + k * 203, 600, 203, 36, mainhud)
end

local first, barwidth, barheight, gap = 876 / 1024, 462 / 1024, 17.4 / 1024, 4.5 / 1024
for k = 0, 6 do
    League.Atlas.Frame.bars[k + 1] = function(x, y, w, h, progress)
        surface.SetMaterial(mainhud)
        surface.SetDrawColor(clr or color_white)
        surface.DrawTexturedRectUV(x, y, w * progress, h, gap / 4, first + k * barheight + gap * k, barwidth * progress, first + k * barheight + k * gap + barheight)
    end
end

curFrame = 1
local start, bh2, bw2 = 465 / 2048, 16 / 2048, 463 / 1024
League.Atlas.Frame.animated = function(x, y, w, h, progress)
    local frame = 1 + math.floor(RealTime() * 50) % 50
    surface.SetMaterial(animbars)
    surface.SetDrawColor(clr or color_white)
    local ux, uy =  frame % 2 == 0 and 0 or bw2,
                    start + (math.ceil(frame / 2) - 1) * bh2
    surface.DrawTexturedRectUV(x, y, w * progress, h, ux, uy, ux + bw2 * progress, uy + bh2)
end

hook.Add("HUDPaint", "League.DrawHUD", function()
    //League.Atlas.Frame.animated(96, 96, 462, 18, 1)
end)