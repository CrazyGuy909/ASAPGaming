BATTLEPASS.ActiveTheme = "Dark"
BATTLEPASS.Themes = {}

function BATTLEPASS:SetTheme(str)
  self.ActiveTheme = str
end

function BATTLEPASS:GetTheme(index)
  return self:GetActiveTheme()[index] or Color(20, 20, 20, 200)
end

function BATTLEPASS:GetActiveTheme()
  return self.Themes[self.ActiveTheme] or {}
end

function BATTLEPASS:RegisterTheme(name, tbl)
  self.Themes[name] = tbl
end

BATTLEPASS:SetTheme("Dark")