AddCSLuaFile()
ENT.Type = "anim"
ENT.Category = "ASAP Gangs"
ENT.PrintName = "Crafting Table"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Base = "base_anim"
ENT.Editable = true
ENT.Model = Model("models/zerochain/props_factory/zpf_workbench.mdl")
local w, h = 256, 228

if SERVER then
    include("gang_include/sv_mantable.lua")
    AddCSLuaFile("gang_include/cl_mantable.lua")
else
    include("gang_include/cl_mantable.lua")
end

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "Gang")
    self:NetworkVar("Int", 0, "Pieces")
    self.Ingredients = {}
end

function ENT:SpawnFunction(ply, tr, class)
    local ent = ents.Create(class)
    ent:SetPos(tr.HitPos + tr.HitNormal * 3)
    ent:SetAngles(Angle(0, 0, 0))
    ent:Spawn()
    ent:Activate()

    return ent
end

-- Configs --
function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInitStatic(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
end

if SERVER then return end
local gap = (w - 56 - 20) / 8
local sw, sh = 400, 210
local circle = surface.GetTextureID("holo/asa_hud_frame")
local arrow = Material("asap_printers/back.png")
ENT.RebuildView = true

function ENT:OnRemove()
    if IsValid(self.Preview) then
        self.Preview:Remove()
    end
end

ENT.Push = 0
ENT.Index = 1
ENT.GenerateIcons = true

function ENT:RebuildPreview()
    if IsValid(self.Preview) then
        self.Preview:Remove()
    end

    local data = asapgangs.War.Craftables[self.Index or 1]

    if (not data.Info) then
        data.Info = {
            Scale = 1,
            Angle = Angle(0, 0, 0),
            Origin = Vector(0, 0, 58)
        }
    end

    local ent = ClientsideModel(data.Model)
    local mx = Matrix()
    mx:SetScale(Vector(data.Info.Scale, data.Info.Scale, data.Info.Scale))
    ent:EnableMatrix("RenderMultiply", mx)
    ent:SetLegacyTransform(true)
    ent:SetParent(self)
    ent:SetLocalPos(data.Info.Origin)
    ent:SetLocalAngles(data.Info.Angle)
    ent:SetNoDraw(true)
    ent:SetRenderFX(kRenderFxHologram)
    self.OGOrigin = data.Info.Origin
    self.Preview = ent

    if not self.Icons then
        self.Icons = {}
    end
end

function ENT:GenerateRecipe()
    if (self.Icons) then
        for k, v in pairs(self.Icons) do
            v:Remove()
        end
    end

    self.Icons = {}

    for k, v in pairs(asapgangs.War.Craftables) do
        local icon = vgui.Create("SpawnIcon")
        icon:SetSize(32, 32)
        icon:SetModel(v.Model)
        icon:SetPaintedManually(true)
        self.Icons[k] = icon
    end
end

local keyDown = false
local white = Material("models/shiny")
local dot = surface.GetTextureID("sgm/playercircle")

local colors = {
    [0] = Color(100, 100, 100),
    [1] = Color(235, 235, 235),
    [2] = Color(108, 200, 238),
    [3] = Color(126, 238, 108),
    [4] = Color(214, 77, 77),
    [5] = Color(219, 61, 229)
}

surface.CreateFont("XeninUI.Craft", {
    font = "Montserrat",
    size = 14
})

ENT.Open = 0
function ENT:Draw3DMenu()
    if (self.GenerateIcons) then
        self.GenerateIcons = false
        self:GenerateRecipe()
    end

    local scale = self.Open / 100
    local pos = self:GetPos() + self:GetUp() * 66 + self:GetForward() * -9 + self:GetRight() * -6
    local ang = self:GetAngles()
    --ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 90)
    cam.Start3D2D(pos, ang, .075)
    surface.SetAlphaMultiplier(scale * 255)
    draw.RoundedBox(16, 0, 0, sw, sh, Color(0, 0, 0, 150 * scale))
    surface.SetMaterial(arrow)
    local hover = 0
    local ray = util.IntersectRayWithPlane(EyePos(), LocalPlayer():GetAimVector(), pos, -ang:Up())
    if ray then
        ray = self:WorldToLocal(ray)
    end
    if (ray and ray.x < 20 and ray.x > -7 and ray.z > 50 and ray.z < 60) then
        if (ray.x <= 0) then
            hover = -1
        elseif (ray.x > 12) then
            hover = 1
        end
    else
        hover = 0
    end


    if (not keyDown and input.IsKeyDown(KEY_E)) then
        self.Index = (self.Index or 1) + hover

        if (self.Index > 9) then
            self.Index = 1
        elseif (self.Index < 1) then
            self.Index = 9
        end

        keyDown = true

        timer.Simple(.1, function()
            surface.PlaySound("weapons/symmironin.wav")
        end)

        self.RebuildView = true
        self.Push = -hover
    elseif (keyDown and not input.IsKeyDown(KEY_E)) then
        keyDown = false
    end

    local data = asapgangs.War.Craftables[self.Index or 1]
    local name = data.Name
    surface.SetDrawColor(255, 255, 255, hover == -1 and 255 or 100 * scale)
    surface.DrawTexturedRectRotated(sh / 3, sh / 2, sh / 3, sh / 3, 0)
    surface.SetDrawColor(255, 255, 255, hover == 1 and 255 or 100 * scale)
    surface.DrawTexturedRectRotated(sw - sh / 3, sh / 2, sh / 3, sh / 3, 180)
    draw.SimpleText(name, "Gangs.Medium", sw / 2, sh - 32, ColorAlpha(colors[data.Difficulty], scale * 255 * (1 - math.abs(self.Push))), 1, 1)
    local max = table.Count(data.Needs or {})
    if (max > 0) then
        draw.RoundedBox(4, 24, 0, max * 34 + 8, 48, Color(255, 255, 255, 7))
        local i = 0

        if not IsValid(LocalPlayer().GangComputer) then
            for k, v in pairs(ents.FindByClass("sent_gang_computer")) do
                if (v:GetGang() == LocalPlayer():GetGang()) then
                    LocalPlayer().GangComputer = v
                    break
                end
            end
            return
        end

        if not LocalPlayer().GangComputer.Resources then
            LocalPlayer().GangComputer.Resources = {}
        end

        for k, v in pairs(data.Needs or {}) do
            if (IsValid(self.Icons[k])) then
                self.Icons[k]:SetPos(28 + 34 * i, 0)
                self.Icons[k]:PaintManual()
            end
            local own = LocalPlayer().GangComputer.Resources[k] or 0
            draw.SimpleText(own .. "/" .. v, "XeninUI.Craft", 28 + 34 * i + 16, 38, (own >= v) and Color(150, 255, 50) or Color(255, 0, 0, 200), 1, 1)
            i = i + 1
        end
    end

    cam.End3D2D()
    surface.SetAlphaMultiplier(255)
    if ray and IsValid(self.Preview) then
        if (self.Push ~= 0) then
            self.Push = self.Push + (self.Push > 0 and -1 or 1) * FrameTime() * 4

            if (math.abs(self.Push) < .01) then
                self.Push = 0
            end
        end

        self.Preview:SetLocalPos(self.OGOrigin + Vector(self.Push * 8, 0, 0))
        render.SuppressEngineLighting(true)
        render.SetBlend(scale * .1 * (1 - math.abs(self.Push)))
        render.MaterialOverride(white)
        render.SetColorModulation(5, 6, 8)
        self.Preview:DrawModel()
        render.MaterialOverride(nil)
        render.SetBlend(scale * .4 * (1 - math.abs(self.Push)))
        self.Preview:DrawModel()
        render.SetColorModulation(1, 1, 1)
        render.SetBlend(1)
        render.SuppressEngineLighting(false)
    end

    if (self.RebuildView) then
        self.RebuildView = false
        self:RebuildPreview()
    end
