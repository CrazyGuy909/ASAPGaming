AddCSLuaFile()
ENT.Type = "anim"
ENT.Category = "ASAP Gangs"
ENT.PrintName = "Mining Portal"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Base = "base_anim"
ENT.Editable = true
ENT.Model = Model("models/blackops/portal.mdl")

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "Gang")
    self:NetworkVar("String", 1, "Ore")
end

function ENT:SpawnFunction(ply, tr, class)
    local ent = ents.Create(class)
    ent:SetPos(tr.HitPos + tr.HitNormal * 1 + Vector(0, 0, 0))
    ent:SetAngles(tr.HitNormal:Angle())
    ent:Spawn()
    ent:Activate()

    return ent
end

game.AddParticles("particles/portals.pcf")
PrecacheParticleSystem("portal_fake_b")

-- Configs --
function ENT:Initialize()
    if SERVER then
        self:SetModel(self.Model)
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysicsInitStatic(SOLID_VPHYSICS)
        self:SetMaterial("sprites/ogborder")
        local ent = ents.Create("info_particle_system")
        ent:SetPos(self:GetPos())
        ent:SetKeyValue("effect_name", "portal_2_edge")
        ent:SetKeyValue("start_active", "1")
        ent:Spawn()
        ent:Activate()
        ent:SetParent(self)
        ent:SetLocalAngles(Angle(0, 90, 90))
        self:InitializeOre()
    end
end

function ENT:InitializeOre()
    local oldOre = self:GetOre()

    if not self.availableOres then
        self.availableOres = {}

        for k, v in pairs(asapmining.rocks) do
            if not v.portal then continue end
            table.insert(self.availableOres, k)
        end
    end

    local ore = table.Random(self.availableOres)

    while ore == oldOre do
        ore = table.Random(self.availableOres)
    end

    self:SetOre(ore)
end

if SERVER then return end
local mask = Material("sprites/nored")
local back = Material("sprites/nored")
local sky = Material("skybox/sky_day03_06bup")
-- Give the RT a size
local TEX_SIZE = 512
-- Create the RT
local tex = GetRenderTargetEx("portal_mask" .. os.time(), TEX_SIZE, TEX_SIZE, RT_SIZE_OFFSCREEN, MATERIAL_RT_DEPTH_SHARED, 0, 0, IMAGE_FORMAT_RGBA8888) --[[IMPORTANT]]

local myMat = CreateMaterial("ExampleMaskRTMat" .. os.time(), "UnlitGeneric", {
    ["$basetexture"] = tex:GetName(), -- Make the material use our render target texture
    ["$translucent"] = "1" -- make the drawn material transparent
    
})

local function RenderMaskedRT()
    -- Draw the "background" image
    surface.SetDrawColor(color_white)
    surface.SetMaterial(sky)
    surface.DrawTexturedRect(0, 0, TEX_SIZE, TEX_SIZE)
    -- Animate the background for fun
    surface.DrawTexturedRectRotated(TEX_SIZE / 2, TEX_SIZE / 2, TEX_SIZE, TEX_SIZE, CurTime() * 10)
    -- Draw the actual mask
    render.SetWriteDepthToDestAlpha(false)
    render.OverrideBlend(true, BLEND_SRC_COLOR, BLEND_SRC_ALPHA, 3)
    surface.SetMaterial(mask)
    surface.DrawTexturedRect(0, 0, TEX_SIZE, TEX_SIZE)
    render.OverrideBlend(false)
    render.SetWriteDepthToDestAlpha(true)
end

function ENT:Draw()
    render.PushRenderTarget(tex)
    cam.Start2D()
    render.Clear(0, 0, 0, 0)
    RenderMaskedRT()
    cam.End2D()
    render.PopRenderTarget()
    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), -90)
    cam.Start3D2D(self:GetPos(), ang, .2)
    surface.SetDrawColor(color_white)
    surface.SetMaterial(myMat)
    surface.DrawTexturedRectRotated(0, 0, TEX_SIZE, TEX_SIZE, 0)
    cam.End3D2D()
    self:DrawModel()
end