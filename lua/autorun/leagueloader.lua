DeriveGamemode("sandbox")

AddCSLuaFile("league/globals.lua")
include("league/globals.lua")

local files, _ = file.Find("league/helpers/*", "LUA")
for _, fil in pairs(files) do
    AddCSLuaFile("league/helpers/" .. fil)
    include("league/helpers/" .. fil)
end

-- Functions
local function loadFolder(folder, recursive, ignore)
    local original = folder
    MsgC(Color(255, 100, 0), "[Core]", color_white, " Loading Realm: " .. folder .. "\n")

    if recursive then
        local _, dirs = file.Find(folder .. "/*", "LUA")

        for _, dir in pairs(dirs) do
            loadFolder(original .. "/" .. dir, false)
        end

        return
    end

    if ignore then
        files, _ = file.Find(folder .. "/*.lua", "LUA")
        for _, lua in pairs(files) do
            AddCSLuaFile(folder .. "/" .. lua)
            include(folder .. "/" .. lua)
        end
    end

    local temp = {
        cl = {},
        sv = {},
        sh = {}
    }

    files, _ = file.Find(folder .. "/*.lua", "LUA")

    for _, fil in SortedPairsByValue(files) do
        for start, data in pairs(temp) do
            if string.StartWith(fil, start) then
                table.insert(data, fil)
                break
            end
        end
    end

    for k, v in pairs(temp.sh) do
        if SERVER then
            AddCSLuaFile(folder .. "/" .. v)
        end

        include(folder .. "/" .. v)
    end

    for k, v in pairs(temp.cl) do
        if SERVER then
            AddCSLuaFile(folder .. "/" .. v)
            continue
        end

        include(folder .. "/" .. v)
    end

    if CLIENT then return end

    for k, v in pairs(temp.sv) do
        include(folder .. "/" .. v)
    end
end

loadFolder("league/core", true)
loadFolder("league/content", true)