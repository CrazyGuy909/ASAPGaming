AddCSLuaFile()
ENT.Type = "anim"
ENT.Category = "ASAP Gangs"
ENT.PrintName = "Computer"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Base = "base_anim"
ENT.Editable = true
ENT.Model = Model("models/zerochain/props_factory/zpf_lab.mdl")
ENT.CurrentScene = "Components"
ENT.EntitiesInfo = ENT.EntitiesInfo or {}

local maxHealth = CreateConVar("asap_gangs_computerhealth", 1000, FCVAR_ARCHIVE, "Max health of the gang computer", 100, 10000)

if SERVER then
    util.AddNetworkString("ASAP.Gangs:ReloadBase")
    util.AddNetworkString("ASAP.Gangs:RequestSteal")
    util.AddNetworkString("Gangs.RequestResources")
    util.AddNetworkString("ASAP.Gangs:SendEquipment")
end

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "Gang")
    self:NetworkVar("Bool", 0, "Healing")
    self:NetworkVar("Bool", 1, "Stealing")
    self:NetworkVar("Int", 0, "Money")
    self:NetworkVar("Float", 1, "StealingTime")

    self:NetworkVarNotify("Gang", function(s, old, new)
        if SERVER then
            s:BroadcastResources()

            return
        end
    end)
end

function ENT:Use(ply)
    if (not IsValid(ply) or not ply:IsPlayer()) then return end
    local playerGang = ply:GetGang()
    if (not playerGang) then return end  -- Ensure player has a gang
    if (playerGang ~= self:GetGang()) then return end
    if (ply:HasWeapon("swep_ganger")) then return end

    ply.GangComputer = self
    ply:Give("swep_ganger")
    ply:SelectWeapon("swep_ganger")
end

function ENT:BroadcastResources(ply)
    net.Start("GangsMachine.UpdateResource")
    net.WriteBool(true)
    net.WriteEntity(self)
    net.WriteUInt(table.Count(self.Resources or {}), 4)

    for k, v in pairs(self.Resources or {}) do
        net.WriteUInt(k, 4)
        net.WriteUInt(v, 32)
    end

    net.Send(ply or asapgangs.GetMembers(self:GetGang()))
end

ENT.ResourceAmount = 0
function ENT:AddResource(res, am, gather)
    if not self.Resources then
        self.Resources = {}
    end

    self.ResourceAmount = self.ResourceAmount + am
    table.sort(self.Deliveries or {}, function(a, b) return a:EntIndex() > b:EntIndex() end)
    local allocation = self.ResourceAmount

    for k, v in pairs(self.Deliveries or {}) do
        if (allocation <= 0) then break end

        if (allocation > 100) then
            v:SetDelivery(4)
            allocation = allocation - 100
        elseif (allocation > 0) then
            v:SetDelivery(math.ceil(allocation / 25))
            allocation = 0
            break
        end
    end

    self.Resources[res] = math.max((self.Resources[res] or 0) + am, 0)
    net.Start("GangsMachine.UpdateResource")
    net.WriteBool(false)
    net.WriteEntity(self)
    net.WriteUInt(res, 4)
    net.WriteUInt(self.Resources[res], 32)
    net.Send(asapgangs.GetMembers(self:GetGang()))
    if IsValid(gather) then
        DarkRP.notify(gather, 0, 5, "You " .. (am > 0 and "got " or "lost ") .. am .. " " .. asapgangs.War.Craftables[res].Name)
    end
end

function ENT:SpawnFunction(ply, tr, class)
    local ent = ents.Create(class)
    ent:SetPos(tr.HitPos)
    ent:SetAngles(Angle(0, ply:EyeAngles().y - 90, 0))
    ent:SetGang(ply:GetGang())
    ent:Spawn()
    ent:Activate()

    return ent
end

