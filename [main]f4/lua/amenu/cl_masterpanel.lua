------------------- Base panel
local PANEL = {}
PANEL.iTab = 0

surface.CreateFont("Marlet_32", {
    font = "Marlett",
    size = 28,
    symbol = true,
})

local glow = surface.GetTextureID("particle/particle_glow_04")

function PANEL:Init()
    local disallow = hook.Run("F4MenuOpen")

    if (disallow == false) then
        self:Remove()

        return
    end
    aMenu.Base = self
    self.iTab = 0
    self:Resize()
    self:Center()
    self:MakePopup()
    self.Col = aMenu.Color
    self.Tabs = {}
    self.StartTime = SysTime()
    self.Banner = vgui.Create("DPanel", self)
    self.Banner:SetSize(self:GetParent():GetWide(), 54)
    self.Banner:Dock(TOP)

    self.Banner.Paint = function(this, w, h)
        draw.RoundedBoxEx(16, 0, 0, w, h, self.Col, true, true, false, false)
        draw.SimpleText(aMenu.SubTitle, "aMenuTitle", 16, 12, Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

	if (aMenu.GiveAway) then
        self.GiveAway = vgui.Create("DButton", self)
        self.GiveAway:SetSize(172, 32)
        self.GiveAway:SetText("BIG GIVEAWAY")
        self.GiveAway:SetTextColor(color_white)
        self.GiveAway:SetFont("aMenu20")
        self.GiveAway:SetPos(232, 12)
        self.GiveAway.Alpha = 0

        self.GiveAway.Paint = function(s, w, h)
            s.Alpha = Lerp(FrameTime() * 8, s.Alpha, s:IsHovered() and 200 or 0)
            local percent = s.Alpha / 200

            if (s.Alpha > 5) then
                surface.SetTexture(glow)
                surface.SetDrawColor(75, 255, 0, s.Alpha * .5)
                DisableClipping(true)
                surface.DrawTexturedRectRotated(w / 2, h / 2, percent * w * 2, percent * h * 2, 0)
                DisableClipping(false)
            end

            draw.RoundedBox(4, percent * 2, percent * 2, w - percent * 4, h - percent * 4, Color(6, 6, 6))
            draw.RoundedBox(4, percent * 2, percent * 2, w - percent * 4, h - percent * 4, Color(255, 255, 255, s.Alpha / 25))
        end

        self.GiveAway.DoClick = function()
            if (IsValid(self.Tabs[self.Tab]) and self.OldTab ~= self.Tabs[self.Tab]) then
                self.OldTab = self.Tabs[self.Tab]
                self.OldTab.ShouldUpdate = true
                self:PunchOverlay(self.OldTab)
            end

            for k, v in pairs(self.Tabs) do
                if v:IsValid() then
                    v:SetVisible(false)
                end
            end

            if (IsValid(self.gaPanel)) then
                self.gaPanel:Remove()
            end

            self.gaPanel = vgui.Create("aMenu.GiveAway", self)
        end
    end

    self.Cl = vgui.Create("DButton", self.Banner)
    self.Cl:Dock(RIGHT)
    self.Cl:SetWide(32)
    self.Cl:SetText("✕")
    self.Cl:SetFont("aMenuTitle")
    self.Cl:DockMargin(0, 0, 16, 0)
    self.Cl:SetTextColor(color_white)

    self.Cl.DoClick = function()
        DarkRP.closeF4Menu()
    end

    self.Cl.Paint = function() end
    self.Mx = vgui.Create("DButton", self.Banner)
    self.Mx:Dock(RIGHT)
    self.Mx:SetWide(32)
    self.Mx:SetText("1")
    self.Mx:SetFont("Marlet_32")
    self.Mx:DockMargin(0, 0, 16, 0)
    self.Mx:SetTextColor(color_white)

    self.Mx.DoClick = function()
        cookie.Set("F4_Max", cookie.GetNumber("F4_Max", 0) == 1 and 0 or 1)
        self:Resize()
    end

    self.Mx.Paint = function() end
    self.MenuBar = vgui.Create("DPanel", self)
    self.MenuBar:Dock(LEFT)
    self.MenuBar:SetWide(220)

    self.MenuBar.Paint = function(this, w, h)
        draw.RoundedBox(0, 0, 0, w, h - 36, Color(26, 26, 26, 255))
    end

    self.MenuBar.Info = vgui.Create("DPanel", self.MenuBar)
    self.MenuBar.Info:Dock(BOTTOM)
    self.MenuBar.Info:DockMargin(0, 4, 0, 0)
    self.MenuBar.Info:SetTall(96)

    self.MenuBar.Info.Paint = function(this, w, h)
        --draw.RoundedBox(4, 0, 77, w, 36, self.Col)
        draw.SimpleText(LocalPlayer():Nick(), "aMenuSubTitle", 60, 4, Color(255, 255, 255, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.RoundedBox(0, 62, 30, w - 68, 2, Color(255, 255, 255, 8))
        draw.SimpleText(LocalPlayer():getDarkRPVar("job"), "aMenu20", 60, 34, team.GetColor(LocalPlayer():Team()), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.RoundedBoxEx(16, 0, h - 36, w, 36, Color(6, 6, 6), false, false, true, false)
        draw.SimpleText(DarkRP.formatMoney(LocalPlayer():getDarkRPVar("money")), "aMenu22", w / 2, h - 28, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    self.MenuBar.Info.Avatar = vgui.Create("AvatarCircleMask", self.MenuBar.Info)
    self.MenuBar.Info.Avatar:SetPlayer(LocalPlayer(), 48)
    self.MenuBar.Info.Avatar:SetPos(8, 8)
    self.MenuBar.Info.Avatar:SetSize(48, 48)
    self.MenuBar.Info.Avatar:SetMaskSize(48 / 2)
    self.MenuBar.List = vgui.Create("XeninUI.ScrollPanel", self.MenuBar)
    self.MenuBar.List:Dock(FILL)
    self.MenuBar.List:DockMargin(2, 2, 2, 4)
    self.MenuBar.List.Paint = function(this, w, h) end
    self.Dashboard = vgui.Create("aMenuDashboard", self)
    self.Tab = 0
    self.Jobs = vgui.Create("aMenuContainer", self)
    self.Jobs:SetContents(RPExtraTeams)
    self.Ents = vgui.Create("aMenuEntBase", self)
    self.Ents:SetContents(DarkRPEntities, 1)
    self.Weapons = vgui.Create("aMenuEntBase", self)
    self.Weapons:SetContents(CustomShipments, 2)
    self.Shipments = vgui.Create("aMenuEntBase", self)
    self.Shipments:SetContents(CustomShipments, 3)
    self.Ammo = vgui.Create("aMenuEntBase", self)
    self.Ammo:SetContents(GAMEMODE.AmmoTypes, 4)
    self:AddCat("Dashboard", aMenu.HomeButton, self.Dashboard, aMenu.HomeColor)
    self:AddCat("Jobs", aMenu.JobsButton, self.Jobs, aMenu.JobColor)
    self:AddCat("Entities", aMenu.EntitiesButton, self.Ents, aMenu.EntitiesColor)
    self:AddCat("Weapons", aMenu.WeaponsButton, self.Weapons, aMenu.ShipmentsColor)
    self:AddCat("Shipments", aMenu.ShipmentsButton, self.Shipments, aMenu.ShipmentsColor)
    self:AddCat("Ammo", aMenu.AmmoButton, self.Ammo, aMenu.AmmoColor)
    hook.Run("OnPopulateF4Categories", self)
	self.Skills = vgui.Create("Skills", self)
	self:AddCat("Skills", Material("asapf4/weapon_customs.png"), self.Skills, aMenu.SkillsColor)
	self.DailyReward = vgui.Create("DailyReward", self)
	self:AddCat("DailyReward", Material("asapf4/calendar.png"), self.DailyReward, aMenu.SkillsColor)
	self.SettingsPanel = vgui.Create("ASAP.Settings", self)
    self:AddCat("Settings", aMenu.SettingsButton, self.SettingsPanel, aMenu.SettingsColor)
	
    if not DarkRP.disabledDefaults["modules"]["hungermod"] then
        self.Food = vgui.Create("aMenuEntBase", self)
        self.Food:SetContents(FoodItems, 5)
        self:AddCat("Food", aMenu.FoodButton, self.Food)
    end

    self.Rules = vgui.Create("aMenuWebBase", self)
    self.Rules:SetLink(aMenu.RulesLink)
    self:AddCat("Rules", aMenu.RulesButton, self.Rules, aMenu.RulesColor)
	
    if aMenu.WebsiteLink ~= "" then
        self.Website = vgui.Create("aMenuWebBase", self)
        self.Website:SetLink(aMenu.WebsiteLink)
        self:AddCat("Website", aMenu.WebButton, self.Website)
    end
	
	if aMenu.DiscordLink ~= "" then
        self.Discord = vgui.Create("aMenuWebBase", self)
        self.Discord:SetLink(aMenu.DiscordLink)
        self:AddCat("Discord", aMenu.WebButton, self.Discord)
    end

    if aMenu.WorkshopLink ~= "" then
        self.Workshop = vgui.Create("aMenuWebBase", self)
        self.Workshop:SetLink(aMenu.WorkshopLink)
        self:AddCat("Workshop", aMenu.WorkshopButton, self.Workshop, aMenu.WorkshopColor)
    end

    self.MenuBar:SetWide(self.maxWide)

    for k, v in pairs(self.Tabs) do
        if v:IsValid() then
            v:SetVisible(false)
        end
    end

    self.Tabs[LAST_TAB or 2]:SetVisible(true)
    self.Tab = LAST_TAB or 2

    if aMenu.HideUnavailableTabs then
        self:CheckTabs()
    end

    self:SetupOverlay()
end

function PANEL:Resize()
    self.IsFull = cookie.GetNumber("F4_Max", 0) == 1

    if (not self.IsFull) then
        self:SetSize(ScrW() * .9, ScrH() * .9)
        self:Center()
    else
        self:SetSize(ScrW(), ScrH())
        self:Center()
    end
end

function PANEL:SetupOverlay()
    /*
    self.TabHandler = RT.Create("RT_TabHandler" .. math.Rand(1, CurTime()), self:GetWide() - self.MenuBar:GetWide(), self:GetTall() - 42)
    self.OldTab = nil

    hook.Add("HUDPaint", self, function()
        local panel = self.OldTab

        if (IsValid(panel)) then
            local x, y = panel:LocalToScreen(0, 0)
            local w, h = panel:GetSize()

            if (not panel.DoingRendering and panel.ShouldUpdate) then
                panel.ShouldUpdate = nil
                RT.Pop(self.TabHandler)
                draw.RoundedBox(6, 0, 0, w, h, XeninUI.Theme.Background)
                panel:PaintAt(0, 0)
                RT.Push()
            end
        end
    end)
    */
end

function PANEL:PunchOverlay(panel)
    hook.Remove("DrawOverlay", self)
    self.TabProgress = 0

    hook.Add("DrawOverlay", self, function()
        if not RT.Material(self.TabHandler) then
            hook.Remove("DrawOverlay", self)

            return
        end

        local x, y = panel:LocalToScreen(0, 0)
        local w, h = panel:GetSize()
        local p = self.TabProgress / 100
        self.TabProgress = Lerp(FrameTime() * 8, self.TabProgress, 101)
        surface.SetMaterial(RT.Material(self.TabHandler))
        surface.SetDrawColor(Color(255, 255, 255, 255 - 255 * p))
        local dWide = w * p
        surface.DrawTexturedRectUV(x + dWide, y + p * 64, w - dWide, h - p * 128, p, 0, 1, 1)

        if (self.TabProgress > 100) then
            hook.Remove("DrawOverlay", self)
        end
    end)
end

local degree = surface.GetTextureID("vgui/gradient-l")

function PANEL:AddCat(name, icon, panel, deg)
    if aMenu.AllowedTabs[name] == false then
        panel:Remove()
        self.Tab = 1

        return
    end

    if (not self.Categories) then
        self.Categories = {}
    end

    self.iTab = self.iTab + 1
    panel.Name = name
    table.insert(self.Tabs, panel)
    local cat = vgui.Create("DButton", self.MenuBar.List)
    cat:SetSize(self:GetParent():GetWide(), 48)
    cat:DockMargin(0, 0, 0, 2)
    cat:Dock(TOP)
    cat.Name = name
    cat.ID = self.iTab
    cat.IconOn = Material(icon:GetName() .. "_on.png")
    surface.SetFont("aMenu20")
    local tx, _ = surface.GetTextSize(name)

    if (not self.maxWide or self.maxWide < tx + 96) then
        self.maxWide = tx + 96
    end

    if (cat.IconOn:IsError()) then
        cat.IconOn = Material("asapf4/" .. string.lower(name) .. "_on.png")
    end

    cat.ChildPanel = panel

    cat.DoClick = function(s)
        if panel.IsSitePage then
            panel:OpenPage()

            return
        end

        if (IsValid(self.Tabs[self.Tab]) and self.OldTab ~= self.Tabs[self.Tab]) then
            self.OldTab = self.Tabs[self.Tab]
            self.OldTab.ShouldUpdate = true
            self:PunchOverlay(self.OldTab)
        end

        self.Tab = table.KeyFromValue(self.Tabs, panel)

        for k, v in pairs(self.Tabs) do
            if v:IsValid() then
                v:SetVisible(false)
            end
        end

        if panel:IsValid() then
            panel:SetVisible(true)
            LAST_TAB = s.ID
        end

        self.LastSelected = panel
    end

    cat:SetText("")
    cat.deg = deg
    cat.fillLine = 0

    cat.Paint = function(this, w, h)
        local isSelected = panel.IsSitePage or self.Tab == table.KeyFromValue(self.Tabs, panel)

        if isSelected then
            cat.Col = this.deg[2]
        else
            cat.Col = Color(210, 210, 210)
        end

        draw.RoundedBox(4, 0, 0, w, h, Color(36, 36, 36))
        draw.SimpleText(string.upper(name), "aMenu20", 54, h / 2, cat.Col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        if (not panel.IsSitePage) then
            surface.SetDrawColor(Color(255, 255, 255, 255 - (this.fillLine / w) * 255))
            surface.SetMaterial(icon)
            surface.DrawTexturedRect(10, name == "Dashboard" and 7 or 8, 32, 32)
            surface.SetDrawColor(Color(255, 255, 255, 255 - (1 - this.fillLine / w) * 255))
            surface.SetMaterial(this.IconOn)
            surface.DrawTexturedRectUV(10, name == "Dashboard" and 7 or 8, 32 * this.fillLine / w, 32, 0, 0, this.fillLine / w, 1)
        else
            surface.SetDrawColor(color_white)
            surface.SetMaterial(this.IconOn)
            surface.DrawTexturedRect(10, name == "Dashboard" and 7 or 8, 32, 32)
        end

        if (not panel.IsSitePage) then
            this.fillLine = Lerp(FrameTime() * 4, this.fillLine, isSelected and w or 0)
            surface.DrawRect(0, h - 4, this.fillLine, 4)
            surface.SetTexture(degree)
            surface.SetDrawColor(this.deg[1])
            surface.DrawTexturedRectUV(0, h - 4, this.fillLine, 4, 0, 0, this.fillLine / w, 1)
        end
    end

    self.Categories[name] = cat
end

function PANEL:SetCategory(name)
    if (not IsValid(self.Categories[name])) then
        timer.Simple(.1, function()
            if IsValid(self) and self.SetCategory then
                self:SetCategory(name)
            end
        end)
    else
        self.Categories[name]:DoClick()
    end
end

function PANEL:OnKeyCodePressed(k)
    if k == KEY_F4 then
        DarkRP.toggleF4Menu()
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(self.IsFull and 0 or 16, 0, 0, w, h, Color(36, 36, 36, 255))

    if (LocalPlayer():InArena()) then
        self:Remove()

        return
    end
end

function PANEL:CheckTabs()
end

vgui.Register("aMenuBase", PANEL, "EditablePanel")