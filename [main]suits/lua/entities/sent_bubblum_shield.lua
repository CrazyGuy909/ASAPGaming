AddCSLuaFile()
local global_smoke = {}
DEFINE_BASECLASS("base_anim")
ENT.PrintName = "Bubblum Bubble"
ENT.Author = ""
ENT.Category = "Fun + Games"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Sons = {}
ENT.LifeTime = 5
ENT.MaxSize = 400
ENT.IsBubblumShield = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Status")
    self:NetworkVar("Int", 0, "Kind")
    self:SetStatus(false)
    self:SetKind(0)
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/XQM/Rails/gumball_1.mdl")
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_NONE)
    end

    self:SetModelScale(8, 0)
    self:SetMaterial("asap/hexa_white")
    self:DrawShadow(false)

    hook.Add("EntityTakeDamage", self, function(s, ent, dmg)
        local ret = self:ResolveDamage(ent, dmg)
        if ret == true then return true end
    end)
end

function ENT:Explode()
    local ball = ents.Create("prop_combine_ball")
    ball:SetPos(self:GetPos() + Vector(0, 0, 30))
    ball:Spawn()
    ball:Fire("Explode", 0, 0)
    SafeRemoveEntity(self)
end

ENT.Inside = {}
local noloop = false

function ENT:ResolveDamage(ent, dmg)
    if not self:GetStatus() then return end

    if self:GetKind() == 2 and self.Inside[ent] and dmg:IsBulletDamage() then
        dmg:ScaleDamage(.5 - (self.Level - 1) * .05)
    end

    if self:GetKind() == 1 and self.Inside[ent] and dmg:IsExplosionDamage() then
        dmg:ScaleDamage(1 - self.ExplosiveReduction)
    end
end

function ENT:Think()
    if SERVER then
        if not self:GetStatus() then return end
        self.Inside = {}

        for k, v in pairs(ents.FindInSphere(self:GetPos(), 128)) do
            if not v:IsPlayer() then continue end
            self.Inside[v] = true

            if self:GetKind() == 1 then
                local extra = self.healAmount
                v:SetHealth(math.Clamp(v:Health() + extra, 0, v:GetMaxHealth()))
            end
        end

        self:NextThink(CurTime() + 1)

        return true
    end
end

if SERVER then return end

matproxy.Add({
    name = "ShieldColor",
    init = function(self, mat, values)
        self.r = values.resultvar1
        self.g = values.resultvar2
        self.b = values.resultvar3
        self.vectorLerp = Vector(0, 0, 0)
    end,
    bind = function(self, mat, ent)
        if ent and ent.IsBubblumShield then
            local kind = ent:GetKind()
            local isOff = not ent:GetStatus()
            local target = isOff and Vector(0, 0, 0) or (kind == 1 and Vector(99, 196, 237) or kind == 2 and Vector(232, 138, 55) or Vector(226, 55, 232))
            self.vectorLerp = LerpVector(FrameTime(), self.vectorLerp, target / 255)
            mat:SetFloat(self.r, self.vectorLerp.x)
            mat:SetFloat(self.g, self.vectorLerp.y)
            mat:SetFloat(self.b, self.vectorLerp.z)
        end
    end
})