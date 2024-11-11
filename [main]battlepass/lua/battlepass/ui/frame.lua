BATTLEPASS:CreateFont("BATTLEPASS_TitleBar", 24)
local PANEL = {}
AccessorFunc(PANEL, "m_title", "Title")
AccessorFunc(PANEL, "m_defaultWidth", "DefaultWidth")
AccessorFunc(PANEL, "m_defaultHeight", "DefaultHeight")
AccessorFunc(PANEL, "m_headerHeight", "HeaderHeight")
AccessorFunc(PANEL, "m_primaryColor", "PrimaryColor")
AccessorFunc(PANEL, "m_primaryColorVariant", "PrimaryColorVariant")
AccessorFunc(PANEL, "m_secondaryColor", "SecondaryColor")
AccessorFunc(PANEL, "m_secondaryColorVariant", "SecondaryColorVariant")
AccessorFunc(PANEL, "m_backgroundColor", "BackgroundColor")
local matClose = Material("battlepass/close.png", "noclamp smooth")
local matResize = Material("battlepass/resize.png", "noclamp smooth")
local matMinimise = Material("battlepass/minimise.png", "noclamp smooth")

function PANEL:Init()
    self.Fullscreen = false
    self.TitleBar = vgui.Create("Panel", self)
    self.TitleBar:Dock(TOP)

    self.TitleBar.Paint = function(s, w, h)
        local x, y = s:LocalToScreen(0, 0)
        local color = self:GetPrimaryColorVariant()
        if not color then return end
        draw.RoundedBoxEx(6, 0, 0, w, h, color, true, false, false, false)
        draw.SimpleText(self:GetTitle(), "BATTLEPASS_TitleBar", w / 2, h / 2, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.CloseButton = vgui.Create("BATTLEPASS_Button", self.TitleBar)
    self.CloseButton:Dock(RIGHT)
    self.CloseButton:SetText("")
    self.CloseButton:DockMargin(4, 4, 4, 4)
    self.CloseButton:SetDisableHoverDraw(true)

    self.CloseButton.Paint = function(s, w, h)
        surface.SetDrawColor(255, 255, 255, 200)
        surface.SetMaterial(matClose)
        surface.DrawTexturedRect(8, 8, w - 16, h - 16)
        draw.RoundedBoxEx(6, 0, 0, w, h, Color(255, 255, 255, 20 * s.Hover), false, true, false, false)
    end

    self.CloseButton.DoClick = function(s)
        self:Close()
    end

    self.Header = vgui.Create("Panel", self)
    self.Header:Dock(TOP)

    self.Header.Paint = function(s, w, h)
		local color = self:GetPrimaryColorVariant()
        if not color then return end
        draw.RoundedBoxEx(6, 0, 0, w * 0.01, h, color, true, false, false, false)
    end
end

function PANEL:ToggleResize()
    local width = self.Fullscreen and self:GetDefaultWidth() or ScrW()
    local height = self.Fullscreen and self:GetDefaultHeight() or ScrH()
    BATTLEPASS:SizeTo(self, width, height, 0.1)

    BATTLEPASS:MoveTo(self, ScrW() / 2 - width / 2, ScrH() / 2 - height / 2, 0.1, function()
        self.Fullscreen = not self.Fullscreen
    end)
end

function PANEL:Minimise()
end

-- Override purposes
function PANEL:Paint(w, h)
    local x, y = self:LocalToScreen(0, 0)
    draw.RoundedBox(6, x, y, w, h, Color(0, 0, 0, 0))
end

function PANEL:Close()
    self:Remove()
end

function PANEL:PerformLayout(w, h)
    self.TitleBar:SetTall(42)
    self.CloseButton:SetWide(self.TitleBar:GetTall() - 8)
    --self.resizeButton:SetWide(self.TitleBar:GetTall())
    --self.minimiseButton:SetWide(self.TitleBar:GetTall())
    self.Header:SetTall(self:GetHeaderHeight() or 96)
end

vgui.Register("BATTLEPASS_Frame", PANEL, "EditablePanel")