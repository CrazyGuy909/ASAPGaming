AddCSLuaFile()
local global_smoke = {}
DEFINE_BASECLASS("base_anim")
ENT.PrintName = "Magma Sphere"
ENT.Author = ""
ENT.Category = "Fun + Games"
ENT.Spawnable = false
ENT.AdminSpawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/props/cs_office/snowman_head.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_PUSHAWAY)
        self:SetMaterial("models/shadertest/shader4")
        self:Ignite(999)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        --self:SetModelScale(1, 1)
        self:Activate()

        timer.Simple(0, function()
            local phys = self:GetPhysicsObject()

            if (phys:IsValid()) then
                phys:Wake()
                phys:EnableMotion(true)
            end
        end)

        self:SetHealth(1000)
        self.ShadowParams = {}
        self:StartMotionController()
        self:EmitSound("botw/bomb/pickup.wav")
    end
end

function ENT:Explode()
    local ball = ents.Create("prop_combine_ball")
    ball:SetPos(self:GetPos() + Vector(0, 0, 30))
    ball:SetAngles(Angle(0, 0, 90))
    ball:Spawn()
    ball:Fire("Explode", 0, 0)
    local eff = EffectData()
    eff:SetOrigin(self:GetPos())
    eff:SetMagnitude(.4)
    util.Effect("eff_firestorm", eff, true, true)
    for k, v in pairs(ents.FindInSphere(self:GetPos(), 200)) do
        if (v:IsNPC() or v:IsPlayer()) then
            v:Ignite(10)
        end
    end
    SafeRemoveEntity(self)
    
end


function ENT:PhysicsSimulate(phys, delta)
    phys:Wake()
    if not IsValid(self:GetOwner()) then
        self:Remove()

        return
    end

    local owner = self:GetOwner()

    self.ShadowParams.pos = self:GetPos() + self:GetOwner():GetAimVector() * 64
    self.ShadowParams.angle = Angle(0, self:GetOwner():EyeAngles().y, 0)
    self.ShadowParams.secondstoarrive = delta
    self.ShadowParams.maxangular = 5000 --What should be the maximal angular force applied
    self.ShadowParams.maxangulardamp = 100 -- At which force/speed should it start damping the rotation
    self.ShadowParams.maxspeed = 1000000 -- Maximal linear force applied
    self.ShadowParams.maxspeeddamp = 10000 -- Maximal linear force/speed before damping
    self.ShadowParams.dampfactor = 0.8 -- The percentage it should damp the linear/angular force if it reaches it's max amount
    self.ShadowParams.teleportdistance = 50
    self.ShadowParams.deltatime = deltatime
    phys:ComputeShadowControl(self.ShadowParams)
end

local sprite = Material("sprites/m95_white_tiger_eye")
function ENT:DrawTranslucent()
    render.SetMaterial(sprite)
    render.DrawSprite(self:GetPos(), 96, 96, color_white)
    self:DrawModel()
end