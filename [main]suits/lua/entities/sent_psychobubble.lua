AddCSLuaFile()
local global_smoke = {}
DEFINE_BASECLASS("base_anim")
ENT.PrintName = "Psycho Bubble"
ENT.Author = ""
ENT.Category = "Fun + Games"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Sons = {}
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
        timer.Simple(2, function()
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
    
    local dmg = DamageInfo()
    if IsValid(self:GetOwner()) then
        dmg:SetAttacker(self:GetOwner())
    end
    for k, v in pairs(ents.FindInSphere(self:GetPos(), 256)) do
        if (v:IsNPC() or v:IsPlayer()) then
            local diff = (self:GetPos() - v:GetPos()):GetNormalized() * -800
            local dist = self:GetPos():Distance(v:GetPos()) / 256
            dmg:SetDamage(500 * (1 - dist))
            dmg:SetDamageForce(Vector(diff.x, diff.y, 800))
            v:TakeDamageInfo(dmg)
            v:SetPos(v:GetPos() + Vector(0, 0, 4))
            v:SetVelocity(dmg:GetDamageForce() * (1 - dist))
        end
    end
    SafeRemoveEntity(self)
end

local combine = Material("effects/rollerglow")
local sphere = Material("asap/hexa_red")

function ENT:DrawTranslucent()
    render.SetBlend(.0)
    self:DrawModel()
    render.SetBlend(1)
    local life = CurTime() - self:GetCreationTime()
    local lerp = life < 1.5 and Lerp(life / 1.5, 16, 164) or 164 + math.random(-4, 4)
    render.SetMaterial(combine)
    render.DrawQuadEasy(self:GetPos() + Vector(0, 0, -4), Vector(0, 0, 1), lerp * .8, lerp * .8, color_white, RealTime() * 128)
    render.SetMaterial(sphere)
    render.DrawSphere(self:GetPos() + Vector(0, 0, 0), lerp / 3, 16, 16, color_white)
end