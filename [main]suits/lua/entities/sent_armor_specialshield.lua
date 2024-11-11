AddCSLuaFile()
DEFINE_BASECLASS("base_anim")
ENT.PrintName = "Armor Shield"
ENT.Author = ""
ENT.Category = "ASAP"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Sons = {}
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true
ENT.MaxHealth = 10
ENT.ShieldDamage = true

function ENT:SpawnFunction(ply, tr, ClassName)
    local ent = ents.Create(ClassName)
    ent:SetPos(tr.HitPos)
    ent:Spawn()
    ent:Activate()
    ent:SetOwner(ply)

    return ent
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/gonzo/shield.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
        self:Activate()

        timer.Simple(0, function()
            local phys = self:GetPhysicsObject()

            if (phys:IsValid()) then
                phys:Wake()
                phys:EnableMotion(true)
            end
        end)
    end
end

function ENT:Think()
    local owner = self:GetOwner()

    if not IsValid(owner) then
        if SERVER then
            self:Remove()
        end

        return
    end

    self:SetAngles(Angle(0, owner:EyeAngles().y, 0))
    self:SetPos(owner:GetPos())

    if (SERVER and not owner:Alive()) then
        self:Remove()
    end
end

function ENT:DrawTranslucent()
    self:DrawModel()
end