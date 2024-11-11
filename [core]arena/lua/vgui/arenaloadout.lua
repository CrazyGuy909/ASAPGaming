local PANEL = {}

surface.CreateFont("Arena.Huge", {
    font = "Montserrat",
    size = 80 * (ScrH() / 900)
})

surface.CreateFont("Arena.Medium", {
    font = "Montserrat",
    size = 48 * (ScrH() / 900)
})

surface.CreateFont("Arena.Stat", {
    font = "Montserrat",
    size = 28
})

surface.CreateFont("Arena.Small", {
    font = "Montserrat",
    size = 20 * (ScrH() / 900)
})

local deg = surface.GetTextureID("vgui/gradient-l")
local map = surface.GetTextureID("vgui/arena/radar")
local plIcon = surface.GetTextureID("ui/asap/logo_circle")
local circle = surface.GetTextureID("pp/morph/brush_outline")

function PANEL:Init()
    ARENA_LOADOUT = self
    self:SetSize(ScrW(), ScrH())
    self:SetTitle("")
    self:SetDraggable(false)
    self:ShowCloseButton(false)
    self:MakePopup()
    self._initBlur = 0
    self.Foot = vgui.Create("Panel", self)
    self.Foot:Dock(BOTTOM)
    self.Foot:SetTall(96)
    self.Right = vgui.Create("Panel", self)
    self.Right:SetWide(ScrW() / 2.25)
    self.Right:DockMargin(0, 0, 24, 0)
    self.Right:Dock(RIGHT)
    self.Left = vgui.Create("Panel", self)
    self.Left:Dock(FILL)
    self.Left:DockMargin(32, 0, 0, 0)
    self.Perks = vgui.Create("Panel", self.Left)
    self.Perks:Dock(BOTTOM)
    self.Perks:SetTall(148)
    self.Equipment = vgui.Create("Panel", self.Left)
    self.Equipment:Dock(FILL)
    self:InvalidateLayout(true)
    self:InvalidateChildren(true)
    self.Player = vgui.Create("asap.Arena.Slot", self.Equipment)
    self.Player:Dock(RIGHT)
    self.Player:DockMargin(16, 48, 16, 0)
    self.Player:SetWide(self.Equipment:GetWide() / 2.5)
    self.Player.Coords = {0, 0}
    self.Player.Lerped = {0, 0}
    self.Player:SetKind("PlayerModel")
    self.Player.Model:SetAnimated(true)
    self.Loadout = vgui.Create("Panel", self.Equipment)
    self.Loadout:Dock(FILL)
    self.Map = vgui.Create("Panel", self.Right)
    self.Map:Dock(FILL)
    self:InvalidateLayout(true)
    self:InvalidateChildren(true)
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
                net.Start("ASAP.Arena.RequestSpawn")
                net.WriteBool(true)
                net.SendToServer()
                self:Remove()
            end)
        end
    end

    self:InitLoadout()

    if (not asapArena.Weapons or table.Count(asapArena.Weapons) == 0) then
        include("arena/sh_weapons.lua")
    end

    if (LocalPlayer()._arenaEquipment and LocalPlayer()._arenaEquipment["Primary"]) then
        self:SetWeapon(LocalPlayer()._arenaEquipment["Primary"], asapArena.Weapons[LocalPlayer()._arenaEquipment["Primary"]])
    end
end

