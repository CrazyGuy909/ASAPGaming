BATTLEPASS:CreateFont("BATTLEPASS_Tooltip", 18)

local PanelMeta = FindMetaTable("Panel")

local theme = function(str)
  return BATTLEPASS:GetTheme(str)
end

function PanelMeta:AddTooltip(str, delay, offsetX, offsetY)
  self.CursorEntered = 0
  self.ActivateTooltip = true
  self.TooltipStr = str
  self.TooltipDelay = delay or 0.2

  local oldCursorEntered = self.OnCursorEntered
  self.OnCursorEntered = function(pnl)
    if (oldCursorEntered) then oldCursorEntered(pnl) end

    pnl.CursorEntered = CurTime() + pnl.TooltipDelay
  end
  
  local oldCursorExited = self.OnCursorExited
  self.OnCursorExited = function(pnl)
    if (oldCursorExited) then oldCursorExited(pnl) end

    pnl.CursorEntered = 0

    if (IsValid(pnl.Tooltip)) then
      pnl.Tooltip:Remove()
      pnl.Tooltip = nil
    end
  end

  local oldThink = self.Think
  self.Think = function(pnl)
    if (oldThink) then oldThink(pnl) end

    if (pnl.CursorEntered < CurTime() and !IsValid(pnl.Tooltip) and pnl:IsHovered()) then
      local x, y = pnl:LocalToScreen(offsetX or 0, offsetY or 0)
      local w = pnl:GetWide()

      surface.SetFont("BATTLEPASS_Tooltip")
      local width, height = surface.GetTextSize(self.TooltipStr)

      pnl.Tooltip = vgui.Create("BATTLEPASS_Tooltip")
      pnl.Tooltip:SetAlpha(0)
      pnl.Tooltip:SetDrawOnTop(true)
      pnl.Tooltip:SetSize(width + 32, height + 24)
      pnl.Tooltip:SetPos(x + self:GetWide() / 2 - pnl.Tooltip:GetWide() / 2, y - pnl.Tooltip:GetTall() - 4)
      pnl.Tooltip:AlphaTo(255, 0.15)
      pnl.Tooltip.Str = str
    end
  end

  local oldRemove = self.OnRemove
  self.OnRemove = function(pnl)
    if (oldRemove) then oldRemove(pnl) end

    if (IsValid(pnl.Tooltip)) then
      pnl.Tooltip:Remove()
    end
  end
end

function PanelMeta:SetTooltipString(str)
  self.TooltipStr = str
  if (!IsValid(self.Tooltip)) then return end
  self.Tooltip.Str = str

  local x, y = self:LocalToScreen(0, 0)
  local w = self:GetWide()

  surface.SetFont("BATTLEPASS_Tooltip")
  local width, height = surface.GetTextSize(self.TooltipStr)

  self.Tooltip:SetSize(width + 32, height + 24)
  self.Tooltip:SetPos(x + self:GetWide() / 2 - self.Tooltip:GetWide() / 2, y - self.Tooltip:GetTall() - 4)
end

local PANEL = {}
local back = Color(26, 26, 26)
function PANEL:Paint(w, h)
  local x, y = self:LocalToScreen(0, 0)

  BSHADOWS.BeginShadow()
    draw.RoundedBox(6, x, y, w, h - 8, back)
    draw.SimpleText(self.Str, "BATTLEPASS_Tooltip", x + w / 2, y + (h - 8) / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  BSHADOWS.EndShadow(2, 1, 1, 255, 0, 0)

  local tbl = {
    { x = w / 2 - 8, y = h - 8 },
    { x = w / 2 + 8, y = h - 8 },
    { x = w / 2, y = h },
    { x = w / 2 - 8, y = h - 8 }
  }
  
  draw.NoTexture()
  surface.SetDrawColor(back)
  surface.DrawPoly(tbl)
end

vgui.Register("BATTLEPASS_Tooltip", PANEL, "EditablePanel")