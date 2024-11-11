AddCSLuaFile()
local global_smoke = {}
DEFINE_BASECLASS("base_anim")
ENT.PrintName = "Psycho Shield"
ENT.Author = ""
ENT.Category = "Fun + Games"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/props_phx/construct/metal_plate_curve180x2.mdl")
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_VPHYSICS)
        timer.Simple(5, function()
            if IsValid(self) then
                self:Explode()
            end
        end)
    end
    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    self:EmitSound("beams/beamstart5.wav")
    self:SetMaterial("asap/hexa_power")
    self:DrawShadow(false)
end

function ENT:Explode()
    local ball = ents.Create("prop_combine_ball")
    ball:SetPos(self:GetPos() + Vector(0, 0, 30))
    ball:SetAngles(Angle(0, 0, 90))
    ball:Spawn()
    ball:Fire("Explode", 0, 0)
    SafeRemoveEntity(self)
end

local combine = Material("effects/rollerglow")
local sphere = Material("asap/hexa_red")

function ENT:DrawTranslucent()
    self:DrawModel()
end