function PANEL:InitLoadout()
    --Top container
    local comboSize = (self.Loadout:GetTall() - 128 - 16) / 2
    local label = Label("Primary", self.Loadout)
    label:SetFont("Arena.Medium")
    label:Dock(TOP)
    label:SetTall(48)
    self.Primary = vgui.Create("asap.Arena.Slot", self.Loadout)
    self.Primary:DockMargin(0, 4, 0, 0)
    self.Primary:Dock(TOP)
    self.Primary:SetTall(comboSize - 48)
    self.Primary:SetKind("Primary")
    label = Label("Secondary", self.Loadout)
    label:SetFont("Arena.Medium")
    label:Dock(TOP)
    label:SetTall(48)
    self.Secondary = vgui.Create("asap.Arena.Slot", self.Loadout)
    self.Secondary:DockMargin(0, 4, 0, 0)
    self.Secondary:Dock(TOP)
    self.Secondary:SetTall(comboSize - 48)
    self.Secondary:SetKind("Secondary")
    local miscs = vgui.Create("Panel", self.Loadout)
    miscs:Dock(BOTTOM)
    miscs:SetTall(128)
    --Mele and misc
    local wide = self.Loadout:GetWide() - self.Player:GetWide()
    self.mel = vgui.Create("Panel", miscs)
    self.mel:Dock(LEFT)
    self.mel:SetWide(wide + 64)
    self.mel:DockMargin(0, 0, 16, 0)
    label = Label("Melee", self.mel)
    label:SetFont("Arena.Medium")
    label:Dock(TOP)
    label:SetTall(48)
    self.Melee = vgui.Create("asap.Arena.Slot", self.mel)
    self.Melee:DockMargin(0, 4, 0, 0)
    self.Melee:Dock(FILL)
    self.Melee:SetKind("Melee")
    self.mis = vgui.Create("Panel", miscs)
    self.mis:Dock(FILL)
    label = Label("Misc", self.mis)
    label:SetFont("Arena.Medium")
    label:Dock(TOP)
    label:SetTall(48)
    self.Misc = vgui.Create("asap.Arena.Slot", self.mis)
    self.Misc:DockMargin(0, 4, 0, 0)
    self.Misc:Dock(FILL)
    self.Misc:SetTall(96)
    self.Misc:SetKind("Misc")
    local perks = vgui.Create("Panel", self.Perks)
    perks:Dock(LEFT)
    perks:SetWide(self.Perks:GetTall() * 3 + 6 * 3)
    perks:DockMargin(0, 8, 8, 0)

    for k = 1, 3 do
        local perk = vgui.Create("DButton", perks)
        perk:Dock(TOP)
        perk:SetTall(self.Perks:GetTall() / 3 - 6)
        perk:DockMargin(0, 0, 0, 4)
        perk:SetFont("Arena.Small")
        perk:SetTextColor(color_white)
        if (LocalPlayer()._arenaEquipment.Perks and LocalPlayer()._arenaEquipment.Perks[k]) then
            perk:SetText(asapArena.Perks[k][LocalPlayer()._arenaEquipment.Perks[k]].Name)
        else
            perk:SetText("Perk slot #" .. k)
        end
        
        perk.Color = Color(255, 175, 50)
        perk.HoverProgress = 0

        perk.Paint = function(s, w, h)
            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(ColorAlpha(s.Color or color_white, s:IsHovered() and 150 or 50))
            surface.DrawOutlinedRect(0, 0, w, h)
            surface.SetDrawColor(ColorAlpha(s.Color or color_white, s.HoverProgress))
            s.HoverProgress = Lerp(FrameTime() * 2, s.HoverProgress, s:IsHovered() and 25 or 0)

            local poly = {
                {
                    x = 0,
                    y = 0,
                    u = 0,
                    v = 0
                },
                {
                    x = w,
                    y = 0,
                    u = .75 + math.cos(RealTime() * 4) * .25,
                    v = 0
                },
                {
                    x = w,
                    y = h,
                    u = .75 + math.sin(RealTime() * 4) * .25,
                    v = 1
                },
                {
                    x = 0,
                    y = h,
                    u = .5,
                    v = 0
                }
            }

            surface.SetTexture(deg)
            surface.DrawPoly(poly)
        end

        perk.DoClick = function(s)
            if IsValid(self.perkWindow) then
                self.perkWindow:Remove()
            end

            local perk_list = table.Copy(asapArena.Perks[k])

            perk_list.none = {
                Name = "None",
                Description = "",
                Level = -1
            }

            local x, y = perk:LocalToScreen(0, 0)
            self.perkWindow = vgui.Create("XeninUI.Frame")
            self.perkWindow:SetSize(perk:GetWide(), 48 + table.Count(perk_list) * 64 + 8)
            self.perkWindow:SetPos(x, y - self.perkWindow:GetTall() - 8)
            self.perkWindow:SetTitle("SLOT #" .. k)
            self.perkWindow:MakePopup()

            self.perkWindow.OnFocusChanged = function(s, b)
                if (not b) then
                    s:Remove()
                end
            end

            for id, prk in SortedPairsByMemberValue(perk_list, "Level", true) do
                local pnl = vgui.Create("DButton", self.perkWindow)
                pnl:Dock(TOP)
                pnl:SetTall(58)
                pnl:DockMargin(8, 8, 8, 0)
                pnl:SetText("")

                pnl.DoClick = function(s)
                    if (LocalPlayer():GetArenaLevel() >= prk.Level) then
                        net.Start("ASAP.Arena:SelectPerk")
                        net.WriteInt(k, 3)
                        net.WriteString(id)
                        net.SendToServer()

                        if (not LocalPlayer()._arenaEquipment.Perks) then
                            LocalPlayer()._arenaEquipment.Perks = {}
                        end

                        if (id == "none") then
                            LocalPlayer()._arenaEquipment.Perks[k] = nil
                            perk:SetText("Perk slot #" .. k)
                        else
                            perk:SetText(prk.Name)
                            LocalPlayer()._arenaEquipment.Perks[k] = id
                        end
                    else
                        Derma_Message("You don't meet minimum level to use this perk", "No!")
                    end
                end

                pnl.Paint = function(s, w, h)
                    surface.SetDrawColor(16, 16, 16)
                    surface.DrawRect(0, 0, w, h)
                    draw.SimpleText(prk.Name, "Arena.Small", 12, 8, color_white)
                    draw.SimpleText(prk.Description, "Arena.Small", 12, 30, Color(255, 255, 255, 75))
                    surface.SetDrawColor(255, 255, 255, 50)
                    surface.DrawOutlinedRect(0, 0, w, h)

                    if s:IsHovered() then
                        surface.SetDrawColor(255, 255, 255, 5)
                        surface.DrawRect(0, 0, w, h)
                    end

                    if (prk.Level > 0) then
                        draw.SimpleText("Level: " .. prk.Level, "Arena.Small", w - 12, 8, LocalPlayer():GetArenaLevel() >= prk.Level and Color(150, 255, 50) or Color(200, 100, 50), TEXT_ALIGN_RIGHT)
                    end
                end
            end
        end
    end

    --Bottom panel
    local taunts = vgui.Create("Panel", self.Perks)
    taunts:Dock(FILL)
    taunts:DockMargin(16, 0, 16, 0)
    taunts:SetWide(self.Loadout)
    --Left panel
    label = Label("Taunt", taunts)
    label:SetFont("Arena.Medium")
    label:Dock(TOP)
    label:SetTall(48)
    surface.SetFont("Arena.Medium")
    self.Taunt = vgui.Create("asap.Arena.Slot", taunts)
    self.Taunt:DockMargin(0, 4, 0, 0)
    self.Taunt:Dock(FILL)
    self.Taunt:SetKind("Taunt")
    local info = vgui.Create("DPanel", self.Foot)
    info:Dock(FILL)
    info:DockMargin(32, 0, 0, 0)

    info.Paint = function(s, w, h)
        local progress = LocalPlayer():GetArenaXP() / ((LocalPlayer():GetArenaLevel() + 1) * 100)
        local x, y = s:LocalToScreen(0, 0)
        draw.SimpleText("Level: " .. LocalPlayer():GetArenaLevel(), "Arena.Medium", 0, 0, color_white)
        draw.RoundedBox(8, 0, 46, w, 36, Color(46, 46, 46))
        draw.RoundedBox(8, 4, 46 + 4, w - 8, 36 - 8, Color(26, 26, 26))
        render.SetScissorRect(x + 4, y + 50, x + 4 + (w - 8) * progress, y + 60 + 28, true)
        draw.RoundedBox(8, 4, 46 + 4, w - 8, 36 - 8, Color(255, 162, 0))
        render.SetScissorRect(0, 0, 0, 0, false)
        draw.SimpleText(LocalPlayer():GetArenaXP() .. "/" .. ((LocalPlayer():GetArenaLevel() + 1) * 100), "Arena.Medium", w / 2, 248, color_white, TEXT_ALIGN_CENTER)
        draw.SimpleText("Show Killstreak Effects", "Arena.Small", w - 72, 16, color_white, TEXT_ALIGN_RIGHT)
    end

    info.Play = vgui.Create("XeninUI.Button", self.Foot)
    info.Play:SetText("Play")
    info.Play:Dock(RIGHT)
    info.Play:SetWide(ScrW() / 2.5 - 16)
    info.Play:DockMargin(16, 16, 16, 16)

    info.Play.DoClick = function(s)
        net.Start("ASAP.Arena.SaveInfo")
        net.WriteBool(self.ShouldSave)
        net.SendToServer()
        self:Remove()
    end

    surface.SetFont("Arena.Small")
    tx, _ = surface.GetTextSize("Show Killstreak Effects")
    info.Eff = vgui.Create("XeninUI.Checkbox", info)
    info.Eff:Dock(RIGHT)
    info.Eff:DockMargin(0, 16, 0, 56)
    info.Eff:SetWide(64)
    info.Eff:SetConVar("asap_draw_streak")
