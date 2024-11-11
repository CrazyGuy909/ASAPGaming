local PANEL = {}
Store:CreateFont("Store.Category.Title", 23)
Store:CreateFont("Store.Category.Subtitle", 15)
Store:CreateFont("Store.Item.Title", 19)
Store:CreateFont("Store.Item.Subtitle", 16)
Store:CreateFont("Store.Warning", 22)
Store:CreateFont("Store.Filter", 18)

Store.Filters = {
    ["ID (default)"] = {
        var = "rankId",
        asc = false
    },
    ["Price (high to low)"] = {
        var = "cost",
        asc = false,
    },
    ["Price (low to high)"] = {
        var = "cost",
        asc = true
    },
}

local matWarning = Material("xenin/warning.png", "noclamp smooth")
local matOwned = Material("xenin/owned.png", "smooth")
PANEL.Buttons = {}

function PANEL:Init()
    local perRow = 3
    local ply = LocalPlayer()
    self.Buttons = {}
    self.filterOption = "ID (default)"
    self.background = vgui.Create("XeninUI.Scrollpanel.Wyvern", self)
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
        draw.SimpleText("All packages are permanent", "Store.Warning", 12 + h - 24 + 12, h / 2, XeninUI.Theme.Green, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    self.filter = self.title:Add("DButton")
    self.filter:Dock(RIGHT)
    self.filter:DockMargin(8, 8, 16, 8)
    self.filter:SetFont("Store.Filter")
    self.filter.textColor = Color(180, 180, 180)

    self.filter.Paint = function(pnl, w, h)
        pnl:SetTextColor(pnl.textColor)
        draw.RoundedBox(6, 0, 0, w, h, XeninUI.Theme.Navbar)
    end

    self.filter.OnCursorEntered = function(pnl)
        pnl:LerpColor("textColor", color_white)
    end

    self.filter.OnCursorExited = function(pnl)
        pnl:LerpColor("textColor", Color(180, 180, 180))
    end

    self.filter.DoClick = function(pnl)
        local popup = XeninUI:DropdownPopup(pnl:LocalToScreen(-12, -12 + pnl:GetTall()))

        for i, v in pairs(Store.Filters) do
            popup:AddChoice(i, function(btn)
                self.filter:SetText(i)
                self.filterOption = i
                self:CreatePackages(self.filterOption)
                self:InvalidateLayout()
            end)
        end
    end

    self.filter:SetText("ID (default)")
    self.layout = self.background:Add("DIconLayout")
    self.layout:Dock(FILL)
    self.layout:DockMargin(8, 0, 14, 0)
    self.layout:SetBorder(0)
    self.layout:SetSpaceY(8)
    self.layout:SetSpaceX(12)

    self.layout.PerformLayout = function(pnl, w, h)
        local children = pnl:GetChildren()
        local count = perRow
        local amount = math.max(1, math.floor(#children / perRow)) * 392
        local width = w / math.min(count, #children)
        local x = 0
        local y = 0
        local spacingX = pnl:GetSpaceX()
        local spacingY = pnl:GetSpaceY()
        local border = pnl:GetBorder()
        local innerWidth = w - border * 2 - spacingX * (count - 1)

        for i, child in ipairs(children) do
            if not IsValid(child) then continue end
            child:SetPos(border + x * innerWidth / count + spacingX * x, border + y * child:GetTall() + spacingY * y)
            child:SetSize(innerWidth / count, child:GetTall())
            x = x + 1

            if x >= count then
                x = 0
                y = y + 1
            end
        end

        pnl:SizeToChildren(false, true)
    end

    self:CreatePackages(self.filterOption)
end

function PANEL:CreatePackages(filter)
    self.layout:Clear()
    local ply = LocalPlayer()
    local filteredTbl = table.Copy(Store.Packages)
    local data
    for k, v in pairs(filteredTbl) do
        if (v.rankId == 999) then
            data = v
            table.remove(filteredTbl, k)
            break
        end
    end

    filter = Store.Filters[filter] or Store.Filters["ID (default)"]
    if filter then
        table.SortByMember(filteredTbl, filter.var, filter.asc)
    end
    table.insert(filteredTbl, data)
    local rank = ply:GetDonator() or 0
    if not donationInventory then
        donationInventory = {}
    end

    for i, v in ipairs(filteredTbl) do
        -- Don't show expired items
        local allow = v.limited and not table.HasValue(donationInventory, v.rankId)
        if allow and v.limited < os.time() then continue end
        local panel = self.layout:Add("DButton")
        panel:SetTall(392 - 4 - 4)
        panel:SetText("")
        panel.color = XeninUI.Theme.Navbar
        panel.accent = v.color or XeninUI.Theme.Accent
        panel.subaccent = v.subColor or ColorAlpha(panel.accent, 150)
        panel.titleColor = Color(255, 255, 255, 200)
        panel.subtitleColor = Color(255, 255, 255, 150)
        panel.alpha = 0
        panel.overlayAlpha = 0
        panel.rankId = v.rankId
        panel.uid = v.uid

        local cost = LocalPlayer():GetStoreDiscount(v.rankId)
        panel.cost = cost == 0 and v.cost or cost

        if v.limited then
            panel.limited = true
        end

        panel.contentTitleColor = Color(255, 255, 255, 180)

        panel.Paint = function(pnl, w, h)
            surface.SetDrawColor(pnl.color)
            draw.RoundedBox(8, 0, 0, w, h - 38, pnl.color)
            surface.SetDrawColor(pnl.accent)
            draw.RoundedBoxEx(8, 0, 0, w, 36, pnl.accent, true, true, false, false)

            if pnl.limited then
                local time_remaining = string.NiceTime(v.limited - os.time())

                if not donationAllowedRank and not table.HasValue(donationInventory, v.rankId) then
                    DrawEnchantedText(2, v.title .. " - " .. time_remaining .. " remaining", "Store.Credits.Item.Title", w / 2, 36 / 2, Color(231, 76, 60), Color(46, 204, 113), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                else
                    DrawEnchantedText(2, v.title, "Store.Credits.Item.Title", w / 2, 36 / 2, Color(231, 76, 60), Color(46, 204, 113), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                --draw.SimpleText(v.title, "Store.Credits.Item.Title", w / 2, 36 / 2, pnl.titleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                draw.SimpleText(v.title, "Store.Credits.Item.Title", w / 2, 36 / 2, pnl.titleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end

            surface.SetDrawColor(pnl.subaccent)
            surface.DrawRect(0, 36, w, 26)
            draw.SimpleText(pnl.cost .. " Tokens", "Store.Credits.Item.Subtitle", w / 2, 36 + 26 / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            local y = 36 + 26 + 10

            for k, text in pairs(v.contents) do
                local istbl = istable(text)
                draw.SimpleText(istbl and text[1] or text, "Store.Credits.Item.Content.Content", w / 2, y, istbl and text[2] or Color(235, 235, 235), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                y = y + 18
            end

            draw.RoundedBox(8, 0, 0, w, h - 38, Color(255, 255, 255, pnl.overlayAlpha / 15))

            if pnl.limited then
                surface.SetMaterial(Material("icon16/star.png"))
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawTexturedRect(pnl:GetWide() * 0.02, 7, 16, 16)
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
            local canAfford = ply:CanAffordStoreCredits(pnl.cost)
            local title = canAfford and "Purchase " .. v.title or "Can't afford " .. v.title
            local subtitle = pnl.cost .. " Tokens"

            if table.HasValue(donationInventory, v.rankId) then
                local menu = DermaMenu()

                menu:AddOption("Equip", function()
                    net.Start("DonationRoles.SelectTitle")
                    net.WriteBool(true)
                    net.WriteUInt(v.rankId, 4)
                    net.SendToServer()
                    net.Start("DonationRoles.SelectTitle")
                    net.WriteBool(false)
                    net.WriteUInt(v.rankId, 4)
                    net.SendToServer()
                    LocalPlayer().donatorVisual = v.rankId
                    LocalPlayer().donator = v.rankId

                    for k, but in pairs(self.Buttons) do
                        if not IsValid(but) then continue end
                        but.buy:UpdateText()
                    end

					hook.Run("HUDDoUpdate")
                end):SetIcon("icon16/wand.png")

                menu:AddOption("Use it Visually", function()
                    net.Start("DonationRoles.SelectTitle")
                    net.WriteBool(true)
                    net.WriteUInt(v.rankId, 4)
                    net.SendToServer()
                    LocalPlayer().donatorVisual = v.rankId

                    for k, but in pairs(self.Buttons) do
                        but.buy:UpdateText()
                    end
					hook.Run("HUDDoUpdate")
                end):SetIcon("icon16/star.png")

                menu:AddOption("Use it as Active", function()
                    net.Start("DonationRoles.SelectTitle")
                    net.WriteBool(false)
                    net.WriteUInt(v.rankId, 4)
                    net.SendToServer()
                    LocalPlayer().donator = v.rankId

                    for k, but in pairs(self.Buttons) do
                        if not IsValid(but.buy) then continue end
                        but.buy:UpdateText()
                    end
                end):SetIcon("icon16/wrench.png")

                menu:AddOption("Cancel")
                menu:Open()

                return
            end

            XeninUI:Popup(x, y, title, subtitle, function()
                local canAfford = ply:CanAffordStoreCredits(pnl.cost)

                if not canAfford then
                    gui.OpenURL(Store.StoreURL)

                    return
                end

                if (not donationAllowedRank or v.rankId ~= donationAllowedRank) and v.limited and os.time() > v.limited then
                    XeninUI:Notify("Item has expired. Cannot be purchased.", nil, nil, XeninUI.Theme.Green)

                    return
                end

                ply:AddStoreCredits(-pnl.cost)
                ply:SetDonator(pnl.rankId)

                if pnl.uid == 4 then
                    ply:AddPermanentWeapon("m9k_dbarrel")
                    ply:AddPermanentWeapon("weapon_lightsaber")
                end

                XeninUI:Notify("Unlocked " .. v.title .. "!", nil, nil, XeninUI.Theme.Green)
                net.Start("Store.PurchasePackage")
                net.WriteUInt(pnl.rankId, 8)
                net.SendToServer()
                table.insert(donationInventory, v.rankId)
                pnl.buy:SetText("-Equipped-")

                for k, but in pairs(self.Buttons) do
                    if IsValid(but.buy) and but ~= pnl and table.HasValue(donationInventory, pnl.rankId) then
                        but.buy:UpdateText()
                    end
                end

                self:CreatePackages(filter)
            end, nil, false, nil, not canAfford and XeninUI.Theme.Red, not canAfford and "Get Tokens" or "Purchase")
        end

        panel.buy = panel:Add("DButton")
        panel.buy:SetTall(32)
        panel.buy:DockMargin(0, 8, 0, 0)
        panel.buy:Dock(BOTTOM)
        panel.buy:SetMouseInputEnabled(false)
        panel.buy.color = XeninUI.Theme.Green

        panel.buy.UpdateText = function(s)
            local active, visual = LocalPlayer().donator, LocalPlayer().donatorVisual
            local owned = table.HasValue(donationInventory, v.rankId)

            if not owned then
                s:SetText("Purchase")
                s.color = XeninUI.Theme.Green

                return
            end

            if active == v.rankId or visual == v.rankId then
                local text = active == v.rankId and "Real Rank" or ""

                if visual == v.rankId then
                    text = active == v.rankId and "Real Rank & Visual" or "Visual Rank"
                end

                s:SetText(text)
                s.color = Color(61, 194, 255)
            else
                s:SetText("Equip")
                s.color = Color(200, 50, 255)
            end
        end

        panel.buy:UpdateText()
        panel.buy:SetFont("Store.Filter")
        panel.buy:SetTextColor(color_white)

        panel.buy.Paint = function(pnl, w, h)
            surface.SetDrawColor(pnl.color)
            draw.RoundedBox(h / 2, 0, 0, w, h, pnl.color)
        end

        local owned = table.HasValue(donationInventory, v.rankId)

        if v.rankId == 1 and owned then
            local permWeps = ply:GetPermanentWeapons()
            local hasPermWeps

            if v.uid == 4 then
                owned = hasPermWeps
            end
        end

        table.insert(self.Buttons, panel)
    end

    for k, card in pairs(self.layout:GetChildren()) do
        local owned = table.HasValue(donationInventory, card.rankId)

        if card.rankId == 1 and owned then
            local permWeps = ply:GetPermanentWeapons()
            local hasPermWeps

            if card.uid == 4 then
                owned = hasPermWeps
            end
        end

        --card.overlay:SetVisible(owned)
        local cost = card.cost
        card.cost = cost
    end
end

function PANEL:PerformLayout(w, h)
    self.filter:SizeToContentsX(32)
end

vgui.Register("Store.Packages", PANEL)