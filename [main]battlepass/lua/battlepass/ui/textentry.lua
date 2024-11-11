BATTLEPASS:CreateFont("BATTLEPASS_TextEntry", 18)
BATTLEPASS:CreateFont("BATTLEPASS_TextEntryName", 15)

for i = 15, 18 do
  BATTLEPASS:CreateFont("BATTLEPASS_TextEntry_Size" .. i)
end

local PANEL = {}

AccessorFunc(PANEL, "m_textColor", "TextColor")
AccessorFunc(PANEL, "m_name", "Name")
AccessorFunc(PANEL, "m_backgroundColor", "BackgroundColor")
AccessorFunc(PANEL, "m_markedColor", "MarkedColor")
AccessorFunc(PANEL, "m_nameColor", "NameColor")
AccessorFunc(PANEL, "m_outlineColor", "OutlineColor")

local theme = function(str)
  return BATTLEPASS:GetTheme(str)
end

function PANEL:Init()
  self:SetTextColor(theme("TextEntry.Text"))
  self:SetNameColor(theme("TextEntry.Name.Text"))
  self:SetBackgroundColor(theme("TextEntry.Background"))
  self:SetOutlineColor(theme("TextEntry.Outline"))
  self:SetMarkedColor(theme("TextEntry.Marked"))

  self.Textentry = vgui.Create("DTextEntry", self)
  self.Textentry:SetFont("BATTLEPASS_TextEntryName")
  self.Textentry:SetDrawLanguageID(false)
  self.Textentry.Paint = function(pnl)
    pnl:DrawTextEntryText(self:GetTextColor(), self:GetMarkedColor(), self:GetTextColor())
  end
  self.Textentry.OnFocusChanged = function(pnl, gained)
    self:OnFocusChanged(gained)
  end
  self.NameX = 12
  self.NameY = 23
  self.TextfieldY = 7
  self.FontSize = 18
  self.Outline = 0
end

function PANEL:Think()
  if (self.invalidateLayout) then
    self:InvalidateLayout()
  end
end

function PANEL:PerformLayout(w, h)
  self.Textentry:SetWide(w - 10)
  self.Textentry:SetPos(5, h / 2 - self.Textentry:GetTall() / 2 + self.TextfieldY)
end

function PANEL:ShowOutline()
  self:Lerp("Outline", 2)
end

function PANEL:HideOutline()
  self:Lerp("Outline", 0)
end

function PANEL:MoveNameTopLeft()
  self:Lerp("NameY", 13)
  self:Lerp("NameX", 8)
  self:Lerp("FontSize", 15)
  self:Lerp("TextfieldY", 7, nil, function()
    self.InvalidateLayouts = false
  end)

  self.InvalidateLayouts = true
end

function PANEL:MoveNameMiddle()
  self:Lerp("NameY", 22.5)
  self:Lerp("NameX", 12)
  self:Lerp("FontSize", 18)
  self:Lerp("TextfieldY", 0, nil, function()
    self.InvalidateLayouts = false
  end)

  self.InvalidateLayouts = true
end

function PANEL:Paint(w, h)
  if (self.Outline > 0.2) then
    draw.RoundedBox(6, 0, 0, w, h, self:GetOutlineColor())
  end

  draw.RoundedBox(6 - (self.Outline * 3), self.Outline, self.Outline, w - (self.Outline * 2), h - (self.Outline * 2), self:GetBackgroundColor())

  draw.SimpleText(self:GetName() or "Name", self:GetNameFont(), self.NameX, self.NameY, self:GetNameColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:OnFocusChanged(gained)
  if (gained) then
    self:MoveNameTopLeft()
  elseif (self:GetText() == "" or self:GetText():len() == 0) then
    self:MoveNameMiddle()
  end

  if (gained) then
    self:ShowOutline()
  else
    self:HideOutline()
  end

  self:OnFocusChangedOverride(gained)
end

function PANEL:OnFocusChangedOverride(gained)
  -- Override
end

function PANEL:GetNameFont()
  return "BATTLEPASS_TextEntry_Size" .. math.Round(self.FontSize)
end

function PANEL:SetText(text)
  if (text:len() == 0 or text == "") then
    self:MoveNameMiddle()
  else
    self:MoveNameTopLeft()
  end

  self.Textentry:SetText(text)
end

function PANEL:GetText() return self.Textentry:GetText() end

function PANEL:OnCursorEntered()
  self:SetCursor("beam")
end

function PANEL:OnMousePressed()
  self.Textentry:RequestFocus()
  self.Textentry:SetCaretPos(#self.Textentry:GetText())
end

vgui.Register("BATTLEPASS_TextEntry", PANEL)