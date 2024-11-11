AddCSLuaFile()
ENT.Type = "anim"
ENT.Category = "Galaxium Arena"
ENT.PrintName = "Zombie Barrier"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AutomaticFrameAdvance = true
ENT.Base = "base_anim"

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "Maker")
    self:NetworkVar("Int", 0, "Type")
end

function ENT:SpawnFunction(ply, tr, class)
    local ent = ents.Create(class)
    ent:SetPos(tr.HitPos + tr.HitNormal * 16)
    ent:Spawn()
    ent:Activate()

    return ent
end

-- Configs --
function ENT:Init(data)
    self:SetModel(data.MDL)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetHealth(data.Health or 10)
    self:SetMaxHealth(data.Health or 10)
end

function ENT:Kill()
    self.IsDead = true
    self:SetSolid(SOLID_NONE)
    self:SetNoDraw(true)
    local eff = EffectData()
    eff:SetEntity(self)
    util.Effect("arena_barrier_dead", eff, true, true)
    SafeRemoveEntityDelayed(self, .5)
end

function ENT:OnRemove()
    if IsValid(self.Shadow) then
        self.Shadow:Remove()
    end
end

function ENT:OnTakeDamage(dmg)
    if (self.IsDead) then return end
    self:SetHealth(self:Health() - dmg:GetDamage())
    if (self:Health() <= 0) then
        self.IsDead = true
        self:SetSolid(SOLID_NONE)
        self:SetNoDraw(true)
        local eff = EffectData()
        eff:SetEntity(self)
        util.Effect("arena_barrier_dead", eff, true, true)
        SafeRemoveEntityDelayed(self, .5)
    end
end

if SERVER then return end

ENT.Alpha = 0
ENT.HasLoaded = false
ENT.BirthStamp = CurTime()
function ENT:Draw()
    if (self:Health() <= 0) then 
        self.Shadow:Remove()
        return
    end
    if (not self.HasLoaded) then
        if (IsValid(self.Shadow)) then
            self.Shadow:Remove()
        end
        local min, max = self:GetCollisionBounds()
        self.Shadow = ClientsideModel(self:GetModel())
        self.Shadow:SetPos(self:GetPos() + self:GetUp() * (max.z - min.z) / 2)
        self.Shadow:SetAngles(AngleRand() * 9999)
        self.Shadow.Angle = self:GetAngles() + AngleRand() * 90
        self.Shadow.Matrix = Matrix()
        self.Shadow:SetNoDraw(true)
        self.Shadow.Matrix:Scale(Vector(.1, .1, .1))
        self.Shadow:EnableMatrix("RenderMultiple", self.Shadow.Matrix)
        self.BirthStamp = CurTime()
        self.HasLoaded = true
    elseif (IsValid(self.Shadow)) then
        local progress = (CurTime() - self.BirthStamp)
        local angle = LerpAngle(progress, self.Shadow:GetAngles(), self:GetAngles())
        local pos = Lerp(progress, self.Shadow:GetPos(), self:GetPos())
        self.Shadow.Matrix:SetScale(Vector(1, 1, 1) * math.min(1, 0.7 + progress))
        self.Shadow:EnableMatrix("RenderMultiply", self.Shadow.Matrix)
        self.Shadow:SetPos(pos)
        self.Shadow:SetAngles(angle)
        if (progress > 1) then
            self.Shadow:Remove()
            return
        end

        self.Shadow:DrawModel()
    else
        self:DrawModel()
    end
    --
    local isAim = LocalPlayer():GetEyeTrace().Entity == self
    if not isAim and self.Alpha <= 0 then return end

    self.Alpha = Lerp(FrameTime() * 4, self.Alpha, isAim and 255 or -5)
    local _, max = self:GetRenderBounds()
    local ang = EyeAngles()
    ang:RotateAroundAxis(ang:Right(), 90)
    ang:RotateAroundAxis(ang:Up(), -90)
    cam.Start3D2D(self:GetPos() + Vector(0, 0, max.z / 2), ang, (self.Alpha / 255) * .2)
        cam.IgnoreZ(true)
        draw.RoundedBox(8, -128, -16, 256, 32, Color(46, 46, 46))
        draw.RoundedBox(8, -126, -14, 252, 28, Color(0, 0, 0))
        local fill = math.Clamp(self:Health() / self:GetMaxHealth(), 0, 1)
        draw.RoundedBox(8, -126, -14, 252 * fill, 28, Color(255, 75, 75))
        draw.SimpleText(self:Health() .. "/" .. self:GetMaxHealth(), "Arena.Small", 0, 0, color_white, 1, 1)
        cam.IgnoreZ(false)
    cam.End3D2D()
end