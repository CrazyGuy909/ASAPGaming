local PANEL = {}
local deg = surface.GetTextureID("vgui/gradient-l")

surface.CreateFont("Arena.Death", {
    font = "Montserrat",
    size = 128 * (ScrH() / 900)
})

local map = surface.GetTextureID("vgui/arena/radar")
local plIcon = surface.GetTextureID("ui/asap/logo_circle")
local circle = surface.GetTextureID("pp/morph/brush_outline")

function PANEL:Init()
    DEATH = self

    if (LocalPlayer():IsDueling()) then
        self:Remove()
        net.Start("ASAP.Arena.RequestSpawn")
        net.WriteBool(true)
        net.SendToServer()
        return
    end

    self:SetSize(ScrW(), ScrH())
    self:MakePopup()
    self:SetTitle("")
    self:SetDraggable(false)
    self:SetTitle("")
    self:ShowCloseButton(false)
    self._initBlur = 0
    self:SetAlpha(0)
    self:AlphaTo(255, .1, 0)
    self.Map = vgui.Create("Panel", self)
    self:InvalidateLayout(true)
    local wide, tall = self.Map:GetSize()
    local resolution = tall
    local tempScale = (resolution / 1024)
    --680 it's the distance between edge and edge in screen size
    local dist = (tempScale * 680)
    --14219 it's the distance between edge and edge in world size
    local scale = 14219 / dist

    self.Map.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0)
        surface.DrawRect(0, 0, w, h)
        surface.SetTexture(map)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRectRotated(w / 2, h / 2, h, h, 0)
        surface.SetDrawColor(255, 255, 255, 100)
        surface.DrawOutlinedRect(0, 0, w, h)
        surface.SetDrawColor(255, 100, 0, 200)
        surface.SetTexture(plIcon)

        for k, v in pairs(asapArena:GetPlayers()) do
            if (v._arenaRadar) then continue end
            if (not v:Alive()) then continue end
            local pos = v:GetPos() / scale
            surface.DrawTexturedRect(wide / 2 + pos.x, tall / 2 - pos.y, 16, 16)
        end
    end

    local i = 0

    for k, v in pairs(asapArena.SpawnPoints) do
        local btn = vgui.Create("DButton", self.Map)
        local pos = v.minimap / scale
        btn:SetSize(64, 64)
        btn:SetText("")
        btn:SetPos(wide / 2 + pos.x - 24, tall / 2 - pos.y - 64)
        btn.i = i

        btn.Paint = function(s, w, h)
            surface.SetTexture(circle)
            surface.SetDrawColor(255, 175, 0)
            local sine = math.cos(RealTime() * 2 + s.i) * 4
            surface.DrawTexturedRectRotated(w / 2, h / 2, w + sine - 4, h + sine - 4, 0)
            draw.SimpleTextOutlined(k, "Arena.Small", w / 2, h / 2, Color(255, 225, 175), 1, 1, 1, Color(255, 175, 0))
        end

        i = i + 1

        btn.DoClick = function()
            RunConsoleCommand("arena_fav_spawn", k)

            timer.Simple(LocalPlayer():Ping() / 1000, function()
                if (IsValid(self) and (self.Remaining or 0) <= 0) then
                    net.Start("ASAP.Arena.RequestSpawn")
                    net.WriteBool(true)
                    net.SendToServer()
                    self:Remove()
                end
            end)
        end
    end

    self.List = vgui.Create("Panel", self)
    self.List.Top = vgui.Create("XeninUI.ScrollPanel", self.List)
    self.List.Top:Dock(TOP)
    self.List.Top:SetTall(ScrH() * .5)
    self.List.Top:DockMargin(16, 16, 16, 8)
    self.List.Top:GetCanvas():DockPadding(16, 64, 16, 8)

    self.List.Top.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 200))
        draw.SimpleText("TOP PLAYERS:", "Arena.Small", 16, 16, color_white)
        surface.SetDrawColor(255, 255, 255, 200)
        surface.DrawRect(16, 48, w - 32, 1)
    end

    self.List.Players = vgui.Create("XeninUI.ScrollPanel", self.List)
    self.List.Players:DockMargin(16, 0, 16, 16)
    self.List.Players:Dock(FILL)
    self.List.Players:GetCanvas():DockPadding(16, 64, 16, 8)

    self.List.Players.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 200))
        draw.SimpleText("PLAYING IN ARENA:", "Arena.Small", 16, 16, color_white)
        surface.SetDrawColor(255, 255, 255, 200)
        surface.DrawRect(16, 48, w - 32, 1)
    end

    self.Buttons = vgui.Create("Panel", self)
    -- self.Spawn = vgui.Create("XeninUI.Button", self.Buttons)
    -- self.Spawn:SetText("Respawn")
    -- self.Spawn.DoClick = function()
    --     if (self.Remaining <= 0) then
    --         net.Start("ASAP.Arena.RequestSpawn")
    --         net.WriteBool(true)
    --         net.SendToServer()
    --         self:Remove()
    --     end
    -- end
    self.Loadout = vgui.Create("XeninUI.Button", self.Buttons)
    self.Loadout:SetText("Loadout")

    self.Loadout.DoClick = function(s)
        if (IsValid(ARENA_LOADOUT)) then
            ARENA_LOADOUT:Remove()
        end

        ARENA_LOADOUT = vgui.Create("asap.Arena.Loadout")
    end

    self.Leave = vgui.Create("XeninUI.Button", self.Buttons)
    self.Leave:SetText("Leave arena")

    self.Buttons.PerformLayout = function(s, w, h)
        --self.Spawn:SetSize(w - 8, 64)
        --self.Spawn:SetPos(0, 76)
        self.Loadout:SetSize(w / 2 - 12, 64)
        self.Loadout:SetPos(0, 92)
        self.Leave:SetSize(w / 2 - 8, 64)
        self.Leave:SetPos(w / 2 - 4, 92)
    end

    self.Leave.DoClick = function(s)
        net.Start("ASAP.Arena.RequestSpawn")
        net.WriteBool(false)
        net.SendToServer()
        LocalPlayer():SetNWBool("InArena", false)
        self:Remove()
    end

    self:RebuildPlayerList()
    self.Remaining = 1
