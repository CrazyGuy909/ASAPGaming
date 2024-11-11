AddCSLuaFile()
DEFINE_BASECLASS("base_anim")
ENT.PrintName = "Heaven armor"
ENT.Author = ""
ENT.Category = "ASAP"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Sons = {}
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true
ENT.MaxHealth = 50
ENT.ShieldDamage = true
ENT.Speed = 16

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "owning_ent")
end

function ENT:SpawnFunction(ply, tr, ClassName)
    local ent = ents.Create(ClassName)
    ent:SetPos(tr.HitPos)
    ent:Spawn()
    ent:Activate()
    ent:Setup(ply)

    return ent
end

function ENT:Setup(ply)
    self:SetOwner(ply)
    self:SetPos(ply:GetPos())
    self:SetAngles(Angle(0, ply:GetAimVector():Angle().y, 0))
    ply:SetMoveType(MOVETYPE_NONE)
    ply:SetNoDraw(true)
    ply:DrawViewModel(false)
    self.Height = self:GetPos().z + 40
    self.Speed = 0
    self:ResetSequence("swimming_all")

    timer.Simple(.25, function()
        net.Start("ArmorDLC.ChargeCalcView")
        net.WriteEntity(self)
        net.WriteBool(true)
        net.Send(ply)
    end)

    hook.Add("StartCommand", self, function(self, ply, cmd)
        if (self:GetOwner() == ply) then
            cmd:RemoveKey(IN_ATTACK)
            cmd:RemoveKey(IN_ATTACK2)
        end
    end)
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/konnie/asapgaming/destiny2/solstice.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_PUSHAWAY)
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
    end

    if CLIENT then
        self:SetRenderBounds(-Vector(1, 1, 0) * 160, Vector(1, 1, 1) * 160)
    end
end

function ENT:OnTakeDamage(dmg)
    self:SetHealth(self:Health() - dmg:GetDamage())

    if (self:Health() <= 0) then
        self:Remove()
    end
end

function ENT:Restore()
    if (not IsValid(self:GetOwner())) then return end
    self:GetOwner():SetNoDraw(false)
    self:GetOwner():SetPos(self:GetPos() + Vector(0, 0, 32))
    self:GetOwner():SetAngles(self:GetAngles())
    self:GetOwner():SetNoDraw(false)
    self:GetOwner():DrawViewModel(true)
    self:GetOwner():SetMoveType(MOVETYPE_WALK)
end

function ENT:OnRemove()
    self:Restore()
end

function ENT:Think()
    if SERVER then
        if IsValid(self:GetOwner()) then
            self:GetOwner():SetPos(self:GetPos())
        end

        if (not self.LifeTime) then
            self:NextThink(CurTime())

            return true
        end

        self.LifeTime = (self.LifeTime or 10) - FrameTime()

        if ((self._nextHeal or 0) < CurTime()) then
            self._nextHeal = CurTime() + .75

            for k, v in pairs(ents.FindInSphere(self:GetPos(), 172)) do
                if (v:IsPlayer()) then
                    v:SetHealth(math.Clamp(v:Health() + v:GetMaxHealth() / 10, 0, v:GetMaxHealth()))
                    local eff = EffectData()
                    eff:SetStart(self:GetPos() + Vector(0, 0, 35))
                    eff:SetOrigin(v:GetPos() + Vector(0, 0, 35))
                    util.Effect("tracer_heal", eff, true, true)
                end
            end
        end

        if (self.LifeTime <= 0) then
            self.LifeTime = nil
        end

        self:NextThink(CurTime())

        return true
    end
end

function ENT:PhysicsSimulate(phys, delta)
    phys:Wake()
    self.Speed = self.Speed + delta * 128

    if not IsValid(self:GetOwner()) then
        self:Remove()

        return
    end

    local owner = self:GetOwner()
    local forward = owner:KeyDown(IN_FORWARD) and 1 or owner:KeyDown(IN_BACK) and -1 or 0
    local right = owner:KeyDown(IN_MOVELEFT) and -1 or owner:KeyDown(IN_MOVERIGHT) and 1 or 0
    local height = owner:KeyDown(IN_JUMP) and 1 or owner:KeyDown(IN_DUCK) and -1 or 0
    local tr = util.QuickTrace(self:GetPos(), owner:KeyDown(IN_JUMP) and Vector(0, 0, 96) or owner:KeyDown(IN_DUCK) and Vector(0, 0, -32) or Vector(0, 0, 0), {self, owner})

    if (not IsValid(tr.HitEntity) and not tr.HitWorld) then
        self.Height = self.Height + height
    end

    self.ShadowParams.pos = forward * self:GetForward() * 16 + right * self:GetRight() * 16 + Vector(self:GetPos().x, self:GetPos().y, self.Height)
    self.ShadowParams.angle = Angle(0, self:GetOwner():EyeAngles().y, 0)
    self.ShadowParams.secondstoarrive = .25
    self.ShadowParams.maxangular = 5000 --What should be the maximal angular force applied
    self.ShadowParams.maxangulardamp = 100 -- At which force/speed should it start damping the rotation
    self.ShadowParams.maxspeed = 1000000 -- Maximal linear force applied
    self.ShadowParams.maxspeeddamp = 10000 -- Maximal linear force/speed before damping
    self.ShadowParams.dampfactor = 0.8 -- The percentage it should damp the linear/angular force if it reaches it's max amount
    self.ShadowParams.teleportdistance = 50
    self.ShadowParams.deltatime = deltatime
    phys:ComputeShadowControl(self.ShadowParams)
end

local moon = Material("asap/armors/moon")

function ENT:DrawTranslucent()
    render.SetMaterial(moon)
    render.DrawSprite(self:GetPos() + self:GetRight() * 4 + Vector(0, 0, self:GetModelRadius() / 2), 96, 96, color_white)
    self:DrawModel()
end