function ENT:Think()
    if CLIENT then return end

    if self:Health() <= maxHealth:GetInt() then
        local found = false
        for k, v in pairs(ents.FindInSphere(self:GetPos(), 512)) do
            if (not v:IsPlayer() or not v:GetGang() != self:GetGang() or not v:Alive()) then continue end
            self:SetHealth(math.min(self:Health() + 25, maxHealth:GetInt()))
            self:SetHealing(true)
            found = true
            break
        end

        if not found and self:GetHealing() then
            self:SetHealing(false)
        end
    end

    self:NextThink(CurTime() + 1)
    return true
end

-- Configs --
function ENT:Initialize()
    if SERVER then
        self:SetModel(self.Model)
        self:PhysicsInitStatic(SOLID_VPHYSICS)
        local tr = util.TraceLine({
            start = self:GetPos(),
            endpos = self:GetPos() - Vector(0, 0, 100),
            filter = self
        })
        self:SetUseType(SIMPLE_USE)
        self:SetPos(tr.HitPos)
        self:SetHealth(maxHealth:GetInt())
    else
		timer.Simple(5, function()
			if IsValid(LocalPlayer()) and IsValid(self) and LocalPlayer():GetGang() ~= "" and self:GetGang() ~= "" then
				net.Start("Gangs.RequestResources")
				net.WriteEntity(self)
				net.SendToServer()
			end
		end)
    end

    hook.Add("OnGangEntitySpawned", self, function(gang, ent)
        if (gang == self:GetGang()) then
            local class = ent:GetClass()
            self.EntitiesInfo[class] = self.EntitiesInfo[class] or {}
            table.insert(self.EntitiesInfo[class], ent)
            for k, v in pairs(self.EntitiesInfo) do
                if not IsValid(v) then
                    table.remove(self.EntitiesInfo, k)
                end
            end

            self:UpdateEntities()
        end
    end)
    self.DataLoaded = false
end

function ENT:OnTakeDamage(dmg)
    self:SetHealth(self:Health() - dmg:GetDamage())
    if (self:Health() <= 0) then
        self:EmitSound("ambient/explosions/explode_4.wav")

        hook.Run("OnGangComputerDestroyed", self, self:GetGang(), dmg)
        for k, v in pairs(asapgangs.GetPlayers(self:GetGang())) do
            v:ChatPrint("<color=red>The " .. self:GetGang() .. " gang's computer has been destroyed! Everything is lost!</color>")
        end

        local att = dmg:GetAttacker()
        if (IsValid(att) and att:IsPlayer() and IsValid(att.GangComputer)) then
            for k, v in pairs(self.Resources or {}) do
                att.GangComputer:AddResource(k, v)
            end
            att:ChatPrint("<color=green>You have stolen all the resources from the " .. self:GetGang() .. " gang's computer!</color>")
        end
        for k, v in pairs(ents.FindByClass("sent_gang_*")) do
            if (not v.GetGang) then continue end
            if (v:GetGang() == self:GetGang()) then
                SafeRemoveEntity(v)
            end
        end
        self:Remove()
    end
end

function ENT:UpdateEntities()
    net.Start("ASAP.Gangs:SendEquipment")
    net.WriteUInt(table.Count(self.EntitiesInfo), 4)
    for k, v in pairs(self.EntitiesInfo) do
        net.WriteString(k)
        net.WriteUInt(table.Count(v), 4)
    end
    net.Send(asapgangs.GetMembers(self:GetGang()))
end

net.Receive("Gangs.RequestResources", function(l, ply)
    local cpu = net.ReadEntity()

    if (cpu:GetGang() == ply:GetGang()) then
        cpu:BroadcastResources(ply)
    end
end)

if SERVER then return end
local cursor = Material("asap_printers/cursor.png")
local pressedE = false
ENT.mx = 0
ENT.my = 0

function ENT:PressAt(mx, my)
end

