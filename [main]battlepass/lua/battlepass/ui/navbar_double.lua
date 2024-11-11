local PANEL = {}

function PANEL:Init()
    self.Active = {
        Top = 1,
        Side = 1
    }

    self.Top = self:Add("DPanel")
    self.Top:Dock(TOP)
    self.Side = self:Add("DPanel")
    self.Side:Dock(LEFT)
    self.Background = self:Add("DPanel")
    self.Background:Dock(FILL)
    self.Background.OffsetX = 0
    self.Background.OffsetY = 0
    self.Background.Paint = nil
    self.Background:DockMargin(0, 0, 0, 0)
    self.Background.Panels = {}

    self.Background.PerformLayout = function(pnl, w, h)
        for i, v in ipairs(pnl.Panels) do
            local y = v.y * h - (pnl.OffsetY * h)
            local x = v.x * w - (pnl.OffsetX * w)
            v.pnl:SetSize(w, h)
            v.pnl:SetPos(x, y)
        end
    end

    self.Top.Buttons = {}
    self.Side.Buttons = {}
end

function PANEL:AddPanel(panel, x, y, callback)
    local frame = self.Background:Add(panel)

    table.insert(self.Background.Panels, {
        pnl = frame,
        x = x,
        y = y
    })

    if callback then
        callback(frame)
    end

    return frame
end

function PANEL:AddTopButton(name, onClick)
    local button = self.Top:Add("BATTLEPASS_Button")
    button:Dock(LEFT)
    button:SetText(name)
    button:SetFont("BATTLEPASS_NavbarButton")
    button:SetTextColor(Color(220, 220, 220))
    button.Active = 0

    button.Paint = function(pnl, w, h)
        if pnl.Id == self.Active.Top then
            pnl.Active = pnl.Active + (1 - pnl.Active) * 7 * FrameTime()
        else
            pnl.Active = pnl.Active + (0 - pnl.Active) * 7 * FrameTime()
        end

        local col = BATTLEPASS:GetTheme("Primary.NavBar.Button")
        draw.RoundedBox(4, 2, 2, w - 4, h - 4, ColorAlpha(col, 20 * pnl.Active))
    end

    button.PerformLayout = function(pnl, w, h)
        surface.SetFont(pnl:GetFont())
        local tw = surface.GetTextSize(pnl:GetText())
        pnl:SetWide(tw + 32)
    end

    button.DoClick = function(pnl)
        self:SetTopActive(pnl.Id)

        if onClick then
            onClick(pnl, self)
        end
    end

    button.Id = table.insert(self.Top.Buttons, button)

    if button.Id == 1 then
        button.Active = 1
    end
end

function PANEL:AddSideButton(name, onClick)
    local button = self.Side:Add("BATTLEPASS_Button")
    button:Dock(TOP)
    button:SetText(name)
    button:SetTextColor(Color(190, 190, 190))
    button:SetFont("BATTLEPASS_NavbarButton")
    button:SetTall(40)
    button:SetContentAlignment(4)
    button:SetTextInset(16, 0)
    button.Active = 0

    button.Paint = function(pnl, w, h)
        if pnl.Id == self.Active.Side then
            pnl.Active = pnl.Active + (1 - pnl.Active) * 7 * FrameTime()
        else
            pnl.Active = pnl.Active + (0 - pnl.Active) * 7 * FrameTime()
        end

        local col = BATTLEPASS:GetTheme("Primary.NavBar.Button")
        draw.RoundedBox(4, 2, 2, w - 4, h - 4, ColorAlpha(col, 20 * pnl.Active))
    end

    button.DoClick = function(pnl)
        self:SetSidebarActive(pnl.Id)

        if onClick then
            onClick(pnl)
        end
    end

    button.Id = table.insert(self.Side.Buttons, button)

    if button.Id == 1 then
        button.Active = 1
    end
end

function PANEL:SetTopActive(id)
    self.Active.Top = id

    self.Background.Think = function(pnl)
        pnl:InvalidateLayout()
    end

    self.Background:Lerp("OffsetX", id - 1, 0.3, function()
        self.Background.Think = nil
    end)
end

function PANEL:SetSidebarActive(id)
    self.Active.Side = id

    self.Background.Think = function(pnl)
        pnl:InvalidateLayout()
    end

    self.Background:Lerp("OffsetY", id - 1, 0.3, function()
        self.Background.Think = nil
    end)
end

function PANEL:PerformLayout(w, h)
    self.Top:SetTall(48)
    self.Side:SetWide(140)
    local y = 0

    for i, v in ipairs(self.Side.Buttons) do
        v:SetTall(40)
        v:SetPos(0, y)
        y = y + v:GetTall()
    end
end

vgui.Register("BATTLEPASS_NavbarDouble", PANEL)