if (SERVER) then
    AddCSLuaFile("shared.lua")
    SWEP.Weight = 5
    SWEP.AutoSwitchTo = true
    SWEP.AutoSwitchFrom = true
end

SWEP.Category = "RP Weapons"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_binoculars_usa.mdl"
SWEP.WorldModel = "models/weapons/w_binoculars_usa.mdl"
SWEP.HoldType = "slam"
SWEP.HoldTypeRaised = "camera"
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic = false
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = false
SWEP.Secondary.Automatic = true
SWEP.Zoom_Interval = 2
SWEP.Zoom_Current = 0
SWEP.Zoom_Min = 2
SWEP.Zoom_Max = 8
SWEP.Zoom_Delta = 0.2
SWEP.Zoom_Zooming = false
SWEP.Zoom_InZoom = false
SWEP.Zoom_TransitionTime = nil
SWEP.Zoom_Sound_In = "weapons/sniper/sniper_zoomin.wav"
SWEP.Zoom_Sound_Out = "weapons/sniper/sniper_zoomout.wav"
SWEP.Zoom_Sound_Cloth = "foley/alyx_hug_eli.wav"
SWEP.HasNightVision = false
SWEP.WalkSpeed = 250
SWEP.RunSpeed = 500
SWEP.WalkSpeedMod = 250
SWEP.SpeedMult = 0.6
SWEP.UUID = nil

function SWEP:PrimaryAttack()
    if (self:Clip1() <= 0) then return end
    if (self.Zoom_Interval == 0 or self.Zoom_Min == self.Zoom_Max) then return end
    if CLIENT then return end
    local tr = util.QuickTrace(self.Owner:GetEyeTrace().HitPos + Vector(0, 0, 50), Vector(0, 0, 99999))
    --PrintTable(tr)
    if (not tr.HitNoDraw) then return end
    local ply = {}

    for k, v in pairs(asapArena.Players) do
        table.insert(ply, k)
    end

    net.Start("ASAP.Arena.Nuclear")
    net.WriteVector(self.Owner:GetEyeTrace().HitPos)
    net.Send(ply)

    local owner = self.Owner
    self.Zoom_InZoom = false
    self.Zoom_Current = self.Zoom_Min
    self.Owner:SetDSP(0, false)
    self.Owner:DrawViewModel(true, 0)
    self.Owner:SetRunSpeed(self.RunSpeed)
    self.Owner:SetWalkSpeed(self.WalkSpeed)
    self:StopIdle()
    self.Owner:SetFOV(0, 0)
    self.Owner:ConCommand("lastinv")
    self:TakePrimaryAmmo(1)
    
    timer.Simple(3, function()
        local ent = ents.Create("sent_arena_explosive")
        ent:SetPos(tr.HitPos + tr.HitNormal * 32)
        ent:Spawn()
        ent.Owner = owner
    end)
end

function SWEP:HandleZoom(add)
    self.Zoom_Current = math.Clamp(self.Zoom_Current - (add and .5 or -.5), 2, 10)
    sound.Play(self.Zoom_Sound_Out, self.Owner:GetPos())
end

function SWEP:SecondaryAttack()
end

function SWEP:CalcView(ply, pos, ang, fov)
    if (self.Zoom_InZoom) then return pos, ang, 90 / self.Zoom_Current end
end

function SWEP:Deploy()
    self:SendWeaponAnim(ACT_VM_DRAW)
    self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())
    self.WalkSpeed = self.Owner:GetWalkSpeed()
    self.RunSpeed = self.Owner:GetRunSpeed()
    self.WalkSpeedMod = self.WalkSpeed * self.SpeedMult
    self.Zoom_Current = self.Zoom_Min
    self.Zoom_InZoom = false
    self.Zoom_Zooming = false
    self:SetHoldType(self.HoldType)
    self:Idle()
    self:CallOnClient("Deploy", "")

    if CLIENT then
        hook.Add("PlayerBindPress", self, function(pl, bind)
            if (bind == "invnext" or bind == "invprev") then
                self:HandleZoom(bind == "invnext")

                return true
            end
        end)
    end
end

function SWEP:Initialize()
    self.UUID = tostring(self:EntIndex())
    self.Zoom_Current = self.Zoom_Interval
    self:SetHoldType(self.HoldType)
