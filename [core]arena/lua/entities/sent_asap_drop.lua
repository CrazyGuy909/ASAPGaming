AddCSLuaFile()
ENT.Type = "anim"
ENT.Category = "Galaxium Arena"
ENT.PrintName = "Arena Drop"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.AutomaticFrameAdvance = true
ENT.Base = "base_anim"
local openTime = 5

if SERVER then
    util.AddNetworkString("ASAP.Unbox.OpenCase")
end

function ENT:SetupDataTables()
    self:NetworkVar("Vector", 0, "StartPos")
    self:NetworkVar("Float", 0, "FallProgress")
    self:NetworkVar("Bool", 0, "ShowProps")
    self:SetFallProgress(0)
    self:SetShowProps(false)
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
    self:SetModel("models/asapgaming/crates/crate_1_big.mdl")
    self:SetModelScale(1)
    self:SetSolid(SOLID_VPHYSICS)
    self.FallZone = self:GetPos()

    if (SERVER) then
        self:SetUseType(SIMPLE_USE)
        local tr = util.QuickTrace(self:GetPos(), Vector(0, 0, 9999) + Angle(0, math.random(0, 360), 0):Forward() * 4192, self)
        self:SetStartPos(tr.HitPos)
        self:SetPos(tr.HitPos)
        self:SetAngles((self:GetPos() - self.FallZone):Angle() + Angle(45, 0, 90))
        net.Start("ASAP.Arena.CrateInfo")
        net.WriteBool(true)
        net.Broadcast()

        timer.Simple(15, function()
            if not IsValid(self) then
                return
            end
            self:SetPos(self.FallZone)
        end)
    end

    self:SetFallProgress(0)

    timer.Simple(0.5, function()
        self.Smoke = EffectData()
        self.Smoke:SetEntity(self)
        util.Effect("arena_cratesmoke", self.Smoke, true, true)
    end)
end

ENT.Opening = {}

function ENT:Use(ply)
    if (ply:GetActiveWeapon():GetClass() ~= "csgo_bayonet") then
        ply:PrintMessage(HUD_PRINTTALK, "You can only unlock with the knife!")

        return
    end

    self.Opening[ply] = openTime
    ply._openingCrate = self
    net.Start("ASAP.Unbox.OpenCase")
    net.WriteBool(true)
    net.Send(ply)
end

hook.Add("KeyRelease", "ASAP.Arena.Unboxing", function(ply, key)
    if SERVER and key == IN_USE and IsValid(ply._openingCrate) then
        ply._openingCrate[ply] = nil
        ply._openingCrate = nil
        net.Start("ASAP.Unbox.OpenCase")
        net.WriteBool(false)
        net.Send(ply)
    end
end)

sound.Add({
    name = "crate_impact",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = 500,
    pitch = {95, 110},
    sound = {"phx/explode00.wav", "phx/explode01.wav", "phx/explode02.wav"}
})

sound.Add({
    name = "create_rotate",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = 500,
    pitch = {95, 110},
    sound = "ambient/machines/thumper_dust.wav"
})

sound.Add({
    name = "crate_abandon",
    channel = CHAN_AUTO,
    volume = 1.0,
    level = 500,
    pitch = {95, 110},
    sound = "ambient/machines/teleport3.wav"
})

ENT.Bumped = false
ENT.Delivered = false
ENT.ReleaseState = 0

local models = {
    {
        Model = "models/props_wasteland/rockgranite02b.mdl",
        Pos = Vector(-110, 50, 130),
        Ang = Angle(0, 10, 60)
    },
    {
        Model = "models/props_wasteland/rockgranite02a.mdl",
        Pos = Vector(-110, 50, 80),
        Ang = Angle(20, -35, 0),
        Scale = 1.2
    },
    {
        Model = "models/props_wasteland/rockgranite02a.mdl",
        Pos = Vector(-110, 60, 30),
        Ang = Angle(20, 35, -90),
        Scale = 1.2
    },
    {
        Model = "models/props_wasteland/rockcliff01c.mdl",
        Pos = Vector(-60, 40, 200),
        Ang = Angle(80, -90, -10),
        Scale = 1.3
    },
    {
        Model = "models/props_wasteland/rockcliff01c.mdl",
        Pos = Vector(-60, 40, -45),
        Ang = Angle(110, -90, -10),
        Scale = 1.3
    },
    {
        Model = "models/props_debris/concrete_debris128pile001b.mdl",
        Pos = Vector(-120, -80, 10),
        Ang = Angle(0, 0, 0),
        World = true,
        Scale = 3
    }
}

