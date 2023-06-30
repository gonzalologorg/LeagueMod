League.FontCache = League.FontCache or {}

function League:Font(x)
    if self.FontCache[x] then
        return self.FontCache[x]
    end

    local new_font = "LeagueFont." .. x
    surface.CreateFont(new_font, {
        font = "Beaufort for LOL Ja",
        size = x,
        weight = 500,
        antialias = true,
        shadow = false
    })

    self.FontCache[x] = new_font
    return new_font
end