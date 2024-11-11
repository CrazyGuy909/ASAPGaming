BATTLEPASS:CreateFont("BATTLEPASS_Menu", 19)
BATTLEPASS:CreateFont("BATTLEPASS_Menu_Sub", 16)

local PANEL = {}

function PANEL:Init()
  self:DockPadding(0, 8, 0, 8)
end

function PANEL:Paint(w, h)
  draw.RoundedBox(6, 0, 0, w, h, color_white)
end

function PANEL:AddButton(name, onClick, textColor, init)
  onClick = onClick or function() return true end

  local panel = self:Add("DButton")
  panel:Dock(TOP)
  panel:SetTall(48)
  panel:SetText(name)
  panel:SetFont("BATTLEPASS_Menu")
  panel:SetTextInset(16, 0)
  panel:SetContentAlignment(4)
  panel:SetTextColor(textColor or Color(41, 48, 46))
  panel.alpha = 0
  panel.Paint = function(pnl, w, h)
    surface.SetDrawColor(ColorAlpha(XeninUI.Theme.Accent, pnl.alpha))
    surface.DrawRect(0, 0, w, h)
  end
  panel.OnCursorEntered = function(pnl)
    pnl:Lerp("alpha", 150)
  end
  panel.OnCursorExited = function(pnl)
    pnl:Lerp("alpha", 0)
  end
  panel.DoClick = function(pnl)
    onClick(pnl)
    
    self:Remove()
  end

  if (init) then init(panel) end

  self:InvalidateLayout()
end

function PANEL:PerformLayout(w, h)
  local longest = 0

  surface.SetFont("BATTLEPASS_Menu")
  for i, v in pairs(self:GetChildren()) do
    local width = surface.GetTextSize(v:GetText()) + 32

    if (width > longest) then
      longest = width
    end
  end

  self:SetWide(longest)
  self:SetTall(8 + #self:GetChildren() * 48 + 8)
end

function PANEL:OnFocusChanged(gained)
  if (!IsValid(self)) then return end
  if (gained) then return end
  if (self.Ignore) then return end

  self:Remove()
end

vgui.Register("BATTLEPASS_PopupMenu", PANEL, "EditablePanel")

function BATTLEPASS:Menu(x, y)
  local panel = vgui.Create("BATTLEPASS_PopupMenu")
  panel:SetDrawOnTop(true)
  panel:MakePopup()
  panel:SetPos(x, y)

  return panel
end

local PANEL = {}

function PANEL:Init()
  self.Button = self:Add("DButton")
  self.Button:Dock(FILL)
  self.Button:SetFont("BATTLEPASS_Menu")
  self.Button:SetTextInset(16, 0)
  self.Button:SetContentAlignment(4)
  self.Button.BackgroundColor = color_white
  self.Button.TextColor = Color(41, 48, 46)
  self.Button.Paint = function(pnl, w, h)
    pnl:SetTextColor(pnl.TextColor)

    draw.RoundedBox(6, 0, 0, w, h, pnl.BackgroundColor)
  end
  self.Button.DoCLick = function(pnl)
    self:Remove()
  end
end

function PANEL:PerformLayout(w, h)
  surface.SetFont(self.Button:GetFont())
  local width = surface.GetTextSize(self.Button:GetText())

  self:SetWide(width + 32)
  self:SetTall(48)
end

function PANEL:OnFocusChanged(gained)
  if (!IsValid(self)) then return end
  if (gained) then return end
  if (self.Ignore) then return end

  self:Remove()
end

vgui.Register("BATTLEPASS_PopupSingleMenu", PANEL, "EditablePanel")

function BATTLEPASS:SingleMenu(x, y, color, text, onClick)
  local panel = vgui.Create("BATTLEPASS_PopupSingleMenu")
  panel:SetDrawOnTop(true)
  panel:MakePopup()
  panel:SetPos(x, y)
  panel.Button:SetText(text)
  panel.Button.TextColor = color
  panel.Button.OnCursorEntered = function(pnl)
    pnl:LerpColor("TextColor", color_white)
    pnl:LerpColor("BackgroundColor", color)
  end
  panel.Button.OnCursorExited = function(pnl)
    pnl:LerpColor("TextColor", color)
    pnl:LerpColor("BackgroundColor", color_white)
  end
  panel.Button.DoClick = function(pnl)
    onClick(pnl)

    panel:Remove()
  end

  return panel
end