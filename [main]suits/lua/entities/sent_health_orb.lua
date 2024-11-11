AddCSLuaFile()
ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Health Orb"
ENT.Category = "ASAPGaming"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "GrabTime")
    self:NetworkVar("Vector", 1, "GrabZone")
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/hunter/misc/sphere025x025.mdl")
        self:PhysicsInit(SOLID_NONE)
        self:SetModelScale(math.Rand(.5, 1.5))
        self.Trail = util.SpriteTrail(self, 0, Color(255, 255, 255), false, 10, 0, .75, 1 / (10 + 1) * .5, "tracers/tracer_cyclone.vmt")
        SafeRemoveEntityDelayed(self, 15)
    end

    self.OriginPlace = self:GetPos()
    self.StartTime = CurTime()
end

ENT.Consumed = false

local function easedLerp(fraction, from, to)
    return Lerp(math.EaseInOut(fraction), from, to)
end

ENT.NextCheck = 0

function ENT:Think()
    local owner = self:GetOwner()

    if not IsValid(owner) then
        if SERVER and self.Consumed then
            SafeRemoveEntity(self)
        end

        local progress = math.Clamp(CurTime() - self.StartTime, 0, 1)
        local pos = self.OriginPlace + Vector(math.cos(CurTime() * 4) * 16, math.sin(CurTime() * 4) * 16, easedLerp(progress, 0, 32) + math.cos(CurTime() * 2) * 16)
        self:SetPos(pos)

        if progress >= 1 and self.NextCheck < CurTime() then
            if self.Consumed == true then return end
            self.NextCheck = CurTime() + .5
            local scale = 128

            for k, v in pairs(ents.FindInBox(pos - Vector(1, 1, 1) * scale, pos + Vector(1, 1, 1) * scale)) do
                if v:IsPlayer() and v:Alive() and v:Health() < v:GetMaxHealth() then
                    self.Consumed = true
                    self:SetGrabTime(CurTime() + .5)
                    self:SetGrabZone(self:GetPos())

                    self:Wait(.05, function()
                        self:SetOwner(v)
                    end)
                end
            end
        end

        return
    end

    local progress = 1 - math.Clamp((self:GetGrabTime() - CurTime()) * 2, 0, 1)
    local target = owner:GetPos() + owner:OBBCenter() * progress
    self:SetPos(LerpVector(progress, self:GetGrabZone(), target))

    if SERVER and progress == 1 then
        self.Trail:SetParent(nil)
        owner:SetHealth(math.Clamp(owner:Health() + 50 * self:GetModelScale(), 0, owner:GetMaxHealth()))
        owner:ScreenFade(SCREENFADE.IN, Color(100, 255, 0, 100), .25, 0)
        self:EmitSound("player/portal_enter_01.wav")
        if (self.Money) then
            owner:addMoney(self.Money)
        end
        SafeRemoveEntity(self)
        SafeRemoveEntityDelayed(self.Trail, 1)
    end
end

hook.Add("PlayerDeath", "HealthOrb", function(ply)
    if (not ply.armorSuit) then return end
    local orb = ents.Create("sent_health_orb")
    orb:SetPos(ply:GetPos())
    orb.Money = ply:getDarkRPVar("money") * 0.001
    orb:Spawn()
end)

if SERVER then return end
local glow = Material("sprites/boom_light_glow02")
local green = Color(68, 255, 0)

function ENT:DrawTranslucent()
    local noise = math.cos(RealTime() * 16 + self:EntIndex()) * .5 + .5
    render.SetMaterial(glow)
    render.DrawSprite(self:GetPos(), 42 + noise * 8, 42 + noise * 8, green)
    render.DrawSprite(self:GetPos(), 24 + noise * 8, 24 + noise * 8, color_white)
end