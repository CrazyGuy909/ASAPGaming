AddCSLuaFile()
DEFINE_BASECLASS("base_anim")
ENT.PrintName = "Armor Shield"
ENT.Author = ""
ENT.Category = "ASAP"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Sons = {}
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true
ENT.MaxHealth = 10
ENT.ShieldDamage = true

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "owning_ent")
end

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
        self:SetModel("models/props_mvm/mvm_player_shield2.mdl")
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:DrawShadow(false)
        self:SetSkin(0)

        timer.Simple(0, function()
            local phys = self:GetPhysicsObject()

            if (phys:IsValid()) then
                phys:Wake()
            end
        end)
        SafeRemoveEntityDelayed(self, 10)
    end

    self:SetHealth(self.MaxHealth)
    self:SetMaterial("models/effects/resist_shield/resist_shield_gonzo")
    self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)

    if CLIENT then
        self:SetRenderBounds(-Vector(1, 1, 0) * 160, Vector(1, 1, 1) * 160)
    end
end

function ENT:OnRemove()
    if IsValid(self:GetOwner()) and SERVER then
        local armor = Armor:Get(self:GetOwner().armorSuit)
        self:GetOwner().lastArmorAbilityUsed = CurTime() + ((armor or {}).Cooldown or 10)
    elseif (CLIENT and self:GetOwner() == LocalPlayer()) then
        local armor = Armor:Get(self:GetOwner().armorSuit)
        self:GetOwner().lastArmorAbilityUsed = CurTime() + ((armor or {}).Cooldown or 10)
    end
end


function ENT:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then
        self:Remove()
        return
    end
    local forward = Vector(owner:GetAimVector().x, owner:GetAimVector().y, 0)
    self:SetPos(owner:GetPos() + forward * 128 + Vector(0, 0, 16))
    self:SetAngles(Angle(0, owner:EyeAngles().y, 0))

    if SERVER then
        if ((self._nextThink or 0) < CurTime()) then
            self._nextThink = CurTime() + 1
            self:SetHealth(self:Health() - 1)

            if (self:Health() <= 0) then
                self:Remove()
            end
        end
        self:NextThink(CurTime())

        return true
    end
end

function ENT:DrawTranslucent()
    self:DrawModel()
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