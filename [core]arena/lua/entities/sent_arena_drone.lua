if SERVER then
    util.AddNetworkString("Drone.SetDriver")
end

AddCSLuaFile()
DEFINE_BASECLASS("base_anim")
ENT.Category = "Galaxium Arena"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Editable = true
ENT.PrintName = "Arena drone"

function ENT:SetupDataTables()
    self:NetworkVar("Vector", 0, "Direction")
end

function ENT:SpawnFunction(ply, tr, ClassName)
    if (not ply:IsSuperAdmin()) then return end
    local ent = ents.Create(ClassName)
    ent:SetPos(tr.HitPos + tr.HitNormal * 128)
    ent:Spawn()
    ent:Activate()
    ent:SetDriver(ply)

    return ent
end

function ENT:SetDriver(ply)
    self:SetOwner(ply)

    timer.Simple(0, function()
        ply:SetNoDraw(true)
        ply._drone = self
        ply:GodEnable()
        ply:SetMoveType(MOVETYPE_FLY)

        if (not ply:HasWeapon("weapon_fists")) then
            ply:Give("weapon_fists")
        end

        ply:SelectWeapon("weapon_fists")
        ply:SetNWFloat("Drone.Time", CurTime() + 40)

        timer.Simple(40, function()
            if IsValid(self) then
                self:Remove()
            end
        end)

        timer.Simple(.5, function()
            net.Start("Drone.SetDriver")
            net.WriteEntity(self)
            net.Send(ply)
        end)
    end)
end

function ENT:OnRemove()
    if SERVER and IsValid(self:GetOwner()) then
        self:GetOwner():GodDisable()
        self:GetOwner():SetMoveType(MOVETYPE_STEP)
        self:GetOwner():SetNoDraw(false)
        self:GetOwner():Spawn()
    end
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/asapgaming/scoreboard/scoreboard.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_PUSHAWAY)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        --self:SetModelScale(1, 1)
        self:Activate()

        timer.Simple(0, function()
            local phys = self:GetPhysicsObject()

            if (phys:IsValid()) then
                phys:Wake()
                phys:EnableMotion(true)
            end
        end)

        self:SetHealth(1000)
        self.ShadowParams = {}
        self:StartMotionController()
        local origin = self:GetPos()
        for k = 0, 16 do
            local tr = util.TraceLine({
                start = origin + Vector(0, 0, 32 * k),
                endpos = origin + Vector(0, 0, 99999),
            })
            if (tr.HitNoDraw ) then
                self:SetPos(origin + Vector(0, 0, 32 * k))
                break
            end
        end
    end
end

ENT.LerpSpeed = Vector(0, 0, 0)

function ENT:FireGun()
    local bullet = {
        Attacker = self:GetOwner(),
        Damage = 30,
        Force = 50,
        HullSize = 8,
        Callback = function(a, tr, c)
            local effect = EffectData()
            effect:SetOrigin(tr.HitPos)
            effect:SetScale(8)
            effect:SetMagnitude(8)
            effect:SetNormal(tr.HitNormal)
            util.Effect("watersplash", effect, true, true)
        end,
        Tracer = 1,
        TracerName = "AirboatGunHeavyTracer",
        Src = self:GetOwner():GetShootPos() + Vector(0, 0, -16),
        Dir = (Angle(self:GetOwner():EyeAngles().p, self:GetAngles().y, 0)):Forward(),
        Spread = Vector(.01, .01, 0),
        IgnoreEntity = self
    }

    self:EmitSound("weapons/bo2_hamr.wav", 75, 100 + math.random(-5, 5), 1, CHAN_WEAPON)
    self:GetOwner():LagCompensation(true)
    self:FireBullets(bullet, true)
    self:GetOwner():ViewPunch(Angle(-1, 0, 0))
    self:GetOwner():LagCompensation(false)
end

ENT.Missile = nil

function ENT:FireRocket()
    local ent = ents.Create("rpg_missile")
    ent:SetPos(self:GetOwner():GetShootPos() + Vector(0, 0, -64) + self:GetOwner():GetAimVector() * 64)
    ent:SetAngles(self:GetOwner():EyeAngles())
    ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    ent:SetOwner(self:GetOwner())
    ent:SetSaveValue("m_flDamage", 100)
    self:GetOwner():ViewPunch(Angle(-5, 0, 0))

    --PrintTable(ent:GetSaveTable())
    timer.Simple(1, function()
        if IsValid(ent) then
            --ent:SetOwner(self:GetOwner())
            ent:SetCollisionGroup(COLLISION_GROUP_NONE)
        end
    end)

    ent:Spawn()
    self.Missile = ent
