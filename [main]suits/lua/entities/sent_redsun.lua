AddCSLuaFile()
DEFINE_BASECLASS("base_anim")
ENT.PrintName = "Red Sun"
ENT.Author = ""
ENT.Category = "Armor Suits Entities"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true
ENT.Speed = 1000

function ENT:SpawnFunction(ply, tr, cs)
    local ent = ents.Create(cs)
    ent:SetPos(ply:GetShootPos() + ply:GetAimVector() * 32)
    ent:SetAngles(ply:EyeAngles())
    ent:SetOwner(ply)
    ent:Spawn()
    return ent
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/hunter/misc/sphere025x025.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
        self:SetMaterial("models/shadertest/shader4")
        self:SetColor(Color(255, 0, 0))
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetModelScale(2, 0)
        self:Activate()
        self.sound = self:StartLoopingSound("dragonsbreath/dragon_fireball.wav")

        SafeRemoveEntityDelayed(self, engine.TickInterval() * 30)
        self:SetHealth(1000)
        self.ShadowParams = {}
        self:StartMotionController()
        self:EmitSound("botw/bomb/pickup.wav")
        local phys = self:GetPhysicsObject()
    
        if (phys:IsValid()) then
            phys:Wake()
            phys:EnableMotion(true)
        end
    end
end

function ENT:OnRemove()
    if (self.sound) then
        self:StopLoopingSound(self.sound)
    end
end

function ENT:Think()
    if CLIENT then return end

    for k, v in pairs(ents.FindInSphere(self:GetPos(), 200)) do
        if v:IsPlayer() and v != self:GetOwner() and (v:GetGang() == "" or v:GetGang() != self:GetOwner():GetGang()) then
            local dmg = DamageInfo()
            dmg:SetDamage(v:GetMaxHealth() * .05)
            dmg:SetAttacker(self:GetOwner())
            dmg:SetInflictor(self)
            dmg:SetDamageType(DMG_BURN)
            v:TakeDamageInfo(dmg)
            local diff = (self:GetPos() - v:GetPos()):GetNormalized()
            v:SetLocalVelocity(diff * 200)
        end
    end

    self:NextThink(CurTime() + engine.TickInterval())
end

function ENT:PhysicsSimulate(phys, delta)
    phys:Wake()
    if not IsValid(self:GetOwner()) then
        self:Remove()

        return
    end

    if not self.ang then
        self.ang = self:GetAngles()
    end

    self.ShadowParams.pos = self:GetPos() + self:GetForward() * self.Speed * delta
    self.ShadowParams.angle = self.ang
    self.ShadowParams.secondstoarrive = delta
    self.ShadowParams.maxangular = 5000 --What should be the maximal angular force applied
    self.ShadowParams.maxangulardamp = 100 -- At which force/speed should it start damping the rotation
    self.ShadowParams.maxspeed = 800 -- Maximal linear force applied
    self.ShadowParams.maxspeeddamp = 900 -- Maximal linear force/speed before damping
    self.ShadowParams.dampfactor = 0.8 -- The percentage it should damp the linear/angular force if it reaches it's max amount
    self.ShadowParams.teleportdistance = 50
    self.ShadowParams.deltatime = deltatime
    phys:ComputeShadowControl(self.ShadowParams)
end

local sprite = Material("sprites/m95_white_tiger_eye")
function ENT:DrawTranslucent()
    render.SetMaterial(sprite)
    render.DrawSprite(self:GetPos(), 200, 200, color_white)
    self:DrawModel()
end