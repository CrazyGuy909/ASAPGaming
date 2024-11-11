if CLIENT then
    SWEP.Slot = TTT and 6 or 2
    SWEP.SlotPos = 0
end

SWEP.PrintName = "Whirl Blower"
SWEP.Category = "ASAPGaming"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModel = "models/weapons/tfa_cso/c_watergun.mdl"
SWEP.WorldModel = "models/weapons/tfa_cso/c_watergun.mdl"
SWEP.UseHands = true
SWEP.ViewModelFOV = 90
SWEP.ViewModelFlip = true
SWEP.Primary.Damage = 10
SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true
SWEP.Primary.DrawAmmo = false
SWEP.Primary.Delay = 0.1
SWEP.BeamLength = 600
util.PrecacheModel(SWEP.ViewModel)
util.PrecacheModel(SWEP.WorldModel)

function SWEP:SetupDataTables()
    self:NetworkVar("Float", 0, "NextReload")
    self:NetworkVar("Float", 1, "Start")
    self:NetworkVar("Int", 0, "Munition")
    self:NetworkVar("Bool", 0, "Active")

    self:NetworkVarNotify("Active", function(s, name, old, new)
        if new == false and s:GetOwner().windblowerGun then
            s:GetOwner():StopLoopingSound(s:GetOwner().windblowerGun)
        end
    end)

    self:SetMunition(100)
    self:SetActive(false)
end

function SWEP:Ammo1()
    return self:GetMunition()
end

function SWEP:Initialize()
    self:SetHoldType("pistol")

    hook.Add("OnPlayerHitGround", self, function(s, ply)
        if ply == s:GetOwner() then return true end
    end)

    hook.Add("Move", self, function(s, ply, mv)
        if not s:GetActive() then return end
        if ply ~= s:GetOwner() then return end
        if ply:IsOnGround() then return end

        return s:HandleMovement(mv)
    end)
end

function SWEP:HandleMovement(mv)
    local aim = self:GetOwner():GetAimVector()
    local vel = mv:GetVelocity()
    local new_vel = -aim * 2000 * FrameTime()
    mv:SetVelocity(vel / 2 + math.Clamp(mv:GetSideSpeed(), -200, 200) * mv:GetMoveAngles():Right() + math.Clamp(mv:GetForwardSpeed(), -400, -100) * mv:GetMoveAngles():Forward() + new_vel + Vector(0, 0, new_vel.z))
end

SWEP.NextAmmo = 0

function SWEP:Think()
    if not self:GetActive() then
        if self:GetMunition() < self.Primary.ClipSize and self.NextAmmo < CurTime() then
            if SERVER then
                self:SetMunition(math.Clamp(self:GetMunition() + 2, 0, 100))
            end

            self.NextAmmo = CurTime() + self.Primary.Delay * 2
        end

        return
    end

    if self.NextAmmo > CurTime() then return end
    self.NextAmmo = CurTime() + self.Primary.Delay

    if SERVER then
        self:SetMunition(self:GetMunition() - 1)
        local start, endpos = self:GetOwner():GetShootPos(), self:GetOwner():GetAimVector() * self.BeamLength

        timer.Simple(.1, function()
            local tr = util.QuickTrace(start, endpos, self:GetOwner())

            if tr.Entity:IsNPC() or tr.Entity:IsPlayer() then
                local vel = ((endpos + start) - start):GetNormalized()

                if tr.Entity:IsOnGround() then
                    tr.Entity:SetPos(tr.Entity:GetPos() + Vector(0, 0, 4))
                end

                tr.Entity:SetVelocity(vel * 250 + Vector(0, 0, 75))
                tr.Entity:TakeDamage(15, self:GetOwner(), self)
            end
        end)
    end

    if not self:GetOwner():KeyDown(IN_ATTACK) or self:GetMunition() <= 0 then
        self:SetActive(false)
        self:SetNextReload(CurTime() + (not self:GetOwner():KeyDown(IN_ATTACK) and self.Primary.Delay or 2))
    end
end

