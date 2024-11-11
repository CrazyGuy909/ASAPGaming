AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')
util.AddNetworkString("OpenGobblegumMenu")

function ENT:Initialize()
	self:SetModel("models/Humans/Group02/male_07.mdl");
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:SetUseType(SIMPLE_USE)
	self:SetBloodColor(BLOOD_COLOR_RED)
end


function ENT:AcceptInput(name, activator, caller)	
	net.Start("OpenGobblegumMenu")
	net.Send(caller)
end

local args = {
    ["!gobble"] = true,
    ["!gobblegums"] = true,
    ["!gums"] = true,
    ["!bubblegums"] = true,
}
hook.Add("PlayerSay", "Gobblegums.OpenMenu", function(ply, text)
	if (args[text]) then
		net.Start("OpenGobblegumMenu")
		net.Send(ply)
	end
end)