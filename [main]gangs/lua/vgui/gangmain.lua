local myGang = {}
local back = CreateClientConVar("gangs_showbackground", "0", true)
local PANEL = {}
PANEL.BackAlpha = 0

function PANEL:Init()
    GANG = self
    myGang = (asapgangs.gangList or {})[LocalPlayer():GetGang()] or {}
    if (not self.IsPanel) then
        self:SetSize(ScrW() * .8, ScrH() * .8)
        self:Center()
        self:MakePopup()
        self:SetTitle("ASAP Gangs")
    end
    self.NavBar = vgui.Create("XeninUI.Navbar", self)
    self.NavBar:Dock(TOP)
    self.NavBar:SetTall(48)

    if (back:GetBool()) then
        self:DoBackground()
    end

    self.Body = vgui.Create("DPanel", self)
    self.Body:Dock(FILL)

    self.Body.Paint = function(s, w, h)
        surface.SetDrawColor(16, 16, 16)
        surface.DrawRect(0, 0, w, h)

        if self.BackgroundMat then
            surface.SetMaterial(self.BackgroundMat)
            surface.SetDrawColor(Color(255, 255, 255, self.BackAlpha))

            if (self.BackAlpha < 255) then
                self.BackAlpha = Lerp(FrameTime() * 2, self.BackAlpha, 260)
            end

            local wide, height = self.BackgroundMat:GetTexture("$basetexture"):Width(), self.BackgroundMat:GetTexture("$basetexture"):Height()
            local scale = w / wide
            surface.DrawTexturedRect(0, 0, wide * scale, height * scale, 0)
        end
    end

    self.NavBar:SetBody(self.Body)
    self.NavBar:AddTab("My Gang", "Gangs.Profile")
    if (LocalPlayer():GetGang() ~= "") then
        self.NavBar:AddTab("Inventory", "gangInventory")
    end
    self.NavBar:AddTab("Recruitment", "Gangs.Recruitment")
    self.NavBar:AddTab("Leaderboard", "Gangs.Leaderboard")

    if (LocalPlayer():GangsHasPermission("VIEW_ACTIVITY")) then
        --self.NavBar:AddTab("Logs", "Gangs.Logs")
    end

    self.NavBar:SetActive(LocalPlayer():GetGang() == "" and "Recruitment" or "My Gang")
    self.Background = vgui.Create("XeninUI.Button", self.NavBar)
    self.Background:Dock(RIGHT)
    self.Background:DockMargin(8, 8, 8, 8)
    self.Background:SetWide(32)
    self.Background:SetText("")
    self.Background:SetIcon("ui/gangs/picture")

    self.Background.DoClick = function()
        back:SetBool(not back:GetBool())
        self:DoBackground()
    end
end