ENT.Rocks = {}

function ENT:Think()
    if (SERVER and self:GetFallProgress() < 100 and self.ReleaseState == 0) then
        self:SetFallProgress(self:GetFallProgress() + 1)
        local progress = LerpVector(self:GetFallProgress() / 100, self:GetStartPos(), self.FallZone)
        self:SetPos(progress)
        self:NextThink(CurTime())

        return true
    elseif (SERVER and not self.Bumped and self.ReleaseState == 0) then
        self.Bumped = true
        self:SetShowProps(true)
        self:EmitSound("crate_impact")
        util.ScreenShake(self:GetPos(), 10, 10, 2, 1024 * 16)

        for k, v in pairs(ents.FindInSphere(self:GetPos(), 1024)) do
            if (v:IsPlayer()) then
                --v:SetPos(v:GetPos() + Vector(0, 0, 2))
                v:SetLocalVelocity(Vector(0, 0, 1024) + (v:GetPos() - self:GetPos()):GetNormalized() * 1500)
            end
        end

        for k, v in pairs(self.Rocks or {}) do
            if IsValid(v) then
                v:Remove()
            end
        end

        if SERVER then
            self:SetAngles(Angle(-22 - 180, -33, 90))
            self:SetMoveType(MOVETYPE_NONE)
        end

        for k, v in pairs(models) do
            local ent = ents.Create("prop_physics")
            ent:SetModel(v.Model)
            ent.Scale = v.Scale or 1

            if (v.World) then
                ent:SetAngles(v.Ang)
                ent:SetPos(self:GetPos() + v.Pos)
            else
                ent:SetParent(self)
                ent:SetLocalAngles(v.Ang)
                ent:SetLocalPos(v.Pos)
                ent:SetParent(nil)
            end

            ent:Spawn()
            ent:Activate()
            ent:SetModelScale(ent.Scale, 0)
            ent:SetMoveType(MOVETYPE_NONE)
            table.insert(self.Rocks, ent)
        end
    elseif (self.Bumped and not self.Delivered and self.ReleaseState == 0) then
        for k, v in pairs(self.Opening) do
            self.Opening[k] = self.Opening[k] - FrameTime()

            if (self.Opening[k] <= 0) then
                self.Delivered = k
                self:BringReward(k)
            end

            local tr = util.QuickTrace(k:GetShootPos(), k:GetAimVector() * 128, k)

            if (not k:Alive() or tr.Entity ~= self or not k:KeyDown(IN_USE)) then
                self.Opening[k] = nil

                if (k._openingCrate) then
                    k._openingCrate = nil
                end

                net.Start("ASAP.Unbox.OpenCase")
                net.WriteBool(false)
                net.Send(k)
            end
        end

        self:NextThink(CurTime())

        return true
    elseif (self.ReleaseState == 1) then
        self:SetFallProgress(self:GetFallProgress() + 2)
        self:SetAngles(LerpAngle(self:GetFallProgress() / 100, self.OldAngle, Angle(-90, self.OldAngle.y, 0)))

        if (self:GetFallProgress() >= 100) then
            self:SetShowProps(false)
            self.ReleaseState = 2
            self:SetFallProgress(0)
            self:EmitSound("crate_abandon")
            local tr = util.QuickTrace(self:GetPos(), Vector(0, 0, 999999), self)
            self.FallZone = tr.HitPos
            self:SetStartPos(self:GetPos())
        end
    elseif (self.ReleaseState == 2) then
        self:SetFallProgress(self:GetFallProgress() + 1)
        self:SetPos(LerpVector(math.Clamp(self:GetFallProgress() / 100, 0, 1), self:GetStartPos(), self.FallZone))

        if (self:GetFallProgress() >= 100) then
            self:Remove()
        end
    end

    if (self.ReleaseState > 0) then
        self:NextThink(CurTime())

        return true
    end
