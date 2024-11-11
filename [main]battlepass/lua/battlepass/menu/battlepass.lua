local translate = function(str) return BATTLEPASS:GetTranslation(str) end
BATTLEPASS:CreateFont("BATTLEPASS_PassTitle", 34)
BATTLEPASS:CreateFont("BATTLEPASS_PassSubtitle", 18)
BATTLEPASS:CreateFont("BATTLEPASS_PassPurchase", 18)
BATTLEPASS:CreateFont("BATTLEPASS_PassTime", 20)
BATTLEPASS:CreateFont("BATTLEPASS_PassUnlockedTiers", 22)
BATTLEPASS:CreateFont("BATTLEPASS_PassUnlockableTiers", 15)
BATTLEPASS:CreateFont("BATTLEPASS_PassTier", 15)
BATTLEPASS:CreateFont("BATTLEPASS_PassTierPrice", 15)
BATTLEPASS:CreateFont("BATTLEPASS_PassCardTitle", 16)
BATTLEPASS:CreateFont("BATTLEPASS_PassPages", 16)
BATTLEPASS:CreateFont("BATTLEPASS_PassInfo", 18)
BATTLEPASS:CreateFont("BATTLEPASS_CurrentTierProgress", 16)
BATTLEPASS:CreateFont("BATTLEPASS_Item_Completed", 22)
BATTLEPASS:CreateFont("BATTLEPASS_Item_CompletedSmall", 16)
BATTLEPASS:CreateFont("BATTLEPASS_Item_Claim", 18)
BATTLEPASS:CreateFont("BATTLEPASS_Item_ClaimSmall", 13)
local PANEL = {}

function PANEL:GetBattlePass()
    return self.battlePass
end

local matOwned = Material("battlepass/owned.png", "smooth")
local matLocked = Material("battlepass/lock.png", "smooth")
local matArrow = Material("battlepass/right_arrow.png", "smooth")
local matWallet = Material("battlepass/wallet.png", "smooth")
local matTiers = Material("battlepass/tiers.png", "smooth")
local matItems = Material("battlepass/items.png", "smooth")
local matChallenges = Material("battlepass/challenge.png", "smooth")

function PANEL:SetBattlePass(passId)
end

--self.UnlockedTiers = LocalPlayer().BattlePass.Owned[passId].tier
function PANEL:Init()
    self.Tiers = BATTLEPASS.Pass.tiers
    self.AmountOfItems = 0
    self:DockMargin(0, 0, 0, 0)
    self.Sections = math.ceil(self.Tiers / 10)
    self.CurrentTier = 180
    self.TierRequirement = 10
    self.UnlockedTiers = LocalPlayer():getLevel()
    self.Items = vgui.Create("Panel", self)
    self.Items:Dock(FILL)
    self:CreateFooter()
    self:CreateTiersHeader()
    self:CreateItemsController()
    self:CreateShop()
    local tbl = LocalPlayer().BattlePass.Owned
    local i = 1

    while LocalPlayer():getLevel() > i * 10 do
        self.Items.Background.Right:DoClick()
        i = i + 1
    end
end

