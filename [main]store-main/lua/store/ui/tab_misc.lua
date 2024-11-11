local PANEL = {}

Store:CreateFont("Store.Credits.Item.Title", 18)
Store:CreateFont("Store.Credits.Item.Subtitle", 15)
Store:CreateFont("Store.Credits.Item.Content.Title", 17)
Store:CreateFont("Store.Credits.Item.Content.Content", 15)
Store:CreateFont("Store.Credits.Item.Content.Warning", 16)

COLOR_BLUE = Color(41, 128, 185)

function PANEL:Init()
  local ply = LocalPlayer()
  local perRow = 4
  self.background = vgui.Create("XeninUI.ScrollPanel", self)
  self.background:Dock(FILL)
  self.background:DockMargin(8, 8, 8, 8)

  self.cats = {}

  for i, v in ipairs(Store.Credits) do
    self.cats[i] = vgui.Create("XeninUI.Category", self.background)
    self.cats[i]:Dock(TOP)
    self.cats[i]:DockMargin(0, 0, 8, 8)
    self.cats[i]:SetIcon(v.mat)
    self.cats[i]:SetTitle(v.name:upper())
    self.cats[i]:SetSubtitle(#v.items .. " items")
    self.cats[i]:SetItems(v.items)
    self.cats[i]:SetExpandHeight((math.max(1, math.ceil(#v.items / perRow))) * 276)
    self.cats[i].Add = function(self, pnl)
      return vgui.Create(pnl, self.layout)
    end
    self.cats[i].button:DockMargin(0, 0, 0, 0)
    self.cats[i].rows:Remove()

    self.cats[i].layout = vgui.Create("DIconLayout", self.cats[i])
    self.cats[i].layout:Dock(FILL)
    self.cats[i].layout:DockMargin(0, 0, 0, 0)
    self.cats[i].layout:SetBorder(8)
    self.cats[i].layout:SetSpaceY(8)
    self.cats[i].layout:SetSpaceX(12)

    for k, item in ipairs(v.items) do
      local panel = self.cats[i].layout:Add("DButton")
      panel:SetTall(276 - 4 - 4)
      panel:SetText("")
      panel.color = XeninUI.Theme.Navbar
      panel.accent = item.color or COLOR_BLUE or XeninUI.Theme.Accent
      panel.subaccent = item.subColor or ColorAlpha(panel.accent, 150)
      panel.titleColor = Color(255, 255, 255, 200)
      panel.subtitleColor = Color(255, 255, 255, 150)
      panel.alpha = 0
      panel.overlayAlpha = 0
      if item.limited then
        panel.limited = true 
      end
      panel.contentTitleColor = Color(255, 255, 255, 180)
      panel.parse = markup.Parse(string.format(item.content, unpack(item.values)))
      panel.Paint = function(pnl, w, h)

        draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(pnl.accent, pnl.alpha))
        draw.RoundedBox(8, 1, 1, w - 2, h - 2, pnl.color)

        surface.SetDrawColor(pnl.accent)
        draw.RoundedBoxEx(8, 0, 0, w, 36, pnl.accent, true, true, false, false)

        if (pnl.limited) then
          DrawEnchantedText(1.5, item.title, "Store.Credits.Item.Title",  w / 2, 36 / 2, Color(231, 76, 60), Color(46, 204, 113), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        else
          draw.SimpleText(item.title, "Store.Credits.Item.Title", w / 2, 36 / 2, pnl.titleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        surface.SetDrawColor(pnl.subaccent)
        surface.DrawRect(0, 36, w, 26)
        draw.SimpleText(item.cost .. " tokens", "Store.Credits.Item.Subtitle", w / 2, 36 + 26 / 2, pnl.subtitleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        pnl.parse:Draw(10, 36 + 26 + 10, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

        draw.RoundedBox(8, 0, 0, w, h, Color(255, 255, 255, pnl.overlayAlpha / 25))

        if (pnl.limited) then

          surface.SetMaterial(Material("icon16/star.png"))
          surface.SetDrawColor(255, 255, 255, 255)
          surface.DrawTexturedRect(pnl:GetWide()*0.02, 7, 16, 16)

        end

      end
      panel.OnCursorEntered = function(pnl)
        pnl:Lerp("alpha", 255)
        pnl:Lerp("overlayAlpha", 75)
      end
      panel.OnCursorExited = function(pnl)
        pnl:Lerp("alpha", 0)
        pnl:Lerp("overlayAlpha", 0)
      end
      panel.DoClick = function(pnl)
        local x, y = gui.MouseX(), gui.MouseY()

        local canAfford = ply:CanAffordStoreCredits(item.cost)
        local title = canAfford and item.title or "Can't afford " .. item.title
        local subtitle =  item.cost .. " tokens"
        XeninUI:Popup(x, y, title, subtitle, function(pnl)
          -- Unlock

          -- Check again
          local canAfford = ply:CanAffordStoreCredits(item.cost)

          if (!canAfford) then 
            XeninUI:Notify("You can't afford " .. item.title .. "!", nil, nil, XeninUI.Theme.Red)

            return
          end

          
            if (item.limited and os.time() > item.limited) then
              XeninUI:Notify("Item has expired. Cannot be purchased.", nil, nil, XeninUI.Theme.Green)

              return
            end
          
          ply:AddStoreCredits(-item.cost)

          XeninUI:Notify("Unlocked " .. item.title .. "!", nil, nil, XeninUI.Theme.Green)

          if (item.onUnlock(ply, item, i, k)) then
            net.Start("Store.Misc.OnUnlock")
              net.WriteUInt(i, 8)
              net.WriteUInt(k, 16)
            net.SendToServer()
          end
        end, nil, !canAfford, nil, !canAfford and XeninUI.Theme.Red, "Purchase")
      end

      if (item.limited) then
        
        local time_remaining = string.NiceTime(item.limited - os.time()) or "expired"
        panel.buy = panel:Add("DButton")
        panel.buy:SetTall(25)
        panel.buy:Dock(BOTTOM)
        panel.buy:SetMouseInputEnabled(false)
        panel.buy:SetText(time_remaining .. " remaining")
        panel.buy:SetFont("Store.Filter")
        panel.buy:SetTextColor(color_white)
        panel.buy.Paint = function(pnl, w, h)
          surface.SetDrawColor(Color(231, 76, 60))
          surface.DrawRect(0, 0, w, h)
        end
        panel.buy.Think = function(s)
          if (s.nextThink and s.nextThink < CurTime()) then return end
          local time_remaining = string.NiceTime(item.limited - os.time()) or "expired"
          s:SetText(time_remaining .. " remaining")

          s.nextThink = CurTime() + 1

        end

      end
    end



    self.cats[i].layout.PerformLayout = function(pnl, w, h)
      local children = pnl:GetChildren()
      local count = perRow
      local amount = (math.max(1, math.floor(#children / perRow))) * 276
      local width = w / math.min(count, #children)

      local x = 0 
      local y = 0

      local spacingX = pnl:GetSpaceX()
      local spacingY = pnl:GetSpaceY()
      local border = pnl:GetBorder()
      local innerWidth = w - border * 2 - spacingX * (count - 1)

      for i, child in ipairs(children) do
        if (!IsValid(child)) then continue end
      
        child:SetPos(border + x * innerWidth / count + spacingX * x, border + y * child:GetTall() + spacingY * y)
        child:SetSize(innerWidth / count, child:GetTall())

        x = x + 1
        if (x >= count) then
          x = 0
          y = y + 1
        end
      end

      pnl:SizeToChildren(false, true)
    end

    self.cats[i]:SetExpanded(true)
    self.cats[i].button.color = XeninUI.Theme.Accent
    self.cats[i]:SetTall(48 + self.cats[i]:GetExpandHeight() + 8)
  end
end

vgui.Register("Store.Misc", PANEL)