end

function ENT:Draw()
    self:DrawModel()
    if self:GetGang() == "" then return end
    if self:GetGang() ~= LocalPlayer():GetGang() then return end

    if (self.Open < 100 and LocalPlayer():GetEyeTrace().Entity == self) then
        self.Open = Lerp(FrameTime() * 10, self.Open, 105)
    elseif (self.Open > 0 and LocalPlayer():GetEyeTrace().Entity != self) then
        self.Open = Lerp(FrameTime() * 10, self.Open, -1)
    end

    if self.Open <= 0 then return end

    local pos = self:GetPos() + self:GetUp() * 35 + self:GetForward() * 4 + self:GetRight() * -8.5
    local ang = self:GetAngles()
    local scale = self.Open / 100
    cam.Start3D2D(pos, ang, .075)
    surface.SetDrawColor(66, 157, 231, scale * 255)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(255, 255, 255, 50 * scale)
    surface.DrawRect(16, 16, w - 32, 8)
    surface.DrawRect(16, 24, 8, h - 32 - 16)
    surface.DrawRect(w - 24, 24, 8, h - 32 - 16)
    surface.DrawRect(16, h - 16 - 8, w - 32, 8)

    for k = 1, 8 do
        surface.DrawRect(24 + k * gap + 2, 24, 2, w - 56 - 20)
        surface.DrawRect(24, 24 + k * gap, w - 48, 2)
    end

    local ray = util.IntersectRayWithPlane(EyePos(), LocalPlayer():GetAimVector() * 300, pos, ang:Up())
    if (ray) then
        ray = self:WorldToLocal(ray)
    end
    if (ray and ray.x > 3 and ray.x < 23 and ray.y < 8 and ray.y > -8) then
        surface.SetTexture(circle)
        local pulse = 148 + math.cos(RealTime() * 2) * 16
        surface.DrawTexturedRectRotated(w / 2, h / 2, pulse, pulse, RealTime() * 64)
        draw.SimpleText("Fabricate", "Arena.Medium", w / 2, h / 2, Color(255, 255, 255, scale * 255), 1, 1)

        if (not keyDown and input.IsKeyDown(KEY_E) and not vgui.CursorVisible()) then
            if IsValid(self.Minigame) then
                self.Minigame:Remove()
            end

            if not self.Resources then
                self.Resources = {}
            end

            local data = asapgangs.War.Craftables[self.Index or 1]
            local canCraft = true
            local missing


            if not data.Needs then
                Derma_Message("You don't craft weed, harvest it instead.", "Go away!")
                return
            end
            for k, v in pairs(data.Needs) do
                if not IsValid(LocalPlayer().GangComputer) then
                    for k, v in pairs(ents.FindByClass("sent_gang_computer")) do
                        if (v:GetGang() == LocalPlayer():GetGang()) then
                            LocalPlayer().GangComputer = v
                            break
                        end
                    end
                end
                if (IsValid(LocalPlayer().GangComputer) and (LocalPlayer().GangComputer.Resources[k] or 0) < v) then
                    canCraft = false
                    missing = k
                    break
                end
            end
            keyDown = true
            if (not canCraft) then
                Derma_Message("You don't have enough " .. asapgangs.War.Craftables[missing].Name .. " - " .. (LocalPlayer().GangComputer.Resources[missing] or 0) .. "/" .. data.Needs[missing], "Error")
                return
            end
            self.Minigame = vgui.Create("Manufacture:Minigame" .. string.char(data.Minigame + 64))
            self.Minigame:RequestData(self, self.Index or 1)
        elseif (keyDown and not input.IsKeyDown(KEY_E)) then
            keyDown = false
        end
    else
        draw.SimpleText("(E)", "Arena.Huge", w / 2, h / 2, Color(255, 255, 255, scale * 255), 1, 1)
    end

    cam.End3D2D()
    self:Draw3DMenu()
end