end

ENT.LerpAngle = Angle(0, 0, 0)

function ENT:Think()
    if not IsValid(self:GetOwner()) then return end
    local owner = self:GetOwner()
    local velocity = Vector(0, 0, 0)
    local recover = 1

    if (owner:KeyDown(IN_MOVELEFT) or owner:KeyDown(IN_MOVERIGHT)) then
        velocity = velocity + Vector(owner:KeyDown(IN_MOVELEFT) and -16 or 16, 0, 0)
        recover = 4
    end

    if (owner:KeyDown(IN_FORWARD) or owner:KeyDown(IN_BACK)) then
        velocity = velocity + Vector(0, owner:KeyDown(IN_FORWARD) and 16 or -16, 0)
        recover = 4
    end

    if (owner:KeyDown(IN_JUMP) or owner:KeyDown(IN_DUCK)) then
        velocity = velocity + Vector(0, 0, owner:KeyDown(IN_JUMP) and 16 or -16)
        recover = 4
    end

    self.LerpSpeed = LerpVector(FrameTime() * recover, self.LerpSpeed, velocity)
    self:SetDirection(self.LerpSpeed)
    self.LerpAngle = LerpAngle(FrameTime() * 2, self.LerpAngle, Angle(0, self:GetOwner():EyeAngles().y, 0))
    self:SetAngles(self.LerpAngle)

    if SERVER then
        if (self.CanAttack and (self._nextAttack or 0) < CurTime()) then
            self._nextAttack = CurTime() + .15
            self:FireGun()
        end

        if (self.CanAttackRockets and (self._nextAttackRocket or 0) < CurTime()) then
            self._nextAttackRocket = CurTime() + 1
            self:FireRocket()
        end

        self:GetOwner():SetPos(self:GetPos() - self:GetUp() * 162)
        local hitPos = self:GetOwner():GetEyeTrace().HitPos

        if IsValid(self.Missile) then
            self.Missile:SetLocalVelocity((hitPos - self.Missile:GetPos()):GetNormalized() * 1000)
            self.Missile:SetAngles((hitPos - self.Missile:GetPos()):Angle())
        end

        self:NextThink(CurTime())

        return true
    end
end

if SERVER then end
--[[
    if IsValid(DRONE) then
        DRONE:Remove()
    end

    DRONE = ents.Create("sent_arena_drone")
    DRONE:SetPos(Vector(-2390, 2464, -8986))
    DRONE:Spawn()
    DRONE:SetDriver(player.GetByID(1))
]]
ENT.Speed = 16

function ENT:PhysicsSimulate(phys, delta)
    phys:Wake()
    self.Speed = self:GetOwner():KeyDown(IN_SPEED) and 32 or 16

    if (not self.Remaining) then
        self.Remaining = CurTime() + 3

        return
    elseif (self.Remaining >= CurTime()) then
        if (not self.TargetPos) then
            local tr = util.QuickTrace(self:GetPos(), Vector(0, 0, -9999), self)
            self.TargetPos = tr.HitPos + Vector(0, 0, 1000)
        end

        self.ShadowParams.pos = self.TargetPos + self:GetRight() * self:GetDirection().x * self.Speed + self:GetForward() * self:GetDirection().y * self.Speed
    else
        self.ShadowParams.pos = self:GetPos() + self:GetRight() * self:GetDirection().x * self.Speed + self:GetForward() * self:GetDirection().y * self.Speed + self:GetUp() * self:GetDirection().z * self.Speed / 2
    end

    if not IsValid(self:GetOwner()) then return end
    self.ShadowParams.secondstoarrive = .5
    self.ShadowParams.maxangular = 5000 --What should be the maximal angular force applied
    self.ShadowParams.maxangulardamp = 100 -- At which force/speed should it start damping the rotation
    self.ShadowParams.maxspeed = 1000000 -- Maximal linear force applied
    self.ShadowParams.maxspeeddamp = 10000 -- Maximal linear force/speed before damping
    self.ShadowParams.dampfactor = 0.8 -- The percentage it should damp the linear/angular force if it reaches it's max amount
    self.ShadowParams.teleportdistance = 20000
    self.ShadowParams.deltatime = deltatime
    phys:ComputeShadowControl(self.ShadowParams)
end

ENT.BoneInit = -1
ENT.Propellers = {1, 3, 5, 7}
ENT.Boneless = {2, 4, 6, 0}
ENT.Roll = {9, 10, 11, 12}

