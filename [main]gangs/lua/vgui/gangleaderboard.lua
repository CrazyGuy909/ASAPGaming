local PANEL = {}
local gang_Panel = nil
local back = CreateClientConVar("gangs_showbackground", "0", true)

function PANEL:Init()
    gang_Panel = self
    self.Left = vgui.Create("DPanel", self)
    self.Left:Dock(LEFT)
    self.Left:DockMargin(8, 8, 8, 8)
    self.Left.Paint = function() end

    self.Left.Top = Label("Gang #1", self.Left)
    self.Left.Top:SetFont("Gangs.Huge")
    self.Left.Top:Dock(TOP)
    self.Left.Top:SetTall(42)
    self.Left.Top:DockMargin(8, 0, 0, 0)
    self.Left.Top:SetTextInset(4, 0)
    self.Left.Top:SetTextColor(Color(255, 200, 0))
    self.Left.Top.Paint = function(s,w,h)
        local usesBackground = back:GetBool()
        if (usesBackground) then
            surface.SetFont(s:GetFont())
            local tx,_ = surface.GetTextSize(s:GetText())
            DisableClipping(true)
            draw.RoundedBoxEx(4, 0, 0, tx + 10, h + 16, Color(36, 36, 36), true, true, false, false)
            DisableClipping(false)
        end
        draw.SimpleText("Capture the Control Points across the map", "Gangs.Small", w - 8, 8, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    end

    self.FirstGang = vgui.Create("Gangs.Banner", self.Left)
    self.FirstGang:Dock(TOP)

    self.Left.Second = Label("Gang #2", self.Left)
    self.Left.Second:SetFont("Gangs.Medium")
    self.Left.Second:Dock(TOP)
    self.Left.Second:SetTall(32)
    self.Left.Second:SetTextInset(4, 0)
    self.Left.Second:DockMargin(8, 0, 0, 0)
    self.Left.Second:SetTextColor(Color(120, 215, 240))
    self.Left.Second.Paint = function(s,w,h)
        local usesBackground = back:GetBool()
        if (usesBackground) then
            surface.SetFont(s:GetFont())
            local tx,_ = surface.GetTextSize(s:GetText())
            DisableClipping(true)
            draw.RoundedBoxEx(4, 0, 0, tx + 10, h + 16, Color(36, 36, 36), true, true, false, false)
            DisableClipping(false)
        end
    end

    self.SecondGang = vgui.Create("Gangs.Banner", self.Left)
    self.SecondGang:Dock(TOP)

    self.Left.Third = Label("Gang #3", self.Left)
    self.Left.Third:SetFont("Gangs.Small")
    self.Left.Third:Dock(TOP)
    self.Left.Third:SetTall(28)
    self.Left.Third:SetTextInset(4, 0)
    self.Left.Third:DockMargin(8, 0, 0, 0)
    self.Left.Third:SetTextColor(Color(150, 210, 100))
    self.Left.Third.Paint = function(s,w,h)
        local usesBackground = back:GetBool()
        if (usesBackground) then
            surface.SetFont(s:GetFont())
            local tx,_ = surface.GetTextSize(s:GetText())
            DisableClipping(true)
            draw.RoundedBoxEx(4, 0, 0, tx + 10, h + 16, Color(36, 36, 36), true, true, false, false)
            DisableClipping(false)
        end
    end

    self.ThirdGang = vgui.Create("Gangs.Banner", self.Left)
    self.ThirdGang:Dock(TOP)

    self.Right = vgui.Create("DPanel", self)
    self.Right:Dock(FILL)
    self.Right:DockMargin(0, 16, 16, 16)
    self.Right.Top = Label("Gangs Ranking:", self.Right)
    self.Right.Top:Dock(TOP)
    self.Right.Top:SetFont("Gangs.Huge")
    self.Right.Top:SetColor(Color(255, 255, 255, 200))
    self.Right.Top:SetTall(48)
    self.Right.Top:SetTextInset(8, 0)

    self.Right.Paint = function(s,w,h)
        local usesBackground = back:GetBool()
        draw.RoundedBox(4, 0, 0, w, h, Color(36, 36, 36, usesBackground && 225 || 255))
    end

    self:PrepareRight()

    if (asapgangs.RankCache) then
        self:FillRanking()
    end

    net.Start("Gangs.SendRanking")
    net.SendToServer()
end

function PANEL:PrepareRight()

    self.RankScroll = vgui.Create("XeninUI.ScrollPanel", self.Right)
    self.RankScroll:Dock(FILL)
    self.RankScroll:DockMargin(8,8,8,8)
    self.Cards = {}
    for k = 4, 15 do
        local card = vgui.Create("Gangs.Banner", self.RankScroll)
        card:Dock(TOP)
        card:SetTall(76)
        card:SetIsList(true)
        card:SetID(k)
        card:DockMargin(0, 0, 8, 8)
        self.Cards[k] = card
    end
end

function PANEL:PerformLayout(w, h)
    self.Left:SetWide(w * .5)

    local cardSize = h - 42 - 32 - 24 - 24 - 42
    if IsValid(self.FirstGang) then
        self.FirstGang:SetTall(cardSize * .45)
        self.SecondGang:SetTall(cardSize * .3)
        self.ThirdGang:SetTall(cardSize * .25)
    end
end

function PANEL:FillRanking()
    local data = asapgangs.RankCache

    if (data[1]) then
        self.FirstGang:SetGang(data[1])
    end
    if (data[2]) then
        self.SecondGang:SetGang(data[2])
    end
    if (data[3]) then
        self.ThirdGang:SetGang(data[3])
    end

    for k = 4, 15 do
        if (data[k]) then
            self.Cards[k]:SetGang(data[k])
        end
    end
end

function PANEL:Paint(w, h)

end

vgui.Register("Gangs.Leaderboard", PANEL, "DPanel")

local GANG = {}
AccessorFunc(GANG, "m_bIsList", "IsList", FORCE_BOOL)
AccessorFunc(GANG, "m_iID", "ID", FORCE_NUMBER)

function GANG:Init()
    self:DockMargin(8, 8, 8, 8)
end

function GANG:SetGang(data)
    self.Data = data
    self:LoadIcon()

    if (self:GetIsList()) then return end

    if (IsValid(self.BottomAvatars)) then 
        self.BottomAvatars:Remove()
    end
    self.BottomAvatars = vgui.Create("DPanel", self)
    self.BottomAvatars.Paint = function() end
    self.BottomAvatars:Dock(BOTTOM)

    if (isstring(self.Data.Members)) then
        self.Data.Members = util.JSONToTable(self.Data.Members)
    end

    self.BottomAvatars.Icons = {}

    self:InvalidateLayout(true)
    self.BottomAvatars:InvalidateParent(true)

    if (self.BottomAvatars:GetTall() == 0) then return end

    local fac = math.min(math.floor((self.BottomAvatars:GetWide() - 8) / self.BottomAvatars:GetTall()), 10)
    local diff = self.BottomAvatars:GetWide() - math.Round(fac * self.BottomAvatars:GetTall())
    for k = 1, math.min(fac, 10) do
        local ply = self.Data.Members[k]
        local icon
        if (ply) then
            icon = vgui.Create("AvatarImage", self.BottomAvatars)
            icon:SetSteamID(ply, 64)
            if (player.GetBySteamID64(ply)) then
                icon:DockMargin(4,4,4,4)
                icon.Paint = function(s,w,h)
                    icon.NoMargin = true
                    surface.SetDrawColor(100, 255, 75)
                    DisableClipping(true)
                    surface.DrawRect(-1, -1, w + 2, h + 2)
                    DisableClipping(false)
                end
            end
            steamworks.RequestPlayerInfo(ply, function(name)
                if IsValid(icon) then
                    icon:SetTooltip(name)
                end
            end)
        else
            icon = vgui.Create("DPanel", self.BottomAvatars)
            icon:SetTooltip("Empty slot")
            icon.Paint = function(s,w,h)
                draw.RoundedBox(4, 0, 0, w, h, Color(6, 6, 6))
            end
        end
        if (!icon.NoMargin) then
            icon:DockMargin(k == 1 && 0 || 4, 0, 4, 0)
        end
        icon:Dock(LEFT)
        self.BottomAvatars.Icons[k] = icon
    end

end

function GANG:PerformLayout(w,h)
    if (self.BottomAvatars) then
        self.BottomAvatars:SetTall(h / 2 - 32)
        self.BottomAvatars:DockMargin(h * .1, 8, h * .1, 8)
        --local availableSize = w - h * .2 - (self.BottomAvatars:GetTall() * table.Count(self.BottomAvatars.Icons))
        for k,v in pairs(self.BottomAvatars.Icons) do
            v:SetWide(self.BottomAvatars:GetTall())
        end
    end
end

function GANG:LoadIcon()
    local link = string.Replace(self.Data.Icon, "https://i.imgur.com/", "")
    
    if file.Exists("gangs/avatar/" .. link, "DATA") then
        self.GangIcon = Material("../data/gangs/avatar/" .. link)
    else
        http.Fetch(self.Data.Icon, function(data)
            if not IsValid(self) then return end
            file.Write("gangs/avatar/" .. link, data)
            self.GangIcon = Material("../data/gangs/avatar/" .. link)
        end)
    end
end

function GANG:Paint(w, h)
    if (self:GetIsList()) then
        draw.RoundedBox(4, 0, 0, w, h, self:IsHovered() && Color(42, 42, 42) || Color(26, 26, 26))
        draw.SimpleText("#" .. self:GetID(), "Gangs.Medium", 12, h / 2, Color(255, 255, 255, 25), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    else
        draw.RoundedBox(4, 0, 0, w, h, Color(36, 36, 36))
    end

    if (self.Data && !self:GetIsList()) then
        if (self.GangIcon) then
            surface.SetMaterial(self.GangIcon)
            surface.SetDrawColor(color_white)
            surface.DrawTexturedRect(h * .1, 16, h * .5, h * .5)
        end
        local tx,_ = draw.SimpleText(self.Data.Name, "Gangs.Huge", h * .5 + h * .1 + 16, 8, color_white)
        draw.SimpleText(self.Data.Tag, "Gangs.Medium", h * .5 + h * .1 + 24 + tx, 16, Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        draw.SimpleText(string.Comma(self.Data.Experience) .. "xp", "Gangs.Medium", h * .5 + h * .1 + 16, 46, Color(255, 75, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(DarkRP.formatMoney(self.Data.Money), "Gangs.Small", h * .5 + h * .1 + 16, 76, Color(175, 255, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    elseif (self.Data) then
        if (self.GangIcon) then
            surface.SetMaterial(self.GangIcon)
            surface.SetDrawColor(color_white)
            surface.DrawTexturedRect(56, h * .15, h * .7, h * .7)
        end
        draw.SimpleText(self.Data.Name, "Gangs.Medium", 64 + h * .7 + 8, 6, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(self.Data.Tag, "Gangs.Medium", 64 + h * .7 + 8, 36, Color(150, 150, 150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(self.Data.Experience .. "xp", "Gangs.Medium", w - 8, 36, Color(255, 75, 200), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
    end
end

vgui.Register("Gangs.Banner", GANG, "DPanel")

net.Receive("Gangs.SendRanking", function()
    asapgangs.RankCache = net.ReadTable()
    SHOULD_UPDATE_BANNERS = true
    if IsValid(gang_Panel) then
        gang_Panel:FillRanking()
    end
end)

concommand.Add("open_gangs", function()
    if IsValid(GANGS) then
        GANGS:Remove()
    end

    GANGS = vgui.Create("Gangs.Main")
end)
