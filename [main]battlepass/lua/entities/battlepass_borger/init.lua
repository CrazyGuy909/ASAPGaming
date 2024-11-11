AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local positions = {
    Vector(-325.094116, -1164.744629, 100.085587),
    Vector(1078.018433, -27.001736, -131.969254),
    Vector(3187.557861, 513.647217, -131.956833),
    Vector(6512.856445, 745.729431, -133.708221),
    Vector(1320.611206, 7024.078125, -131.976608),
    Vector(2213.914795, 3715.168701, -131.975540),
    Vector(66.406876, 496.173828, -794.675476),
    Vector(928.195557, 1943.838013, -80.582764)
}

function ENT:Initialize()
    self:SetModel("models/food/burger.mdl")
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
    hook.Run("BATTLEPASS.SecretPresent", caller)
    self:SetPos(positions[math.random(#positions)])
end
