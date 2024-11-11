hook.Add("OnGamemodeLoaded", "aMenuIncludeCall", function()
	if string.find(string.lower(GAMEMODE.Name), "rp") or string.find(string.lower(GAMEMODE.Name), "purge") then
		include("amenu.lua")
	end
end)
include("amenu.lua")

CUSTOM_ENTITIES_ON = {}

net.Receive("CustomEntity.Network", function(l, ply)
	local id = net.ReadString()
	local ent = net.ReadUInt(16)
	timer.Simple(LocalPlayer():Ping() / 200, function()
		CUSTOM_ENTITIES_ON[id] = Entity(ent)
	end)
end)

hook.Add("OnPlayerChat", "HideSkillsCommand", function(ply, text, teamChat, isDead)
    -- Check if the chat message is "!skills"
    if text == "!skills" then
        -- Hide the command by returning true
        return true
    end
end)