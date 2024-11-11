if not file.Exists("weapons/csgo_baseknife.lua", "LUA") then
    SWEP.Spawnable = false
    print("csgo_karambit_slaughter failed to initialize: csgo_baseknife.lua not found. Did you install the main part?")

    return
end

local TTT = (GAMEMODE_NAME == "terrortown" or cvars.Bool("csgo_knives_force_ttt", false))
DEFINE_BASECLASS("csgo_baseknife")

if (SERVER) then
    SWEP.Weight = 5
    SWEP.AutoSwitchTo = false
    SWEP.AutoSwitchFrom = false

    util.AddNetworkString("Zombies.RequestPosition")

    if TTT then
        SWEP.EquipMenuData = nil
    end
end

if (CLIENT) then
    SWEP.Slot = TTT and 6 or 2
    SWEP.SlotPos = 0
end

SWEP.PrintName = "Zombie Knife"
SWEP.Category = "CS:GO Knives"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModel = "models/weapons/v_csgo_default.mdl"
SWEP.WorldModel = "models/weapons/w_csgo_default.mdl"
SWEP.SkinIndex = 8
SWEP.PaintMaterial = nil
SWEP.AreDaggers = false
util.PrecacheModel(SWEP.ViewModel)
util.PrecacheModel(SWEP.WorldModel)
-- TTT config values
-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_EQUIP
-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2, then this gun can
-- be spawned as a random weapon.
SWEP.AutoSpawnable = false
-- The AmmoEnt is the ammo entity that can be picked up when carrying this gun.
-- SWEP.AmmoEnt = "item_ammo_smg1_ttt"
-- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If
-- a role is in this table, those players can buy this.
SWEP.CanBuy = nil
-- InLoadoutFor is a table of ROLE_* entries that specifies which roles should
-- receive this weapon as soon as the round starts. In this case, none.
SWEP.InLoadoutFor = nil
-- If LimitedStock is true, you can only buy one per round.
SWEP.LimitedStock = false
-- If AllowDrop is false, players can"t manually drop the gun with Q
SWEP.AllowDrop = false
-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = true
-- If NoSights is true, the weapon won"t have ironsights
SWEP.NoSights = true
-- This sets the icon shown for the weapon in the DNA sampler, search window,
-- equipment menu (if buyable), etc.
SWEP.Icon = "vgui/entities/csgo_karambit_slaughter.vmt"
SWEP.IsZombie = true
--This also used for variable declaration and SetVar/GetVar getting work
function SWEP:SetupDataTables()
    self:NetworkVar("Float", 0, "InspectTime")
    self:NetworkVar("Float", 1, "IdleTime")
    self:NetworkVar("Bool", 2, "Thrown")
    self:NetworkVar("Float", 3, "Cooldown")
    self:NetworkVar("Float", 4, "CooldownKnife")
end

hook.Add("PlayerButtonDown", "ZombieKnife", function(ply, key)
    if (IsFirstTimePredicted() and key == KEY_Q and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon().IsZombie) then
        ply:GetActiveWeapon():DoJump()
    end
end)

SWEP.NextJump = 0
function SWEP:DoJump()
    if (self.NextJump > CurTime()) then
        return
    end
    self.NextJump = CurTime() + 1
    if (self.Owner:IsOnGround()) then
        self.Owner:SetPos(self.Owner:GetPos() + Vector(0, 0, 2))
        self.Owner:SetVelocity(self.Owner:GetAimVector() * 850)
        self.Owner:EmitSound("npc/fast_zombie/claw_miss" .. math.random(1, 2) .. ".wav")
        return
    end
end

function SWEP:SecondaryAttack()
    if CLIENT then return end
    if (CurTime() < self:GetNextSecondaryFire()) then return end
    self:SetNextSecondaryFire(CurTime() + 5)

    if (self:GetCooldownKnife() > CurTime()) then
        return
    end

    self:SetThrown(true)
    self:SetCooldownKnife(CurTime() + 30)
    timer.Simple(30, function()
        if IsValid(self) then
            self:SetThrown(false)
        end
    end)

    self:SetNextPrimaryFire( CurTime() + 1 )
    self:SetNextSecondaryFire( CurTime() + 1 )

    local ply = self.Owner
    local ang = ply:EyeAngles()

    self:SendWeaponAnim( ACT_VM_DRAW )
    ply:SetAnimation( PLAYER_ATTACK1 )

    if ang.p < 90 then
        ang.p = -10 + ang.p * ((90 + 10) / 90)
    else
        ang.p = 360 - ang.p
        ang.p = -10 + ang.p * -((90 + 10) / 90)
    end

    local vel = math.Clamp((90 - ang.p) * 5.5, 550, 800)

    local vfw = ang:Forward()
    local vrt = ang:Right()

    local src = ply:GetPos() + (ply:Crouching() and ply:GetViewOffsetDucked() or ply:GetViewOffset())

    src = src + (vfw * 1) + (vrt * 3)

    local thr = vfw * vel + ply:GetAimVector() * 250

    local knife_ang = Angle(-28,0,0) + ang
    knife_ang:RotateAroundAxis(knife_ang:Right(), -90)
    local knife = ents.Create("sent_zombie_knife")
    if not IsValid(knife) then return end
    knife:SetPos(src)
    knife:SetAngles(knife_ang)

    knife:Spawn()

    knife.Damage = self.Primary.Damage

    knife:SetOwner(ply)

    local phys = knife:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetVelocity(thr)
        phys:AddAngleVelocity(Vector(0, 1500, 0))
        phys:Wake()
    end
