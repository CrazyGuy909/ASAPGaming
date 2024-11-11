game.AddParticles("particles/gb5_fireball.pcf")

concommand.Add("arena_load", function()
    http.Fetch(asapMarket.API .. "/arena?sid=" .. LocalPlayer():SteamID64(), function(body)
        local data = util.JSONToTable(body)
        local ply = LocalPlayer()
        ply._arenaData = util.JSONToTable(data.Data or "[]")

        if LocalPlayer()._challengeCache then
            ply._arenaData.Challenges = table.Copy(LocalPlayer()._challengeCache)
            LocalPlayer()._challengeCache = nil
        end

        ply._arenaEquipment = util.JSONToTable(data.Equipment or "[]")
        net.Start("ASAP.Arena.VoiceChannel")
        net.WriteBool(GetConVar("asap_enablevoicearena"):GetBool())
        net.SendToServer()
    end)
end)

hook.Add("InitPostEntity", "Arena.SendData", function()
    if IsValid(LocalPlayer()) then
    else --RunConsoleCommand("arena_load")
        timer.Simple(5, function() end) --RunConsoleCommand("arena_load")
    end
end)

net.Receive("ASAP.UpdateStats", function()
    LocalPlayer()._arenaData = net.ReadTable() or {}
end)

net.Receive("ASAP.Arena:SyncNWVars", function()
    LocalPlayer():SetNW2Int("GGLevel", 1)
    LocalPlayer():SetNWBool("InArena", true)
end)

local function initializeData()
    if IsValid(LocalPlayer()) then
        if ASAP_GOBBLEGUMS then
            ASAP_GOBBLEGUMS.cooldowns = {}
        end

        if not asapArena.ActiveGamemode then
            asapArena:SetGamemode(GetGlobalString("ActiveGamemode", "deathmatch"))
        end

        if not asapArena.ActiveGamemode.DisableSelect then
            timer.Simple((LocalPlayer():Ping() / 1000) * 2, function()
                ARENA_LOADOUT = vgui.Create("asap.Arena.Loadout")
            end)
        end

        net.Start("ASAP.Arena.VoiceChannel")
        net.WriteBool(GetConVar("asap_enablevoicearena"):GetBool())
        net.SendToServer()
        asapArena:_initModes()
    else
        timer.Simple(1, function()
            initializeData(data)
        end)
    end
end

net.Receive("ASAP.Arena.SendData", function()
    local b = net.ReadBool()

    if not b then
        initializeData(data)
    end

    asapArena:SetGamemode("deathmatch")
end)

local notifications = {}

local function arenaNotif(cause, xp)
    local data = {
        Text = "+" .. xp .. "xp for " .. cause,
        Y = ScrH(),
        Life = 3
    }

    table.insert(notifications, 1, data)
end

surface.CreateFont("Arena.Killfeed", {
    font = "Montserrat",
    size = 26
})

local glow = surface.GetTextureID("particle/particle_glow_05")
local kill = Material("asapf4/ammo.png")

hook.Add("HUDPaint", "XP.Drawing", function()
    if not LocalPlayer():InArena() then return end

    for k, v in pairs(notifications) do
        if v.tx then
            surface.SetTexture(glow)
            surface.SetDrawColor(0, 0, 0, 255 * (v.Life / 3))
            surface.DrawTexturedRectRotated(ScrW() / 2, v.Y + 16, v.tx * 3, 128, 0)
        end

        v.tx, _ = draw.SimpleText(v.Text, "Arena.Killfeed", ScrW() / 2, v.Y, Color(255, 255, 255, math.Clamp(400 * (v.Life / 3), 0, 255)), TEXT_ALIGN_CENTER)
        v.Y = Lerp(FrameTime() * 2, v.Y, ScrH() - 96 - k * 28)
        v.Life = v.Life - FrameTime()

        if v.Life <= 0 then
            table.remove(notifications, k)
        end
    end

    surface.SetMaterial(kill)

    for k = 1, #(LocalPlayer().ArenaKills or {}) do
        surface.SetDrawColor(LocalPlayer().ArenaKills[k] == true and Color(255, 75, 0, 200) or Color(255, 255, 255, 175))
        surface.DrawTexturedRect(ScrW() / 2 - 256 + (k - 1) * 20, ScrH() - 86, 32, 32)
    end
end)

net.Receive("ASAP.Arena.XP", function(l, ply)
    local xp = net.ReadUInt(24)
    local level = net.ReadUInt(16)
    LocalPlayer()._arenaLevel = level
    LocalPlayer()._arenaXP = xp
end)