function ENT:HandleInput(dist, origin, ang)
    if (dist > 5500) then return 200, 200 end
    local ray = util.IntersectRayWithPlane(EyePos(), LocalPlayer():GetAimVector() * 1024, origin, ang:Up())
    if not ray then return end
    local mousePos = self:WorldToLocal(ray)
    if (mousePos.x < 0 or mousePos.x > 35) then return end
    if (mousePos.z < 50 or mousePos.z > 70) then return end
    local fx = mousePos.x / 35
    local fy = 1 - (mousePos.z - 50) / 20
    local mx, my = 420 * fx - 8, 246 * fy + 16
    surface.SetMaterial(cursor)
    surface.SetDrawColor(color_white)
    surface.DrawTexturedRectRotated(mx, my, 24, 24, 0)

    return mx, my
end

local bad = Material("asap_printers/noaccess.png")
local lock = Material("asap_printers/lock.png")

function ENT:DisplayNone()
    local w, h = 400, 272
    surface.SetMaterial(bad)
    surface.SetDrawColor(255, 0, 0, 25)
    surface.DrawTexturedRectRotated(w / 1.3, h / 1.7, w / 1.3, w / 1.3, 0)
    surface.SetDrawColor(36, 36, 36)
    surface.DrawRect(0, 0, w, 48)
    draw.SimpleText("Gang's Computer", "Gangs.Medium", 8, 8, color_white)
    draw.SimpleText("This base is not owned.", "Gangs.Small", 32, 76, Color(255, 255, 255, 150))
    draw.SimpleText("Claim it in the main door!", "Gangs.Small", 32, 104, Color(255, 255, 255, 150))
end

function ENT:NotAllowed()
end

local arrow = Material("asap_printers/back.png")

function ENT:DrawIcon(text, mat, x, y, w, h, clb, ang)
    local isHovered = self.mx > x and self.mx < x + w and self.my > y and self.my < y + h + 52
    surface.SetMaterial(mat)
    surface.SetDrawColor(255, 255, 255, isHovered and 255 or 100)
    surface.DrawTexturedRectRotated(x + w / 2, y + h / 2, w, h, ang or 0)
    draw.SimpleText(text, "Gangs.Small", x + w / 2, y + h + 24, Color(255, 255, 255, isHovered and 255 or 100), 1, 1)

    if isHovered and not pressedE and input.IsKeyDown(KEY_E) then
        clb()
        pressedE = true
    elseif not input.IsKeyDown(KEY_E) then
        pressedE = false
    end
end

local progress = surface.GetTextureID("ui/gangs/computer/circle")
local circles = include("xeninui/libs/circles.lua")
ENT.Circle = nil

function ENT:DisplayHome()
    self:DrawIcon("Components", arrow, 400 - 128, 78, 96, 96, function()
        self.CurrentScene = "Components"
    end, -90)

    if not self.Circle then end
    self.Circle = circles.New(CIRCLE_FILLED, 82, 92, 148, 4)
    local prg = self:Health() / maxHealth:GetInt()
    self.Circle:SetStartAngle(-90)
    self.Circle:SetEndAngle(Lerp(prg, 0, 360) - 90)
    surface.SetTexture(progress)
    surface.SetDrawColor(Color(16, 16, 16))
    surface.DrawTexturedRectRotated(92, 148, 82 * 2, 82 * 2, 0)
    surface.SetDrawColor(color_white)
    self.Circle()
    draw.SimpleText(math.Round(prg * 100) .. "%", "Gangs.Huge", 92, 148, Color(255, 255, 255, 255), 1, 1)
end

local icons = {
    ["Delivery Pallet"] = {surface.GetTextureID("ui/gangs/computer/delivery"), Color(255, 144, 0), "sent_gang_delivery", 1},
    ["Crafting Table"] = {surface.GetTextureID("ui/gangs/computer/crafting"), Color(0, 186, 255), "sent_gang_manufacture_table", 2},
    ["Mining Portal"] = {surface.GetTextureID("ui/gangs/computer/portal"), Color(198, 0, 255), "sent_gang_portal", 1},
    ["Weed Pot"] = {surface.GetTextureID("ui/gangs/computer/pot"), Color(36, 255, 0), "sent_gang_pot", 4},
}

