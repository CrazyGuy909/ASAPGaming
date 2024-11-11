AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local positions = {
    Vector(-4342.968750, -6177.463867, -8625.308594),
    Vector(360.377380, -5937.080566, -8283.739258),
    Vector(-1811.512817, -9546.861328, -7390.799316),
    Vector(-3932.746094, -1483.574219, -9496.413086),
    Vector(3883.394287, 4059.987549, -8952.682617),
    Vector(286.123444, 1488.482300, -8775.293945),
    Vector(-4190.304199, 2894.306396, -8975.300781),
    Vector(2557.164307, 5389.946289, -8936.489258)
}

function ENT:Initialize()
    self:SetModel("models/props_junk/watermelon01.mdl")
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
    hook.Run("BATTLEPASS.SecretCactus", caller)
    self:SetPos(positions[math.random(#positions)])
end
