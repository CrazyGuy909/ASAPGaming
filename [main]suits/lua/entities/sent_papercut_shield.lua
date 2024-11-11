AddCSLuaFile()
local global_smoke = {}
DEFINE_BASECLASS("base_anim")
ENT.PrintName = "Papercut Bubble"
ENT.Author = ""
ENT.Category = "Fun + Games"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Sons = {}
ENT.LifeTime = 5
ENT.MaxSize = 400
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "owning_ent")
    self:NetworkVar("Float", 1, "CreationTime")
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_NONE)

        timer.Simple(self.LifeTime, function()
            if IsValid(self) then
                self:Explode()
            end
        end)
    end

    self:EmitSound("beams/beamstart5.wav")
    self:DrawShadow(false)
    self:SetCreationTime(CurTime())
end

function ENT:Explode()
    local ball = ents.Create("prop_combine_ball")
    ball:SetPos(self:GetPos() + Vector(0, 0, 30))
    ball:Spawn()
    ball:Fire("Explode", 0, 0)
    SafeRemoveEntity(self)
end

function ENT:Think()
    if SERVER then
        local dmg = DamageInfo()
        dmg:SetDamage(5)
        dmg:SetDamageType(DMG_CLUB)
        dmg:SetAttacker(self)
        local size = (CurTime() - self:GetCreationTime()) / 5

        local owner = self:GetOwner()
        for k, v in pairs(ents.FindInSphere(self:GetPos(), self.MaxSize * size)) do
            if not v:IsPlayer() or not v:Alive() then continue end
            if v == self:GetOwner() then continue end
            if owner:IsPlayer() and owner:GetGang() ~= "" and owner:GetGang() == v:GetGang() then
                continue
            end

            v:TakeDamageInfo(dmg)

            if math.random(1, 3) == 1 then
                v:EmitSound("npc/manhack/mh_blade_snick1.wav", 75, math.random(85, 115), 1)
            end
        end

        self:NextThink(CurTime() + 1)
    end
end

function ENT:OnRemove()
    if CLIENT then
        for k, v in pairs(self.Clouds or {}) do
            v:Remove()
        end
    end
end

local combine = Material("particle/smokestack")
local sphere = Material("asap/sphere_texture")
local ballModel = "models/hunter/misc/sphere375x375.mdl"
ENT.Clouds = nil

function ENT:DrawTranslucent()
    render.SetBlend(0)
    self:DrawModel()
    render.SetBlend(1)
    local life = CurTime() - self:GetCreationTime()
    local lerp = life < self.LifeTime / 2 and Lerp(life / (self.LifeTime / 2), 16, self.MaxSize) or self.MaxSize + math.random(-4, 4)

    if not self.Clouds then
        self.Clouds = {}
        self.Matrixes = {}

        for k = 1, 4 do
            self.Clouds[k] = ClientsideModel(ballModel)
            self.Clouds[k]:SetMaterial("asap/particles/smokesprites_000" .. math.random(1, 9))
            self.Clouds[k]:SetColor(Color(75, 75, 75, 50))
            self.Clouds[k]:SetParent(self)
            self.Clouds[k]:SetNoDraw(true)
            self.Clouds[k]:SetLocalPos(Vector(0, 0, 0))
            self.Clouds[k]:SetAngles(AngleRand())
            self.Clouds[k].Random = math.Rand(.5, 5.5)
            self.Matrixes[k] = Matrix()
            self.Matrixes[k]:Scale(Vector(.1, .1, .1))
            self.Clouds[k]:EnableMatrix("RenderMultiply", self.Matrixes[k])
        end
    end

    render.SetMaterial(combine)
    render.DrawQuadEasy(self:GetPos() + Vector(0, 0, -4), Vector(0, 0, 1), lerp * .8, lerp * .8, color_white, RealTime() * 128)
    render.SetMaterial(sphere)
    render.DrawSphere(self:GetPos() + Vector(0, 0, 0), lerp / 3, 16, 16, color_white)

    for k, v in pairs(self.Clouds or {}) do
        self.Matrixes[k]:SetScale(Vector(1, 1, 1) * .5 * (lerp / 255 + math.Rand(.8, 1.1)))
        v:EnableMatrix("RenderMultiply", self.Matrixes[k])
        render.SetColorModulation(.25, .25, .25)
        render.SetBlend(life / self.LifeTime)
        v:DrawModel()
        render.SetBlend(1)
        render.SetColorModulation(1, 1, 1)
        v:SetAngles(v:GetAngles() + Angle(1, 1, 0) * v.Random)
    end
end