local deactive = Color(255, 255, 255, 100)

ENT.EntitiesList = {}
ENT.NextCheck = 0
function ENT:DisplayUpgrades()
    local i = 1

    if self.NextCheck < CurTime() then
        self.NextCheck = CurTime() + 1
        self.EntitiesInfo = {}
        for k, v in pairs(ents.FindByClass("sent_gang_*")) do
            if not v.GetGang then continue end
            if v:GetGang() == self:GetGang() then
                self.EntitiesInfo[v.PrintName] = (self.EntitiesInfo[v.PrintName] or 0) + 1
            end
        end
    end
    for k, v in SortedPairs(icons) do
        surface.SetTexture(v[1])
        local x = ((i - 1) % 3) * 128 + 32
        local y = math.ceil(i / 3) * 88 - 30
        local hovered = self.mx > x - 8 and self.mx < x + 96 and self.my > y and self.my < y + 96

        surface.SetDrawColor(v[2])

        surface.DrawTexturedRect(x - 16, y, 64, 64)
        draw.SimpleText(k, "XeninUI.TextEntry", x + 32, y + 62, hovered and color_white or deactive, 1)

        draw.SimpleText(self.EntitiesInfo[k] or 0, "Gangs.Medium", x + 50, y + 8, hovered and color_white or deactive)
        surface.DrawLine(x + 58, y + 42, x + 78, y + 16)
        draw.SimpleText(v[4], "Gangs.Medium", x + 82, y + 28, hovered and color_white or deactive, 2)

        i = i + 1
    end

    self:DrawIcon("Components", arrow, 400 - 104, 148, 48, 48, function()
        self.CurrentScene = "Home"
    end, 0)
end

local nextProtocol = 0
local hackstring = ""

function ENT:DisplayHacking(name)
    draw.SimpleText("This terminal has been compromised", "Arena.Small", 8, 56, color_white, 0, 0)
    draw.SimpleText("Reboot progress:", "Arena.Small", 8, 84, Color(255, 255, 255, 32), 0, 0)
    draw.RoundedBox(2, 8, 108, 400 - 16, 32, Color(16, 16, 16))

    if (nextProtocol < RealTime()) then
        nextProtocol = RealTime() + math.Rand(.2, .6)
        hackstring = ""

        for k = -4, 16 do
            hackstring = (math.random(1, 3) == 1 and " " or "") .. hackstring .. string.char(math.random(1, 128))
        end
    end

    surface.SetDrawColor(100, 255, 100)
    surface.DrawRect(0, 196, 400, 64)
    draw.SimpleText(hackstring, "Arena.Medium", -96, 200, Color(20, 50, 20), 0, 0)
    local remaining = math.Clamp(1 - ((self:GetStealingTime() - CurTime()) / asapgangs.War.CaptureTime), 0, 1)
    draw.SimpleText(math.Round(remaining * 100) .. "%", "Arena.Small", 392, 84, Color(235, 235, 235), 2, 0)
    draw.RoundedBox(2, 8, 108, (400 - 16) * remaining, 32, Color(232, 155, 33))

    if (remaining == 1) then
        self.CurrentScene = "Home"
    end
end

local hack = Material("ui/gangs/computer/hack.png")

