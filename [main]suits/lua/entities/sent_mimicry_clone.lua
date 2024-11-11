AddCSLuaFile()
DEFINE_BASECLASS("base_anim")
ENT.PrintName = "Mimicry Clone"
ENT.Author = ""
ENT.Category = "ASAP"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Sons = {}
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true
ENT.MaxHealth = 50
ENT.ShieldDamage = true

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "WeaponClass")
    self:NetworkVar("String", 0, "Armor")
end

function ENT:SpawnFunction(ply, tr, ClassName)
    local ent = ents.Create(ClassName)
    ent:SetPos(tr.HitPos)
    ent:Spawn()
    ent:Activate()

    return ent
end

function ENT:Initialize()
    if SERVER then
        self:SetModel(self:GetOwner():GetModel())
        self:PhysicsInitBox(Vector(-24, -24, 0), Vector(24, 24, 90))
        self:SetCollisionGroup(COLLISION_GROUP_PUSHAWAY)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:Activate()
        self:SetHealth(self:GetOwner():Health())
        self:EmitSound("staff/ult_melee_swing.mp3")

        timer.Simple(0, function()
            local phys = self:GetPhysicsObject()

            if (phys:IsValid()) then
                phys:Wake()
                phys:EnableMotion(true)
            end
        end)

        local holdtype = self:GetOwner():GetActiveWeapon():GetHoldType()
        self:SetSequence("run_" .. holdtype)
    end

    self.ShadowParams = {}
    self.Forward = Angle(0, self:GetOwner():EyeAngles().y, 0):Forward()
    self:StartMotionController()
    self:SetPoseParameter("move_x", 10)
    self:SetWeaponClass(self:GetOwner():GetActiveWeapon():GetModel())

    if CLIENT then
        self:SetRenderBounds(-Vector(1, 1, 0) * 160, Vector(1, 1, 1) * 160)
        self:InvalidateBoneCache()
    end
end

function ENT:OnTakeDamage(dmg)
    self:SetHealth(self:Health() - dmg:GetDamage())

    if (self:Health() <= 0) then
        self:Remove()
    end
end

function ENT:Nick()
    return self:GetOwner():Nick()
end

function ENT:Team()
    return self:GetOwner():Team()
end

ENT.DidSpark = false

function ENT:Think()
    self:SetAngles(Angle(0, self:GetAngles().y, 0))
    self:SetCycle(CurTime() % 1)

    if SERVER then
        self.LifeTime = (self.LifeTime or 5) - FrameTime()

        if (not self.DidSpark and self.LifeTime < .1) then
            self.DidSpark = true
            local eff = EffectData()
            self:EmitSound("weapons/immo/plasma_stop.wav")
            eff:SetEntity(self)
            util.Effect("entity_remove", eff, true, true)
        end

        if (self.LifeTime <= 0) then
            self:Remove()

            return
        end

        self:NextThink(CurTime())

        return true
    end
end

function ENT:PhysicsSimulate(phys, delta)
    phys:Wake()

    if not IsValid(self:GetOwner()) then
        SafeRemoveEntityDelayed(self, .1)
        self.Collided = true

        return
    end

    self.ShadowParams.pos = self:GetPos() + self.Forward * self:GetOwner():GetWalkSpeed()
    self.ShadowParams.angle = self.Forward:Angle()
    self.ShadowParams.secondstoarrive = 1
    self.ShadowParams.maxangular = 1 --What should be the maximal angular force applied
    self.ShadowParams.maxangulardamp = 1 -- At which force/speed should it start damping the rotation
    self.ShadowParams.maxspeed = self:GetOwner():GetWalkSpeed() -- Maximal linear force applied
    self.ShadowParams.maxspeeddamp = 500 -- Maximal linear force/speed before damping
    self.ShadowParams.dampfactor = 1 -- The percentage it should damp the linear/angular force if it reaches it's max amount
    self.ShadowParams.teleportdistance = 2000
    self.ShadowParams.deltatime = delta
    phys:ComputeShadowControl(self.ShadowParams)
end

function ENT:OnRemove()
    if IsValid(self.VM) then
        self.VM:Remove()
    end
end

function ENT:DrawTranslucent()
    self:DrawModel()

    if (self:GetArmor() == "") then return end
    self.armorSuit = self:GetArmor()
    if hook.GetTable()["PostPlayerDraw"]["PostArmorDraw"] then
        hook.GetTable()["PostPlayerDraw"]["PostArmorDraw"](self)
    else
        return
    end

    if (self:GetWeaponClass() ~= "" and not IsValid(self.VM)) then
        self.VM = ClientsideModel(self:GetWeaponClass())

        if not self.VM then
            self.VM = true

            return
        end

        self.VM:SetParent(self)
        self.VM:AddEffects(EF_BONEMERGE)
    end

end