function ENT:Draw()
    self:DrawModel()

    for k, v in pairs(self.Propellers) do
        self:ManipulateBoneAngles(v, Angle(0, (RealTime() * 1024) % 360, 0))
    end

    for k, v in pairs(self.Boneless) do
        self:ManipulateBoneAngles(v, Angle(0, 0, math.cos(RealTime() * 2) * 8))
    end
end

drone_vehicle = drone_vehicle or nil

net.Receive("Drone.SetDriver", function()
    drone_vehicle = net.ReadEntity()
    LocalPlayer():SetMoveType(MOVETYPE_FLY)
end)

hook.Add("KeyRelease", "Drone.Attack", function(ply, key)
    if SERVER and IsValid(ply._drone) then
        if key == IN_ATTACK then
            ply._drone.CanAttack = false
        end

        if key == IN_ATTACK2 then
            ply._drone.CanAttackRockets = false
        end
    end
end)

hook.Add("KeyPress", "Drone.Attack", function(ply, key)
    if SERVER and IsValid(ply._drone) then
        if key == IN_ATTACK then
            ply._drone.CanAttack = true
        end

        if key == IN_ATTACK2 then
            ply._drone.CanAttackRockets = true
        end
    end
end)

if SERVER then return end

hook.Add("StartCommand", "Drone.Controls", function(ply, cmd)
    if (not IsValid(drone_vehicle)) then return end
    cmd:ClearMovement()

    return true
end)

hook.Add("SetupPlayerVisibility", "Drone.Visibility", function(ply)
    if (IsValid(ply._drone)) then
        AddOriginToPVS(ply._drone:GetPos())
    end
end)

hook.Add("CalcView", "Drone.View", function(ply, pos, ang, fov)
    if (not IsValid(drone_vehicle)) then return end

    local data = {
        origin = drone_vehicle:GetPos() - drone_vehicle:GetUp() * 96,
        angles = ang,
        drawviewer = true,
        fov = 90
    }

    return data
end)

local refract = Material("gmod/scope-refract")
local scope = Material("gmod/scope")
local screen = Material("dev/samplefullfb_nolog")
local mat

if CLIENT then
    mat = CreateMaterial("_droneVision5", "UnlitGeneric", {
        ["$basetexture"] = "dev/dev_scanline",
        ["$additive"] = 1,
        ["$vertexcolor"] = 1,
        ["$vertexalpha"] = 1,
        ["Proxies"] = {
            ["TextureScroll"] = {
                ["texturescrollvar"] = "$basetexturetransform",
                ["texturescrollrate"] = 3,
                ["texturescrollangle"] = 90
            }
        }
    })
end

local noloopb = false
local fullwhite = Material("debug/debugdrawflat")
local fire = surface.GetTextureID("ui/flame")

hook.Add("PostDrawTranslucentRenderables", "Drone.DrawPlayers", function()
    if (noloopb) then return end
    if not LocalPlayer():InArena() then return end
    noloopb = true

    if IsValid(drone_vehicle) then
        cam.IgnoreZ(true)
        render.MaterialOverride(fullwhite)

        for k, ply in pairs(player.GetAll()) do
            if (not ply:InArena()) then continue end
            if (not ply:Alive()) then continue end
            if (ply == LocalPlayer()) then continue end

            if (IsValid(drone_vehicle)) then
                local dist = ply:GetPos():Distance(EyePos())
                render.DrawWireframeBox(ply:GetPos(), LocalPlayer():GetAimVector():Angle(), -Vector(1, 1, 1) * dist / 32, Vector(1, 1, 1) * dist / 32, color_white, true)
            else
                render.SetColorMaterial()
                render.SetColorModulation(1, .7, 0)
            end

            ply:DrawModel()
        end

        render.MaterialOverride()
        cam.IgnoreZ(false)
        noloopb = false

        return
    end

    if LocalPlayer():GetNWBool("HawkEye", false) then
        cam.IgnoreZ(true)
        render.MaterialOverride(fullwhite)

        for k, ply in pairs(player.GetAll()) do
            if (not ply:InArena()) then continue end
            if (not ply:Alive()) then continue end
            if (ply == LocalPlayer()) then continue end
            local ang = EyeAngles()
            --ang:RotateAroundAxis(ang:Up(), 90)
            ang:RotateAroundAxis(ang:Forward(), 90)
            ang:RotateAroundAxis(ang:Right(), 90)
            cam.Start3D2D(ply:EyePos() + ply:GetUp() * 16, ang, .5)
            surface.SetTexture(fire)
            surface.SetDrawColor(color_white)
            surface.DrawTexturedRectRotated(0, 0, 196, 196, 0)
            cam.End3D2D()
        end

        render.MaterialOverride()
        cam.IgnoreZ(false)
        noloopb = false
    end
end)