end

function SWEP:Holster()
    if self.Zoom_Zooming then return false end

    if (self.Zoom_InZoom) then
        self.Owner:SetFOV(0, self.Zoom_Delta)
    end

    self.Zoom_InZoom = false
    self.Zoom_Current = self.Zoom_Min
    self.Owner:SetDSP(0, false)
    self.Owner:DrawViewModel(true, 0)
    self.Owner:SetRunSpeed(self.RunSpeed)
    self.Owner:SetWalkSpeed(self.WalkSpeed)
    self:StopIdle()

    if CLIENT then
        hook.Remove("PlayerBindPress", self)
    end

    return true
end

function SWEP:Think()
    if self.Owner:KeyPressed(IN_ATTACK2) and not self.Zoom_Zooming then
        self:SetZoom()
    end

    if self.Owner:KeyReleased(IN_ATTACK2) and not self.Zoom_Zooming then
        self:EndZoom()
    end

    if (self.Owner:KeyReleased(IN_ATTACK) or (not self.Owner:KeyDown(IN_ATTACK) and self.Sound)) then
        self:Idle()
    end

    if (self.Owner:KeyPressed(IN_USE) and self.Zoom_InZoom) then
        timer.Simple(0.01, function()
            if not (self:IsValid()) then return end
            self.Owner:DrawViewModel(false, 0)
        end)
    end
end

function SWEP:SetZoom()
    self.Zoom_Zooming = true
    self:StopIdle()
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
    self:EmitSound(self.Zoom_Sound_Cloth, 50, 110)
    self.Owner:SetRunSpeed(self.WalkSpeedMod)
    self.Owner:SetWalkSpeed(self.WalkSpeedMod)
    self:SetHoldType(self.HoldTypeRaised)

    timer.Simple(self:SequenceDuration() * 4 / 5, function()
        if not self:IsValid() then return end
        self.Zoom_InZoom = true
        self.Zoom_Current = self.Zoom_Interval
        self.Owner:DrawViewModel(false, 0)
        self.Owner:SetFOV(90 / self.Zoom_Current, self.Zoom_Delta)
        self.Owner:SetDSP(30, false)
    end)

    timer.Simple(self:SequenceDuration(), function()
        if not self:IsValid() then return end
        self.Zoom_Zooming = false

        if not self.Owner:KeyDown(IN_ATTACK2) then
            self:EndZoom()
        end
    end)
end

function SWEP:EndZoom()
    self.Zoom_Zooming = true
    self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
    self:EmitSound(self.Zoom_Sound_Cloth, 50, 90)
    self.Owner:SetRunSpeed(self.RunSpeed)
    self.Owner:SetWalkSpeed(self.WalkSpeed)
    self:SetHoldType(self.HoldType)

    timer.Simple(self:SequenceDuration() * 1 / 5, function()
        if not self:IsValid() then return end
        self.Zoom_InZoom = false
        self.Zoom_Current = self.Zoom_Interval
        self.Owner:DrawViewModel(true, 0)
        self.Owner:SetFOV(0, self.Zoom_Delta)
        self.Owner:SetDSP(0, false)
    end)

    timer.Simple(self:SequenceDuration(), function()
        if not self:IsValid() then return end
        self.Zoom_Zooming = false
        self:Idle()

        if self.Owner:KeyDown(IN_ATTACK2) then
            self:SetZoom()
        end
    end)
end

function SWEP:DoIdleAnimation()
    self:SendWeaponAnim(ACT_VM_IDLE)
end

function SWEP:DoIdle()
    self:DoIdleAnimation()

    timer.Adjust("weapon_idle" .. self:EntIndex(), self:SequenceDuration(), 0, function()
        if (not IsValid(self)) then
            timer.Remove("weapon_idle" .. self:EntIndex())

            return
        end

        self:DoIdleAnimation()
    end)
end

function SWEP:StopIdle()
    timer.Destroy("weapon_idle" .. self:EntIndex())
end

function SWEP:Idle()
    if (CLIENT or not IsValid(self.Owner)) then return end

    timer.Create("weapon_idle" .. self:EntIndex(), self:SequenceDuration() - 0.2, 1, function()
        if (not IsValid(self)) then return end
        self:DoIdle()
    end)
end