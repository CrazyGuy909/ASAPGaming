local PANEL = {}
PANEL.Categories = {}

local tokens = Material("pcshadowwz/flash.png")
function PANEL:Init()
    BPSHOP = self
    self:Dock(FILL)
    self:InvalidateParent(true)
    self:InvalidateLayout(true)

    self:DockMargin(0, 8, 0, 0)

    self.Scroll = vgui.Create("XeninUI.ScrollPanel", self)
    self.Scroll:Dock(FILL)
    self:GenerateItems()
    
    self.Currency = vgui.Create("DButton", self)
    self.Currency:SetText(LocalPlayer().bpTokens or 0)
    self.Currency:SetFont(XeninUI:Font(48))
    self.Currency:SetTextColor(color_white)
    self.Currency:SetContentAlignment(6)
    self.Currency:SetTextInset(14, -3)
    self.Currency:SetDrawOnTop(true)
    self.Currency:SetTooltip("Tokens\nEarn Tokens by completing challenges and leveling up!")
    self.Currency.Paint = function(s, w, h)
        draw.RoundedBox(h / 2, 0, 0, w, h, Color(255, 255, 255, 10))
        draw.RoundedBox(h / 2, 1, 1, w - 2, h - 2, Color(0, 0, 0, 255))

        draw.RoundedBox(h / 2, 0, 0, h, h, Color(255, 255, 255, 10))
        surface.SetMaterial(tokens)
        surface.SetDrawColor(BATTLEPASS:GetTheme("Pass.Items.Arrow.Material"))
        surface.DrawTexturedRect(6, 6, 36, 36)
    end

end

function PANEL:GenerateItems()
    for k, items in SortedPairsByMemberValue(BATTLEPASS.TokenStore, "Progression") do
        if IsValid(self.Categories[k]) then
            self.Categories[k]:Remove()
            self.Categories[k] = nil
        end

        local cat = vgui.Create("DPanel", self.Scroll)
        cat:Dock(TOP)
        //cat:SetTall(256)
        cat:DockMargin(16, 0, 16, 8)
        cat:DockPadding(0, 48, 0, 0)

        cat.Paint = function(s, w, h)
            draw.SimpleText(k, XeninUI:Font(32), 0, 0)
            surface.SetDrawColor(255, 255, 255, 25)
            surface.DrawRect(0, 36, w, 1)
            if (items.Progression > 0) then
                draw.SimpleText("Requires " .. items.Progression .. " tiers", XeninUI:Font(20), w - 8, 8, color_white, TEXT_ALIGN_RIGHT)
            end
        end

        cat:InvalidateLayout(true)

        cat.IconLayout = vgui.Create("DIconLayout", cat)
        cat.IconLayout:Dock(FILL)
        cat.IconLayout:SetSpaceX(16)
        cat.IconLayout:SetSpaceY(8)
        cat.Items = {}
        self.Categories[k] = cat

        for slot, data in pairs(items.Items, true) do
            local item = vgui.Create("gInventory.Item", cat.IconLayout)
            item:SetSize(132, 172)
            item:SetText("")
            item:SetItem(data.item)
            item.ignoreAmount = true

            item.DoClick = function(s)
                if (LocalPlayer().bpTokens or 0) < data.price then
                    Derma_Message("You don't have enough tokens to purchase this item!", "Error", "OK")

                    return
                end

                if (data.max and data.max > 0) and (LocalPlayer().bpClaimed or {})[data.item] and (LocalPlayer().bpClaimed or {})[data.item] >= data.max then
                    Derma_Message("You have reached the maximum amount of this item you can purchase!", "Error", "OK")

                    return
                end

                if (items.Progression > LocalPlayer():getLevel(true)) then
                    Derma_Message("You need to be at tier " .. items.Progression .. " in order to get this item\nRight now you're tier " .. LocalPlayer():getLevel(), "Error", "OK")

                    return
                end
                Derma_Query("Are you sure you want to purchase this item for " .. data.price .. " tokens?", "Purchase", "Yes", function()
                    LocalPlayer().bpClaimed = LocalPlayer().bpClaimed or {}
                    LocalPlayer().bpClaimed[data.item] = (LocalPlayer().bpClaimed[data.item] or 0) + 1
                    net.Start("BATTLEPASS.BuyStore")
                    net.WriteString(k, 7)
                    net.WriteUInt(slot, 7)
                    net.SendToServer()
                end, "No")
            end

            item.customPaint = function(s, w, h)
                draw.RoundedBox(12, 12, h - 34, w - 24, 24, Color(66, 66, 66))
                draw.RoundedBox(12, 13, h - 33, w - 26, 22, Color(36, 36, 36))

                surface.SetMaterial(tokens)
                surface.SetDrawColor(BATTLEPASS:GetTheme("Pass.Items.Arrow.Material"))
                surface.DrawTexturedRect(16, h - 30, 16, 16)

                if (data.max) then
                    draw.SimpleText(string.Comma(data.price) .. " - " .. ((LocalPlayer().bpClaimed or {})[data.item] or 0) .. "/" .. data.max, XeninUI:Font(20), w / 2 + 4, h - 22, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                else
                    draw.SimpleText(string.Comma(data.price), XeninUI:Font(20), w / 2 + 4, h - 22, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end

            table.insert(cat.Items, item)
        end
    end
end

local lightBlack = Color(0, 0, 0, 100)
function PANEL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, lightBlack)
end

local noloop = false
function PANEL:PerformLayout(w, h)
    if not IsValid(self.Scroll) then return end

    if IsValid(self.Currency) then
        surface.SetFont(XeninUI:Font(48))
        local tx, _ = surface.GetTextSize(self.Currency:GetText())
        self.Currency:SetSize(tx + 72, 48)
        self.Currency:SetPos(w - self.Currency:GetWide() - 22, 8)
    end

    if noloop then return end

    noloop = true
    for per, cat in pairs(self.Categories) do
        cat:SizeToChildren(true, true)
    end
    noloop = false
end

vgui.Register("BP.Shop", PANEL, "DPanel")

if IsValid(BP_PANEL) then
    BP_PANEL:Remove()
end
