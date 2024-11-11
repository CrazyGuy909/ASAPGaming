local myGang = {}
local back = CreateClientConVar("gangs_showbackground", "0", true)
local PANEL = {}
local wallet = surface.GetTextureID("ui/gangs/wallet")
local currency = surface.GetTextureID("ui/gangs/currency")

surface.CreateFont("Gangs.Huge", {
    font = "Montserrat",
    size = 42
})

surface.CreateFont("Gangs.Medium", {
    font = "Montserrat",
    size = 32
})

surface.CreateFont("Gangs.Small", {
    font = "Montserrat",
    size = 24
})

surface.CreateFont("Gangs.Tiny", {
    font = "Montserrat",
    size = 20
})

function PANEL:Init()
    if (not asapgangs.gangList) then
        asapgangs.gangList = {}
    end

    myGang = asapgangs.gangList[LocalPlayer():GetGang()] or {}

    if (not myGang.Level or not myGang.Experience) then
        myGang.Level = 1
        myGang.Experience = 1
    end

    if (not myGang.Name) then
        self:CreateGang()

        return
    end

    self.Header = vgui.Create("DPanel", self)
    self.Header:Dock(TOP)
    self.Header:SetTall(80)

    self.Header.Paint = function(s, w, h)
        if (not myGang.Name) then return end
        local usesBackground = back:GetBool()
        surface.SetDrawColor(26, 26, 26, usesBackground and 175 or 255)
        surface.DrawRect(0, 0, w, h)
        local tx, _ = draw.SimpleText(myGang.Name, "Gangs.Huge", 108, 4, color_white)
        local tagx, _ = draw.SimpleText(myGang.Tag, "Gangs.Medium", 108, 42, Color(150, 150, 150))
        local start = 108 + tagx + 14
        local dx, _ = surface.GetTextSize(myGang.Experience)
        draw.RoundedBox(4, 108 + tagx + 8, h - 32, dx + 12, 22, Color(36, 36, 36))
        draw.SimpleText(myGang.Experience, "XeninUI.Query.Text", 108 + tagx + 14, h - 29, color_white)
        local mx, _ = draw.SimpleText(DarkRP.formatMoney(myGang.Money), "XeninUI.Navbar.Button", w - 16, 10, color_white, TEXT_ALIGN_RIGHT)
        local cx, _ = draw.SimpleText(DarkRP.formatMoney(myGang.Credits), "XeninUI.Navbar.Button", w - 16, 38, color_white, TEXT_ALIGN_RIGHT)
        surface.SetDrawColor(Color(255, 255, 255, 100))
        surface.SetTexture(wallet)
        surface.DrawTexturedRectRotated(w - 16 - mx - 24, 22, 32, 32, 0)
        surface.SetTexture(currency)
        surface.DrawTexturedRectRotated(w - 16 - cx - 20, 52, 28, 28, 0)
    end

    self.Edit = vgui.Create("DButton", self.Header)
    self.Edit:SetText("")

    self.Edit.DoClick = function()
        self:GetParent():GetParent():CreateNew(true)
    end

    self.Edit.Paint = function(s, w, h)
        local c = s:IsHovered() and 46 or 16
        draw.RoundedBox(h / 2, 0, 0, w, h, Color(c, c, c))
        surface.SetMaterial(Material("ui/gangs/edit"))
        surface.SetDrawColor(255, 255, 255, c * 5)
        surface.DrawTexturedRectRotated(w / 2, h / 2, h * .7, h * .7, 0)
    end

    self.Header.PerformLayout = function(s, w, h)
        if (not myGang.Name) then return end
        surface.SetFont("Gangs.Huge")
        local tx, _ = surface.GetTextSize(myGang.Name)
        self.Edit:SetPos(tx + 120, 8)
        self.Edit:SetSize(42, 42)
    end

    self.Avatar = vgui.Create("XeninUI.CircledMask", self.Header)
    self.Avatar:Dock(LEFT)
    self.Avatar:SetWide(64)
    self.Avatar:DockMargin(18, 8, 8, 8)
    self.Avatar:SetVertices(32)
    self.Avatar:SetMouseInputEnabled(true)
    self.Avatar:SetCursor("hand")

    self.Avatar.Drawable = function(s, w, h)
        surface.SetDrawColor(16, 16, 16)
        surface.DrawRect(0, 0, w, h)

        if (self.GangIcon) then
            local max = math.max(w, h)
            surface.SetMaterial(self.GangIcon)
            surface.SetDrawColor(255, 255, 255, s:IsHovered() and 255 or 175)
            surface.DrawTexturedRectRotated(w / 2, h / 2, max, max, 0)
        end
    end

    self.Avatar.DoClick = function()
        local menu = XeninUI:Menu()

        menu:AddOption("Exit gang", function()
            Derma_Query("Are you sure do you want to leave this gang?", "Leaving your gang", "Yes", function()
                net.Start("Gangs.Leave")
                net.SendToServer()
            end, "Cancel")
        end)

        menu:AddOption("Cancel", function() end)
        menu:Open()
    end

    self.Avatar.OnMousePressed = function()
        local menu = XeninUI:Menu()

        menu:AddOption("Exit gang", function()
            Derma_Query("Are you sure do you want to leave this gang?", "Leaving your gang", "Yes", function()
                net.Start("Gangs.Leave")
                net.SendToServer()
                GANGS:Remove()
                asapgangs.gangList[LocalPlayer():GetGang()] = nil
            end, "Cancel")
        end)

        menu:AddOption("Cancel", function() end)
        menu:Open()
    end

    self.Sidebar = vgui.Create("XeninUI.Sidebar", self)

    self.Sidebar.Paint = function(s, w, h)
        local usesBackground = back:GetBool()
        surface.SetDrawColor(36, 36, 36, usesBackground and 225 or 255)
        surface.DrawRect(0, 0, w, h)
    end

    local cont = vgui.Create("DPanel", self)
    cont:Dock(FILL)
    cont.Paint = function() end
    self.Perks = vgui.Create("DPanel", cont)
    self.Perks:Dock(RIGHT)
    self.Perks:SetWide(172)

    self.Perks.Paint = function(s, w, h)
        local usesBackground = back:GetBool()
        surface.SetDrawColor(16, 16, 16, usesBackground and 175 or 255)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("PERKS", "Gangs.Medium", w / 2 - 8, 16, color_white, TEXT_ALIGN_CENTER)
        local i = 0

        for k, v in pairs(UPGRADE_TEST) do
            if (myGang.Shop.Upgrades[k]) then
                surface.SetMaterial(Material(v.Icon))
                surface.SetDrawColor(Color(255, 255, 255, 200))
                surface.DrawTexturedRectRotated(w / 2 - 8, 86 + 120 * i, 64, 64, 0)
                draw.SimpleText(v.Name, "Gangs.Small", w / 2 - 8, 86 + 120 * i + 32, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER)
                draw.SimpleText(asapgangs.GetUpgrade(LocalPlayer():GetGang(), k) .. "/" .. v.Levels, "Gangs.Small", w / 2 - 8, 86 + 116 * i + 56, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER)
                i = i + 1
            end
        end
    end

    self.Body = vgui.Create("DPanel", cont)
    self.Body:Dock(FILL)
    self.Body:DockMargin(0, 0, 0, 0)
    self.Body.Paint = function(s, w, h) end
    self.Sidebar:SetBody(self.Body)
    file.CreateDir("gangs/avatar")
    self:LoadAvatar()
    self:CreateOptions()
