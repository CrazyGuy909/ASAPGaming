AddCSLuaFile()
DEFINE_BASECLASS("base_anim")
ENT.PrintName = "Poison Shield"
ENT.Author = ""
ENT.Category = "ASAP"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Sons = {}
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true
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
        self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:DrawShadow(false)
        self:SetSkin(0)

        self:SetModelScale(.1)

        timer.Simple(0, function()
            self:SetModelScale(.5, .5)
        end)
        
        timer.Simple(0, function()
            local phys = self:GetPhysicsObject()

            if (phys:IsValid()) then
                phys:Wake()
            end
        end)
        self:SetHealth(10)
    end

    self:SetMaterial("models/props_foliage/tree_springers_01a_trunk")
    self:SetColor(Color(5, 150, 5))
    self:SetSpawnEffect(true)
    self.MaxProgress = CurTime() + 1

    timer.Simple(0, function()
        local eff = EffectData()
        eff:SetEntity(self)
        util.Effect("eff_venomsuit", eff, true, true)
    end)
end

function ENT:OnTakeDamage(dmg)
    self:SetHealth(self:Health() - dmg:GetDamage())

    if (self:Health() <= 0) then
        self:Remove()
    end
end

function ENT:OnRemove()
    if (IsValid(self:GetOwner())) then
        local armor = Armor:Get(self:GetOwner().armorSuit)
        if (self:GetOwner()._maxRunSpeed) then
            self:GetOwner():SetRunSpeed(self:GetOwner()._maxRunSpeed)
        end
        if (self:GetOwner()._maxWalkSpeed) then
            self:GetOwner():SetWalkSpeed(self:GetOwner()._maxWalkSpeed)
        end
        if (armor and armor.OnRemove) then
            self:GetOwner().lastArmorAbilityUsed = CurTime() + armor.Cooldown or 10
        end
    end
end

ENT.NextTake = 0
ENT.Progress = 0

ENT.Particles = {}
ENT.NextDamage = 0
ENT.NextParticle = 0
function ENT:Think()
    local owner = self:GetOwner()
    if (self.Progress < 1) then
        self.Progress = 1 - (self.MaxProgress - CurTime())
    end
    self:SetPos(owner:GetPos() + Vector(0, 0, 95 * self.Progress))

    if (self.NextParticle < CurTime()) then
        for k = 1, 4 do
            local cos = math.cos((math.pi * 2) * (k / 4) + self:Health())
            local sin = math.sin((math.pi * 2) * (k / 4) + self:Health())
            local dir = Vector(cos, sin, 0)
            table.insert(self.Particles,{
                dir = dir,
                pos = self:GetPos(),
                life = 2
            })
        end
        self.NextParticle = CurTime() + .75
    else
        local evalDamage = false
        if (self.NextDamage < CurTime()) then
            self.NextDamage = CurTime() + .5
            evalDamage = true
        end

        local framers = {}
        for k,v in pairs(self.Particles) do
            if (v.life <= 0) then
                table.remove(self.Particles, k)
                continue
            end
            v.life = v.life - FrameTime()
            v.pos = v.pos + v.dir - Vector(0, 0, .5)

            if (SERVER and evalDamage) then
                local power =  (1 - v.life / 2) * 64
                for _, ent in pairs(ents.FindInBox(v.pos - Vector(1, 1, 1) * power, v.pos + Vector(1, 1, 1) * power)) do
                    if (ent:IsPlayer() and ent != self:GetOwner() and not framers[ent]) then
                        local dmg = DamageInfo()
                        dmg:SetDamage(5)
                        dmg:SetDamageType(DMG_RADIATION)
                        dmg:SetAttacker(self:GetOwner())
                        ent:TakeDamageInfo(dmg)
                        framers[ent] = true
                    end
                end
            end
        end

        evalDamage = false
    end

    if SERVER then
        self:NextThink(CurTime())
        if (self.NextTake <= CurTime()) then
            self.NextTake = CurTime() + 1
            self:SetHealth(self:Health() - 1)
            if (self:Health() <= 0) then
                self:Remove()
                return
            end
        end
        return true
    end
end

if CLIENT then
    matproxy.Add({
        name = "ShieldDamage",
        init = function(self, mat, values)
            -- Store the name of the variable we want to set
            self.ResultTo = values.resultvar
        end,
        bind = function(self, mat, ent)
            if (ent.ShieldDamage) then
                mat:SetFloat(self.ResultTo, 1 - ent:Health() / ent.MaxHealth)
            end
        end
    })
end