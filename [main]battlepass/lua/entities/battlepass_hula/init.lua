AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local positions = {
    Vector(369.717041, 268.651337, 5.735385),
    Vector(-735.238708, -450.478699, 376.007751),
    Vector(-4584.758301, -7274.594727, -93.221581),
    Vector(2394.390869, -4080.653076, -131.977142),
    Vector(13266.442383, -5696.721191, -119.400276),
    Vector(598.136475, 3855.582520, -375.976593),
    Vector(1510.878662, 2656.023193, 24.033220),
    Vector(-1470.433716, 5357.767578, -499.970032),
    Vector(-979.312927, 3855.735596, -375.973938)
}

function ENT:Initialize()
    self:SetModel("models/props_lab/huladoll.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:SetPos(positions[math.random(#positions)])
    self:DropToFloor()

    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:Use(caller)
    hook.Run("BATTLEPASS.SecretCane", caller)
    self:SetPos(positions[math.random(#positions)])
end
