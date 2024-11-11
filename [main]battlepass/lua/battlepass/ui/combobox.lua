local PANEL = {}

AccessorFunc(PANEL, "m_textColor", "TextColor")
AccessorFunc(PANEL, "m_name", "Name")

local theme = function(str) return BATTLEPASS:GetTheme(str) end

function PANEL:Init()
  self.Choices = {}
  self.Data = {}

  self.BackgroundColor = theme("Background.Accent")
  self.NameColor = theme("TextEntry.Name.Text")
  self.Combobox = vgui.Create("DButton", self)
  self.Combobox:SetText("")
  self.Combobox:SetFont("BATTLEPASS_TextEntryName")
  self.Combobox:SetTextColor(theme("TextEntry.Text"))
  self.Combobox:SetContentAlignment(4)
  self.Combobox:SetTextInset(3, 0)
  self.Combobox.Paint = nil
  self.Combobox.DoClick = function(pnl)
    self:OpenMenu()
  end
end

function PANEL:GetExpanded()
  if (IsValid(self.Combobox.Menu)) then
    if self.Combobox.Menu._closing then return false end

    return true
  end

  return false
end

function PANEL:OpenMenu()
  if (table.Count(self.Choices) == 0) then return end

  if (IsValid(self.Combobox.Menu)) then
    self.Combobox.Menu:Remove()
    self.Combobox.Menu = nil
  end

  self.Combobox.Menu = vgui.Create("EditablePanel")
  self.Combobox.Menu.Paint = function(pnl, w, h)
    local x, y = pnl:LocalToScreen(0, 0)
    
    BSHADOWS.BeginShadow()
      draw.RoundedBox(6, x, y, w, h, theme("Combobox.Dropdown"))
    BSHADOWS.EndShadow(1, 2, 2, nil, nil, nil, false)
  end
  self.Combobox.Menu:SetDrawOnTop(true)
  self.Combobox.Menu:MakePopup()
  local x, y = self.Combobox:LocalToScreen(0, self.Combobox:GetTall() + 4)
  self.Combobox.Menu:SetPos(x - 4, y)
  self.Combobox.Menu:SetWide(self.Combobox:GetWide() + 8)
  self.Combobox.Menu:SetTall(table.Count(self.Choices) * 48 + 8 + 8)
  self.Combobox.Menu.OnFocusChanged = function(pnl, gained)
    timer.Simple(0, function()
      if (IsValid(self)) then
        if (!gained and !self.textentryHasFocus and IsValid(self.Combobox.Menu)) then
          self.Combobox.Menu:Remove()
          self.Combobox.Menu = nil
        end
      end
    end)
  end
  self.Combobox.Menu.Tbl = {}
  self.Combobox.Menu:DockPadding(0, 8, 0, 8)
  self.Combobox.Menu.PerformLayout = function(pnl, w, h)
    local y = 8

    for i, v in ipairs(pnl.Tbl) do
      v:SetWide(w)
      v:SetPos(0, y)

      y = y + v:GetTall()
    end
  end

  for i, v in ipairs(self.Choices) do
    local data = self.Data[i]
    
    self.Combobox.Menu.Tbl[i] = vgui.Create("DButton", self.Combobox.Menu)
    self.Combobox.Menu.Tbl[i]:SetTall(48)
    self.Combobox.Menu.Tbl[i]:SetText(v)
    self.Combobox.Menu.Tbl[i]:SetFont("BATTLEPASS_TextEntry")
    self.Combobox.Menu.Tbl[i]:SetContentAlignment(4)
    self.Combobox.Menu.Tbl[i]:SetTextInset(16, 0)
    self.Combobox.Menu.Tbl[i]:SetTextColor(theme("Combobox.Options.Text"))
    self.Combobox.Menu.Tbl[i].Alpha = 0
    self.Combobox.Menu.Tbl[i].HighlightColor = theme("Combobox.Options.Highlight")
    self.Combobox.Menu.Tbl[i].Paint = function(pnl, w, h)
      surface.SetDrawColor(ColorAlpha(pnl.HighlightColor, pnl.Alpha))
      surface.DrawRect(0, 0, w, h)

      if (pnl:IsHovered()) then
        pnl.Alpha = pnl.Alpha + (150 - pnl.Alpha) * 15 * FrameTime()
      else
        pnl.Alpha = pnl.Alpha + (0 - pnl.Alpha) * 15 * FrameTime()
      end
    end
    self.Combobox.Menu.Tbl[i].DoClick = function(pnl)
      self:SetActive(i, pnl:GetText())

      self.Combobox.Menu:Remove()
      self.Combobox.Menu = nil
    end
  end
end

function PANEL:SetActive(index, name)
  self.Active = index

  self.Combobox:SetText(name)

  self:OnChoice(index, name)
end

function PANEL:SetActiveByName(name)
  for i, v in pairs(self.Choices) do
    if (name == v) then
      self:SetActive(i, v)

      break
    end
  end
end

function PANEL:OnChoice() 
  -- override
end

function PANEL:RemoveAllChoices()
  if (IsValid(self.Combobox.Menu)) then
    self.Combobox.Menu:Remove()
    self.Combobox.Menu = nil
  end

  table.Empty(self.Choices)
  table.Empty(self.Data)
end


function PANEL:GetActive()
  return self.Active
end

function PANEL:GetActiveName()
  return self.Combobox:GetText()
end

function PANEL:OnRemove()
  if (IsValid(self.Combobox.Menu)) then
    self.Combobox.Menu:Remove()
  end
end

function PANEL:Think()
  if (self.invalidateLayout) then
    self:InvalidateLayout()
  end
end

function PANEL:PerformLayout(w, h)
  self.Combobox:SetWide(w - 10)
  self.Combobox:SetPos(5, h / 2 - self.Combobox:GetTall() / 2 + 9)
end

function PANEL:Paint(w, h)
  draw.RoundedBox(6, 0, 0, w, h, self.BackgroundColor)

  draw.SimpleText(self:GetName() or "Name", "BATTLEPASS_TextEntryName", 8, 13, self.NameColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

function PANEL:AddChoice(name, data)
  local i = table.insert(self.Choices, name)
  self.Data[i] = data
end

vgui.Register("BATTLEPASS_Combobox", PANEL)