color_nigger = color_black
BATTLEPASS = {}
BATTLEPASS.Database = {}
BATTLEPASS.Challenges = {}
BATTLEPASS.ChallengeCategories = {}
--a
BATTLEPASS.ActiveChallenges = {}

--[[
BATTLEPASS.Theme = {
	PrimaryVariant = Color(72, 40, 128),
	Primary = Color(103,58,183),
	Background = Color(33, 33, 33),
	BackgroundAccent = Color(43, 43, 43)
}
]]
local function IncludeClient(str)
    if SERVER then
        AddCSLuaFile("battlepass/" .. str .. ".lua")
    elseif CLIENT then
        include("battlepass/" .. str .. ".lua")
    end
end

local function IncludeServer(str)
    if SERVER then
        include("battlepass/" .. str .. ".lua")
    end
end

local function IncludeShared(str)
    IncludeClient(str)
    IncludeServer(str)
end

-- Theme
IncludeClient("ui/theme")

for i, v in pairs(file.Find("battlepass/themes/*.lua", "LUA")) do
    IncludeClient("themes/" .. v:sub(1, v:len() - 4))
end

-- Include third party
IncludeClient("thirdparty/shadows")
IncludeClient("thirdparty/gradient")
-- Include UI essentials
IncludeClient("ui/fonts")
IncludeClient("ui/animations")
-- Include Database elements
IncludeServer("database/sql")
-- Include UI elements
IncludeClient("ui/button")
IncludeClient("ui/frame")
IncludeClient("ui/layout")
IncludeClient("ui/textentry")
IncludeClient("ui/tooltip")
IncludeClient("ui/navbar_side")
IncludeClient("ui/menu")
IncludeClient("ui/combobox")
IncludeClient("ui/checkbox")
IncludeClient("ui/navbar_double")
-- Include script UI
IncludeClient("menu/frame")
IncludeClient("menu/navbar")
IncludeClient("menu/battlepass")
IncludeClient("menu/challenges")
IncludeClient("menu/help")
IncludeClient("menu/shop")

local function loadSystems()
    -- Include shared elements
    IncludeShared("shared/helper")
    IncludeShared("shared/unlock_functions")
    IncludeShared("shared/language")
    IncludeShared("shared/challenges")
    IncludeShared("shared/pass")
    -- Include networking
    IncludeClient("network/client")
    IncludeServer("network/server")
    -- Include essentials
    IncludeServer("server/player")
    IncludeServer("server/secret_ents")
    
    for i, v in pairs(file.Find("battlepass/challenges/*.lua", "LUA")) do
        IncludeShared("challenges/" .. v:sub(1, v:len() - 4))
    end
end

loadSystems()

concommand.Add("asap_bp_hardload", function(ply)
    if IsValid(ply) then return end
    BATTLEPASS.Challenges = {}
    BATTLEPASS.ChallengeCategories = {}
    BATTLEPASS.ActiveChallenges = {}

    loadSystems()

    for k, v in pairs(player.GetAll()) do
        BATTLEPASS:InitialPlayerSpawn(v)
    end
end)