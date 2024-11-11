AddCSLuaFile()
ENT.Type = "anim"
ENT.Category = "ASAP Gangs"
ENT.PrintName = "Weed Pot"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Base = "base_anim"
ENT.Editable = true
ENT.Model = Model("models/gonzo/weedb/pot3.mdl")
function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "Level")
    self:NetworkVar("Int", 1, "Weed")
    self:NetworkVar("Entity", 0, "Plant")
    self:NetworkVar("Float", 0, "NextLevel")
    self:NetworkVar("String", 0, "Gang")
    self:NetworkVarNotify("NextLevel", function(s, name, old, new)
        s._startMark = CurTime()
        s._nextMark = new
        s._markDuration = new - CurTime()
    end)
    self:SetLevel(0)
end

function ENT:SpawnFunction(ply, tr, class)
    local ent = ents.Create(class)
    ent:SetPos(tr.HitPos)
    ent:SetAngles(Angle(0, 0, 0))
    ent:Spawn()
    ent:Activate()

    return ent
end

-- Configs --
function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetBodygroup(1, 1)

    if SERVER then
        self:PhysicsInitStatic(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self.Shadow = ents.Create("prop_dynamic")
        self.Shadow:SetModel("models/gonzo/weed_shared.mdl")
        self.Shadow:SetParent(self)
        self.Shadow:SetLocalPos(Vector(0, 0, 16))
        self.Shadow:SetBodygroup(1, 0)
        self.Shadow:SetNoDraw(true)
        self:DeleteOnRemove(self.Shadow)
    end
end

function ENT:Evolve()
    if (self:GetLevel() < 6) then
        self:SetLevel(self:GetLevel() + 1)
        self.Shadow:SetBodygroup(1, self:GetLevel())
        self:SetNextLevel(CurTime() + 3)
        self:Wait(3, function()
            self:Evolve()
        end)
    end
end

function ENT:Use(act)
    if (act:GetGang() != self:GetGang()) then return end
    local level = self:GetLevel()
    if (level == 0) then
        self.Shadow:SetParent(self)
        self.Shadow:SetLocalPos(Vector(0, 0, 16))
        self.Shadow:SetBodygroup(1, 0)
        self.Shadow:SetNoDraw(false)
        self:Evolve()
    elseif (level == 6) then
        if IsValid(act.GangComputer) then
            act.GangComputer:AddResource(1, math.random(4, 6), act)
            self.Shadow:SetNoDraw(true)
            self:SetLevel(0)
        else
            act:ChatPrint("This pot doesn't have a computer!")
        end
    end
end

if SERVER then return end
local circles = include("xeninui/libs/circles.lua")
--local tex = surface.GetTextureID("scope/gdcw_asiiscope")
local tex = surface.GetTextureID("hud/wvh/wolf_ultimate")
function ENT:Draw()
    self:DrawModel()
    if (not self._markDuration) then return end
    local dist = self:GetPos():DistToSqr(EyePos())

    if (dist < 20000) then
        local ang = self:GetAngles()
        cam.Start3D2D(self:GetPos(), ang, .15)
        --surface.DrawRect(-128, -128, 256, 256)

        if not IsValid(self.Circle) then
            self.Circle = circles.New(CIRCLE_FILLED, 128, 0, 0)
        end

        if not IsValid(self.OutCircle) then
            self.OutCircle = circles.New(CIRCLE_FILLED, 128, 0, 0)
        end
        local prg = 1 - (self._nextMark - CurTime()) / self._markDuration
        self.Circle:SetStartAngle(-98)
        self.Circle:SetEndAngle(Lerp(prg, 0, 360) - 98)

        surface.SetTexture(tex)
        surface.SetDrawColor(Color(25, 25, 25, 255))
        self.OutCircle()
        surface.SetDrawColor(color_white)
        self.Circle()
        cam.End3D2D()
    end
end