hook.Add("SpawnMenuOpen", "ASAP.Arena.NoSpawnmenu", function()
    if LocalPlayer():InArena() then return false end
end)

--[[
local flash_glow = Material("effects/laser_tracer")
local shafts = {}

net.Receive("ASAP.Arena.SendShaft", function(l, ply)
    local pos = net.ReadVector()
    local size = EyePos():Distance(pos) / 1024

    table.insert(shafts, {
        pos = pos,
        size = size,
        progress = 0,
        disband = 255
    })
end)

hook.Add("PostDrawTranslucentRenderables", "ASAP.Arena.SpawnNotif", function()

    if (not LocalPlayer():InArena()) then return end
    render.SetMaterial(flash_glow)

    for k, v in pairs(shafts) do
        render.DrawQuadEasy(v.pos + Vector(0, 0, v.progress * 4), (Angle(0, EyeAngles().y + 270, 0)):Right(), v.progress * .3, v.progress * 6, Color(255, 255, 255, v.disband), 0)
        render.DrawQuadEasy(v.pos + Vector(0, 0, v.progress * 4), (Angle(0, EyeAngles().y + 270, 0)):Right(), v.progress * .8, v.progress * 6, Color(255, 0, 0, v.disband), 0)
        v.progress = Lerp(FrameTime() * 3, v.progress, 255)

        if (v.progress > 150) then
            v.disband = Lerp(FrameTime() * 4, v.disband, -5)

            if (v.disband <= 0) then
                table.remove(shafts, k)
            end
        end
    end
end)
]]
local radarTex = surface.GetTextureID("vgui/arena/radar")
local resolution = 1250
local tempScale = resolution / 1024
--680 it's the distance between edge and edge in screen size
local dist = tempScale * 680
--14219 it's the distance between edge and edge in world size
local scale = 14219 / dist
local ply = surface.GetTextureID("ui/asap/logo_circle")
--Map center
local center = Vector(450, -665, 0)

local function radarToWorld(pos)
end

local function worldToRadar(pos)
end

function surface.DrawTexturedRectRotatedPivot(x, y, w, h, rot, x0, y0, dx, dy)
    local c = math.cos(math.rad(rot))
    local s = math.sin(math.rad(rot))
    local newx = y0 * s - x0 * c
    local newy = y0 * c + x0 * s
    surface.DrawTexturedRectRotated(x + newx, y + newy, w, h, rot)
    surface.SetDrawColor(255, 0, 0)
    surface.DrawRect(x, y, 2, 2)
end

function GetAngleBetweenPoints(p1, p2)
    local xDiff = p2.x - p1.x
    local yDiff = p2.y - p1.y

    return math.atan2(yDiff, xDiff) * (180 / math.pi)
end

local mask = BMASKS.CreateMask("radar_mask", "ui/asap/logo_circle")

local guns = {
    {
        Pos = Vector(-4622, -5227, -8849),
        Life = 3
    },
    {
        Pos = Vector(-6449, -1709, -9157),
        Life = 3
    },
    {
        Pos = Vector(721, -5865 - 7834),
        Life = 3
    }
}

local circle = surface.GetTextureID("pp/morph/brush_outline")
local ammo = Material("asapf4/ammo.png")
local showminimap = CreateClientConVar("asap_showminimap", 1, true)
local case = surface.GetTextureID("vgui/arena/case")