function SWEP:PrimaryAttack()
    if self:GetNextReload() < CurTime() and self:GetMunition() > 0 and not self:GetActive() then
        self:SetActive(true)
        self:SetStart(CurTime())

        if CLIENT then
            self.Target = self:GetOwner():GetShootPos()
            self.bpos = {}
        end

        if self:GetOwner().windblowerGun then
            self:GetOwner():StopLoopingSound(self:GetOwner().windblowerGun)
        end

        self:GetOwner().windblowerGun = self:GetOwner():StartLoopingSound("ambient/gas/cannister_loop.wav")
    end
end

if CLIENT then
    local trail = Material("effects/qc_trail")
    local push = Material("effects/muzzleflashx_nemole_w")
    SWEP.bpos = {}

    function SWEP:DrawWorldModel(flags)
        if not self:GetActive() then return end
        local ply = self:GetOwner()
        local pos, ang = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Hand"))
        local power = math.Clamp(CurTime() - self:GetStart(), 0.1, 1)
        render.SetMaterial(trail)
        local tr = util.QuickTrace(pos, ply:GetAimVector() * math.Clamp(CurTime() - self:GetStart(), 0, 1) * power * self.BeamLength, ply)
        self.Target = LerpVector(FrameTime() * 8, self.Target or tr.HitPos, tr.HitPos)
        render.StartBeam(8)

        for k = 0, 8 do
            self.bpos[k] = LerpVector(FrameTime() * k * 2, self.bpos[k] or self.Target, self.Target)
            render.AddBeam(LerpVector(k / 8, pos, LerpVector(FrameTime() * k, self.bpos[k], self.Target)), ((k + 1) / 8) * 32, k / 4 - (RealTime() * 8) % 1, Color(150, 225 + math.cos(RealTime() + k) * 25, 255))
        end

        render.EndBeam()
        --render.DrawBeam(pos, self.Target, 16, (RealTime() * 2) % 1, (RealTime() * 2) % 1 - 1, color_white)
        render.SetMaterial(push)
        render.DrawSprite(pos, 24, 24, color_white)
        render.DrawSprite(self.bpos[8], 48, 48, color_white)
        ang:RotateAroundAxis(ang:Forward(), -90)
        ang:RotateAroundAxis(ang:Right(), 90)
        ang:RotateAroundAxis(ang:Up(), 90)
        ang:RotateAroundAxis(ang:Right(), -30)
        pos = pos + ang:Up() * 16 + ang:Forward() * -8 + ang:Right() * 8
        self:SetPos(pos)
        self:SetAngles(ang)
        self:SetupBones()
        self:DrawModel(flags)
    end

    function SWEP:PreDrawViewModel(vm, wep, ply)
        if not self:GetActive() then return end
        render.SetMaterial(trail)
        local origin = vm:GetAttachment(1)
        local pos, ang = origin.Pos
        render.SetMaterial(trail)
        local power = math.Clamp(CurTime() - self:GetStart(), 0.1, 1)
        local tr = util.QuickTrace(pos, ply:GetAimVector() * power * self.BeamLength, ply)
        self.Target = LerpVector(FrameTime() * 16, self.Target or tr.HitPos, tr.HitPos)
        render.StartBeam(8)

        for k = 0, 8 do
            self.bpos[k] = LerpVector(FrameTime() * k, self.bpos[k] or self.Target, self.Target)
            render.AddBeam(LerpVector(k / 8, pos, LerpVector(FrameTime() * k, self.bpos[k], self.Target)), ((k + 1) / 8) * 32, k / 4 - (RealTime() * 8) % 1, Color(150, 225 + math.cos(RealTime() + k) * 25, 255))
        end

        render.EndBeam()
        --render.DrawBeam(pos, self.Target, 16, (RealTime() * 2) % 1, (RealTime() * 2) % 1 - 1, color_white)
        render.SetMaterial(push)
        render.DrawSprite(pos, 12, 12, Color(150, 225 + math.cos(RealTime() * 4) * 25, 255))
        render.DrawSprite(self.bpos[8], power * 48, power * 48, Color(150, 225 + math.cos(RealTime() * 4) * 25, 255))
    end
end

function SWEP:SecondaryAttack()
end