local reticle = Material("vgui/hud/xbox_reticle")

hook.Add("HUDPaint", "Drone.Visor", function()
    if (not IsValid(drone_vehicle)) then return end
    surface.SetDrawColor(color_white)
    surface.SetMaterial(refract)
    surface.DrawTexturedRectRotated(ScrW() / 2 - 32, ScrH() / 2, ScrH() * 1.8 + 48, ScrH(), 0)
    surface.SetDrawColor(75, 255, 0, math.random(15, 25))
    surface.DrawRect(0, 0, ScrW(), ScrH())
    surface.SetMaterial(mat)
    surface.SetDrawColor(255, 255, 255, math.random(15, 25))
    surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
    surface.SetDrawColor(Color(0, 0, 0, 254))
    surface.SetMaterial(scope)
    local wide = ScrW() - ScrH() * 1.8
    surface.DrawTexturedRectRotated(ScrW() / 2, ScrH() / 2, ScrH() * 1.8, ScrH(), 0)
    surface.DrawRect(0, 0, wide / 2, ScrH())
    surface.DrawRect(ScrW() - wide / 2, 0, wide / 2, ScrH())
    surface.SetMaterial(reticle)
    surface.SetDrawColor(color_white)
    surface.DrawTexturedRectRotated(ScrW() / 2, ScrH() / 2, 96, 96, 0)

    local hitPos = util.TraceLine({
        start = LocalPlayer():GetShootPos(),
        endpos = LocalPlayer():GetShootPos() + (Angle(LocalPlayer():EyeAngles().p, drone_vehicle:GetAngles().y, 0)):Forward() * 9999,
        filter = {drone_vehicle, LocalPlayer()}
    })

    local sc = hitPos.HitPos:ToScreen()
    surface.DrawTexturedRectRotated(sc.x, sc.y, 172, 172, 0)
    local tx, ty = draw.SimpleText("Time remaining:", "Arena.Medium", ScrW() / 2, 128, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    tx = tx + 16
    draw.RoundedBox(4, ScrW() / 2 + -tx / 2, 96 + ty + 8, tx, 32, Color(26, 26, 26))
    surface.SetDrawColor(Color(255, 255, 255))
    surface.DrawRect(ScrW() / 2 + -tx / 2 + 8, 96 + ty + 16, (tx - 16) * ((LocalPlayer():GetNWFloat("Drone.Time", CurTime()) - CurTime()) / 40), 16)
end)

local back = surface.GetTextureID("ui/onfire")

local hawkeye_pp = {
    ["$pp_colour_addr"] = 0,
    ["$pp_colour_addg"] = -.02,
    ["$pp_colour_addb"] = -.02,
    ["$pp_colour_brightness"] = -0.15,
    ["$pp_colour_contrast"] = 1.2,
    ["$pp_colour_colour"] = .6,
    ["$pp_colour_mulr"] = 0.4,
    ["$pp_colour_mulg"] = 0.1,
    ["$pp_colour_mulb"] = 0.1
}

local drone_pp = {
    ["$pp_colour_addr"] = -.01,
    ["$pp_colour_addg"] = -.01,
    ["$pp_colour_addb"] = -.01,
    ["$pp_colour_brightness"] = -0.3,
    ["$pp_colour_contrast"] = 1.5,
    ["$pp_colour_colour"] = .5,
    ["$pp_colour_mulr"] = .25,
    ["$pp_colour_mulg"] = .3,
    ["$pp_colour_mulb"] = .4
}

--surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
hook.Add("RenderScreenspaceEffects", "Drone.VisorV2", function()
    if (not LocalPlayer():InArena()) then return end

    if IsValid(drone_vehicle) then
        DrawColorModify(drone_pp)

        return
    end

    if LocalPlayer():GetNWBool("HawkEye", false) then
        DrawColorModify(hawkeye_pp)

        return
    end
end)

hook.Add("InputMouseApply", "Drone.Camera", function(cmd, x, y, angle)
    if (not IsValid(drone_vehicle)) then return end
    -- By leaving angle.roll and angle.yaw alone, we effectively lock them
    angle.pitch = math.Clamp(angle.pitch + y / 50, 0, 90)
    angle.yaw = angle.yaw - x / 50
    cmd:SetViewAngles(angle)

    return true
end)