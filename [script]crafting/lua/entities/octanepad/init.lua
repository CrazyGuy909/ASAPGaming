AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/octane_jump_pad/octane_jump_pad.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetTrigger(true)
    self:SetCollisionBounds(self:OBBMaxs(), self:OBBMins())
    self:UseTriggerBounds(true)
	local phys = self:GetPhysicsObject()
	if phys then
		phys:Wake()
	end
end

function ENT:StartTouch(ent)
	if !ent:IsPlayer() then return end
	if !ent:Alive() then return end -- How this dude touching it then O-o
	ent:SetVelocity((ent:GetForward() * 1000) + Vector(0, 0, 500))
	self:EmitSound("HL1/ambience/steamburst1.wav")
end