end

function PANEL:LoadAvatar()
    if (not myGang.Icon) then return end
    local link = string.Replace(myGang.Icon, "https://i.imgur.com/", "")

    if file.Exists("gangs/avatar/" .. link, "DATA") then
        self.GangIcon = Material("../data/gangs/avatar/" .. link)
    else
        http.Fetch(myGang.Icon, function(data)
            file.Write("gangs/avatar/" .. link, data)
            if not IsValid(self) then return end
            self.GangIcon = Material("../data/gangs/avatar/" .. link)
        end)
    end
end

function PANEL:CreateGang()
    self.JC = vgui.Create("DPanel", self)
    self.JC.Paint = function() end
    self.Join = vgui.Create("XeninUI.Button", self.JC)
    self.Join:SetText("Join")

    self.Join.DoClick = function()
        if not IsValid(GANGS) then return end
        GANGS.NavBar:SetActive("Recruitment")
    end
    
    self.Create = vgui.Create("XeninUI.Button", self.JC)
    self.Create:SetText("Create")
    
    self.Create.DoClick = function()
        self:GetParent():GetParent():CreateNew()
    end
end

function PANEL:PerformLayout(w, h)
    if IsValid(self.JC) then
        self.JC:SetSize(w * .5, 48)
        self.JC:SetPos(w * .25 - 8, h / 2 - 26)
        self.Join:Dock(LEFT)
        self.Join:DockMargin(0, 0, 16, 0)
        self.Join:SetWide(self.JC:GetWide() / 2)
        self.Create:Dock(FILL)
        self.Join:DockMargin(16, 0, 16, 0)
        --self.Join:DockMargin(8, 0, 0, 0)
    end
