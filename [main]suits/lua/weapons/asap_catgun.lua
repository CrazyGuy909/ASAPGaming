AddCSLuaFile()
SWEP.Author = ""
SWEP.Instructions = ""
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModel = "models/weapons/v_catgun.mdl"
SWEP.UseHands = true
SWEP.WorldModel = "models/weapons/w_catgun.mdl"
SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 90
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Delay = 1
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.PrintName = "Cat gun"
SWEP.Category = "BP8"
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false

if SERVER then
    util.AddNetworkString("Catgun.Charm")
end

local catSound = {Sound("weapons/catgun_fire01.wav"), Sound("weapons/catgun_fire02.wav"), Sound("weapons/catgun_fire03.wav"), Sound("weapons/catgun_fire04.wav"), Sound("weapons/catgun_fire05.wav"), Sound("weapons/catgun_fire06.wav"), Sound("weapons/catgun_fire07.wav"), Sound("weapons/catgun_fire08.wav"),}

local reloadSounds = {Sound("weapons/catgun_reload.wav"), Sound("weapons/catgun_reload00.wav"), Sound("weapons/catgun_reload_shorter.wav"),}

function SWEP:PrimaryAttack()
    if (not self:CanPrimaryAttack() or self.IsReloading) then return end
    self:SetNextPrimaryFire(CurTime() + .25)
    local a, _ = table.Random(catSound)
    self:EmitSound(a)
    self:ShootEffects(self)
    if (not SERVER) then return end
    self:TakePrimaryAmmo(1)
    local tr = util.QuickTrace(self:GetOwner():GetShootPos(), self:GetOwner():GetAimVector() * 400, self:GetOwner())
    local eff = EffectData()
    eff:SetOrigin(self:GetOwner():GetShootPos())
    eff:SetStart(tr.HitPos)
    eff:SetNormal(tr.HitNormal)
    eff:SetFlags(0)
    util.Effect("paw_effect", eff, true, true)

    if (IsValid(tr.Entity) and (tr.Entity:IsPlayer() or tr.Entity:IsNPC())) then
        local dmg = DamageInfo()
        dmg:SetAttacker(self:GetOwner())
        dmg:SetInflictor(self)
        dmg:SetDamageType(DMG_DISSOLVE)
        dmg:SetDamage(40)
        tr.Entity:TakeDamageInfo(dmg)
    end
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 5)
    self:EmitSound("weapons/catgun_reload00_shorter.wav")
    self:ShootEffects(self)
    if (not SERVER) then return end

    local tr = util.TraceHull({
        start = self:GetOwner():GetShootPos(),
        endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 400,
        filter = self:GetOwner(),
        mins = Vector(1, 1, 1) * -32,
        maxs = Vector(1, 1, 1) * 32,
        ignoreworld = true
    })

    local eff = EffectData()
    eff:SetOrigin(self:GetOwner():GetShootPos())
    eff:SetStart(tr.HitPos)
    eff:SetNormal(tr.HitNormal)
    eff:SetFlags(1)
    util.Effect("paw_effect", eff, true, true)

    if (IsValid(tr.Entity) and tr.Entity:IsPlayer()) then
        self:Attract(tr.Entity)
    end
end

function SWEP:Attract(ent)
    if SERVER then
        net.Start("Catgun.Charm")
        net.WriteEntity(self)
        net.Send(ent)

		local eff = EffectData()
		eff:SetEntity(ent)
		util.Effect("paw_heart", eff, true, true)
    end

    local stamp = ent:EntIndex() .. "_catGun"
    local owner = self:GetOwner()

    timer.Simple(3, function()
        hook.Remove("StartCommand", stamp)
    end)

    hook.Add("StartCommand", stamp, function(ply, cmd)
        if ply ~= ent then return end

        if not IsValid(ent) or not IsValid(owner) then
            hook.Remove("StartCommand", stamp)

            return
        end

        local diff = (owner:GetPos() - ent:GetPos()):GetNormalized()
        cmd:ClearMovement()
		cmd:ClearButtons()

		cmd:SetViewAngles((owner:EyePos() - ent:EyePos()):Angle())
		cmd:SetForwardMove(50)
    end)
end

function SWEP:Deploy()
    self:SendWeaponAnim(ACT_VM_DRAW)
    self:EmitSound("weapons/catgun_deploy.wav")
end

SWEP.NextReload = 0
SWEP.PushVM = 0
SWEP.IsReloading = false

function SWEP:Reload()
    if (self.IsReloading) then return end
    if (self.NextReload > CurTime()) then return end
    if (self:Clip1() == self.Primary.ClipSize) then return end
    local ammoCount = self:GetOwner():GetAmmoCount("SMG1")
    self.NextReload = CurTime() + 2.5
    self.IsReloading = true
    self:SendWeaponAnim(ACT_VM_RELOAD)
    self:GetOwner():SetAnimation(PLAYER_RELOAD)

    self:SendWeaponAnim(ACT_VM_RELOAD)
    local a, _ = table.Random(reloadSounds)
    self:EmitSound(a)

    if CLIENT then
        self.PushVM = 6
    end

    timer.Create(self:EntIndex() .. "_reload", 2.5, 1, function()
        if (not IsValid(self)) then return end
        self.IsReloading = false
        self:GetOwner():RemoveAmmo(ammoCount < self.Primary.ClipSize and ammoCount or self.Primary.ClipSize, "SMG1")
        self:SetClip1(ammoCount < self.Primary.ClipSize and ammoCount or self.Primary.ClipSize)
        self:SendWeaponAnim(ACT_VM_IDLE)
    end)
end

function SWEP:ShouldDropOnDie()
    return false
end

net.Receive("Catgun.Charm", function()
    local wep = net.ReadEntity()

    if IsValid(wep) then
        wep:Attract(LocalPlayer())
    end
end)