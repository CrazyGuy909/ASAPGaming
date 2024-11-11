AddCSLuaFile()
local global_smoke = {}
DEFINE_BASECLASS("base_anim")
ENT.PrintName = "Dark Sphere"
ENT.Author = ""
ENT.Category = "Fun + Games"
ENT.Spawnable = false
ENT.AdminSpawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true

if SERVER then
    util.AddNetworkString("DarkSphere.Explode")
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/props/cs_office/snowman_head.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetCollisionGroup(COLLISION_GROUP_PUSHAWAY)
        self:SetMaterial("models/props_combine/com_shield001a")
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
        self:EmitSound("raygun_fire.wav")
    end
end

function ENT:Explode()
    local ball = ents.Create("prop_combine_ball")
    ball:SetPos(self:GetPos() + Vector(0, 0, 30))
    ball:SetAngles(Angle(0, 0, 90))
    ball:Spawn()
    ball:Fire("Explode", 0, 0)
    local eff = EffectData()
    eff:SetOrigin(self:GetPos())
    eff:SetMagnitude(.4)
    util.Effect("eff_darksphere", eff, true, true)

    for k, v in pairs(ents.FindInSphere(self:GetPos(), 256)) do
        if (v:IsPlayer() or v:IsNPC()) then
            if (v:IsPlayer()) then
                net.Start("DarkSphere.Explode")
                net.WriteVector(self:GetPos())
                net.Send(v)
            end

            local eff = EffectData()
            eff:SetEntity(v)
            util.Effect("eff_darkned", eff, true, true)
        end
    end

    SafeRemoveEntity(self)
end

function ENT:PhysicsSimulate(phys, delta)
    phys:Wake()

    if not IsValid(self:GetOwner()) then
        self:Remove()

        return
    end

    local owner = self:GetOwner()
    self.ShadowParams.pos = self:GetPos() + self:GetOwner():GetAimVector() * 64
    self.ShadowParams.angle = Angle(0, self:GetOwner():EyeAngles().y, 0)
    self.ShadowParams.secondstoarrive = delta
    self.ShadowParams.maxangular = 5000 --What should be the maximal angular force applied
    self.ShadowParams.maxangulardamp = 100 -- At which force/speed should it start damping the rotation
    self.ShadowParams.maxspeed = 1000000 -- Maximal linear force applied
    self.ShadowParams.maxspeeddamp = 10000 -- Maximal linear force/speed before damping
    self.ShadowParams.dampfactor = 0.8 -- The percentage it should damp the linear/angular force if it reaches it's max amount
    self.ShadowParams.teleportdistance = 50
    self.ShadowParams.deltatime = deltatime
    phys:ComputeShadowControl(self.ShadowParams)
end

local sprite = Material("sprites/sgmissile_plasma_ball")
local sprite2 = Material("sprites/trinity_stun_particles")

function ENT:DrawTranslucent()
    render.SetMaterial(sprite)
    render.DrawSprite(self:GetPos(), 96 + math.random(1, 5), 96 + math.random(1, 5), Color(255, 255, 255, math.random(100, 255)))
    render.SetMaterial(sprite2)
    render.DrawSprite(self:GetPos(), 64 + math.random(1, 5), 64 + math.random(1, 5), Color(255, 255, 255, math.random(100, 255)))
    self:DrawModel()
end

if SERVER then return end
local deg = surface.GetTextureID("vgui/gradient-u")
local smokes = {}
local runtime = 0
local cache

local tab = {
    ["$pp_colour_addr"] = 0,
    ["$pp_colour_addg"] = 0,
    ["$pp_colour_addb"] = 0,
    ["$pp_colour_brightness"] = -.5,
    ["$pp_colour_contrast"] = .4,
    ["$pp_colour_colour"] = .6,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0,
    ["$pp_colour_mulb"] = 0
}

for k = 1, 9 do
    smokes[k] = surface.GetTextureID("particle/smokesprites_000" .. k)
end

local function createPuff()
    if (runtime <= 0) then return end
    local dir = math.random(1, 2) == 1 and -1 or 1
    local size = math.random(1024, 2048)

    local tbl = {
        x = dir < 0 and ScrW() + size / 2 + math.random(16, 256) or -size / 2 - math.random(16, 256),
        y = math.random(-size / 2, size / 2),
        variation = math.random(1, 9),
        size = size, --math.random(256, 512),
        speed = math.random(10, 16) * dir
    }

    table.insert(cache, tbl)
end

net.Receive("DarkSphere.Explode", function()
    runtime = net.ReadUInt(8)
    cache = {}

    for k = 1, 32 do
        createPuff()
    end

    tab = {
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = -.5,
        ["$pp_colour_contrast"] = .4,
        ["$pp_colour_colour"] = .6,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    }
end)

hook.Add("HUDPaint", "DarkSphere", function()
    if (runtime < 0) then return end
    if not cache then return end
    surface.SetTexture(deg)
    surface.SetDrawColor(0, 0, 0, runtime > 1 and 100 or 100 * runtime)
    surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
    surface.DrawTexturedRectRotated(ScrW() / 2, ScrH() / 2, ScrW(), ScrH(), 180)

    for k, v in pairs(cache) do
        v.x = v.x + v.speed

        if (math.abs(v.x) > ScrW() + v.size) then
            table.remove(cache, k)
            createPuff()
            continue
        end

        surface.SetTexture(smokes[v.variation])
        surface.SetDrawColor(75, 75, 75, 100)
        surface.DrawTexturedRect(v.x, v.y, v.size, v.size / 1.5, 0)
    end

    runtime = runtime - FrameTime()
end)

hook.Add("RenderScreenspaceEffects", "DarkSphere", function()
    if (runtime <= 0) then return end
    if (runtime < 1) then
        tab["$pp_colour_brightness"] = Lerp(1 - runtime, -.5, 0)
        tab["$pp_colour_contrast"] = Lerp(1 - runtime, .4, 1)
        tab["$pp_colour_colour"] = Lerp(1 - runtime, .6, 1)
    end

    DrawColorModify(tab)
end)