AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Category = "ASAPGaming"

ENT.PrintName = "Capture Point"
ENT.Spawnable = true
ENT.Editable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "Progress")
    self:NetworkVar("String", 0, "Faction")
    self:NetworkVar("Int", 1, "Speed")
    self:NetworkVar("Bool", 0, "IsCapturing")
    self:NetworkVar("Bool", 1, "IsBlocking")
    self:NetworkVar("Int", 2, "X", {
        KeyName = "xsuze",
        Edit = {
            type = "Int",
            min = 16,
            max = 128,
            order = 1
        }
    })

    self:NetworkVar("Int", 3, "Y", {
        KeyName = "ysize",
        Edit = {
            type = "Int",
            min = 16,
            max = 128,
            order = 2
        }
    })

    self:NetworkVar("Int", 4, "Z", {
        KeyName = "zsize",
        Edit = {
            type = "Int",
            min = 16,
            max = 128,
            order = 3
        }
    })
    self:NetworkVar("String", 1, "ZoneName", {
        KeyName = "zonename",
        Edit = {type = "Generic", order = 4},
        Default = "Zone"
    })

    self:SetFaction("")
    self:SetX(16)
    self:SetY(16)
    self:SetZ(8)
    self:SetProgress(0)
    self:SetFaction(0)
    self:SetIsCapturing(false)
    
end

function ENT:GetBounds()
    return Vector(self:GetX(), self:GetY(), self:GetZ()) * 16
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/props_lab/teleplatform.mdl")
        self:PhysicsInitStatic(SOLID_VPHYSICS)
    else
        self:SetRenderBounds(Vector(-256, -256, 0), Vector(256, 256, 4196))
    end
end

if SERVER then return end

local beam = Material("particle/beam_taser")
local circle_floor = Material("sgm/playercircle")
local Circles = include("xeninui/libs/circles.lua")
ENT.FloorCircle = Circles.New(CIRCLE_FILLED, 114, 0, 0)
local clr = {
    [0] = Color(252, 255, 81),
    [1] = Color(255, 94, 0),
    [2] = Color(0, 153, 255),
}
local progressColor = Color(255, 255, 255, 100)
function ENT:DrawTranslucent()
    self:DrawModel()

    local pos, ang = self:GetPos() + Vector(0, 0, 64), EyeAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)

    cam.Start3D2D(pos, ang, .15)
        if self:GetFaction() != "0" then
            draw.SimpleText("Controlled by:", XeninUI:Font(48), 112, 0, color_white)
            draw.SimpleText(self:GetFaction(), XeninUI:Font(96), 112, 24, color_white)
        end

        draw.SimpleText("Zone:", XeninUI:Font(48), -112, 0, color_white, TEXT_ALIGN_RIGHT)
        draw.SimpleText(self:GetZoneName(), XeninUI:Font(96), -112, 24, color_white, TEXT_ALIGN_RIGHT)
    cam.End3D2D()

    cam.Start3D2D(self:GetPos() + Vector(0, 0, 8), Angle(0, 0, 0), 1)
        if self:GetIsCapturing() then
            surface.SetMaterial(circle_floor)
            surface.SetDrawColor(progressColor)
            surface.DrawTexturedRectRotated(0, 0, 228, 228, (RealTime() * 60) % 360)
        end

        if (self:GetProgress() > 0) then
            draw.NoTexture()
            self.FloorCircle:SetColor(self:GetIsBlocking() and Color(255, 129, 25, 125) or Color(100, 255, 75, 125))
            self.FloorCircle:SetEndAngle((self:GetProgress() / 100) * 360)
            self.FloorCircle()
        end
    cam.End3D2D()

    local skin = self:GetFaction() == "" and 0 or self:GetFaction() == LocalPlayer():GetNWString("Gang.Name") and 2 or 1
    self:SetSkin(skin)

    render.SetMaterial(beam)
    render.DrawBeam(self:GetPos(), self:GetPos() + Vector(0, 0, 4196), 96, 0, 1, clr[skin])
    render.DrawBeam(self:GetPos(), self:GetPos() + Vector(0, 0, 4196), 32, 0, 1, Color(255, 255, 255, 255))

end