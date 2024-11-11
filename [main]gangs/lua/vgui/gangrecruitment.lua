local PANEL = {}
local back = ConVarExists("gangs_showbackground") and GetConVar("gangs_showbackground") or CreateClientConVar("gangs_showbackground", "0", true)

function PANEL:Init()
    if (LocalPlayer():GetGang() != "") then
        self.Left = vgui.Create("DPanel", self)
        self.Left:Dock(LEFT)
        self.Left:DockMargin(16, 16, 16, 16)
        self.Left.Paint = function(s, w, h) end

        if (LocalPlayer():GangsHasPermission("INVITE_MEMBERS")) then
            self.Left.Messages = vgui.Create("DPanel", self.Left)
            self.Left.Messages:Dock(TOP)
            self.Left.Messages:DockMargin(0, 0, 0, 4)
            self.Left.Messages:SetTall(186)

            self.Left.Messages.Paint = function(s, w, h)
                local usesBackground = back:GetBool()
                surface.SetDrawColor(16, 16, 16, usesBackground and 225 or 255)
                draw.RoundedBox(4, 0, usesBackground and 0 or 48, w, h - (usesBackground and 0 or 48), Color(36, 36, 36, usesBackground and 225 or 255))
                draw.SimpleText("Messages", "Gangs.Medium", 8, 4, Color(200, 200, 200))

                if (s.NoMembers) then
                    draw.SimpleText("-You have no messages-", "Gangs.Medium", w / 2, h / 2 + 16, Color(200, 200, 200, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end

            net.Start("Gangs.RequestInvitations")
            net.SendToServer()
        end

        self.Left.Players = vgui.Create("DPanel", self.Left)
        self.Left.Players:Dock(FILL)

        self.Left.Players.Paint = function(s, w, h)
            local usesBackground = back:GetBool()
            surface.SetDrawColor(16, 16, 16, usesBackground and 225 or 255)
            draw.RoundedBox(4, 0, usesBackground and 0 or 48, w, h - (usesBackground and 0 or 48), Color(36, 36, 36, usesBackground and 225 or 255))
            draw.SimpleText("Players", "Gangs.Medium", 8, 4, Color(200, 200, 200))
        end

        self.Left.Search = vgui.Create("XeninUI.TextEntry", self.Left.Players)
        self.Left.Search:Dock(TOP)
        self.Left.Search:DockMargin(8, 56, 8, 0)
        self.Left.Search:SetPlaceholder("Search player")
        self.Left.Players.Scroll = vgui.Create("XeninUI.ScrollPanel", self.Left.Players)
        self.Left.Players.Scroll:Dock(FILL)
        self.Left.Players.Scroll:DockMargin(8, 8, 8, 8)

        self.Left.Players.Scroll.Paint = function(s, w, h)
            if (s.Childs == 0) then
                draw.SimpleText("No players found :(", "Gangs.Medium", w / 2, h / 2 - 8, Color(255, 255, 255, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        self.Left.Search:SetUpdateOnType(true)

        self.Left.Search.OnValueChange = function(s, val)
            self:FillPlayers(string.lower(val))
        end

        self:FillPlayers()
    end

    self.Right = vgui.Create("DPanel", self)

    if (LocalPlayer():GetGang() ~= "") then
        self.Right:DockMargin(0, 16, 16, 16)
    else
        self.Right:DockMargin(16, 16, 16, 16)
    end

    self.Right:Dock(FILL)

    self.Right.Paint = function(s, w, h)
        local usesBackground = back:GetBool()

        if (not usesBackground) then
            draw.RoundedBox(4, 0, 48, w, h - 48, Color(36, 36, 36, 255))
        else
            draw.RoundedBox(4, 0, 0, w, h, Color(36, 36, 36, 225))
        end

        draw.SimpleText("Public Gangs", "Gangs.Medium", 8, 4, Color(200, 200, 200))

        if (s.NoMembers) then
            draw.SimpleText("No Gangs available :(", "Gangs.Medium", w / 2, h / 2, Color(200, 200, 200), TEXT_ALIGN_CENTER)
        end
    end

    self.Right.Scroll = vgui.Create("XeninUI.ScrollPanel", self.Right)
    self.Right.Scroll:Dock(FILL)
    self.Right.Scroll:DockMargin(8, 56, 8, 0)
    GANG_RECRUITMENT_REF = self
    net.Start("Gangs.RequestPublic")
    net.SendToServer()
end

function PANEL:LoadAvatar(tag, url, callback)
    local link = string.Replace(url, "https://i.imgur.com/", "")

    if file.Exists("gangs/avatar/" .. link, "DATA") then
        callback(Material("../data/gangs/avatar/" .. link))
    else
        if (not myGang) then
            myGang = LocalPlayer():GetGang()
            if (not myGang) then return end
        end

        http.Fetch(url, function(data)
            file.Write("gangs/avatar/" .. link, data)
            callback(Material("../data/gangs/avatar/" .. link))
        end)
    end
end

function PANEL:InstallMessages(data)
    if IsValid(self.MessageContainer) then
        self.MessageContainer:Clear()
    else
        self.MessageContainer = vgui.Create("XeninUI.ScrollPanel", self.Left.Messages)
        self.MessageContainer:Dock(FILL)
        self.MessageContainer:DockMargin(0, 48, 0, 0)
    end

    self.Left.Messages.NoMembers = true

    for k, v in pairs(data) do
        self.Left.Messages.NoMembers = false
        local card = vgui.Create("DButton", self.MessageContainer)
        card:Dock(TOP)
        card:DockMargin(4, 4, 4, 0)
        card:SetTall(36)
        card:SetText("")

        card.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, s:IsHovered() and Color(46, 46, 46) or Color(26, 26, 26))
        end

        card.Avatar = vgui.Create("AvatarImage", card)
        card.Avatar:SetSteamID(v.steamid, 32)
        card.Avatar:Dock(LEFT)
        card.Avatar:SetWide(card:GetTall() - 4)
        card.Avatar:DockMargin(2, 2, 2, 2)
        card.Name = Label("Loading name", card)
        card.Name:Dock(FILL)
        card.Name:DockMargin(8, 0, 0, 0)
        card.Name:SetFont("Gangs.Tiny")

        steamworks.RequestPlayerInfo(v.steamid, function(name)
            card.Name:SetText(name)
        end)

        card.DoClick = function()
            local pnl = vgui.Create("XeninUI.Frame")
            pnl:SetSize(400, 200)
            pnl:Center()
            pnl:SetTitle(card.Name:GetText() .. "'s Application")
            pnl:SetBackgroundBlur(true)
            pnl:MakePopup()
            pnl.MarkUP = markup.Parse("<font=Gangs.Tiny><colour=200, 200, 200>" .. v.message .. "</color></font>", pnl:GetWide() - 32)
            pnl:SetTall(pnl.MarkUP:GetHeight() + 36 + 96)

            pnl.PaintOver = function(s, w, h)
                pnl.MarkUP:Draw(w / 2, 68, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            pnl.Bottom = vgui.Create("Panel", pnl)
            pnl.Bottom:SetTall(36)
            pnl.Bottom:DockMargin(12, 12, 12, 12)
            pnl.Bottom.Accept = vgui.Create("XeninUI.Button", pnl.Bottom)
            pnl.Bottom.Accept:Dock(LEFT)
            pnl.Bottom.Accept:SetText("ACCEPT")
            pnl.Bottom.Accept:SetColor(Color(25, 100, 50))
            pnl.Bottom.Accept:SetWide(pnl:GetWide() / 2 - 24)

            pnl.Bottom.Accept.DoClick = function()
                net.Start("Gangs.ReplyRequest")
                net.WriteString(v.steamid)
                net.WriteBool(true)
                net.SendToServer()
                pnl:Remove()
                table.RemoveByValue(data, v)
                self:InstallMessages(data)
            end

            pnl.Bottom.Reject = vgui.Create("XeninUI.Button", pnl.Bottom)
            pnl.Bottom.Reject:Dock(FILL)
            pnl.Bottom.Reject:SetText("REJECT")
            pnl.Bottom.Reject:SetColor(Color(100, 50, 25))
            pnl.Bottom.Reject:DockMargin(8, 0, 0, 0)

            pnl.Bottom.Reject.DoClick = function()
                net.Start("Gangs.ReplyRequest")
                net.WriteString(v.steamid)
                net.WriteBool(false)
                net.SendToServer()
                pnl:Remove()
                table.RemoveByValue(data, v)
                self:InstallMessages(data)
            end

            pnl.oldPerformLayout = pnl.PerformLayout

            pnl.PerformLayout = function(s, w, h)
                s:oldPerformLayout(w, h)
                s.Bottom:SetPos(16, h - 36 - 16)
                s.Bottom:SetSize(w - 32, 36)
            end
        end
    end
end

function PANEL:InstallData(data)
    self.Right.NoMembers = true

    for k, v in pairs(data) do
        self.Right.NoMembers = false
        local card = vgui.Create("DButton", self.Right.Scroll)
        card:Dock(TOP)
        card:SetTall(72)
        card:SetText("")

        self:LoadAvatar(v.Tag, v.Avatar, function(icon)
            if IsValid(card) then
                card.Icon = icon
            end
        end)

        card.Paint = function(s, w, h)
            local usesBackground = back:GetBool()

            if (usesBackground) then
                draw.RoundedBox(4, 0, 0, w, h, s:IsHovered() and Color(36, 36, 36) or Color(26, 26, 26))
            else
                draw.RoundedBox(4, 0, 0, w, h, s:IsHovered() and Color(30, 30, 30) or Color(26, 26, 26))
            end

            draw.SimpleText(v.Name, "Gangs.Medium", 72, 6, Color(235, 235, 235), TEXT_ALIGN_LEFT)
            draw.SimpleText(v.Tag, "Gangs.Small", 72, 42, Color(235, 235, 235, 100), TEXT_ALIGN_LEFT)

            if (s.Icon) then
                surface.SetDrawColor(color_white)
                surface.SetMaterial(s.Icon)
                surface.DrawTexturedRect(8, 8, h - 16, h - 16)
            end
        end

        card.DoClick = function(s)
            if (LocalPlayer():GetGang() == v.Tag) then
                Derma_Message("You are already in this gang", "Wait a minute", "Okay")

                return
            end

            if IsValid(GFORM) then
                GFORM:Remove()
            end

            GFORM = vgui.Create("gangForm")
            GFORM:SetGang(v.Tag)
        end
    end
end

local invite_filters = {}
function PANEL:FillPlayers(val)
    self.Left.Players.Scroll:Clear()
    self.Left.Players.Scroll.Childs = 0

    for k, v in pairs(player.GetAll()) do
        if (v:GetGang() == LocalPlayer():GetGang()) then continue end
        if (v:GetGang() != "") then continue end
        if (not string.find(string.lower(v:Nick()), val or "", 1, true)) then continue end
        local card = vgui.Create("DButton", self.Left.Players.Scroll)
        card:Dock(TOP)
        card:DockMargin(0, 0, 0, 8)
        card:SetTall(52)
        card:SetText("")

        card.Paint = function(s, w, h)
            if (not IsValid(v)) then
                self:FillPlayers(val)

                return
            end

            draw.RoundedBox(4, 0, 0, w, h, s:IsHovered() and Color(36, 36, 36) or Color(26, 26, 26))
            draw.SimpleText(v:Nick(), "Gangs.Medium", 62, h / 2, Color(235, 235, 235), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        card.Avatar = vgui.Create("AvatarImage", card)
        card.Avatar:SetMouseInputEnabled(false)
        card.Avatar:Dock(LEFT)
        card.Avatar:SetWide(46)
        card.Avatar:SetPlayer(v, 48)
        card.Avatar:DockMargin(4, 4, 4, 4)

        card.DoClick = function(s)
            if (true or !invite_filters[v] || invite_filters[v] < CurTime()) then
                invite_filters[v] = CurTime() + 60 * 5
                Derma_Query("Do you wanna invite " .. v:Nick() .. " to your gang?", "Invitation", "Yes", function()
                    net.Start("Gangs.Invite")
                    net.WriteEntity(v)
                    net.SendToServer()
                end, "Nah")
            else
                Derma_Message("You must wait " .. math.Round(invite_filters[v] - CurTime()) .. " seconds for a new invitation", "Invitation", "Yes")
            end
        end

        self.Left.Players.Scroll.Childs = self.Left.Players.Scroll.Childs + 1
    end
end

function PANEL:PerformLayout(w, h)
    if (self.Left) then
        self.Left:SetWide(w * .4)
    end
end

function PANEL:Paint()
end

vgui.Register("Gangs.Recruitment", PANEL, "DPanel")

net.Receive("Gangs.RequestPublic", function()
    if IsValid(GANG_RECRUITMENT_REF) then
        GANG_RECRUITMENT_REF:InstallData(net.ReadTable())
    end
end)

net.Receive("Gangs.RequestInvitations", function()
    local data = net.ReadTable()

    if IsValid(GANG_RECRUITMENT_REF) then
        GANG_RECRUITMENT_REF:InstallMessages(data)
    end
end)