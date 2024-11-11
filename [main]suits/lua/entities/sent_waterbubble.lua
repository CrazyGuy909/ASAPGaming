AddCSLuaFile()
local global_smoke = {}
DEFINE_BASECLASS("base_anim")
ENT.PrintName = "Water jutsu"
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
    self:SetStatus(false)
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
    self:SetModelScale(4, 0)
end

if CLIENT then
    CreateMaterial("predator_asap", "Refract", {
        ["$model"] = "1",
        ["$refractamount"] = ".1",
        ["$refracttint"] = "[.8 .9 1]",
        ["$dudvmap"] = "dev/water_dudv",
        ["$normalmap"] = "dev/water_normal",
        ["Proxies"] = {
            ["AnimatedTexture"] = {
                ["animatedtexturevar"] = "$normalmap",
                ["animatedtextureframenumvar"] = "$bumpframe",
                ["animatedtextureframerate"] = "60",
            }
        }
    })
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/XQM/Rails/gumball_1.mdl")
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_NONE)
    end

    self:SetMaterial("!predator_asap")
    self:DrawShadow(false)
    self.Inside = {}
end


ENT.Inside = {}

function ENT:Think()
    if SERVER then
        if not IsValid(self:GetOwner()) then self:Remove() return end
    end
    
    self:SetPos(self:GetOwner():GetPos() + Vector(0, 0, 32))

    if SERVER then
        self.General = table.Copy(self.Inside)
        self.Inside = {}
        for k, v in pairs(ents.FindInSphere(self:GetPos(), self:GetStatus() and 256 or 128)) do
            if not v:IsPlayer() then continue end
            if (self:GetOwner() == v) then continue end
            self.Inside[v] = true
            if (!v.savedInfo) then
                v.savedInfo = {
                    v:GetWalkSpeed(),
                    v:GetRunSpeed(),
                    v:GetJumpPower()
                }
                v:SetWalkSpeed(50)
                v:SetRunSpeed(50)
                v:SetGravity(.15)
                v:SetJumpPower(50)
            end
            local dmg = DamageInfo()
            local dealt = math.Clamp(v:Health() * .1, 0, 50)
            v.waterDealt = (v.waterDealt or 0) + dealt
            dmg:SetDamage(dealt)
            dmg:SetDamageType(DMG_DROWN)
            dmg:SetAttacker(self:GetOwner())
            dmg:SetInflictor(self)
            v:TakeDamageInfo(dmg)

            local tag = v:SteamID64() .. "_drownRecover"
            
            timer.Create(tag, 2, 0, function()
                if not IsValid(v) or not v:Alive() then timer.Remove(tag) return end

                if (v.waterDealt > 0) then
                    v.waterDealt = v.waterDealt - math.Round(v.waterDealt / 5)
                    v:SetHealth(v:Health() + math.Round(v.waterDealt / 5))
                    if (v.waterDealt <= 0) then timer.Remove(tag) end
                end
            end)
        end

        for k, v in pairs(self.Inside) do
            if (not self.General[k]) then
                k:SetGravity(1)
                if not k.savedInfo then continue end
                k:SetWalkSpeed(k.savedInfo[1])
                k:SetRunSpeed(k.savedInfo[2])
                k:SetJumpPower(k.savedInfo[3])
                k.savedInfo = nil
            end
        end

        self:NextThink(CurTime() + 1)
        return true
    end
end

function ENT:OnRemove()
    if SERVER then
        for k, v in pairs(self.General) do
            k:SetGravity(1)
            if not k.savedInfo then continue end
            k:SetWalkSpeed(k.savedInfo[1])
            k:SetRunSpeed(k.savedInfo[2])
            k:SetJumpPower(k.savedInfo[3])
            k.savedInfo = nil
        end
    end
end

ENT.Clouds = nil

function ENT:DrawTranslucent()
    if (self:GetStatus() and LocalPlayer() == self:GetOwner()) then
        render.CullMode(MATERIAL_CULLMODE_CW)
        --self:DrawModel()
        render.CullMode(MATERIAL_CULLMODE_CCW)
        return
    end
    self:DrawModel()
end