end

function PANEL:RebuildPlayerList()
    self.List.Top:Clear()
    local players = asapArena:GetPlayers()
    table.sort(players, function(a, b) return a:GetArenaFrags() > b:GetArenaFrags() end)

    for k = 1, 10 do
        local line = vgui.Create("DPanel", self.List.Top)
        line:SetTall(32)
        line:Dock(TOP)
        line.Player = players[k]

        line.Paint = function(s, w, h)
            draw.SimpleText(k .. " - ", "Arena.Small", 0, h / 2, Color(255, 200, 75), 0, TEXT_ALIGN_CENTER)

            if not IsValid(s.Player) then
                draw.SimpleText("EMPTY", "Arena.Small", 32, h / 2, Color(255, 255, 255, 75), 0, TEXT_ALIGN_CENTER)
                draw.SimpleText("-", "Arena.Small", w - 8, h / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

                return
            end

            draw.SimpleText(s.Player:Nick(), "Arena.Small", 32, h / 2, color_white, 0, TEXT_ALIGN_CENTER)
            draw.SimpleText(s.Player:GetArenaFrags(), "Arena.Small", w - 8, h / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end

    self.List.Players:Clear()

    for k, v in pairs(asapArena:GetPlayers()) do
        local line = vgui.Create("DPanel", self.List.Players)
        line:SetTall(24)
        line:Dock(TOP)
        line.Player = v

        line.Paint = function(s, w, h)
            if not IsValid(s.Player) then
                s:Remove()
                self:RebuildPlayerList()

                return
            end

            draw.SimpleText(s.Player:Nick(), "Arena.Small", 0, h / 2, color_white, 0, TEXT_ALIGN_CENTER)
            draw.SimpleText(s.Player:GetArenaFrags(), "Arena.Small", w - 8, h / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end

    timer.Create("reload_arena_db", 1, 0, function()
        if IsValid(DEATH) then
            DEATH:RebuildPlayerList()
        else
            timer.Remove("reload_arena_db")
        end
    end)
end

function PANEL:PerformLayout(w, h)
    self.Map:SetSize(w * .45, h - 256)
    self.Map:SetPos(w * .3)

    if (IsValid(self.List)) then
        self.List:SetSize(w * .3, h)
    end

    if (IsValid(self.Buttons)) then
        self.Buttons:SetSize(w * .45, 256)
        self.Buttons:SetPos(w * .3, h - 256)
    end
end

function PANEL:Paint(w, h)
    self._initBlur = Lerp(FrameTime() * 3, self._initBlur, 7)
    surface.SetDrawColor(0, 0, 0, self._initBlur * 25)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(25, 25, 45, 255)
    surface.SetTexture(deg)
    surface.DrawTexturedRect(0, 0, w / 2, h)
    surface.DrawTexturedRectRotated(w - w / 4, h / 2, w / 2, h, 180)
    XeninUI:DrawBlur(self, self._initBlur)
    local tx = 0
    local y = h - 256
    draw.RoundedBox(8, w * .3, y + 46, w * .45 - 8, 32, Color(0, 0, 0))
    draw.SimpleText("You can respawn in:", "Inventory.Button", w * .3, y + 24, Color(255, 255, 255, 255 * (self._initBlur / 7)), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    render.SetScissorRect(w * .3, 0, w * .3 + (w * .45 - 8) * (1 - self.Remaining / 3), h, true)
    draw.RoundedBox(8, w * .3, y + 46, w * .45 - 8, 32, color_white)
    render.SetScissorRect(0, 0, 0, 0, false)

    if (self.Remaining > 0) then
        self.Remaining = self.Remaining - FrameTime()
    end
end

function PANEL:SetOwner(killer)
    if (not IsValid(killer) or not killer:IsPlayer()) then
        killer = LocalPlayer()
    end

    self.Model = vgui.Create("DModelPanel", self)
    self.Model:SetSize(ScrW() * .25, ScrH())
    self.Model:SetPos(ScrW() - ScrW() * .25, 0)
    self.Model:SetModel(killer:GetModel())

    self.Model.LayoutEntity = function(s, ent)
        if (ent:GetCycle() >= .95) then
            ent:SetCycle(0)
        end

        s:RunAnimation()
    end

    self.Model:SetAnimated(true)
    local dist = 70
    self.Model:SetCamPos(Vector(-0, dist + dist * .1, 40))
    self.Model:SetMouseInputEnabled(false)
    self.Model:GetEntity():SetAngles(Angle(0, 75, 0))
    self.Model:SetFOV(30)
    self.Model:SetLookAt(Vector(0.5, dist, 40))
    self.Model.Entity:ResetSequence(asapArena.Taunts[killer:GetNWString("ArenaTaunt", "laugh")].Anim)
    self.Model.Badge = vgui.Create("DPanel", self.Model)
    self.Model.Badge:Dock(BOTTOM)
    self.Model.Badge:SetTall(112)
    self.Model.Badge:DockMargin(16, 0, 16, 72)

    self.Model.Badge.Killer = {
        Name = killer:Nick(),
        Level = killer:GetArenaLevel(),
        Weapon = IsValid(killer:GetActiveWeapon()) and killer:GetActiveWeapon():GetPrintName() or "A fork"
    }

    self.Model.Badge.Paint = function(s, w, h)
        local x, y = s:LocalToScreen(0, 0)
        DisableClipping(true)
        draw.SimpleText(killer == LocalPlayer() and "You kermit suicide" or "You were killed by:", "Arena.Medium", 8, -42, Color(200, 75, 75, 255))
        DisableClipping(false)
        BSHADOWS.BeginShadow()
        draw.RoundedBox(8, x, y, w, h, Color(26, 26, 26))
        BSHADOWS.EndShadow(2, 2, 2)
        draw.SimpleText(s.Killer.Name, "Arena.Medium", 112, 4, Color(255, 255, 255, 200))
        local tx, _ = draw.SimpleText("Level: ", "Arena.Small", 112, 54, Color(255, 255, 255, 100))
        draw.SimpleText(s.Killer.Level, "Arena.Small", 112 + tx, 54, Color(255, 255, 255, 255))

        if (killer ~= LocalPlayer()) then
            tx, _ = draw.SimpleText("Killed you with: ", "Arena.Small", 112, 78, Color(255, 255, 255, 255))
            draw.SimpleText(s.Killer.Weapon, "Arena.Small", 112 + tx, 78, Color(255, 200, 100, 255))
        end
    end

    self.Model.Badge.Avatar = vgui.Create("AvatarImage", self.Model.Badge)
    self.Model.Badge.Avatar:SetPlayer(killer, 96)
    self.Model.Badge.Avatar:Dock(LEFT)
    self.Model.Badge.Avatar:SetWide(82)
    self.Model.Badge.Avatar:DockMargin(16, 16, 0, 16)
end

vgui.Register("arenaDeathScreen", PANEL, "DFrame")

net.Receive("ASAP.Arena.ShowDeathScreen", function()
    local ply = net.ReadEntity()
    local target = net.ReadEntity()
    local isHeadshot = net.ReadBool()

    if (ply ~= target and target == LocalPlayer()) then
        if (not LocalPlayer().ArenaKills) then
            LocalPlayer().ArenaKills = {}
        end

        table.insert(LocalPlayer().ArenaKills, isHeadshot)
        local lerp = 1

        hook.Add("RenderScreenspaceEffects", "GTA Zoom", function()
            local tab = {
                ["$pp_colour_addr"] = 0,
                ["$pp_colour_addg"] = 0,
                ["$pp_colour_addb"] = .1 * lerp,
                ["$pp_colour_brightness"] = -.1 * lerp,
                ["$pp_colour_contrast"] = 1 + .4 * lerp,
                ["$pp_colour_colour"] = 1 + .1 * lerp,
                ["$pp_colour_mulb"] = .5 * lerp
            }

            lerp = Lerp(FrameTime() * 2, lerp, -.01)
            DrawColorModify(tab)

            if (lerp <= 0) then
                hook.Remove("RenderScreenspaceEffects", "GTA Zoom")
            end
        end)

        return
    end

    LocalPlayer().ArenaKills = {}

    if IsValid(DEATH) then
        DEATH:Remove()
    end

    DEATH = vgui.Create("arenaDeathScreen")
    DEATH:SetOwner(target)
end)

if IsValid(DEATH) then DEATH:Remove() end