end

function PANEL:Paint(w, h)
    self._initBlur = Lerp(FrameTime() * 3, self._initBlur, 7)
    surface.SetDrawColor(0, 0, 0, self._initBlur * 25)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(20, 25, 35, 255)
    surface.SetTexture(deg)
    surface.DrawTexturedRect(0, 0, w / 2, h)
    surface.DrawTexturedRectRotated(w - w / 4, h / 2, w / 2, h, 180)
    XeninUI:DrawBlur(self, self._initBlur)
end

function PANEL:OnRemove()
    if IsValid(wpn_pnl) then
        wpn_pnl:Remove()
    end

    if IsValid(self._weapon) then
        self._weapon:Remove()
    end
end

function PANEL:SetWeapon(class, data)
end

vgui.Register("asap.Arena.Loadout", PANEL, "DFrame")
local back = surface.GetTextureID("asapf4/weapon_customs/background")
local CUSTOMS = {}

function CUSTOMS:Init()
    if IsValid(_CUSTOMS) then
        _CUSTOMS:Remove()
    end
    _CUSTOMS = self
    self:SetSize(600, 500)
    self:Center()
    self:MakePopup()
    self.Body = vgui.Create("Panel", self)
    self.Body:Dock(TOP)
    self.Body:SetTall(self:GetTall() - 48 - 64 - 48)

    self.Body.Paint = function(s, w, h)
        local tw = w + w * .25
        local th = tw / 2

        if (th < h) then
            th = h + h * .125
            tw = h * 2 + h * .25
        end

        surface.SetTexture(back)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRectRotated(w / 2, h / 2 + 16, tw, th, 0)
    end

    self.Mods = vgui.Create("Panel", self)
    self.Mods:Dock(FILL)
    self.Mods:DockMargin(16, 16, 16, 16)
    self:InvalidateLayout(true)
