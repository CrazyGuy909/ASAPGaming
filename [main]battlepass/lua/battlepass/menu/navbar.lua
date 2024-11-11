BATTLEPASS:CreateFont("BATTLEPASS_NavbarButton", 16)

local PANEL = {}

function PANEL:Init()
  self.Buttons = {}
  self.Panels = {}
  self.Active = 1
end

function PANEL:SetChild(panel)
  self.Child = vgui.Create("Panel", panel)
  self.Child:Dock(FILL)
  self.Child.Offset = 0
  self.Child.Panels = {}
  self.Child.AddPanel = function(pnl, panel, callback)
    local frame = vgui.Create(panel, pnl)

    table.insert(pnl.Panels, frame)

    if (callback) then callback(frame) end

    return frame
  end
  self.Child.PerformLayout = function(pnl, w, h)
    for i, v in ipairs(pnl.Panels) do
      local x = (i - 1) * w - (pnl.Offset * w)

      v:SetSize(w, h)
      v:SetPos(x, 0)
    end
  end
end

function PANEL:AddButton(name, panel, onClick, onCreate)
  local button = vgui.Create("BATTLEPASS_Button", self)
  button:Dock(LEFT)
  button:SetText(name)
  button:SetFont("BATTLEPASS_NavbarButton")
  button:SetTextColor(Color(190, 190, 190))
  button.Active = 0
  button.Paint = function(pnl, w, h)
    if (pnl.Id == self.Active) then
      pnl.Active = pnl.Active + (1 - pnl.Active) * 7 * FrameTime()
    else
      pnl.Active = pnl.Active + (0 - pnl.Active) * 7 * FrameTime()
    end

    local col = 190 + (50 * pnl.Active)
    pnl:SetTextColor(Color(col, col, col))

    draw.RoundedBox(4, 2, 2, w - 4, h - 4, ColorAlpha(color_white, 20 * pnl.Active))
  end
  button.PerformLayout = function(pnl, w, h)
    surface.SetFont(pnl:GetFont())
    local tw = surface.GetTextSize(pnl:GetText())

    pnl:SetWide(tw + 32)
  end
  button.DoClick = function(pnl)
    self:SetActive(pnl.Id)

    if (onClick) then
      onClick(pnl, self)
    end
  end

  local pnl = self.Child:AddPanel(panel)

  button.Id = table.insert(self.Buttons, button)

  if (button.Id == 1) then
    button.Active = 1
  end

  if (onCreate) then
    onCreate(pnl, self)
  end
end

function PANEL:SetActive(id)
  if (id == self.Active) then return end

  self.Active = id
  self.Child.Think = function(pnl)
    pnl:InvalidateLayout()
  end
  self.Child:Lerp("Offset", id - 1, 0.3, function()
    self.Think = nil
  end)
end

vgui.Register("BATTLEPASS_Navbar", PANEL)