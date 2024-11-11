AddCSLuaFile()
local global_smoke = {}
DEFINE_BASECLASS("base_anim")
ENT.PrintName = "Gas trap"
ENT.Author = ""
ENT.Category = "Fun + Games"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Sons = {}
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "owning_ent")
    self:NetworkVar("Bool", 0, "Active")
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/tfa/doom/props/ammo/ammo_plasma_large.mdl")
        self:SetColor(Color(150, 255, 50))
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        local phys = self:GetPhysicsObject()

        if IsValid(phys) then
            phys:Wake()
        end

        self:EmitSound("buttons/button5.wav")
        self.totalHealth = 100
    end

    self.Sons = {}

    if CLIENT then
        self:SetRenderBounds(-Vector(1, 1, 0) * 160, Vector(1, 1, 1) * 160)
    end

end

function ENT:StartSmoke()
    self:SetMoveType(MOVETYPE_NONE)
    local eff = EffectData()
    eff:SetOrigin(self:GetPos())
    eff:SetEntity(self)
    util.Effect("eff_gastrap", eff, true, true)
    self:SetActive(true)
    self.LifeTime = CurTime() + 12
    SafeRemoveEntityDelayed(self, 12)
    self:Getowning_ent().causticExploded = CurTime()
end

function ENT:OnTakeDamage(dmg)
    if not self:GetActive() then
        self:StartSmoke()
    else
        self.totalHealth = self.totalHealth - dmg:GetDamage()

        if self.totalHealth <= 0 then
            SafeRemoveEntity(self)
        end
    end
end

function ENT:CanAffect(v)
    if not IsValid(self:GetOwner()) or not self:GetOwner():IsPlayer() then
        return true
    end
    return not (v == self:GetOwner() or (v:GetGang() ~= "" and v:GetGang() == self:GetOwner():GetGang()))
end

ENT.IsEmitter = true

function ENT:Think()
    if SERVER then
        if self:GetActive() then
            local scale = math.max((self.LifeTime - CurTime()) / 12, 0)

            for k, v in pairs(ents.FindInSphere(self:GetPos(), 160 * (1 - (scale ^ 2)))) do
                if v ~= self and v.IsEmitter then
                    SafeRemoveEntity(v)
                    continue
                end

                if v:IsPlayer() and v:Alive() then
                    if not self:CanAffect(v) then continue end
                    local dmg = DamageInfo()
                    dmg:SetDamage(math.Clamp(v:Health() * .1, 20, 100))
                    dmg:SetDamageType(DMG_POISON)
                    dmg:SetInflictor(self)
                    dmg:SetAttacker(IsValid(self:GetOwner()) and self:GetOwner() or self)
                    v:TakeDamageInfo(dmg)

                    if (v.nextSound or 0) < CurTime() then
                        v.nextSound = CurTime() + math.Rand(.4, .7)
                        v:EmitSound("ambient/voices/cough" .. math.random(1, 3) .. ".wav")
                    end
                end
            end

            self:NextThink(CurTime() + .5)

            return true
        else
            for k, v in pairs(ents.FindInSphere(self:GetPos(), 100)) do
                if v:IsPlayer() and v:Alive() and self:CanAffect(v) then
                    self:StartSmoke()
                end
            end

            self:NextThink(CurTime() + .5)

            return true
        end
    end
end

function ENT:OnRemove()
    if IsValid(self:GetOwner()) then
        self:GetOwner():SetNWInt("PlacedTraps", self:GetOwner():GetNWInt("PlacedTraps", 0) - 1)
    end
end

local nextPuff = 0
local alpha = 0
local smokeActive = false
local smokeEntity = nil
local puffs = {}

local function drawClouds(alpha)
    if nextPuff < RealTime() then
        nextPuff = RealTime() + math.Rand(.05, .25)
        local size = math.random(128, 2048)
        local dir = math.Rand(-4, 4)
        local rand = math.random(1, 16)
        local id = rand > 9 and rand or ("0" .. rand)

        local data = {
            x = dir > 0 and -size or ScrW() + size,
            dir = dir,
            y = math.random(0, ScrH()),
            size = size,
            rotation = math.random(0, 360),
            roll = math.Rand(-.5, .5),
            mat = Material("particle/smokesprites_00" .. id)
        }

        table.insert(puffs, data)
    end

    surface.SetDrawColor(150, 175, 100, alpha)

    for k, v in pairs(puffs) do
        surface.SetMaterial(v.mat)
        surface.DrawTexturedRectRotated(v.x, v.y, v.size, v.size, v.rotation)
        v.x = v.x + v.dir
        v.rotation = v.rotation + v.roll
        local del = false

        if v.dir < 0 and v.x < -v.size then
            del = true
        elseif v.dir > 0 and v.x > ScrW() then
            del = true
        end

        if del then
            table.remove(puffs, k)
            break
        end
    end
end

function ENT:DrawTranslucent()
    self:DrawModel()

    if self:GetActive() and self:CanAffect(LocalPlayer()) then
        local dist = LocalPlayer():GetPos():Distance(self:GetPos())

        if dist < 160 then
            alpha = 255 * math.Clamp(1 - (dist / 160) ^ 3, 0, 1)
            smokeActive = true
            smokeEntity = self
        end
    end
end

hook.Add("HUDPaint", "SmokeController", function()
    if smokeActive then
        if not IsValid(smokeEntity) then
            alpha = Lerp(FrameTime() * 4, alpha, -1)

            if alpha <= 0 then
                smokeActive = false
                puffs = {}

                return
            end
        end

        surface.SetDrawColor(150, 175, 100, alpha)
        surface.DrawRect(0, 0, ScrW(), ScrH())
        drawClouds(alpha)
    end
end)

hook.Add("CalcView", "Smoke.Coughing", function(ply, pos, ang)
    if smokeActive then
        local power = alpha / 255

        return {
            origin = pos,
            angles = ang + Angle(math.cos(RealTime() * 2) * 8 * power, math.sin(RealTime() * 2) * 8 * power, 0)
        }
    end
end)