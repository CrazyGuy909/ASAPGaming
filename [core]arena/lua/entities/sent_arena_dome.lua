AddCSLuaFile()
ENT.Type = "anim"
ENT.Category = "Galaxium Arena"
ENT.PrintName = "Arena Dome"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AutomaticFrameAdvance = true
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_BOTH
function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "DomeSize")
    self:SetDomeSize(10000)
end

function ENT:SpawnFunction(ply, tr, class)
    local ent = ents.Create(class)
    ent:SetPos(tr.HitPos + tr.HitNormal * 16)
    ent:Spawn()
    ent:Activate()

    return ent
end

-- Configs --
function ENT:Initialize()
    BR_Dome = self
    self:SetPos(Vector(-4205, -2027, -9172))
    self:SetModel("models/props_combine/breenglobe.mdl")
    self:SetSolid(SOLID_NONE)
    self:SetMoveType(MOVETYPE_NONE)
    if CLIENT then
        self:SetNoDraw(true)
    end
end

local tab = {
    ["$pp_colour_addr"] = .25,
    ["$pp_colour_addg"] = 0,
    ["$pp_colour_addb"] = 0,
    ["$pp_colour_brightness"] = -0.3,
    ["$pp_colour_contrast"] = 1,
    ["$pp_colour_colour"] = .7,
    ["$pp_colour_mulr"] = 1,
    ["$pp_colour_mulg"] = 1,
    ["$pp_colour_mulb"] = 0
}

hook.Add("PostDrawTranslucentRenderables", "Arena.BattleRoyale", function()
    if IsValid(BR_Dome) then
        BR_Dome:DrawTranslucent()
    end
end)

hook.Add("RenderScreenspaceEffects", "Arena.BattleRoyale", function()
    if (LocalPlayer():GetViewEntity() == LocalPlayer() and LocalPlayer():InArena() and LocalPlayer().OutsideDome) then
        DrawColorModify(tab) --Draws Color Modify effect
    end
end)


function ENT:OnRemove()
    BroadcastLua("LocalPlayer().OutsideDome = nil")
end

ENT.NextCheck = 0
function ENT:Think()
    if (self.NextCheck < CurTime()) then
        if SERVER then
            if (asapArena.ActiveGamemode.id != "battleroyale") then
                self:Remove()
                return
            end
            for k, v in pairs(asapArena:GetPlayers(true)) do
                local pos = Vector(self:GetPos().x, self:GetPos().y, v:GetPos().z)
                local dist = pos:Distance(v:GetPos())
                if (v:Alive() and dist > self:GetDomeSize()) then
                    v:TakeDamage(30, self, self)
                    v:EmitSound("player/pl_burnpain" .. math.random(1, 3) .. ".wav")
                end
            end
        else
            local pos = Vector(self:GetPos().x, self:GetPos().y, LocalPlayer():GetPos().z)
            LocalPlayer().OutsideDome = pos:Distance(LocalPlayer():GetPos()) > self:GetDomeSize()
        end
        self.NextCheck = CurTime() + (SERVER and 1 or .5)
    end
    if SERVER then
        if (self:GetDomeSize() > 700) then
            self:SetDomeSize(self:GetDomeSize() - 8)
        end
        self:NextThink(CurTime() + 1)
        return true
    end
end

if SERVER then return end

local degree = CreateMaterial("degree_cilinderdddddd","UnlitGeneric", {
	["$basetexture"] = "vgui/gradient-u",
	["$vertexcolor"] = 1,
    ["$vertexalpha"] = 1,
    ["$model"] = 1,
})

ENT.Size = 0
function ENT:DrawTranslucent()
    self:DrawModel()
    self:SetColor(Color(252, 150, 0))
    render.SetMaterial(degree)
    if (self.Size == 0) then
        self.Size = self:GetDomeSize()
    else
        self.Size = Lerp(FrameTime(), self.Size, self:GetDomeSize())
    end
    render.DrawCilinder(Vector(self:GetPos().x, self:GetPos().y, -9777), Angle(0, 0, 0), self.Size, 4000, math.Clamp(math.ceil(self:GetDomeSize() / 16), 24, 96), Color(255, 75, 0, 200), 256, 8)
    render.SetBlend(1)
end

function render.DrawCilinder(pos, ang, radius, tall, verts, color, anim_height, anim_wave)

    for k=1,verts do
        k = k - 1
        local lcos = math.cos(math.pi * 2 * (k/verts)) * radius
        local lsin = math.sin(math.pi * 2 * (k/verts)) * radius
        k = k + 1
        local cos = math.cos(math.pi * 2 * (k/verts)) * radius
        local sin = math.sin(math.pi * 2 * (k/verts)) * radius

        local topLeft = pos + ang:Right() * lcos + ang:Forward() * lsin + ang:Up() * (tall + math.cos(RealTime() * (anim_wave or 4) + k) * (anim_height or 4))
        local topRight = pos + ang:Right() * cos + ang:Forward() * sin + ang:Up() * (tall + math.cos(RealTime() * (anim_wave or 4) + k + 1) * (anim_height or 4))

        local botLeft = pos + ang:Right() * lcos + ang:Forward() * lsin
        local botRight = pos + ang:Right() * cos + ang:Forward() * sin

        render.CullMode(1)
        render.DrawQuad( botRight,botLeft,topLeft, topRight , color or color_white )
        render.CullMode(0)
        render.DrawQuad( botRight,botLeft,topLeft, topRight , color or color_white )

    end

end
