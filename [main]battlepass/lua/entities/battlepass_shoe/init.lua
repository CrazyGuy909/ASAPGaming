AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local positions = {
    Vector(1002.683350, 4926.052246, -639.971252),
    Vector(-1251.160522, 3191.664551, -131.894287),
    Vector(-1718.948364, 1434.013672, 28.032574),
    Vector(6872.732910, -4572.919922, -53.868507),
    Vector(-3799.570313, -1797.704590, -123.976883)
}

function ENT:Initialize()
    self:SetModel("models/props_junk/Shoe001a.mdl")
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
    hook.Run("BATTLEPASS.SecretCDoll", caller)
    self:SetPos(positions[math.random(#positions)])
end