end

if SERVER then
    util.AddNetworkString("Arena.GotCrate")
    util.AddNetworkString("Arena.WonCaseRound")
else
    net.Receive("Arena.GotCrate", function()
        local ply = net.ReadEntity()
        if not IsValid(ply) or not ply.Nick then return end
        chat.AddText(Color(255, 210, 0), "[Arena] ", color_white, ply:Nick(), " earned the '<rainbow=2>Royal Crate</rainbow>'")
    end)

    net.Receive("Arena.WonCaseRound", function()
        local ply = net.ReadEntity()
        local crate = net.ReadString()
        if not IsValid(ply) or not ply.Nick then return end
        chat.AddText(Color(255, 210, 0), "[Arena] ", color_white, ply:Nick(), " earned the '<rainbow=2>" .. crate .. "</rainbow>'")
    end)
end

function ENT:BringReward(ply)
    asapArena.ActiveGamemode:EndRound(ply, self)
end

function ENT:OnRemove()
    if self.Rocks then
        for k, v in pairs(self.Rocks) do
            if IsValid(v) then
                v:Remove()
            end
        end
    end
end

ENT.ReloadModels = false

function ENT:Draw()
    self:DrawModel()
    self:SetColor(Color(252, 150, 0))
end

local time = -1

local function showBox()
    if (time <= 0) then return end
    local w, h = 350, 48
    local x, y = ScrW() / 2 - w / 2, ScrH() / 2 + 32 + h
    draw.RoundedBox(8, x, y, w, h, Color(26, 26, 26))
    draw.RoundedBox(8, x + 4, y + h - 20, w - 8, 16, Color(16, 16, 16))
    draw.RoundedBox(8, x + 4, y + h - 20, (1 - time / openTime) * (w - 8), 16, Color(200, 200, 200))
    draw.SimpleText("Unboxing in " .. math.ceil(time) .. " seconds...", "XeninUI.TextEntry", x + 4, y + 6, Color(255, 255, 255, 150))
    time = time - FrameTime()

    if (time <= 0) then
        hook.Remove("HUDPaint", "ASAP.Unbox")
        hook.Remove("RenderScreenspaceEffects", "ASAP.Unbox")
    end
end

local function unboxPP()
    local tab = {
        ["$pp_colour_addr"] = (1 - time / openTime) / 2,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = -(1 - time / openTime) / 3,
        ["$pp_colour_contrast"] = 1 + (1 - time / openTime) / 2,
        ["$pp_colour_colour"] = 1 + (1 - time / openTime) / 2,
        ["$pp_colour_mulr"] = (1 - time / openTime) / 2,
        ["$pp_colour_mulg"] = 0,
        ["$pp_colour_mulb"] = 0
    }

    DrawColorModify(tab)
end

net.Receive("ASAP.Unbox.OpenCase", function()
    local b = net.ReadBool()

    if (b) then
        time = openTime
        hook.Add("HUDPaint", "ASAP.Unbox", showBox)
        hook.Add("RenderScreenspaceEffects", "ASAP.Unbox", unboxPP)
        surface.PlaySound("ambient/alarms/klaxon1.wav")

        timer.Create("Unbox.Alarm", 1, math.ceil(openTime), function()
            surface.PlaySound("ambient/alarms/klaxon1.wav")
        end)
    else
        timer.Remove("Unbox.Alarm")
        hook.Remove("HUDPaint", "ASAP.Unbox")
        hook.Remove("RenderScreenspaceEffects", "ASAP.Unbox")
    end
end)