function ENT:DisplayScene(mx, my)
    local w, h = 400, 272
    surface.SetDrawColor(36, 36, 36)
    surface.DrawRect(0, 0, w, 48)
    draw.SimpleText("Gang's Computer", "Gangs.Medium", 8, 8, color_white)
    local cpuGang = self:GetGang()

    if (cpuGang == LocalPlayer():GetGang()) then
        if (self.CurrentScene == "Home") then
            self:DisplayHome()
        elseif (self.CurrentScene == "Components") then
            self:DisplayUpgrades()
        end
    else
        if (not asapgangs.gangList[cpuGang]) then
            asapgangs.gangList[cpuGang] = {
                Name = "LOADING...",
            }

            net.Start("ASAP.Gangs:RequestName")
            net.WriteString(cpuGang)
            net.SendToServer()
        end

        local name = asapgangs.gangList[cpuGang].Name

        if (self.CurrentScene == "Hack" or self:GetStealing()) then
            self:DisplayHacking(name)

            return
        end

        draw.SimpleText("This computer belongs to:", "Gangs.Small", 32, 76, Color(255, 255, 255, 150))
        draw.SimpleText(name, "Gangs.Small", 32, 104, Color(255, 255, 255, 150))
        surface.SetMaterial(lock)
        surface.SetDrawColor(255, 0, 0, 25)
        surface.DrawTexturedRectRotated(w / 1.2, h / 1.7, w / 2, w / 2, 0)

        self:DrawIcon("Hack", hack, 148, 118, 72, 72, function()
            self.CurrentScene = "Hack"
            net.Start("ASAP.Gangs:RequestSteal")
            net.WriteEntity(self)
            net.SendToServer()
        end, 0)
    end
end

local circle = Material("asap/armors/fire_ring")

function ENT:Draw()
    if (halo.RenderedEntity() == self) then return end
    self:DrawModel()
    if (self:GetHealing()) then
        render.SuppressEngineLighting(true)
        render.SetColorModulation(1, 3, 1)
        render.SetBlend(0.5)
        self:DrawModel()
        render.SetBlend(1)
        render.SetColorModulation(1, 1, 1)
        render.SuppressEngineLighting(false)
    end
    local origin = self:GetPos() + self:GetUp() * 70 + self:GetForward() * 2 + self:GetRight() * -1.5
    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Forward(), 105)
    local dist = EyePos():DistToSqr(origin)
    if dist > 80000 then return end
    cam.Start3D2D(origin, ang, .0825)
    surface.SetDrawColor(26, 26, 26)
    surface.DrawRect(0, 0, 400, 272)
    render.SetStencilWriteMask(0xFF)
    render.SetStencilTestMask(0xFF)
    render.SetStencilReferenceValue(0)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilPassOperation(STENCIL_KEEP)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilReferenceValue(1)
    render.SetStencilCompareFunction(STENCIL_NEVER)
    render.SetStencilFailOperation(STENCIL_REPLACE)
    surface.DrawRect(0, 0, 400, 272)
    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.SetStencilFailOperation(STENCIL_KEEP)

    if (self:GetGang()) then
        self:DisplayScene()
    else
        self:DisplayNone()
    end

    local mx, my = self:HandleInput(dist, origin, ang)

    if mx then
        self.mx = mx
        self.my = my
    end

    render.SetStencilEnable(false)
    render.ClearStencilBufferRectangle(0, 0, 400, 272, 0)
    cam.End3D2D()

    if (self:GetStealing()) then
        render.SetMaterial(circle)
        local siz = (RealTime() % 2) * 200
        render.DrawQuadEasy(self:GetPos(), Vector(0, 0, 1), siz, siz, Color(255, 150, 50, 255 * (1 - siz / 400)), 0)
    end
end

net.Receive("ASAP.Gangs:ReloadBase", function()
    local ent = net.ReadEntity()
    local base = net.ReadString()
    ent:LoadBaseData(base)
end)

net.Receive("ASAP.Gangs:SendEquipment", function()
    local ent = net.ReadEntity()
    local num = net.ReadUInt(4)

    ent.EntitiesInfo = {}
    for k = 1, num do
        ent.EntitiesInfo[net.ReadString()] = net.ReadUInt(8)
    end
end)

hook.Add("playerBoughtCustomEntity", "return entities", function(ply, ent_table, ent, price)
    if (ent:GetClass() == "sent_gang_computer" or ent:GetClass() == "asap_driller") then
        SafeRemoveEntity(ent)
        ply:addMoney(price)
        ply:ChatPrint("Sorry, this entity it's not available, but here's your money")
    end
end)