end

function SWEP:Reload()
    if (self:GetCooldown() > CurTime()) then return end
    self:SetCooldown(CurTime() + 3)
    if CLIENT then return end
    self.Owner:EmitSound("npc/zombie_poison/pz_alert" .. math.random(1,2) .. ".wav", 90, 100, .25)
    local pos = {}
    for k, v in pairs(asapArena:GetPlayers()) do
        if (v:GetNWBool("ArenaInfected", false)) then continue end
        if (not v:Alive()) then continue end
        table.insert(pos, {
            pos = v:GetPos() + Vector(0, 0, 40),
            dist = (v:GetPos() + Vector(0, 0, 60)):Distance(self.Owner:GetPos())
        })
    end
    net.Start("Zombies.RequestPosition")
    net.WriteTable(pos)
    net.Send(self.Owner)
end

if CLIENT then
net.Receive("Zombies.RequestPosition", function(l, ply)
    local wep = LocalPlayer():GetActiveWeapon()
    wep.Life = 5
    wep.HeartBeats = net.ReadTable()
end)
end

if SERVER then return end
local rmb = Material("gui/rmb.png")
local r = Material("gui/r.png")
local gradient = Material("hud/wvh/timer")
local bar = Material("hud/wvh/human_bar")
local heart = Material("hud/wvh/wolf_ultimate")

SWEP.HeartBeats = {}
SWEP.Life = 0
function SWEP:DrawHUD()
    
    if (self.Life > 0) then
        surface.SetMaterial(heart)
        local power = (self.Life / 5)
        surface.SetDrawColor(255, 0, 0, power * 255)
        self.Life = self.Life - FrameTime()
        for k, v in pairs(self.HeartBeats) do
            local screen = v.pos:ToScreen()
            local maxSize = (1 - math.Clamp(v.dist / 8192, 0, .75)) * 196
            surface.DrawTexturedRectRotated(screen.x, screen.y, maxSize * (1 - power), maxSize * (1 - power), power * 720)
        end
    end
    surface.SetMaterial(bar)
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawTexturedRect(ScrW() / 2 - 128, ScrH() / 2 + 212 - 24, 256, 48)
    local fill = self:GetCooldown() < CurTime() and 1 or 1 - (self:GetCooldown() - CurTime()) / 3
    surface.SetDrawColor(color_white)
    surface.DrawTexturedRectUV(ScrW() / 2 - 128, ScrH() / 2 + 212 - 24, fill * 256, 48, 0, 0, fill, 1)

    surface.SetMaterial(r)
    surface.SetDrawColor(color_white)
    tx, _ = draw.SimpleText("Listen heartbeats", "XeninUI.TextEntry", ScrW() / 2 - 128, ScrH() / 2 + 180, color_white, 0, 1)
    surface.DrawTexturedRectRotated(ScrW() / 2 - 128 + tx + 16, ScrH() / 2 + 180, 16, 16, 0)
    surface.SetMaterial(gradient)
    surface.SetDrawColor(0, 0, 0, 255)
    local fillb = self:GetThrown() and math.Clamp(1 - (self:GetCooldownKnife() - CurTime()) / 30, 0, 1) or 1
    --surface.DrawTexturedRectRotated(ScrW() / 2 + 32, ScrH() / 2 + 128, 256, 48, 0)

    surface.DrawTexturedRect(ScrW() / 2 - 128, ScrH() / 2 + 102, 256, 48)
    if (fillb < 1) then
        surface.SetDrawColor(150, 150, 150, 255)
        surface.DrawTexturedRectUV(ScrW() / 2 - 128, ScrH() / 2 + 102, .1 + (fillb * .8) * 256, 48, 0, 0, fillb * .8, 1)
    end

    surface.SetMaterial(rmb)
    surface.SetDrawColor(color_white)
    local tx, _ = draw.SimpleText(self:GetThrown() and "Building knife" or "Throw knife", "XeninUI.TextEntry", ScrW() / 2 - 16, ScrH() / 2 + 128, color_white, 1, 1)
    
    surface.DrawTexturedRectRotated(ScrW() / 2 + tx / 2, ScrH() / 2 + 128, 24, 24, 0)

    draw.SimpleText("[Q] Long Jump", "XeninUI.TextEntry", ScrW() / 2, ScrH() / 2 + 228, color_white, 1)
end