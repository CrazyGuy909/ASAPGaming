AddCSLuaFile()
DEFINE_BASECLASS("base_anim")
ENT.PrintName = "Charge armor"
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

if SERVER then
    util.AddNetworkString("ArmorDLC.ChargeCalcView")
end


function ENT:SpawnFunction(ply, tr, ClassName)
    local ent = ents.Create(ClassName)
    ent:SetPos(tr.HitPos)
    ent:Spawn()
    ent:Activate()

    return ent
end

function ENT:Setup(ply)
    self:SetOwner(ply)
    self:SetPos(ply:GetPos())
    self:SetAngles(Angle(0, ply:GetAimVector():Angle().y, 0))
    self.LifeTime = 5
    self.Dir = self:GetAngles().y
    ply:SetNoDraw(true)
    self.Speed = 0
    self:ResetSequence("run_physgun")
    self:SetPoseParameter("move_x", 10)
    self:GetPhysicsObject():SetMass(1)
    ply:DrawViewModel(false)
    timer.Simple(.25, function()
        net.Start("ArmorDLC.ChargeCalcView")
        net.WriteEntity(self)
        net.Send(ply)
    end)
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/konnie/asapgaming/destiny2/tangledweb.mdl")
        self:PhysicsInitBox( -Vector(24, 24, 0), Vector(24, 24, 96) )
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

        self:SetModelScale(.7, 0)
    end

    self.ShadowParams = {}
    self:StartMotionController()

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
    self:GetOwner():SetNoDraw(false)
    self:GetOwner():SetPos(self:GetPos())
    self:GetOwner():SetAngles(self:GetAngles())
    self:GetOwner():SetNoDraw(false)
    self:GetOwner():DrawViewModel(true)
end

function ENT:OnRemove()
    self:Restore()
    if IsValid(self:GetOwner()) and SERVER then
        local armor = Armor:Get(self:GetOwner().armorSuit)
        self:GetOwner().lastArmorAbilityUsed = CurTime() + (armor.Cooldown or 10)
    elseif (CLIENT and self:GetOwner() == LocalPlayer()) then
        local armor = Armor:Get(self:GetOwner().armorSuit)
        self:GetOwner().lastArmorAbilityUsed = CurTime() + (armor.Cooldown or 10)
    end
end

function ENT:Think()
    if (math.abs(self:GetAngles().p) > 5 or math.abs(self:GetAngles().r) > 5) then
        self:SetAngles(Angle(0, self:GetAngles().y, 0))
    end
    if SERVER then
        self.LifeTime = (self.LifeTime or 5) - FrameTime()
        if (self.Collided) then return end
        if (self.LifeTime <= 0) then
            self:Remove()
            return
        end

        self:NextThink(CurTime())

        return true
    end
end

ENT.Collided = false
function ENT:PhysicsCollide(data, col)
    if (not self.Collided and data.HitEntity == game.GetWorld() and data.HitNormal.z == 0) then
        SafeRemoveEntityDelayed(self, .1)
        self:Restore()
        self.Collided = true
    end

    local hit = data.HitEntity
    if (hit == game.GetWorld()) then return end
    if (hit:IsPlayer() or hit:IsNPC() or IsValid(hit:GetPhysicsObject())) then
        local moveDir = (hit:GetPos() - self:GetPos()):GetNormalized() * 128 + self:GetAngles():Forward() * 96 + Vector(0, 0, 200)
        hit:SetLocalVelocity(moveDir)
    end
end

function ENT:PhysicsSimulate(phys, delta)
    if (self.Collided) then return end
    if CLIENT then return end
    phys:Wake()

    self.Speed = math.Clamp(self.Speed + 16, 0, 2000)
    if not IsValid(self:GetOwner()) then
        SafeRemoveEntityDelayed(self, .1)
        self.Collided = true
        return
    end
    local forward = Angle(0, self:GetOwner():GetAngles().y, 0):Forward() * self.Speed
    local tr = util.TraceHull({
        start = self:GetPos(), 
        endpos = self:GetPos() + forward,
        filter = self,
        mins = -Vector(48, 48, -8),
        maxs = Vector(48, 48, 96),
    })

    self.ShadowParams.pos = tr.HitPos
    self.ShadowParams.angle = Angle(0, self:GetOwner():GetAngles().y, 0)
    self.ShadowParams.secondstoarrive = .1
    self.ShadowParams.maxangular = 10000 --What should be the maximal angular force applied
    self.ShadowParams.maxangulardamp = 1 -- At which force/speed should it start damping the rotation
    self.ShadowParams.maxspeed = 2000 -- Maximal linear force applied
    self.ShadowParams.maxspeeddamp = 2000 -- Maximal linear force/speed before damping
    self.ShadowParams.dampfactor = 0.1 -- The percentage it should damp the linear/angular force if it reaches it's max amount
    self.ShadowParams.teleportdistance = 6000
    self.ShadowParams.deltatime = deltatime
    phys:ComputeShadowControl(self.ShadowParams)
end

function ENT:DrawTranslucent()
    self:DrawModel()
end

net.Receive("ArmorDLC.ChargeCalcView", function()
    local ent = net.ReadEntity()
    local noAttack = net.ReadBool()
    local targetView = LocalPlayer():EyePos()
    hook.Add("CalcView", ent, function(self, ply, pos, ang)
        targetView = LerpVector(FrameTime() * 5, targetView, ent:GetPos() + (ent:GetAngles():Forward() * -48 + Vector(0, 0, 64)))
        ply:DrawViewModel( false ) 
        return {
            origin = targetView,
            angles = Angle(16, ent:GetAngles().y, 0),
            fov = 85
        }
    end)
    if (noAttack) then
        hook.Add("StartCommand", ent, function(self, ply, cmd)
            if (ent:GetOwner() == ply) then
                cmd:RemoveKey(IN_ATTACK)
                cmd:RemoveKey(IN_ATTACK2)
            end
        end)
    end
end)