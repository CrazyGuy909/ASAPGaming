local PANEL = {}

AccessorFunc(PANEL, "m_disableHoverDraw", "DisableHoverDraw")

function PANEL:Init()
  self.Hover = 0
end

function PANEL:PaintOver(w, h)
  if self:IsHovered() or self.Depressed then
    self.Hover = self.Hover + (1 - self.Hover) * 7 * FrameTime()
  else
    self.Hover = self.Hover + (0 - self.Hover) * 7 * FrameTime()
  end

  if (!self:GetDisableHoverDraw()) then
    local col = BATTLEPASS:GetTheme("Primary.NavBar.Button")
    surface.SetDrawColor(col.r, col.g, col.b, 20 * self.Hover)
    surface.DrawRect(0, 0, w, h)
  end
end


vgui.Register("BATTLEPASS_Button", PANEL, "DButton")