end

local info = Material("asapf4/weapon_customs/info.png")
local preview = Material("asapf4/weapon_customs/preview.png")

local function CreateControl(s, data, frame)
    local self = s
    local control = vgui.Create("DPanel", frame)
    control:Dock(TOP)
    control:SetTall(72)
    control.Owner = frame:GetParent()
    control.Att = vgui.Create("DButton", control)
    control.Att:SetText("")
    control.Att:Dock(LEFT)
    control.Att:SetWide(64)
    control.Att:DockMargin(4, 4, 4, 4)
    control.Att.Owner = control
    control.Att.Master = control.Owner
    control.Att.Paint = self.PaintIcon
    control.Paint = self.PaintControl

    if (data) then
        local data = istable(data) and data or TFA.Attachments.Atts[data] or {}
        self.id = data.ID
        local hasAttachments = data.Description and #data.Description > 0
        control.Data = data
        control.Tooltip = vgui.Create("DButton", control)
        control.Tooltip:SetSize(20, 20)
        control.Tooltip:SetText("")
        control.Tooltip.Data = data
        control.Tooltip:SetPos(76, control:GetTall() - 28)

        control.Tooltip.Paint = function(s, w, h)
            surface.SetDrawColor(255, 255, 255, hasAttachments and (control.Owner.Light and 10 or (s:IsHovered() and 200 or 75)) or 5)
            surface.SetMaterial(info)
            surface.DrawTexturedRectRotated(w / 2, h / 2, 32, 32, 0)
        end

        control.Tooltip.OnCursorEntered = function(s)
            if (hasAttachments) then
                self:DrawTooltipAtt(s.Data)
            end
        end

        control.Tooltip.OnCursorExited = function(s)
            if (hasAttachments) then
                self:StopTooltip()
            end
        end

        control.Preview = vgui.Create("DButton", control)
        control.Preview:SetSize(20, 20)
        control.Preview:SetText("")
        control.Preview:SetPos(76 + 26, control:GetTall() - 28)

        control.Preview.Paint = function(s, w, h)
            surface.SetDrawColor(255, 255, 255, s:IsHovered() and 200 or (control.Owner.Light and 10 or 75))
            surface.SetMaterial(preview)
            surface.DrawTexturedRectRotated(w / 2, h / 2, 32, 32, 0)
        end

        control.Preview.OnCursorEntered = function(s)
            control.Owner.Light = true

            if (self.Equipped) then
                self.Controller:Setup(false, self.Equipped, true)
            end

            self.Controller:Setup(true, data)
        end

        control.Preview.OnCursorExited = function(s)
            control.Owner.Light = false
            self.Controller:Setup(false, data)

            if (self.Equipped) then
                self.Controller:Setup(true, self.Equipped, true)
            end
        end

        frame:InvalidateParent(true)
        control:InvalidateParent(true)
        control.Settings = vgui.Create("DButton", control)
        control.Settings:SetPos(76 + 52, control:GetTall() - 42)
        control.Settings:SetSize(272 - (76 + 52) - (frame.IsBig and 32 or 16), 34)
        control.Settings.Price = asap_weps.list.prices[data.ID]
        local challenges = asapArena.Attachments[data.ID]
        self.Challenges = challenges
        local ourData = asapArena:GetWeaponStats(LocalPlayer(), self.Controller.Class)

        control.Settings.Update = function(s)
            local class = self.Controller.Class
            local canEquip = true

            if (challenges.Kills and challenges.Kills > ourData[1]) then
                canEquip = false
            end

            if (challenges.Headshots and challenges.Headshots > ourData[2]) then
                canEquip = false
            end

            if (challenges.Damage and challenges.Damage > ourData[3]) then
                canEquip = false
            end

            local isEquipped = asapArena:GetAttachmentEquippedArena(LocalPlayer(), class, self.Slot) == data.ID
            s.State = canEquip
            s.IsEquipped = isEquipped
            control.Settings:SetText(not canEquip and "LOCKED" or (isEquipped and "UNEQUIP" or "EQUIP"))
            control.Settings:SetFont("XeninUI.TextEntry")
            control.Settings:SetTextColor(not canEquip and Color(210, 70, 70) or (isEquipped and Color(210, 160, 70) or Color(70, 155, 210)))
        end

        control.Settings.OnCursorEntered = function(s)
            if (control.Settings.State) then return end
            self:DrawTooltip(data)
        end

        control.Settings.OnCursorExited = function(s)
            self:StopTooltip()
        end

        control.Settings:Update()

        control.Settings.DoClick = function(s)
            if (not s.State) then return end
            local class = self.Controller.Class
            local isEquipped = asapArena:GetAttachmentEquippedArena(LocalPlayer(), class, self.Slot) == data.ID
            net.Start("ASAP.Arena:EquipAttachment")
            net.WriteString(class)
            net.WriteString(data.ID)
            net.WriteInt(self.Slot, 8)
            net.WriteBool(not isEquipped)
            net.SendToServer()

            if (s.State) then
                if (not LocalPlayer()._arenaData.Attachments[class]) then
                    LocalPlayer()._arenaData.Attachments[class] = {}
                end

                if not LocalPlayer()._arenaData.Attachments[class].equipped then
                    LocalPlayer()._arenaData.Attachments[class].equipped = {}
                end

                LocalPlayer()._arenaData.Attachments[class].equipped[self.Slot] = not isEquipped and data.ID or nil
                self.Controller:Setup(not isEquipped, data, true)

                if (not isEquipped) then
                    self.Equipped = data
                else
                    self.Controller:Setup(false, data, true)
                    self.Equipped = nil
                end

                for k, v in pairs(self.ControlTable) do
                    if (v.Update) then
                        v:Update()
                    end
                end
            end
        end

        control.Settings.Paint = function(s, w, h)
            draw.RoundedBox(8, 0, 0, w, h, s:IsHovered() and Color(46, 46, 46, control.Owner.Light and 5 or 255) or Color(26, 26, 26, control.Owner.Light and 5 or 255))
        end

        if (not self.ControlTable) then
            self.ControlTable = {}
        end

        table.insert(self.ControlTable, control.Settings)
    end
