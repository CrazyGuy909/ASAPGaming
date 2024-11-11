AddCSLuaFile()
local global_smoke = {}
DEFINE_BASECLASS("base_anim")
ENT.PrintName = "Karma Sphere"
ENT.Author = ""
ENT.Category = "Fun + Games"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Sons = {}
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "owning_ent")
    self:NetworkVar("Entity", 1, "BadTarget")
    self:NetworkVar("Entity", 2, "GoodTarget")
end

function ENT:SpawnFunction(ply, tr)
    if not tr.Hit then return end
    local SpawnPos = tr.HitPos + tr.HitNormal * 25
    local ent = ents.Create("sent_karma_sphere")
    ent:SetPos(SpawnPos)
    ent:Spawn()
    ent:Activate()
    ent:SetOwner(ply)

    if ShouldSetOwner then
        ent.Owner = ply
    end

    return ent
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_NONE)
        hook.Add("EntityTakeDamage", self, self.HandleDamage)
        hook.Add("PlayerDeath", self, self.HandleDeath)
    else
        self:SetRenderBounds(-Vector(512, 512, 0), Vector(512, 512, 512))
    end

    self:DrawShadow(false)
end

function ENT:HandleDeath(ply)
    if self:GetGoodTarget() == ply then
        ply.goodBall = nil
        ply.ballEnemy = nil
        self:SetGoodTarget(self:GetOwner())
    end

    if self:GetBadTarget() == ply then
        ply.badBall = nil
        ply.ballEnemy = nil
        self:SetBadTarget(self:GetOwner())
    end
end

function ENT:Explode()
    local owner = self:GetOwner()
    local bad = self:GetBadTarget()
    local good = self:GetGoodTarget()
    self:EmitSound("tfa_cso2/weapons/valentine_grenade/valentine_grenade_throw.wav")
    local eff = EffectData()
    local cos = math.cos(RealTime() * 2) * 32
    local sin = math.sin(RealTime() * 2) * 32
    eff:SetOrigin(self:GetGoodTarget():GetPos() + Vector(cos, sin, 32 + sin * .5))
    util.Effect("gamma_impact", eff, true, true)
    local eff2 = EffectData()
    cos = -math.cos(CurTime() * 2) * 32
    sin = -math.sin(CurTime() * 2) * 32
    eff:SetOrigin(self:GetBadTarget():GetPos() + Vector(cos, sin, 32 + sin * .5))
    util.Effect("exp_balrog", eff2, true, true)

    for k, v in pairs(ents.FindInSphere(bad:GetShootPos(), 128)) do
        if not v:IsPlayer() then continue end

        if v:IsGangEnemy(owner:GetGang()) then
            local dmg = DamageInfo()
            dmg:SetAttacker(self:GetOwner())
            dmg:SetInflictor(self)
            dmg:SetDamage(400)
            dmg:SetDamageType(DMG_BURN)
            v:TakeDamageInfo(dmg)
            v:Ignite(5)
        end
    end

    for k, v in pairs(ents.FindInSphere(good:GetShootPos(), 128)) do
        if not v:IsPlayer() then continue end

        if v:IsGangEnemy(owner:GetGang()) then
            v:CreateIce(5, owner, self)
        end
    end
end

function ENT:HandleDamage(ply, dmg)
    local att = dmg:GetAttacker()
    local owner = self:GetOwner()
    if not att:IsPlayer() then return end

    if self:GetBadTarget() == ply and ply:IsGangEnemy(att:GetGang()) then
        dmg:ScaleDamage(1.25)
    end

    if self:GetGoodTarget() == ply and not ply:IsGangEnemy(owner:GetGang()) then
        dmg:ScaleDamage(.75)
    end

    ply.ballCooldown = CurTime() + 5
end

ENT.NextTick = 0

function ENT:Think()
    if SERVER and not IsValid(self:GetOwner()) then
        self:Remove()

        return
    end

    if not IsValid(self:GetBadTarget()) then
        self:SetBadTarget(self:GetOwner())
    end

    if not IsValid(self:GetGoodTarget()) then
        self:SetGoodTarget(self:GetOwner())
    end

    self:SetPos(self:GetOwner():GetPos())

    if SERVER then
        if self.NextTick < CurTime() then
            self.NextTick = CurTime() + 1
            local owner = self:GetOwner()
            local bad = self:GetBadTarget()
            local good = self:GetGoodTarget()
            local benemy = bad:GetGang() == "" or bad:GetGang() ~= owner:GetGang()
            local genemy = good:GetGang() == "" or good:GetGang() ~= owner:GetGang()
            local canReceive = not benemy and (bad.ballCooldown or CurTime() - 1) < CurTime()

            if canReceive and good:Armor() < 500 then
                good:SetArmor(math.Clamp(good:Armor() + 40, 0, good:GetMaxArmor()))
            elseif genemy and good:Armor() > 100 then
                good:SetArmor(good:Armor() - math.min(good:Armor() * .1, 50))
            end

            if canReceive and not benemy and not benemy and bad:Health() < bad:GetMaxHealth() / 2 then
                bad:SetHealth(bad:Health() + bad:GetMaxHealth() * .02)
            end
        end

        self:NextThink(CurTime())

        return true
    end
end

if SERVER then return end
local glow = Material("effects/mph_glow2")
local energy = Material("effects/muzzleflashx_nemole_w")
local refract = Material("effects/energy_swave_warp2")

local function drawSphere(pos, a, b, c)
    render.SetMaterial(refract)
    render.DrawSprite(pos, 20, 20, a)
    render.SetMaterial(glow)
    render.DrawSprite(pos, 16 + math.random(-2, 2), 16 + math.random(-2, 2), a)
    render.SetMaterial(energy)
    render.DrawSprite(pos, 16, 16, b)
    render.DrawSprite(pos, 28, 28, c)
end

local hellOverlay = Material("skin/hellflame_overlay")
local iceOverlay = Material("skin/prism_overlay")

function ENT:DrawTranslucent()
    if not self:GetOwner():Alive() or not self:GetOwner().armorSuit then return end
    local cos = math.cos(CurTime() * 2) * 32
    local sin = math.sin(CurTime() * 2) * 32
    local pos = self:GetGoodTarget():GetPos() + Vector(cos, sin, 32 + sin * .5)
    local cosb = -math.cos(CurTime() * 2) * 32
    local sinb = -math.sin(CurTime() * 2) * 32
    local posb = self:GetBadTarget():GetPos() + Vector(cosb, sinb, 32 + cosb * .5)
    self.a_pos = LerpVector(FrameTime() * 8, self.a_pos or self:GetPos(), pos)
    self.b_pos = LerpVector(FrameTime() * 8, self.b_pos or self:GetPos(), posb)

    if self:GetGoodTarget() ~= LocalPlayer() then
        render.MaterialOverride(iceOverlay)
        render.SuppressEngineLighting(true)
        self:GetGoodTarget():DrawModel()
        render.SuppressEngineLighting(false)
        render.MaterialOverride(nil)
    end

    if self:GetBadTarget() ~= LocalPlayer() then
        render.MaterialOverride(hellOverlay)
        render.SuppressEngineLighting(true)
        self:GetBadTarget():DrawModel()
        render.SuppressEngineLighting(false)
        render.MaterialOverride(nil)
    end

    drawSphere(self.b_pos, Color(255, 177, 75, 255), Color(252, 255, 75, 100), Color(206, 40, 40))
    drawSphere(self.a_pos, Color(75, 243, 255, 255), Color(75, 243, 255, 100), Color(40, 112, 206))
end