function PANEL:CreateNew(isEdit)
    if (IsValid(CREATE_GANG)) then
        CREATE_GANG:Remove()
    end

    CREATE_GANG = vgui.Create("XeninUI.Frame")
    CREATE_GANG:SetSize(600, 320)
    CREATE_GANG:Center()
    CREATE_GANG:MakePopup()
    CREATE_GANG:SetTitle("New Gang")
    CREATE_GANG:SetBackgroundBlur(true)
    local cont = vgui.Create("DPanel", CREATE_GANG)
    cont:Dock(FILL)
    cont:DockMargin(8, 8, 8, 8)
    cont.Paint = function(s, w, h) end
    local name = Label("Gang's Name", cont)
    name:Dock(TOP)
    name:SetFont("XeninUI.TextEntry")
    CREATE_GANG.Name = vgui.Create("XeninUI.TextEntry", cont)
    CREATE_GANG.Name:Dock(TOP)
    CREATE_GANG.Name:DockMargin(0, 0, 0, 8)

    if (isEdit) then
        CREATE_GANG.Name:SetText(myGang.Name)
    end

    local tag = Label("Tag", cont)
    tag:Dock(TOP)
    tag:SetFont("XeninUI.TextEntry")
    CREATE_GANG.Tag = vgui.Create("XeninUI.TextEntry", cont)
    CREATE_GANG.Tag:Dock(TOP)
    CREATE_GANG.Tag:DockMargin(0, 0, 0, 16)

    if (isEdit) then
        CREATE_GANG.Tag:SetText(myGang.Tag)
        CREATE_GANG.Tag.textentry:SetEditable(false)
    end

    local avatarPanel = vgui.Create("DPanel", cont)
    avatarPanel:Dock(TOP)
    avatarPanel:SetTall(72)
    avatarPanel:DockMargin(0, 0, 8, 0)
    avatarPanel.Paint = function() end
    local avatar = vgui.Create("XeninUI.CircledMask", avatarPanel)
    avatar:Dock(LEFT)
    avatar:SetWide(72)
    avatar:SetVertices(32)
    avatar:DockMargin(4, 0, 16, 0)

    avatar.Drawable = function(s, w, h)
        draw.RoundedBox(h / 2, 0, 0, w, h, Color(56, 56, 56))
        surface.SetDrawColor(color_white)

        if (s.Icon) then
            surface.SetMaterial(s.Icon)
            surface.DrawTexturedRect(2, 2, w - 4, h - 4)
        end
    end

    local icon = Label("Icon URL (Only Imgur)", avatarPanel)
    icon:Dock(TOP)
    icon:SetFont("XeninUI.TextEntry")
    CREATE_GANG.URL = vgui.Create("XeninUI.TextEntry", avatarPanel)
    CREATE_GANG.URL:Dock(FILL)
    CREATE_GANG.URL:DockMargin(0, 8, 0, 0)
    CREATE_GANG.URL:SetText(self.Avatar or "")

    CREATE_GANG.URL.OnEnter = function(s, val)
        if (string.find(val, "imgur", 1, true) and (string.EndsWith(val, ".png") or string.EndsWith(val, ".jpg" or string.EndsWith(val, ".jpeg")))) then
            http.Fetch(val, function(data)
                local link = string.Replace(val, "https://i.imgur.com/", "")
                file.Write("gangs/roles/" .. link, data)
                if IsValid(avatar) then
                    avatar.Icon = Material("../data/gangs/roles/" .. link)
                end
            end)
        else
            Derma_Message("Your link must come from imgur and must be jpg, jpeg or png", "Error", "Okay")
        end
    end

    if (isEdit) then
        CREATE_GANG.URL:SetText(myGang.Icon)
        CREATE_GANG.URL:OnEnter(myGang.Icon)
    end

    local save = vgui.Create("XeninUI.Button", cont)
    local canRemove = LocalPlayer():GangsHasPermission("DISBAND_GANG")
    save:Dock((isEdit and canRemove) and LEFT or FILL)

    if (isEdit and canRemove) then
        local del = vgui.Create("XeninUI.Button", cont)
        del:Dock(FILL)
        del:SetText("Disband Gang (REMOVE)")
        del:DockMargin(4, 16, 8, 4)

        del.DoClick = function()
            Derma_Query("Are you way sure do you want to disband this gang?", "WARNING", "Yes", function()
                net.Start("Gangs.Disband")
                net.SendToServer()
                CREATE_GANG:Remove()

                if IsValid(GANGS) then
                    GANGS:Remove()
                end
            end, "No")
        end

        save:SetWide(CREATE_GANG:GetWide() / 2 - 16)
    end

    save:DockMargin(4, 16, 8, 4)
    save:SetText(isEdit and "Save & Continue" or "Create Gang " .. DarkRP.formatMoney(GANG_PRICE))

    save.DoClick = function(s, w, h)
        local tag = CREATE_GANG.Tag:GetText()

        if (#tag > 6) then
            Derma_Message("Your Tag must have 6 characters max", "Error", "Continue")

            return
        elseif (#tag < 3) then
            Derma_Message("Your Tag must have 3 characters min", "Error", "Continue")

            return
        elseif (string.find(tag, "[%c%p']")) then
            Derma_Message("Tags shouldn't contain any special character", "Error", "Continue")

            return
        end

        net.Start(isEdit and "Gangs.Edit" or "Gangs.Create")
        net.WriteString(CREATE_GANG.Name:GetText())

        if (not isEdit) then
            net.WriteString(tag)
        end

        net.WriteString(CREATE_GANG.URL:GetText())
        net.SendToServer()
        CREATE_GANG:Remove()
    end
end

function PANEL:DoBackground()
    if (not back:GetBool()) then
        self.BackgroundMat = nil
        self.BackAlpha = 0

        return
    end

    if (myGang.Background and file.Exists("gangs/backgrounds/" .. myGang.Background .. ".jpg", "DATA")) then
        self.BackgroundMat = Material("../data/gangs/backgrounds/" .. myGang.Background .. ".jpg")
        self.BackAlpha = 0
    elseif (myGang.Background and myGang.Background ~= "") then
        http.Fetch(asapgangs.backgrounds[myGang.Background].URL, function(data)
            file.CreateDir("gangs")
            file.Write("gangs/backgrounds/" .. myGang.Background .. ".jpg", data)

            if IsValid(self) then
                self.BackgroundMat = Material("../data/gangs/backgrounds/" .. myGang.Background .. ".jpg")
                self.BackAlpha = 0
            end
        end)
    end
end

vgui.Register("Gangs.Main", PANEL, "XeninUI.Frame")

local PANEL2 = table.Copy(PANEL)
PANEL2.IsPanel = true
vgui.Register("Gangs.MainF4", PANEL2, "DPanel")

hook.Add("OnPopulateF4Categories", "GangFramePanel", function(pnl)
    pnl.GangsPanel = vgui.Create("Gangs.MainF4", pnl)
    pnl:AddCat("Gangs", Material("asapf4/gangs.png"), pnl.GangsPanel, {Color(51, 13, 120), Color(41, 200, 200)})
    pnl.GangsPanel:Dock(FILL)
end)

net.Receive("Gangs.RemovePanel", function()
    if IsValid(GANGS) then
        GANGS:Remove()
    end
end)

concommand.Add("open_gangs", function()
    if IsValid(GANGS) then
        GANGS:Remove()
    end

    GANGS = vgui.Create("Gangs.Main")
end)

local commands = {"!gangs", "!gang", "!clan", "!clans", "!gay", "!biggergay"}

hook.Add("OnLoungePlayerChat", "GangCommands", function(f, ply, strText)
    
    if (ply ~= LocalPlayer()) then return end

    -- if the player typed /hello then
    if (table.HasValue(commands, strText)) then
        RunConsoleCommand("open_gangs")
        -- this suppresses the message from being shown

        return true
    end
end)