end

function CUSTOMS:SetWeapon(id)
    self:InvalidateLayout(true)
    local wepData = weapons.GetStored(id)
    self:SetTitle("Setting up " .. wepData.PrintName)
    self.Controller = vgui.Create("ASAP.Arena.WeaponController", self.Body)
    self.Controller.Mods = self.Mods
    self.Controller.Class = id
    self.Controller:SetClass(wepData, false)
    
    self:SetWide(#self.Controller.Mods.List * 78 + 32)
    self:Center()
    for k, v in pairs(self.Controller.Mods.List) do
        v.DrawTooltip = function(s, data)
            self:DrawTooltip(s.Challenges, data.ID)
        end

        v.DrawTooltipAtt = function(s, data)
            self:DrawTooltipAtt(data)
        end

        v.StopTooltip = function(s, data)
            self:StopTooltip()
        end

        v.CreateControl = function(s, v, data)
            CreateControl(s, v, data)
        end

        if (LocalPlayer().aweapons and LocalPlayer().aweapons[id] && LocalPlayer().aweapons[id].equipped and LocalPlayer().aweapons[id].equipped[v.Slot]) then
            local data = TFA.Attachments.Atts[LocalPlayer().aweapons[id].equipped[v.Slot]]
            timer.Simple(0, function()
                self.Controller:Setup(false, data, true)
            end)
            v.Equipped = data
        end

        if (LocalPlayer()._arenaData.Attachments and LocalPlayer()._arenaData.Attachments[id] && LocalPlayer()._arenaData.Attachments[id].equipped and LocalPlayer()._arenaData.Attachments[id].equipped) then
            local data = TFA.Attachments.Atts[LocalPlayer()._arenaData.Attachments[id].equipped[v.Slot]]
            timer.Simple(0, function()
                self.Controller:Setup(true, data, true)
            end)
            v.Equipped = data
        end
        v.Content.Paint = function(s, w, h)
            surface.SetDrawColor(255, 255, 255, s:IsHovered() and 200 or 75)
            surface.DrawOutlinedRect(0, 0, w, h)
            surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
            surface.SetDrawColor(0, 0, 0, 100)
            surface.SetTexture(deg)
            surface.DrawTexturedRect(2, 2, w / 2, h - 4)
            surface.DrawTexturedRectRotated(w - w / 4 - 2, h / 2 + 2, w / 2, h - 6, 180)
            surface.DrawTexturedRectRotated(w / 2, h / 2 + h / 4 - 2, w / 2, h - 4, 90)
            surface.DrawTexturedRectRotated(w / 2, h / 2 - h / 4 + 2, w / 2, h - 4, 270)
            local class = self.Controller.Class

            if (LocalPlayer()._arenaData.Attachments and LocalPlayer()._arenaData.Attachments[class] and LocalPlayer()._arenaData.Attachments[class].equipped) then
                local strSlot = LocalPlayer()._arenaData.Attachments[class].equipped[v.Slot]

                if (strSlot and TFA.Attachments.Atts[strSlot].Icon) then
                    surface.SetMaterial(Material(TFA.Attachments.Atts[strSlot].Icon))
                    surface.SetDrawColor(color_white)
                    surface.DrawTexturedRect(8, 8, w - 16, h - 16)
                end
            end
        end
    end
end

function CUSTOMS:DrawTooltipAtt(data)
    if IsValid(self.Tooltip) then
        self.Tooltip:Remove()
    end

    local mx, my = gui.MousePos()
    self.Tooltip = vgui.Create("DPanel")
    self.Tooltip:SetPos(mx + 24, my)

    self.Tooltip.Paint = function(s, w, h)
        local x, y = s:LocalToScreen()
        BSHADOWS.BeginShadow()
        draw.RoundedBox(6, x, y, w, h, XeninUI.Theme.Background)
        BSHADOWS.EndShadow(1, 2, 2, 255, 0, 0)
    end

    local richtext = vgui.Create("RichText", self.Tooltip)
    richtext:Dock(FILL)
    richtext:DockMargin(4, 4, 4, 4)
    richtext:SetFontInternal("aMenu18")
    richtext:SetVerticalScrollbarEnabled(false)

    richtext.PerformLayout = function()
        richtext:SetFontInternal("aMenu18")
    end

    local lines = 0
    local total = ""
    richtext:InsertColorChange(175, 175, 175, 255)

    for i, piece in pairs(data.Description) do
        if (istable(piece)) then
            richtext:InsertColorChange(piece.r, piece.g, piece.b, 255)
        else
            richtext:AppendText(piece .. "\n")
            total = total .. piece
            lines = lines + 1
        end
    end

    self.Tooltip:SetSize(256, 8 + lines * 20)
    self.Tooltip:SetDrawOnTop(true)
end

function CUSTOMS:DrawTooltip(challenges, id)
    if IsValid(self.Tooltip) then
        self.Tooltip:Remove()
    end

    local mx, my = gui.MousePos()
    self.Tooltip = vgui.Create("DPanel")
    self.Tooltip:SetPos(mx + 24, my)

    self.Tooltip.Paint = function(s, w, h)
        local x, y = s:LocalToScreen()
        BSHADOWS.BeginShadow()
        draw.RoundedBox(6, x, y, w, h, XeninUI.Theme.Background)
        BSHADOWS.EndShadow(1, 2, 2, 255, 0, 0)
    end

    local richtext = vgui.Create("RichText", self.Tooltip)
    richtext:Dock(FILL)
    richtext:DockMargin(4, 4, 4, 4)
    richtext:SetFontInternal("aMenu18")
    richtext:SetVerticalScrollbarEnabled(false)

    richtext.PerformLayout = function()
        richtext:SetFontInternal("aMenu18")
    end

    local lines = 0
    local total = ""
    richtext:InsertColorChange(175, 175, 175, 255)
    local data = asapArena.Attachments[id]
    local challenges = asapArena:GetWeaponStats(LocalPlayer(), self.Controller.Class)

    if (data.Kills) then
        richtext:AppendText("Kills: ")

        if (data.Kills > challenges[1]) then
            richtext:InsertColorChange(200, 125, 50, 255)
        else
            richtext:InsertColorChange(125, 255, 50, 255)
        end

        richtext:AppendText(challenges[1] .. "/" .. data.Kills .. "\n")
        lines = lines + 1
    end

    richtext:InsertColorChange(175, 175, 175, 255)

    if (data.Headshots) then
        richtext:AppendText("Headshots: ")

        if (data.Headshots > challenges[2]) then
            richtext:InsertColorChange(200, 125, 50, 255)
        else
            richtext:InsertColorChange(125, 255, 50, 255)
        end

        richtext:AppendText(challenges[2] .. "/" .. data.Headshots .. "\n")
        lines = lines + 1
    end

    richtext:InsertColorChange(175, 175, 175, 255)

    if (data.Damage) then
        richtext:AppendText("Damage: ")

        if (data.Damage > challenges[3]) then
            richtext:InsertColorChange(200, 125, 50, 255)
        else
            richtext:InsertColorChange(125, 255, 50, 255)
        end

        richtext:AppendText(challenges[3] .. "/" .. data.Damage .. "\n")
        lines = lines + 1
    end

    richtext:InsertColorChange(175, 175, 175, 255)

    if (data.weplevel) then
        richtext:AppendText("Level: ")

        if (data.weplevel > challenges[4][1]) then
            richtext:InsertColorChange(200, 125, 50, 255)
        else
            richtext:InsertColorChange(125, 255, 50, 255)
        end

        richtext:AppendText(challenges[4][1] .. "/" .. data.weplevel .. "\n")
        lines = lines + 1
    end

    self.Tooltip:SetSize(256, 8 + lines * 20)
    self.Tooltip:SetDrawOnTop(true)
end

function CUSTOMS:StopTooltip()
    if IsValid(self.Tooltip) then
        self.Tooltip:Remove()
    end
end

vgui.Register("asap.Arena.Customs", CUSTOMS, "XeninUI.Frame")
--ARENA_LOADOUT:SetWeapon("tfa_ak74")

if (IsValid(ARENA_LOADOUT)) then
    ARENA_LOADOUT:Remove()
end