end

function PANEL:Paint(w, h)
    if (myGang.Icon) then return end
    draw.SimpleText("Uh oh! Seems like you don't have a Gang!", "Gangs.Medium", w / 2, h / 2 - 96, Color(235, 235, 235), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("What about if you join one or create a new one?", "Gangs.Medium", w / 2, h / 2 - 56, Color(235, 235, 235), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function PANEL:GenerateProfile()
    local pnl = vgui.Create("DPanel")
    pnl.Paint = function() end
    if (not myGang.Members) then return end
    surface.SetFont("Gangs.Medium")
    local memLevel = asapgangs.GetUpgrade(LocalPlayer():GetGang(), "Members")
    local wide, _ = surface.GetTextSize("Members: " .. table.Count(myGang.Members) .. "/" .. (UPGRADE_TEST["Members"].Data[memLevel] or 10))
    local container = vgui.Create("DPanel", pnl)
    container:Dock(FILL)

    container.Paint = function(s, w, h)
        if (myGang) then
            draw.SimpleText("Members: " .. table.Count(myGang.Members) .. "/" .. (UPGRADE_TEST["Members"].Data[memLevel] or 6), "Gangs.Medium", 12, 8, color_white)
        end
    end

    local options = vgui.Create("DPanel", container)
    options:Dock(TOP)
    options:SetTall(32)
    options:DockMargin(12, 8, 0, 28)

    options.Paint = function(s, w, h)
        DisableClipping(true)
        draw.SimpleText("#", "Gangs.Small", 28, h + 4, Color(255, 255, 255, 100))
        draw.SimpleText("Name", "Gangs.Small", 84, h + 4, Color(255, 255, 255, 100))
        draw.SimpleText("Rank", "Gangs.Small", w / 2, h + 4, Color(255, 255, 255, 100), TEXT_ALIGN_CENTER)
        DisableClipping(false)
    end

    options.All = vgui.Create("XeninUI.Button", options)
    options.All:SetText("All")
    options.All:Dock(LEFT)
    options.All:SetWide(64)
    options.All:DockMargin(wide + 12, 0, 16, 0)

    options.All.DoClick = function()
        for k, v in pairs(pnl.Members) do
            v:Remove()
        end

        for k, v in pairs(myGang.Members) do
            local card = self:CreatePlayerCard(v, pnl.Body, function(sid64) return true end)

            if IsValid(card) then
                table.insert(pnl.Members, card)
            end
        end
    end

    options.Rank = vgui.Create("XeninUI.Button", options)
    options.Rank:SetText("-Rank-")
    options.Rank:Dock(RIGHT)
    options.Rank:SetWide(96)

    options.Rank.DoClick = function()
        local menu = XeninUI:Menu()

        for k, v in pairs(myGang.Ranks or {}) do
            menu:AddOption(k, function()
                for k, v in pairs(pnl.Members) do
                    v:Remove()
                end

                for i, sid64 in pairs(myGang.Ranks[k].Members) do
                    local card = self:CreatePlayerCard(sid64, pnl.Body, function(sid64) return myGang.Ranks[k].Members[i] end)

                    if IsValid(card) then
                        table.insert(pnl.Members, card)
                    end
                end
            end)
        end

        menu:Open()
    end

    options.Online = vgui.Create("XeninUI.Button", options)
    options.Online:SetText("Online")
    options.Online:Dock(LEFT)
    options.Online:SetWide(128)

    options.Online.DoClick = function()
        for k, v in pairs(pnl.Members) do
            v:Remove()
        end

        for k, v in pairs(myGang.Members) do
            local card = self:CreatePlayerCard(v, pnl.Body, function(sid64) return IsValid(player.GetBySteamID64(sid64)) end)

            if IsValid(card) then
                table.insert(pnl.Members, card)
            end
        end
    end

    options.Offline = vgui.Create("XeninUI.Button", options)
    options.Offline:SetText("Offline")
    options.Offline:Dock(LEFT)
    options.Offline:DockMargin(16, 0, 0, 0)
    options.Offline:SetWide(128)

    options.Offline.DoClick = function()
        for k, v in pairs(pnl.Members) do
            v:Remove()
        end

        for k, v in pairs(myGang.Members) do
            local card = self:CreatePlayerCard(v, pnl.Body, function(sid64) return not IsValid(player.GetBySteamID64(sid64)) end)

            if IsValid(card) then
                table.insert(pnl.Members, card)
            end
        end
    end

    pnl.Body = vgui.Create("XeninUI.ScrollPanel", container)
    pnl.Body:DockMargin(8, 8, 0, 8)
    pnl.Body:Dock(FILL)
    pnl.Members = {}

    local mentioned = {}
    for k, v in pairs(myGang.Members) do
        local card = self:CreatePlayerCard(v, pnl.Body)

        if IsValid(card) then
            table.insert(pnl.Members, card)
            mentioned[v] = true
        end
    end

    for k, v in pairs(asapgangs.GetMembers(LocalPlayer():GetGang())) do
        if mentioned[v] or v == LocalPlayer() or v:GetGang() != LocalPlayer():GetGang() then continue end
        local card = self:CreatePlayerCard(v, pnl.Body, nil, true)
        card.isTemp = true

        if IsValid(card) then
            table.insert(pnl.Members, card)
        end
    end

    self.RefreshUsers = function()
        for k, v in pairs(pnl.Members) do
            v:Remove()
        end

        for k, v in pairs(myGang.Members) do
            local card = self:CreatePlayerCard(v, pnl.Body, function(sid64) return true end)

            if IsValid(card) then
                table.insert(pnl.Members, card)
            end
        end
    end
    return pnl
end

function PANEL:CreatePlayerCard(sid64, body, filter, istemp)
    if (filter and not filter(sid64)) then return end
    local box = vgui.Create("DPanel", body)
    box:Dock(TOP)
    box:SetTall(72)
    box:DockMargin(0, 0, 0, 4)
    box:SetText("")
    box.Name = ""

    if (isstring(sid64)) then
        steamworks.RequestPlayerInfo(sid64, function(name)
            if IsValid(box) then
                box.Name = name
            end
        end)
    elseif (isentity(sid64)) then
        box.Name = sid64:Nick()
    end

    box.Rank = "User"

    for k, v in pairs(myGang.Ranks or {}) do
        if (table.HasValue(v.Members or {}, sid64)) then
            box.Rank = k
            box.RankColor = GANG_COLORS[v.Color or 1]
            break
        end
    end

    box.Alpha = 0

    box.Paint = function(s, w, h)
        local isHover = s:IsHovered() or s:IsChildHovered()
        draw.RoundedBox(8, 0, 0, w, h, isHover and Color(36, 36, 36) or Color(26, 26, 26))
        draw.SimpleText(s.Name, "Gangs.Medium", 84, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(s.Rank, "XeninUI.Query.Text", w / 2, h / 2, s.RankColor or Color(255, 255, 255, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        s.Alpha = Lerp(FrameTime() * (isHover and 4 or 10), s.Alpha, isHover and 255 or 0)

        if IsValid(s.Edit) then
            s.Edit:SetAlpha(s.Alpha)
        end

        if IsValid(s.Settings) then
            s.Settings:SetAlpha(s.Alpha)
        end
    end

    box.Icon = vgui.Create("XeninUI.Avatar", box)
    if (isstring(sid64)) then
        box.Icon:SetSteamID(sid64, 128)
    else
        box.Icon:SetPlayer(sid64, 128)
    end

    box.Icon:SetVertices(32)
    box.Icon:Dock(LEFT)
    box.Icon:SetWide(64)
    box.Icon:DockMargin(8, 8, 8, 8)
    if (LocalPlayer():SteamID64() != sid64 && not istemp && LocalPlayer():GangsHasPermission("EDIT_ROLES")) then
        box.Edit = vgui.Create("XeninUI.Button", box)
        box.Edit:Dock(RIGHT)
        box.Edit:SetWide(48)
        box.Edit:SetText("")
        box.Edit:DockMargin(8, 12, 12, 12)
        box.Edit:SetAlpha(0)
        box.Edit:SetIcon("ui/gangs/edit")

        box.Edit.DoClick = function()
            local menu = XeninUI:Menu()
            local ranks = table.Copy(asapgangs.gangList[LocalPlayer():GetGang()].Ranks)
            ranks["User"] = {}

            for k, v in pairs(ranks) do
                menu:AddOption(k, function()
                    net.Start("Gangs.SetRank")
                    net.WriteString(sid64)
                    net.WriteString(k)
                    net.SendToServer()
                end)
            end

            menu:AddOption("Cancel")
            menu:Open()
        end
    end

    if (LocalPlayer():SteamID64() != sid64 && LocalPlayer():GangsHasPermission("KICK_MEMBERS")) then
        box.Settings = vgui.Create("XeninUI.Button", box)
        box.Settings:Dock(RIGHT)
        box.Settings:SetWide(48)
        box.Settings:SetText("")
        box.Settings:DockMargin(8, 12, 0, 12)
        box.Settings:SetAlpha(0)
        box.Settings:SetIcon("ui/gangs/options")

        box.Settings.DoClick = function()
            local menu = XeninUI:Menu()

            menu:AddOption("Yes, kick " .. box.Name, function()
                net.Start("Gangs.KickMember")
                net.WriteBool(isstring(sid64))
                if (isstring(sid64)) then
                    net.WriteString(sid64)
                else
                    net.WriteEntity(sid64)
                end
                net.SendToServer()
                table.RemoveByValue(asapgangs.gangList[LocalPlayer():GetGang()].Members, sid64)
                self:RefreshUsers()
            end)

            menu:AddOption("Cancel")
            menu:Open()
        end
    end

    return box
end

net.Receive("Gangs.KickMember", function(l)
    local ply = net.ReadEntity()
    local tag = net.ReadString()
    notification.AddLegacy(ply:Nick() .. " kicked out of your gang", NOTIFY_ERROR, 5)
    asapgangs.gangList[tag] = nil
    ply:SetNWString("Gang", "")
    ply:SetNWString("Gang.Rank", "User")
end)

function PANEL:CreateOptions()
    self.Sidebar:AddTab("Profile", self:CreateSideButton("user", Color(240, 40, 255)), self:GenerateProfile())

    if (LocalPlayer():GangsHasPermission("PURCHASE") or LocalPlayer():GangsHasPermission("CHANGE_BACK")) then
        self.Sidebar:AddTab("Store", self:CreateSideButton("store", Color(40, 207, 255)), vgui.Create("Gangs.Shop"))
    end

    if (LocalPlayer():GangsHasPermission("EDIT_ROLES")) then
        self.Sidebar:AddTab("Roles", self:CreateSideButton("add", Color(90, 255, 100)), vgui.Create("Gangs.Roles"))
    end

    self.Sidebar:AddTab("Savings", self:CreateSideButton("savings", Color(255, 200, 50)), vgui.Create("Gangs.Bank"))
    self.Sidebar:SetActive("Profile")

    local option = vgui.Create("DPanel", self.Sidebar)
    option:Dock(BOTTOM)
    option:SetTall(96)
    option:DockMargin(8, 0, 8, 8)
    option.Paint = function(s, w, h)
        surface.SetMaterial(Material("ui/gangs/upgrades/halo"))
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRectRotated(w / 2, w / 2 - 8, w / 2, w / 2, 0)
        draw.SimpleText("Halo", "XeninUI.TextEntry", w / 2, h - 32, color_white, 1, 1)
    end
    option.Tick = vgui.Create("XeninUI.Checkbox", option)
    option.Tick:Dock(BOTTOM)
    option.Tick:SetConVar("asap_gangs_halo")

    option:SetVisible(asapgangs.GetUpgrade(LocalPlayer():GetGang(), "Halo") > 0)
    halo_option = option
end

PANEL.Icons = {}

function PANEL:CreateSideButton(icon, clr)
    if (not self.Icons[icon]) then
        self.Icons[icon] = surface.GetTextureID("ui/gangs/" .. icon)
    end

    local btn = vgui.Create("DButton")
    btn:SetText("")
    btn.Color = Vector(255, 255, 255)
    btn.Power = 0

    btn.Paint = function(s, w, h)
        if (not IsValid(self)) then
            self:Remove()

            return
        end

        s.Power = s.Selected and 1 or Lerp(FrameTime() * 5, s.Power, s:IsHovered() and 1 or 0)
        s.Color = LerpVector(s.Power, Vector(255, 255, 255), Vector(clr.r, clr.g, clr.b))
        surface.SetDrawColor(s.Color.x, s.Color.y, s.Color.z, s.Power * 150 + 75)
        surface.SetTexture(self.Icons[icon])
        render.PushFilterMin(TEXFILTER.ANISOTROPIC)
        surface.DrawTexturedRectRotated(w / 2, h / 2, w * .7, h * .7, 0)
        render.PopFilterMin(TEXFILTER.ANISOTROPIC)
    end

    return btn
end

vgui.Register("Gangs.Profile", PANEL, "DPanel")