function PANEL:CreateItemsController()
    self.PageSize = 10
    self.Pages = math.ceil(self.Tiers / self.PageSize)
    self.Items.Background = vgui.Create("Panel", self.Items)
    self.Items.Background:Dock(BOTTOM)
    self.Items.Background:SetTall(180)
    self.Items.Background:DockMargin(0, 0, 0, 8)
    self.Items.Background.Left = vgui.Create("BATTLEPASS_Button", self.Items.Background)
    self.Items.Background.Left:Dock(LEFT)
    self.Items.Background.Left:SetWide(24)
    self.Items.Background.Left:SetText("")
    self.Items.Background.Left.MaterialColor = BATTLEPASS:GetTheme("Pass.Arrow.Material")

    self.Items.Background.Left.Paint = function(pnl, w, h)
        surface.SetDrawColor(pnl.MaterialColor)
        surface.SetMaterial(matArrow)
        surface.DrawTexturedRectRotated(8, h / 2 - 7, 14, 14, 180)
    end

    self.Items.Background.Left:SetVisible(false)

    self.Items.Background.Left.DoClick = function(pnl)
        if self.CurrentPage <= 1 then return end
        self.CurrentPage = self.CurrentPage - 1

        if not self.Items.Background.Right:IsVisible() then
            self.Items.Background.Right:SetVisible(true)
            self.Items.Background.Right.Hover = 0
            self.Items.Background.Right:SetAlpha(0)
            self.Items.Background.Right:AlphaTo(255, 0.15)
        end

        self:PopulatePage()
        self:InvalidateLayout()

        if self.CurrentPage <= 1 then
            pnl:AlphaTo(0, 0.15, nil, function()
                pnl:SetVisible(false)
            end)
        end
    end

    self.Items.Background.Right = vgui.Create("BATTLEPASS_Button", self.Items.Background)
    self.Items.Background.Right:SetText("")
    self.Items.Background.Right:Dock(RIGHT)
    self.Items.Background.Right:SetWide(20)
    self.Items.Background.Right.MaterialColor = BATTLEPASS:GetTheme("Pass.Arrow.Material")

    self.Items.Background.Right.Paint = function(pnl, w, h)
        surface.SetDrawColor(pnl.MaterialColor)
        surface.SetMaterial(matArrow)
        surface.DrawTexturedRectRotated(9, h / 2 - 7, 14, 14, 0)
    end

    self.Items.Background.Right.DoClick = function(pnl)
        if self.CurrentPage >= self.Pages then return end
        self.CurrentPage = self.CurrentPage + 1

        if not self.Items.Background.Left:IsVisible() then
            self.Items.Background.Left:SetVisible(true)
            self.Items.Background.Left.Hover = 0
            self.Items.Background.Left:SetAlpha(0)
            self.Items.Background.Left:AlphaTo(255, 0.15)
        end

        self:PopulatePage()

        if self.CurrentPage >= self.Pages then
            pnl:AlphaTo("0", 0.15, nil, function()
                pnl:SetVisible(false)
            end)
        end
    end

    self.Page = vgui.Create("Panel", self.Items.Background)
    self.Page:Dock(BOTTOM)
    self.Page:SetTall(172)
    self.Page.BackgroundColor = BATTLEPASS:GetTheme("Pass.Page")

    self.Page.Paint = function(pnl, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, 5))
    end

    self.Page.Panels = {}
    self.CurrentPage = 1
    local topColor = BATTLEPASS:GetTheme("Pass.Page.Tier.Top")
    local topTextColor = BATTLEPASS:GetTheme("Pass.Page.Tier.Top.Text")
    local premiumColor = BATTLEPASS:GetTheme("Pass.Page.Tier.Premium")
    local lockedColor = BATTLEPASS:GetTheme("Pass.Page.Tier.Locked")
    local lockedMatColor = BATTLEPASS:GetTheme("Pass.Page.Tier.Locked.Material")
    local lockedMatBackgroundColor = BATTLEPASS:GetTheme("Pass.Page.Tier.Locked.Background")

    for i = 1, self.PageSize do
        local page = 10 * (self.CurrentPage - 1) + i
        local panel = vgui.Create("Panel", self.Page)

        panel.Paint = function(pnl, w, h)
            draw.RoundedBoxEx(6, 0, 0, w, 24, topColor, true, true, false, false)
            pnl.Page = 10 * (self.CurrentPage - 1) + i
            --if (pnl.Page >= (BATTLEPASS.Pass.tiers - 8) and self.CurrentPage == self.Pages) then
            --pnl.Page = pnl.Page - (10 - (i + 2)) - i
            --end
            draw.SimpleText(pnl.Page, "BATTLEPASS_PassCardTitle", w / 2, 24 / 2, topTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            if pnl.Page <= LocalPlayer():getLevel() then
                surface.SetDrawColor(0, 200, 150)
                surface.DrawOutlinedRect(0, 0, w, h, 2)
            end
        end

        panel.Premium = panel:Add("DPanel")
        panel.Premium:Dock(FILL)
        panel.Premium.Dragging = 0
        panel.Premium.Unlocked = (self.UnlockedTiers >= page or self.OwnsBattlePass) and 1 or 0

        panel.Premium.Paint = function(pnl, w, h)
            draw.RoundedBoxEx(6, 0, 0, w, h, premiumColor, false, false, true, true)
            local page = 10 * (self.CurrentPage - 1) + i

            if page >= (BATTLEPASS.Pass.tiers - 10) and self.CurrentPage == self.Pages then
                page = page - (10 - (i + 2)) - i
            end

            local unlocked = self.UnlockedTiers >= page

            if not unlocked then
                draw.RoundedBoxEx(6, 0, 0, w, h, lockedColor, false, false, true, true)
            end

            unlocked = not unlocked or not self.OwnsBattlePass
            pnl.Unlocked = pnl.Unlocked + ((unlocked and 1 or 0) - pnl.Unlocked) * 12 * FrameTime()
            pnl:PaintLocked(w, h)
        end

        panel.Premium.PaintLocked = function(pnl, w, h)
            XeninUI:DrawCircle(w - 22, 22, 12, 90, ColorAlpha(lockedMatBackgroundColor, pnl.Unlocked * 255))
            surface.SetDrawColor(ColorAlpha(lockedMatColor, pnl.Unlocked * 255))
            surface.SetMaterial(matLocked)
            surface.DrawTexturedRect(w - 22 - 12 / 2, 22 - 12 / 2, 12, 12)
        end

        panel.Premium.Items = {}
        table.insert(self.Page.Panels, panel)
    end

    self.Page.PerformLayout = function(pnl, w, h)
        local x = 8
        local width = (w - 8 - (10 * 10)) / 10

        for i, v in ipairs(self.Page.Panels) do
            v:SetPos(x, 8)
            v:SetSize(width, h - 16)
            x = x + width + 8
        end

        -- Wait for first performlayout then we populate
        if not pnl.HasPerformedLayout then
            self:PopulatePage()
            pnl.HasPerformedLayout = true
        end
    end
end

function PANEL:CreateTiersHeader()
    local tiersData = vgui.Create("Panel", self.Items)
    tiersData:Dock(BOTTOM)
    tiersData:DockMargin(0, 0, 0, 8)
    tiersData:SetTall(64)
    self.CurrentTiers = vgui.Create("DPanel", tiersData)
    self.CurrentTiers:SetWide(200)
    self.CurrentTiers:DockMargin(0, 0, 8, 0)
    self.CurrentTiers:Dock(LEFT)
    self.CurrentTiers.BackgroundColor = BATTLEPASS:GetTheme("Background.Accent")
    self.CurrentTiers.MatColor = BATTLEPASS:GetTheme("Pass.CurrentTiers.Material")
    self.CurrentTiers.ProgressColor = BATTLEPASS:GetTheme("Pass.CurrentTiers.Progress.Text")
    self.CurrentTiers.HighlightColor = BATTLEPASS:GetTheme("Pass.CurrentTiers.Highlight")
    self.CurrentTiers.HighlightBackgroundColor = BATTLEPASS:GetTheme("Pass.CurrentTiers.Highlight.Background")
    self.CurrentTiers.FilledColor = BATTLEPASS:GetTheme("Pass.CurrentTiers.Filled")
    self.CurrentTiers.UnfilledColor = Color(16, 16, 16) --BATTLEPASS:GetTheme("Pass.CurrentTiers.Unfilled")
    self.CurrentTiers.ArrowColor = BATTLEPASS:GetTheme("Pass.CurrentTiers.Arrow.Material")
    self.CurrentTiers.NextTierColor = BATTLEPASS:GetTheme("Pass.CurrentTiers.NextTier.Text")

    self.CurrentTiers.Paint = function(pnl, w, h)
        local tbl = LocalPlayer().BattlePass.Owned
        draw.RoundedBox(4, 0, 0, w, h, pnl.BackgroundColor)
        surface.SetMaterial(matTiers)
        surface.SetDrawColor(pnl.MatColor)
        surface.DrawTexturedRect(8, 8, 20, 20)
        draw.SimpleText(tbl.progress .. "/" .. self.TierRequirement, "BATTLEPASS_CurrentTierProgress", 8 + 20 + 8, 8 + (20 / 2), pnl.ProgressColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        local width = w - 16
        local barWidth = width / self.TierRequirement
        local x = 8
        surface.SetDrawColor(pnl.HighlightColor)
        surface.DrawRect(x, 8 + 20 + 8, width, h - 16 - 20 - 8)
        local width = w - 16
        local barWidth = (width - 8 - (4 * (self.TierRequirement - 1))) / self.TierRequirement
        local x = 12

        for i = 1, self.TierRequirement do
            surface.SetDrawColor(Color(16, 16, 16))
            surface.DrawRect(x, 8 + 20 + 8 + 4, barWidth, h - 16 - 20 - 8 - 8)
            local col = tbl.progress >= i and pnl.FilledColor or pnl.UnfilledColor
            surface.SetDrawColor(col)
            surface.DrawRect(x, 8 + 20 + 8 + 4, barWidth, h - 16 - 20 - 8 - 8)
            x = x + barWidth + 4
        end

        draw.SimpleText(self.UnlockedTiers + 1, "BATTLEPASS_CurrentTierProgress", w - 8, 8 + (20 / 2), pnl.NextTierColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        surface.SetFont("BATTLEPASS_CurrentTierProgress")
        local width = surface.GetTextSize(self.UnlockedTiers + 1)
        surface.SetMaterial(matArrow)
        surface.SetDrawColor(pnl.ArrowColor)
        surface.DrawTexturedRect(w - 8 - width - 9 - 3, 8 + (20 / 2) - (8 / 2), 9, 9)
    end

    self.Header = vgui.Create("Panel", tiersData)
    self.Header:Dock(FILL)
    self.Header.BackgroundColor = BATTLEPASS:GetTheme("Background.Accent")
    self.Header.FocusColor = BATTLEPASS:GetTheme("Pass.Items.Focus.Text")
    self.Header.NonfocusColor = BATTLEPASS:GetTheme("Pass.Items.Nonfocus.Text")
    self.Header.ArrowColor = BATTLEPASS:GetTheme("Pass.Items.Arrow.Material")
    self.Header.ArrowTextColor = BATTLEPASS:GetTheme("Pass.Items.Arrow.Text")
    self.Header.FilledColor = BATTLEPASS:GetTheme("Pass.Items.Filled")
    self.Header.UnfilledColor = BATTLEPASS:GetTheme("Pass.Items.Unfilled")
    self.Header.HighlightBackgroundColor = BATTLEPASS:GetTheme("Pass.Items.Highlight.Background")

    self.Header.Paint = function(pnl, w, h)
        draw.RoundedBox(4, 0, 0, w, h, pnl.BackgroundColor)
        local tbl = LocalPlayer().BattlePass.Owned
        local str = LocalPlayer():getLevel()

        if str < 10 then
            str = "0" .. str
        end

        str = str .. "/"
        surface.SetFont("BATTLEPASS_PassUnlockedTiers")
        local tw, th = surface.GetTextSize(str)
        draw.SimpleText(str, "BATTLEPASS_PassUnlockedTiers", 8, 8, pnl.FocusColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(self.Tiers, "BATTLEPASS_PassUnlockableTiers", 8 + tw, 8 + 5, pnl.NonfocusColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        local width = w - 16
        local y = 8 + 5 + th
        local barWidth = (w - 42 - (16 * (10 - 1))) / 10
        local x = 8
        local cpage = math.floor((self.CurrentPage - 1) / 10)
        local i = 0

        for page = cpage * 10 + 1, (cpage + 1) * 10 do
            i = i + 1
            surface.SetDrawColor(pnl.HighlightBackgroundColor)
            surface.DrawRect(x, y, barWidth, h - y - 8)
            local boxesCount = math.Clamp(self.Tiers - (i * 10) + 10, 1, 10)

            if i ~= self.Sections then
                local h = (h - y - 8) / 2
                surface.SetDrawColor(pnl.ArrowColor)
                surface.SetMaterial(matArrow)
                surface.DrawTexturedRect(x + barWidth, y + h / 2, 16, h)
            end

            local textX = x + barWidth + 6
            local str = tostring(boxesCount)

            if page == self.Sections then
                if boxesCount % 10 ~= 0 then
                    str = tostring(tonumber(tostring(i .. boxesCount)) - 10)
                else
                    str = page .. str:sub(2)
                end

                surface.SetFont("BATTLEPASS_PassTier")
                local tw = surface.GetTextSize(str)
                textX = textX - tw
            else
                str = page .. str:sub(2)
            end

            draw.SimpleText(str, "BATTLEPASS_PassTier", textX, 8 + 5, pnl.ArrowColor, TEXT_ALIGN_CENTER)
            local innerX = x + 4
            local innerWidth = barWidth - 4
            local innerBarWidth = (innerWidth - (4 * boxesCount)) / boxesCount
            local sectionToFull = 10 * (page - 1)

            for j = 1, boxesCount do
                if LocalPlayer():getLevel() >= sectionToFull + j then
                    surface.SetDrawColor(pnl.FilledColor)
                else
                    surface.SetDrawColor(pnl.UnfilledColor)
                end

                surface.DrawRect(innerX, y + 4, innerBarWidth, h - y - 8 - 8)
                innerX = innerX + innerBarWidth + 4
            end

            x = x + barWidth + 16
        end
    end
end

function PANEL:CreateFooter()
    local footer = self:Add("Panel")
    footer:Dock(BOTTOM)
    footer:SetTall(32)
    self.Info = vgui.Create("DPanel", footer)
    self.Info:Dock(RIGHT)
    self.Info:SetWide(ScrH() * .75)
    self.Info.MatColor = BATTLEPASS:GetTheme("Pass.Info.Material")
    self.Info.TextColor = BATTLEPASS:GetTheme("Pass.Info.Text")
    local challenges = 0

    for i, v in pairs(BATTLEPASS.Pass.challenges) do
        for k, tbl in pairs(v) do
            challenges = challenges + 1
        end
    end

    self.Info.Challenges = challenges

    local txt = {
        [1] = {matTiers, "Contains " .. self.Tiers .. " tiers"},
        [2] = {matItems, "Has " .. self.AmountOfItems .. " rewards"},
        [3] = {matChallenges, "Includes " .. challenges .. " challenges"}
    }

    self.Owned = vgui.Create("DImage", self.Info)
    self.Owned:Dock(LEFT)
    self.Owned:SetWide(32)
    self.Info.totalWide = 0

    self.Info.Paint = function(pnl, w, h)
        local y = 0
        local x = w - 8
        -- Tiers
        draw.RoundedBox(4, w - pnl.totalWide - 8, y, pnl.totalWide + 8, h, Color(255, 255, 255, 16))
        surface.SetDrawColor(color_white)

        for k = 3, 1, -1 do
            local tx, _ = draw.SimpleText(txt[k][2], "BATTLEPASS_PassInfo", x, h / 2, pnl.TextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            surface.SetMaterial(txt[k][1])
            surface.DrawTexturedRect(x - tx - h + 2, 4, h - 8, h - 8)
            x = x - tx - 36
        end

        pnl.totalWide = w - (x + 8)
    end

    self.BuyButton = footer:Add("BATTLEPASS_Button")
    self.BuyButton:Dock(LEFT)
    self.BuyButton:SetWide(250)
    self.BuyButton:SetText("Purchase Battle Pass")
    self.BuyButton:SetContentAlignment(4)
    self.BuyButton:SetTextInset(16, 0)
    self.BuyButton:SetFont("BATTLEPASS_PassPurchase")
    self.BuyButton.BackgroundColor = BATTLEPASS:GetTheme("Pass.CurrentTiers.Filled")
    self.BuyButton:SetTextColor(color_white)
    self.BuyButton.Extra = 111
    self.BuyButton:SizeToContentsX(32 + 90)

    self.BuyButton.Paint = function(pnl, w, h)
        pnl.Extra = not pnl.Owned and 111 or 108
        draw.RoundedBoxEx(6, 0, 0, w - pnl.Extra, h, pnl.BackgroundColor, true, false, true, false)
        draw.RoundedBoxEx(6, w - pnl.Extra, 0, pnl.Extra, h, BATTLEPASS:GetTheme("Background.Accent"), false, true, false, true)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(matWallet)
        surface.DrawTexturedRect(w - pnl.Extra + 8, 8, 16, 16)
        local text = pnl.Owned and BATTLEPASS.Config.TierPrice or BATTLEPASS.Config.PassPrice
        text = text .. " credits"
        draw.SimpleText(text, "BATTLEPASS_PassTierPrice", w - pnl.Extra + 8 + 16 + 5, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.RoundedBox(6, 0, 0, w, h, Color(0, 0, 0, 100 * pnl.Hover))
    end

    self.BuyButton.DoClick = function(pnl)
        local msg = "You don't have enough credits for that!"

        if not pnl.Owned then
            local canBuy = BATTLEPASS:CanBuyPass(LocalPlayer())

            if canBuy then
                local popup = vgui.Create("XeninUI.Query")
                popup:SetSize(ScrW(), ScrH())
                popup:SetBackgroundWidth(400)
                popup:SetBackgroundHeight(140)
                popup:SetTitle("Buy Battle Pass")
                popup:SetText("Do you wish to buy the Battle Pass for 1000 credits?")

                popup:SetAccept("Yes, I want to", function()
                    LocalPlayer():AddStoreCredits(-BATTLEPASS.Config.PassPrice)
                    BATTLEPASS:SetOwned(LocalPlayer(), true)
                    net.Start("BATTLEPASS.BuyPass")
                    net.SendToServer()
                    self:SetOwned(true)
                    self:InvalidateLayout()
                end)

                popup:SetDecline("Nevermind", function() end)
                popup:MakePopup()
            else
                local popup = vgui.Create("XeninUI.Query")
                popup:SetSize(ScrW(), ScrH())
                popup:SetBackgroundWidth(400)
                popup:SetBackgroundHeight(140)
                popup:SetTitle("Buy Battle Pass")
                popup:SetText("You can't afford the Battle Pass, you need to have 1000 credits. Visit the website to get some credits")

                popup:SetAccept("Go to website", function()
                    gui.OpenURL("https://galaxium.tebex.io/")
                end)

                popup:SetDecline("Nevermind", function() end)
                popup:MakePopup()
            end
        else
            local canBuy = BATTLEPASS:CanBuyTiers(LocalPlayer(), 1)

            if canBuy then
                local popup = vgui.Create("XeninUI.Query")
                popup:SetSize(ScrW(), ScrH())
                popup:SetBackgroundWidth(400)
                popup:SetBackgroundHeight(140)
                popup:SetTitle("Buy Tier")
                popup:SetText("Do you wish to buy a tier for the Battle Pass for 100 credits?")

                popup:SetAccept("Yes, I want to", function()
                    LocalPlayer():AddStoreCredits(-BATTLEPASS.Config.TierPrice)
                    net.Start("BATTLEPASS.BuyTier")
                    net.WriteUInt(1, 10)
                    net.SendToServer()
                end)

                popup:SetDecline("Nevermind", function() end)
                popup:MakePopup()
            else
                local popup = vgui.Create("XeninUI.Query")
                popup:SetSize(ScrW(), ScrH())
                popup:SetBackgroundWidth(400)
                popup:SetBackgroundHeight(140)
                popup:SetTitle("Buy Battle Pass")
                popup:SetText("You can't afford a tier, you need to have 100 credits. Visit the website to get some credits")

                popup:SetAccept("Go to website", function()
                    gui.OpenURL("https://galaxium.tebex.io/")
                end)

                popup:SetDecline("Nevermind", function() end)
                popup:MakePopup()
            end
        end
    end

    self.BuyButton:SetDisableHoverDraw(true)
end

BATTLEPASS:CreateFont("BATTLEPASS_ItemTitle", 16)
BATTLEPASS:CreateFont("BATTLEPASS_ItemTitleSmall", 13)
BATTLEPASS:CreateFont("BATTLEPASS_ItemAmount", 15)
BATTLEPASS:CreateFont("BATTLEPASS_ItemAmountSmall", 12)

function PANEL:CreateItem(tbl, size, index, passIndex)
    local ply = LocalPlayer()

    if not tbl.display then
        PrintTable(tbl)

        return
    end

    local item = BU3.Items.Items[tbl.display]
    if not item then return end
    tbl.color = BU3.Items.RarityToColor[item.itemColorCode or 1]

    local color = {
        background = color_white,
        outline = tbl.color or color_white
    }

    local panel = vgui.Create("DButton")
    panel:SetText("")
    panel:Dock(FILL)
    panel.Background = color.background
    panel.Outline = color.outline
    panel.Hover = 0
    panel.Dragging = 0
    panel.BackgroundColor = BATTLEPASS:GetTheme("Pass.Page.Tier.Item.Background")
    panel.TextColor = BATTLEPASS:GetTheme("Pass.Page.Tier.Item.Text")
    panel.HoverColor = BATTLEPASS:GetTheme("Pass.Page.Tier.Item.Hover")
    panel.DraggingColor = BATTLEPASS:GetTheme("Pass.Page.Tier.Item.Dragging")
    panel.AmountTextColor = BATTLEPASS:GetTheme("Pass.Page.Tier.Item.Amount.Text")

    panel.Paint = function(pnl, w, h)
        draw.RoundedBox(4, 0, 0, w, h, passIndex % 5 == 0 and Color(49, 100, 18, 150) or Color(255, 255, 255, 15))
        draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(255, 255, 255, 5))
        draw.RoundedBoxEx(4, 0, h - 24, w, 24, ColorAlpha(pnl.Outline, 100), false, false, true, true)
        local font = index == 1 and "BATTLEPASS_ItemTitle" or "BATTLEPASS_ItemTitleSmall"
        draw.SimpleText(tbl.name, font, w / 2, h - (24 / 2), pnl.TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        if pnl:IsHovered() or pnl.Depressed then
            pnl.Hover = pnl.Hover + (1 - pnl.Hover) * 7 * FrameTime()
        else
            pnl.Hover = pnl.Hover + (0 - pnl.Hover) * 7 * FrameTime()
        end

        draw.RoundedBox(6, 0, 0, w, h, ColorAlpha(pnl.HoverColor, 20 * pnl.Hover))
        local isDragging = dragndrop.IsDragging()
        pnl.Dragging = pnl.Dragging + ((isDragging and 1 or 0) - pnl.Dragging) * 12 * FrameTime()
        draw.RoundedBox(6, 0, 0, w, h, ColorAlpha(pnl.DraggingColor, pnl.Dragging * 20))

        if tbl.amount then
            font = index == 1 and "BATTLEPASS_ItemAmount" or "BATTLEPASS_ItemAmountSmall"
            local margin = index == 1 and 8 or 4
            draw.SimpleText("x" .. tbl.amount, font, w - margin, h - 24 - margin, pnl.AmountTextColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        end
    end

    if tbl.extra and (tbl.extra.hidden or tbl.extra.locked) then
        if tbl.extra.locked or LocalPlayer():getLevel() < index then
            panel.PaintOver = function(s, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(26, 26, 26))
                draw.SimpleText("?", "Arena.Medium", w / 2, h / 2, color_white, 1, 1)
                draw.SimpleText("Hidden/Locked", "BATTLEPASS_ItemTitleSmall", w / 2, h - 12, color_white, 1, 1)
            end
        else
            if item.name then
                panel:AddTooltip(item.name, 0.4)
            end
        end
    else
        if item.name then
            panel:AddTooltip(item.name, 0.4)
        end
    end

    local ismodel = isstring(tbl.display) and tbl.display:find(".mdl")
    panel.display = panel:Add(ismodel and "DModelPanel" or "Panel")
    panel.display:SetMouseInputEnabled(false)
    panel.display:DockMargin(1, 1, 1, 24)
    panel.display:SetSize(128, 128)
    panel.display.MaterialColor = BATTLEPASS:GetTheme("Pass.Page.Tier.Locked.Material")
    panel.display.MaterialBackgroundColor = BATTLEPASS:GetTheme("Pass.Page.Tier.Locked.Background")

    if ismodel then
        panel.display:SetModel(tbl.display)
        panel.display.LayoutEntity = function() end
        local mn, mx = panel.display.Entity:GetRenderBounds()
        local size = 0
        size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
        size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
        size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
        panel.display:SetFOV(tbl.extra.fov or 33)
        panel.display:SetCamPos(Vector(size, size + 30, size - 30))
        panel.display:SetLookAt((mn + mx) * 0.5)

        if index == 1 then
            local oldPaint = panel.display.Paint

            panel.display.Paint = function(pnl, w, h)
                oldPaint(pnl, w, h)
                local parent = pnl:GetParent():GetParent()
                XeninUI:DrawCircle(w - 13, 13, 12, 90, ColorAlpha(pnl.MaterialBackgroundColor, parent.Unlocked * 255))
                surface.SetDrawColor(ColorAlpha(pnl.MaterialColor, parent.Unlocked * 255))
                surface.SetMaterial(matLocked)
                surface.DrawTexturedRect(w - 13 - 12 / 2, 13 - 12 / 2, 12, 12)
            end
        end
    elseif isstring(tbl.display) then
        local mat = Material(tbl.display, "smooth")

        panel.display.Paint = function(pnl, w, h)
            surface.SetDrawColor(color_white)
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(w / 2 - h / 4, h / 4, h / 2, h / 2)
            if index ~= 1 then return end
            local parent = pnl:GetParent():GetParent()
            XeninUI:DrawCircle(w - 13, 13, 12, 90, ColorAlpha(pnl.MaterialBackgroundColor, parent.Unlocked * 255))
            surface.SetDrawColor(ColorAlpha(pnl.MaterialColor, parent.Unlocked * 255))
            surface.SetMaterial(matLocked)
            surface.DrawTexturedRect(w - 13 - 12 / 2, 13 - 12 / 2, 12, 12)
        end
    else
        local iconPreview = nil
        local item = BU3.Items.Items[tbl.display]

        if not item then
            MsgN("[BP] Invalid item")
            PrintTable(tbl)
            panel:Remove()

            return
        end

        panel.display.Item = item

        if item.iconIsModel then
            iconPreview = BU3.UI.Elements.ModelView(item.iconID, item.zoom, panel.display)
        else
            iconPreview = BU3.UI.Elements.IconView(item.iconID, item.color, panel.display, false)
        end

        panel.display.Paint = function(pnl, w, h) end
        iconPreview:SetParent(panel.display)
        iconPreview:Dock(FILL)
        panel.icon = iconPreview
    end

    local stage = ply.bpStage or 0
    local canClaim = false
    local claimed = stage >= index
    local owned = ply.BattlePass.Owned.owned

    if not owned and not claimed and index % 5 == 0 then
        canClaim = true
    end

    if ply:getLevel() >= index and (canClaim or not claimed) then
        panel.overlay = panel:Add("DButton")
        panel.overlay:Dock(FILL)
        panel.overlay:SetText("")
        panel.overlay.Alpha = 220
        panel.overlay.anim = 1

        panel.overlay.Paint = function(pnl, w, h)
            surface.SetDrawColor(Color(255, 191, 0))
            surface.DrawOutlinedRect(0, 0, w, h, 2)

            for k = 1, 4 do
                pnl.anim = (RealTime() / 2 + k / 4) % 1
                surface.SetDrawColor(Color(255, 191, 0, 50 - pnl.anim * 50))
                local x, y = 32 * pnl.anim, 32 * pnl.anim
                surface.DrawOutlinedRect(x, y, w - x * 2, h - y * 2, 2)
            end

            if pnl:IsHovered() then
                surface.SetDrawColor(Color(255, 255, 255, 10))
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(Color(255, 191, 0, pnl.Alpha))
                surface.DrawOutlinedRect(0, 0, w, h, 4)
            end

            if (ply.bpStage or 0) >= index then
                pnl:Remove()
            end
        end

        panel.overlay.OnCursorEntered = function(pnl)
            pnl:Lerp("Alpha", 235)
        end

        panel.overlay.OnCursorExited = function(pnl)
            pnl:Lerp("Alpha", 220)
        end

        panel.overlay.DoClick = function(pnl)
            BATTLEPASS:ClaimItem(LocalPlayer())
            net.Start("BATTLEPASS.ClaimItem")
            net.SendToServer()
            pnl:Remove()
        end

        if item.name then
            panel.overlay:AddTooltip(item.name, 0.4)
        end
    end

    panel.PerformLayout = function(pnl, w, h)
        local width = self.Page.Panels[1]:GetWide()
        local height = self.Page.Panels[1]:GetTall()
        local size = math.min(width, height, 96)
        panel.display:SetSize(size, size)
        panel.display:SetPos(w / 2 - size / 2, h / 2 - size / 2 - 16)
    end

    return panel
end

function PANEL:PopulatePage()
    local tbl = self.Page.Panels
    local bTbl = BATTLEPASS.Pass
    if not bTbl then return end
    local startLevel = 10 * (self.CurrentPage - 1) + 1
    local endLevel = startLevel + 9
    -- Makes the last page always (tiers - 7 to tiers) which might show (50 - 7 to 50) aka (43-50)
    startLevel = math.min(startLevel, math.max(1, bTbl.tiers - 9))
    endLevel = math.min(endLevel, math.max(1, bTbl.tiers))
    local panelIndex = 1

    for i = startLevel, endLevel do
        local panel = tbl[panelIndex]

        if not panel then
            panel = tbl[panelIndex - 1]
        end

        if not panel:IsVisible() and i <= self.Tiers then
            panel:SetVisible(true)
        elseif panel:IsVisible() and i > self.Tiers then
            panel:SetVisible(false)
        end

        for i, v in pairs(panel.Premium.Items) do
            v:Remove()
            panel.Premium.Items[i] = nil
        end

        local pnl = self:CreateItem(bTbl.rewards[i], #bTbl.rewards, i, i)
        if not IsValid(pnl) then continue end
        pnl:SetParent(panel.Premium)
        pnl:DockMargin(0, 24, 0, 0)
        table.insert(panel.Premium.Items, pnl)
        panelIndex = panelIndex + 1
    end

    self:CalculateItems()
end

function PANEL:SetOwned(owned)
    self.Owned:SetMaterial(owned and matOwned or matLocked)
    self.Owned:SetImageColor(owned and XeninUI.Theme.Green or XeninUI.Theme.Red)
    self.OwnsBattlePass = owned
    self.BuyButton.Owned = owned
    self.BuyButton:SetText(owned and "Purchase Tiers" or "Purchase Battle Pass")
end

function PANEL:CreateShop()
    self.BattleShop = vgui.Create("BP.Shop", self.Items)
    self.BattleShop:Dock(FILL)
end

function PANEL:Think()
    local keyboardFocus = vgui.GetKeyboardFocus()
    if keyboardFocus ~= self:GetParent():GetParent():GetParent() then return end
    local rightDown = input.IsKeyDown(KEY_D)
    local leftDown = input.IsKeyDown(KEY_A)
    local shiftDown = input.IsKeyDown(KEY_LSHIFT)
    local ctrlDown = input.IsKeyDown(KEY_LCONTROL)
    local count = ctrlDown and math.Clamp(2, 1, self.Pages) or 1

    if self.RightDown and not rightDown and self.CurrentPage ~= self.Pages then
        if shiftDown then
            count = self.Pages - self.CurrentPage
        end

        for i = 1, count do
            self.Items.Background.Right:DoClick()
        end
    elseif self.LeftDown and not leftDown and self.CurrentPage ~= 1 then
        if shiftDown then
            count = self.CurrentPage - 1
        end

        for i = 1, count do
            self.Items.Background.Left:DoClick()
        end
    end

    self.RightDown = rightDown
    self.LeftDown = leftDown
end

function PANEL:CalculateItems()
    local tbl = BATTLEPASS.Pass
    if not tbl then return end
    local items = 0

    for i, v in pairs(tbl.rewards) do
        items = items + #v
    end

    self.AmountOfItems = items

    return self.AmountOfItems
end

function PANEL:Reload()
    local id = self:GetBattlePass()
    local tbl = BATTLEPASS.Pass
end

function PANEL:SetTitle()
end

vgui.Register("BATTLEPASS_Pass", PANEL)