function DisplayNotification(gm)
    if isstring(gm) then
        gm = asapArena.Gamemodes[gm]
    end

    if LocalPlayer():InArena() then return end

    if IsValid(CASE_ON) then
        CASE_ON:Remove()
    end

    surface.PlaySound("ui/achievement_earned.wav")
    local texture = Material(gm.Icon)
    CASE_ON = vgui.Create("DPanel")
    CASE_ON:SetSize(420, 96)
    CASE_ON:SetPos(ScrW() / 2 - CASE_ON:GetWide() / 2, -96)
    CASE_ON:MoveTo(ScrW() / 2 - CASE_ON:GetWide() / 2, 172, .5)

    CASE_ON.Paint = function(s, w, h)
        local x, y = s:LocalToScreen(0, 0)
        BSHADOWS.BeginShadow()
        draw.RoundedBox(8, x, y, w, h, Color(36, 36, 36))
        BSHADOWS.EndShadow(1, 2, 2)
        draw.SimpleText(gm.Description, "Arena.Small", w / 2, 24, color_white, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(texture)
        DisableClipping(true)
        surface.DrawTexturedRectRotated(w / 2, -52, 256, 256, 0)
        DisableClipping(false)
    end

    CASE_ON._btn = vgui.Create("DButton", CASE_ON)
    CASE_ON._btn:SetSize(24, 24)
    CASE_ON._btn:SetPos(CASE_ON:GetWide() - 28, 4)
    CASE_ON._btn:SetText("❌")
    CASE_ON._btn:SetTextColor(color_white)
    CASE_ON._btn.Paint = function() end

    CASE_ON._btn.DoClick = function()
        CASE_ON:Remove()
        surface.PlaySound("ui/hint.wav")
    end

    CASE_ON.Join = vgui.Create("DButton", CASE_ON)
    CASE_ON.Join:Dock(BOTTOM)
    CASE_ON.Join:SetTall(32)
    CASE_ON.Join:SetText("JOIN")
    CASE_ON.Join:SetFont("Arena.Small")
    CASE_ON.Join:SetTextColor(color_white)
    CASE_ON.Join:DockMargin(32, 0, 32, 10)

    CASE_ON.Join.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(125, 200, 25))

        if s:IsHovered() then
            draw.RoundedBox(8, 0, 0, w, h, Color(255, 255, 255, 50))
        end
    end

    CASE_ON.Join.DoClick = function(s, w, h)
        net.Start("ASAP.Arena.JoinArena")
        net.SendToServer()
        surface.PlaySound("ui/freeze_cam.wav")
        CASE_ON:Remove()
    end

    timer.Simple(60, function()
        if IsValid(CASE_ON) then
            CASE_ON:Remove()
        end
    end)
end

net.Receive("ASAP.Arena.CrateInfo", function()
    local b = net.ReadBool()

    if not b and IsValid(CASE_ON) then
        CASE_ON:Remove()

        return
    end

    if b and not LocalPlayer():InArena() then
        DisplayNotification("gungame")
    end
end)

local deathCounter = 0
local hitmarkers = {}
local gr = surface.GetTextureID("vgui/gradient-u")

