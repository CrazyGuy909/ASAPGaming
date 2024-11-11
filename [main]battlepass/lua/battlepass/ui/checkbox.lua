local PANEL = {}

AccessorFunc(PANEL, "m_name", "Name")
AccessorFunc(PANEL, "m_backgroundColor", "BackgroundColor")
AccessorFunc(PANEL, "m_nameColor", "NameColor")

local theme = function(str)
  return BATTLEPASS:GetTheme(str)
end

BATTLEPASS:CreateFont("BATTLEPASS_Checkbox", 15)

function PANEL:Init()
  self:SetNameColor(theme("TextEntry.Name.Text"))
  self:SetBackgroundColor(theme("TextEntry.Background"))

  self.Checkbox = self:Add("DButton")
  self.Checkbox:SetText("")
  self.Checkbox:SetFont("BATTLEPASS_Checkbox")
  self.Checkbox.Offset = 0
  self.Checkbox.State = false
  self.Checkbox.States = { "", "" }
  self.Checkbox.Paint = function(pnl, w, h)
    pnl.Offset = pnl.Offset + ((pnl.State and 1 or 0) - pnl.Offset) * 7 * FrameTime()
    surface.SetDrawColor(21, 21, 21, 200)
    surface.DrawRect(0, 0, w, h)

    surface.SetDrawColor(255, 255, 255)
    surface.DrawRect(2 + (w / 2) * pnl.Offset, 2, w / 2 - 4, h - 4)

    local firstCol = 255 * pnl.Offset
    local firstColor = Color(firstCol, firstCol, firstCol)
    draw.SimpleText(pnl.States[1], pnl:GetFont(), w / 4, h / 2, firstColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    local secondCol = 255 - (255 * pnl.Offset)
    local secondColor = Color(secondCol, secondCol, secondCol)
    draw.SimpleText(pnl.States[2], pnl:GetFont(), w / 2 + w / 4, h / 2, secondColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  end
  self.Checkbox.DoClick = function(pnl)
    pnl.State = !pnl.State

    self:Toggled(pnl.State)
  end

  self.NameX = 8
  self.NameY = 13
  self.FontSize = 15
  self.Outline = 0
end

function PANEL:Toggled()
  -- Overwrite
end

function PANEL:SetStates(onTrue, onFalse)
  self.Checkbox.States = { onTrue, onFalse }
end

function PANEL:Think()
  if (self.invalidateLayout) then
    self:InvalidateLayout()
  end
end

function PANEL:PerformLayout(w, h)
  self.Checkbox:SetTall(h - 32)
  self.Checkbox:SetWide(w - 16)
  self.Checkbox:SetPos(8, h / 2 - self.Checkbox:GetTall() / 2 + 9)
end

function PANEL:Paint(w, h)
  draw.RoundedBox(6, 0, 0, w, h, self:GetBackgroundColor())
  draw.SimpleText(self:GetName() or "Name", "BATTLEPASS_TextEntry_Size15", self.NameX, self.NameY, self:GetNameColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:OnCursorEntered()
  self:SetCursor("hand")
end

function PANEL:OnMousePressed()
  self.Checkbox:DoClick()
end

vgui.Register("BATTLEPASS_Checkbox", PANEL)