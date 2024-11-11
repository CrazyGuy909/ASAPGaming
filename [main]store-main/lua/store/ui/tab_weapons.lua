local PANEL = {}

Store:CreateFont("Store.Weapons.Handle", 16)
Store:CreateFont("Store.Credits.Item.Title2", 16)

local matWarning = Material("xenin/warning.png", "noclamp smooth")
local matOwned = Material("xenin/owned.png", "smooth")

function PANEL:Init()
  local ply = LocalPlayer()
  local perRow = 5
  self.background = vgui.Create("XeninUI.ScrollPanel", self)
  self.background:Dock(FILL)
  self.background:DockMargin(8, 8, 8, 8)

  self.title = vgui.Create("DPanel", self.background)
  self.title:Dock(TOP)
  self.title:DockMargin(0, 0, 0, 8)
  self.title:SetTall(48)
  self.title.Paint = function(pnl, w, h)
    surface.SetDrawColor(XeninUI.Theme.Green)
    surface.SetMaterial(matWarning)
    surface.DrawTexturedRect(12, 12, h - 24, h - 24)

    draw.SimpleText("All weapons are permanent", "Store.Warning", 12 + h - 24 + 12, h / 2, XeninUI.Theme.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
  end

  self.cats = {}

  local permWeapons = ply:GetPermanentWeapons()
  local active = ply:GetActivePermanentWeapons()
  for i, v in ipairs(Store.Weapons) do
    self.cats[i] = vgui.Create("XeninUI.Category", self.background)
    self.cats[i]:Dock(TOP)
    self.cats[i]:DockMargin(0, 0, 8, 8)
    self.cats[i]:SetIcon(v.mat)
    self.cats[i]:SetTitle(v.name:upper())
    self.cats[i]:SetSubtitle(#v.items .. " items")
    self.cats[i]:SetItems(v.items)
    self.cats[i]:SetExpandHeight((math.max(1, math.ceil(#v.items / perRow))) * 240)
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
      panel:SetTall(240 - 4 - 4)
      panel:SetText("")
      panel.color = XeninUI.Theme.Navbar
      panel.accent = item.color or XeninUI.Theme.Accent
      panel.subaccent = item.subColor or ColorAlpha(panel.accent, 150)
      panel.titleColor = Color(255, 255, 255, 200)
      panel.subtitleColor = Color(255, 255, 255, 150)
      panel.alpha = 0
      panel.overlayAlpha = 0
      panel.contentTitleColor = Color(255, 255, 255, 180)
      panel.owned = permWeapons[item.ent]
      panel.equipped = active[item.ent]
      panel.Paint = function(pnl, w, h)

        draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(pnl.accent, pnl.alpha))
        draw.RoundedBox(8, 1, 1, w - 2, h - 2, pnl.color)

        surface.SetDrawColor(pnl.accent)
        draw.RoundedBoxEx(8, 0, 0, w, 36, pnl.accent, true, true, false, false)

        if (item.limited) then
          DrawEnchantedText(1.7, item.title, "Store.Credits.Item.Title2",  w / 2, 36 / 2, Color(155, 89, 182), Color(46, 204, 113), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
          draw.SimpleText(item.title, "Store.Credits.Item.Title2", w / 2, 36 / 2, pnl.titleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        surface.SetDrawColor(pnl.subaccent)
        surface.DrawRect(0, 36, w, 26)
        draw.SimpleText(item.cost .. " tokens", "Store.Credits.Item.Subtitle", w / 2, 36 + 26 / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        draw.RoundedBox(8, 0, 0, w, h, Color(255, 255, 255, pnl.overlayAlpha / 25))

        if (panel.owned) then
          surface.SetDrawColor(0, 0, 0, 100)
          surface.DrawRect(0, 0, w, 62)

          surface.SetDrawColor(0, 0, 0, 100)
          surface.DrawRect(0, h - 40, w, 40)
        end

          if (item.limited) then

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

        if (!pnl.owned) then
          local canAfford = ply:CanAffordStoreCredits(item.cost)
          local title = canAfford and "Purchase " .. item.title or "Can't afford " .. item.title
          local subtitle =  item.cost .. " tokens"
          XeninUI:Popup(x, y, title, subtitle, function()
            local canAfford = ply:CanAffordStoreCredits(item.cost)

            if (!canAfford) then
              gui.OpenURL(Store.StoreURL)

              return
            end

            if (item.limited and os.time() > item.limited) then
              XeninUI:Notify("Item has expired. Cannot be purchased.", nil, nil, XeninUI.Theme.Green)

              return
            end

            
            ply:AddStoreCredits(-item.cost)

            XeninUI:Notify("Unlocked " .. item.title .. "!", nil, nil, XeninUI.Theme.Green)

            net.Start("Store.UnlockPerm")
              net.WriteUInt(i, 8)
              net.WriteUInt(k, 16)
            net.SendToServer()

            pnl.owned = true

            if (pnl.button) then
              pnl.button:SetVisible(true)
            end
          end, nil, false, nil, !canAfford and XeninUI.Theme.Red, !canAfford and "Get tokens" or "Purchase")
        end
      end

      panel.model = panel:Add("DModelPanel")
      panel.model:SetMouseInputEnabled(false)
      panel.model:SetModel(item.model)
      panel.model.LayoutEntity = function() end
      if IsValid(panel.model.Entity) then
        local mn, mx = panel.model.Entity:GetRenderBounds()
        local size = 0
        size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
        size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
        size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
        panel.model:SetFOV(35)
        panel.model:SetCamPos(Vector(size, size + 30, size + 0))
        panel.model:SetLookAt((mn + mx) * 0.5)
      end
      local basePaint = baseclass.Get("DModelPanel").Paint
      panel.model.Paint = function(pnl, w, h)
        basePaint(pnl, w, h)

        if (panel.owned) then
          surface.SetDrawColor(0, 0, 0, 100)
          surface.DrawRect(0, 0, w, h)

          surface.SetDrawColor(XeninUI.Theme.Green)
          surface.SetMaterial(matOwned)
          surface.DrawTexturedRect(w - 10 - 32, 10, 32, 32)
        end
      end

      panel.button = panel:Add("DButton")
      panel.button:SetVisible(panel.owned)
      panel.button:DockMargin(20, 0, 20, 10)
      panel.button:Dock(BOTTOM)
      panel.button:SetTall(26)
      panel.button:SetText(panel.equipped and "UNEQUIP" or "EQUIP")
      panel.button:SetFont("Store.Weapons.Handle")
      panel.button.textColor = panel.equipped and Color(255, 255, 255) or Color(210, 210, 210)
      panel.button.backgroundColor = panel.equipped and XeninUI.Theme.Red or XeninUI.Theme.Primary
      panel.button.IsEquipped = function(pnl)
        return panel.equipped
      end
      panel.button.Paint = function(pnl, w, h)
        pnl:SetTextColor(pnl.textColor)

        draw.RoundedBox(6, 0, 0, w, h, pnl.backgroundColor)
      end
      panel.button.OnCursorEntered = function(pnl)
        panel:OnCursorEntered()

        pnl:LerpColor("textColor", Color(255, 255, 255))
        pnl:LerpColor("backgroundColor", pnl:IsEquipped() and XeninUI.Theme.Red or XeninUI.Theme.Green)
      end
      panel.button.OnCursorExited = function(pnl)
        panel:OnCursorExited()
        
        if (!pnl:IsEquipped()) then
          pnl:LerpColor("textColor", Color(210, 210, 210))
          pnl:LerpColor("backgroundColor", XeninUI.Theme.Primary)
        end
      end
      panel.button.DoClick = function(pnl)
        if (pnl:IsEquipped()) then
          ply:RemoveActivePermanentWeapon(item.ent)

          panel.equipped = false

          net.Start("Store.SetNoActivePerm")
            net.WriteUInt(i, 8)
            net.WriteUInt(k, 16)
          net.SendToServer()

          pnl:SetText("EQUIP")
          pnl:LerpColor("backgroundColor", XeninUI.Theme.Green)
        else
          ply:AddActivePermanentWeapon(item.ent)
          panel.equipped = true

          net.Start("Store.SetActivePerm")
            net.WriteUInt(i, 8)
            net.WriteUInt(k, 16)
          net.SendToServer()

          pnl:SetText("UNEQUIP")
          pnl:LerpColor("backgroundColor", XeninUI.Theme.Red)
        end
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
          surface.SetDrawColor(Color(230, 126, 34))
          surface.DrawRect(0, 0, w, h)
        end
        panel.buy.Think = function(s)
          if (s.nextThink and s.nextThink < CurTime()) then return end
          local time_remaining = string.NiceTime(item.limited - os.time()) or "expired"

          s:SetText(time_remaining .. " remaining")

          s.nextThink = CurTime() + 1
          
        end

      end
      panel.PerformLayout = function(pnl, w, h)
        if (pnl.model) then
          pnl.model:SetPos(0, 36 + 26)
        end
        local height = h - (pnl.model and pnl.model.y or 0)

        if (pnl.button) then
          height = height - (pnl.button:IsVisible() and 40 or 0)
        end

        if (pnl.model) then
          pnl.model:SetSize(w, height)
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

vgui.Register("Store.Weapons", PANEL)