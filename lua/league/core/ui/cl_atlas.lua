League.Atlas = {
    HUD = {}
}
local header = Material("lol/ui/effects/hudbar")
local sizex, sizey = 183, 90
local curFrame = 1
for x = 0, 4 do
    for y = 0, 3 do
        League.Atlas.HUD[curFrame] = GWEN.CreateTextureNormal(x * sizex, y * sizey, sizex, sizey, header)
        curFrame = curFrame + 1
    end
end



hook.Add("HUDPaint", "League.DrawHUD", function()
    local frame = 1 + math.Round(RealTime() * 10) % 19
    local x, y = ScrW() / 2, ScrH() / 2
//    League.Atlas.HUD[frame](x, y, sizex, sizey)
end)