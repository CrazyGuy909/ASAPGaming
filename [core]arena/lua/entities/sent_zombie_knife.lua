AddCSLuaFile()
ENT.Type = "anim"
ENT.Category = "Galaxium Arena"
ENT.PrintName = "Zombie Knife"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AutomaticFrameAdvance = true
ENT.Base = "base_anim"

function ENT:SpawnFunction(ply, tr, class)
    local ent = ents.Create(class)
    ent:SetPos(tr.HitPos + tr.HitNormal * 16)
    ent:Spawn()
    ent:Activate()

    return ent
end

-- Configs --
function ENT:Initialize()
    self:SetModel("models/weapons/w_csgo_karambit.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    if SERVER then
        self:SetGravity(.1)
        self:SetFriction(1)
        self:SetElasticity(.45)
        self.Info = ents.Create("info_target")
        self.Info:SetParent(self)
        self.Info:SetLocalPos(Vector(0, 0, -4))
        self.Info.Trail = util.SpriteTrail( self.Info, 0, Color( 255, 0, 0 ), false, 15, 1, 4, 1 / ( 15 + 1 ) * 0.5, "trails/plasma" )
    end
end

function ENT:OnRemove()
    if IsValid(self.Info) then
        self.Info:SetParent(nil)
        timer.Simple(4, function()
            if IsValid(self.Info) then
                self.Info:Remove()
            end
        end)
    end
end

ENT.Defused = false
function ENT:PhysicsCollide(col, phys)
    if (self.Defused) then return end
    self.Defused = true
    if (col.HitEntity:IsWorld()) then
        timer.Simple(.1, function()
            self:SetMoveType(MOVETYPE_NONE)
            self:SetPos(col.HitPos - col.HitNormal * 2)
        end)
    elseif (col.HitEntity:IsPlayer() or col.HitEntity:IsNPC()) then
        local dmg = DamageInfo()
        dmg:SetDamage(9999)
        dmg:SetAttacker(self:GetOwner())
        dmg:SetInflictor(self)
        col.HitEntity:TakeDamageInfo(dmg)
        self:SetNoDraw(true)
        self:EmitSound("weapons/knife/knife_stab.wav")
        timer.Simple(.1, function()
            self:Remove()
        end)
    end
    timer.Simple(3, function()
        if (IsValid(self)) then
            self:Remove()
        end
    end)
end


function ENT:Draw()
    self:DrawModel()
    self:SetColor(Color(255, 150, 75))
end