hook.Add("HUDPaint", "Arena.Radar", function()
    --crateDisplay()
    surface.SetTexture(gr)
    local doRemove = -1

    for k, v in pairs(hitmarkers) do
        v.life = v.life - FrameTime() * (v.iskill and 2 or 5)
        local wide = v.iskill and 64 or 32
        local progress = 1 - v.life / 1
        surface.SetDrawColor(ColorAlpha(v.type == 0 and color_white or (v.type == 1 and Color(200, 200, 25) or Color(255, 100, 0)), (1 - progress) * 255))
        surface.DrawTexturedRectRotated(ScrW() / 2 - progress * wide, ScrH() / 2 - progress * wide, 2, 24, 225)
        surface.DrawTexturedRectRotated(ScrW() / 2 + progress * wide, ScrH() / 2 - progress * wide, 2, 24, 225 + 90)
        surface.DrawTexturedRectRotated(ScrW() / 2 + progress * wide, ScrH() / 2 + progress * wide, 2, 24, 225 + 180)
        surface.DrawTexturedRectRotated(ScrW() / 2 - progress * wide, ScrH() / 2 + progress * wide, 2, 24, 225 + 270)

        if v.life <= 0 then
            doRemove = k
        end
    end

    if doRemove > 0 then
        table.remove(hitmarkers, doRemove)
    end

    if not LocalPlayer():InArena() then return end
    if LocalPlayer():IsDueling() then return end
    if asapArena.ActiveGamemode and asapArena.ActiveGamemode.NoMinimap then return end

    if showminimap:GetInt() > 0 then
        local x, y = -12, -16
        local w, h = 350, 350
        local a_x, a_y = 0, 0
        a_x = (EyePos().x + center.x) / scale
        a_y = (EyePos().y + center.y) / scale
        local count = 0

        for k, v in pairs(player.GetAll()) do
            if v:InArena() then
                if v:Nick() == "[/LSAC/] AimbotBreakerBot - Buy LSAC now!" then continue end
                count = count + 1
            end
        end

        BSHADOWS.BeginShadow()
        draw.RoundedBox(8, x + h - 172, y + 42, 228, 72, Color(36, 36, 36))
        BSHADOWS.EndShadow(1, 2, 2)
        draw.SimpleText("Alive: " .. count, "Arena.Stat", x + w - 82, y + 48, Color(255, 255, 255, 255))
        draw.SimpleText("Kills: " .. LocalPlayer():Frags(), "Arena.Stat", x + w - 52, y + 80, Color(255, 255, 255, 255))
        surface.SetDrawColor(Color(46, 46, 46))
        surface.SetTexture(ply)
        surface.DrawTexturedRect(x - 4, y - 4, w + 8, h + 8)
        surface.SetTexture(radarTex)
        BMASKS.BeginMask(mask)
        surface.SetDrawColor(color_black)
        render.SetScissorRect(x, y, x + w, y + h, true)
        surface.DrawRect(0, 0, ScrW(), ScrH())
        surface.SetDrawColor(Color(255, 255, 255))
        surface.DrawTexturedRectRotatedPivot(x + w / 2, y + h / 2, resolution, resolution, EyeAngles().y * -1 + 90, a_x - 42 * tempScale, a_y + 66 * tempScale, 0, 0)

        if showminimap:GetInt() >= 1 then
            if GetGlobalBool("Arena.CaseEvent") then
                local pos = Vector(-3330, -3015, -9681)
                local dist = pos:Distance(LocalPlayer():GetPos()) / scale
                local deltaY = GetAngleBetweenPoints(pos, LocalPlayer():GetPos()) - 270 - EyeAngles().y
                local px = dist * math.cos(math.rad(deltaY)) * -1
                local py = dist * math.sin(math.rad(deltaY))
                surface.SetTexture(case)
                surface.SetDrawColor(color_white)

                if math.abs(px) > w * .37 or math.abs(py) > w * .37 then
                    dist = w * .35
                    px = dist * math.cos(math.rad(deltaY)) * -1
                    py = dist * math.sin(math.rad(deltaY))
                    surface.DrawTexturedRectRotated(x + w / 2 + px, y + h / 2 + py, 64, 64, 0)
                else
                    surface.DrawTexturedRectRotated(x + w / 2 + px, y + h / 2 + py, 64, 64, 0)
                end
            end

            for k, v in pairs(asapArena:GetPlayers()) do
                if not v:Alive() then continue end
                if v:GetNWBool("Arena.RadarHide") then continue end
                local pos = v:GetPos()
                local dist = pos:Distance(LocalPlayer():GetPos()) / scale
                local deltaY = GetAngleBetweenPoints(pos, LocalPlayer():GetPos()) - 270 - EyeAngles().y
                local px = dist * math.cos(math.rad(deltaY)) * -1
                local py = dist * math.sin(math.rad(deltaY))

                if math.abs(px) > w * .4 or math.abs(py) > h * .4 then
                    continue
                else
                    surface.SetTexture(ply)
                    surface.SetDrawColor(255, 100, 0, 255)
                    surface.DrawTexturedRectRotated(x + w / 2 + px, y + h / 2 + py, 16, 16, 0)
                end
            end
        end

        render.SetScissorRect(0, 0, 0, 0, false)
        BMASKS.EndMask(mask, x, y, w, h, 255, 0, false)
        surface.SetDrawColor(Color(75, 175, 255))
        surface.SetTexture(ply)
        surface.DrawTexturedRectRotated(x + w / 2, y + h / 2, 16, 16, 0)
    end
end)

local nextHit = 0

net.Receive("ASAP.Arena:HitMark", function()
    if nextHit > CurTime() then return end
    nextHit = CurTime() + .1
    local hit = net.ReadInt(3)
    local isKill = net.ReadBool()

    table.insert(hitmarkers, {
        type = hit,
        iskill = isKill,
        life = 1
    })

    if isKill then
        surface.PlaySound("physics/metal/metal_grenade_impact_hard1.wav")
        surface.PlaySound("physics/metal/metal_grenade_impact_hard1.wav")
        surface.PlaySound("physics/metal/metal_grenade_impact_hard1.wav")
    else
        surface.PlaySound("arena/hitmark.mp3")
        surface.PlaySound("arena/hitmark.mp3")
    end
end)

net.Receive("ASAP.Arena.Score", function()
    LocalPlayer()._arenaScore = net.ReadUInt(24)
end)
--[[
net.Receive("ASAP.Arena.SendBullet", function()
    local pos = net.ReadVector()
    local owner = net.ReadEntity()
    if (owner == LocalPlayer()) then return end
    table.insert(guns, {
        Pos = pos,
        Life = 3
    })
end)
]]