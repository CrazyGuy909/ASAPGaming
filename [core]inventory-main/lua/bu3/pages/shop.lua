local PAGE = {}
local new = surface.GetTextureID("ui/new")
--This is called when the page is called to load
function PAGE:Load(contentFrame)
    self.mirrorPanel = vgui.Create("DPanel", contentFrame)
    self.mirrorPanel:SetSize(contentFrame:GetWide(), contentFrame:GetTall())
    self.mirrorPanel.Paint = function() end --Clear background

    self.mirrorPanel.PerformLayout = function(s, w, h)
        self.tp:SetSize(w, 75)
        self.tp:SetPos(4, 4)
        self.search:SetSize(w / 3, 37)
        self.search:SetPos(w - w / 3 - 24, 24)

        if (self.init) then
            self.scroll:SetSize(w - 32, h - 96)
            self.scroll:SetPos(16, 80)
        end
    end

    local textPanel = vgui.Create("DPanel", self.mirrorPanel)

    textPanel.Paint = function(s, w, h)
        draw.SimpleText("SHOP", BU3.UI.Fonts["large_bold"], w / 2, h / 2, Color(255, 255, 255, 200), 1, 1)
		surface.SetDrawColor(255, 255, 255, 50)
		surface.DrawRect(12, h - 10, w - 32, 1)
    end

    self.tp = textPanel
    --Stores the panel
    local scrollPanel = nil

    --This function will "regenerate" the scroll panel and items in it, can also pass a filter to search
    local function DisplayStoreItems(filter)
        local skipFilter = false

        if filter == nil or string.len(filter) < 1 then
            skipFilter = true
        end

        local storeItems = BU3.Items.GetBuyableItems()
        local featuredItems = {}
        --Filter the items
        if not skipFilter then
            local filteredTable = {}

            for k, v in pairs(storeItems) do
                if string.match(string.lower(v.name), string.lower(filter), 1) then
                    table.insert(filteredTable, v)
                end
            end

            storeItems = filteredTable
        else
            for k, v in pairs(storeItems) do
                if (v.isFeatured) then
                    table.insert(featuredItems, v)
                end
            end
        end

        --Create the scroll panel for the content
        if scrollPanel ~= nil then
            scrollPanel:Remove()
            scrollPanel = nil
        end

        scrollPanel = vgui.Create("DScrollPanel", self.mirrorPanel)
        self.scroll = scrollPanel
        self.mirrorPanel:InvalidateLayout(true)
        local sbar = scrollPanel:GetVBar()

        function sbar:Paint(w, h)
            --draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
        end

        function sbar.btnUp:Paint(w, h)
            --draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 100, 0 ) )
        end

        function sbar.btnDown:Paint(w, h)
            --draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 100, 0 ) )
        end

        sbar.btnGrip:NoClipping(true)

        function sbar.btnGrip:Paint(w, h)
            draw.RoundedBox(8, 4, -10, w - 4, h + 20, Color(66, 66, 66, 255))
        end

        local numberOfItemsCreated = 0
        local money = 0

        if BU3.Config.Currency == "darkrp" then
            money = LocalPlayer():getDarkRPVar("money")
        end

        if BU3.Config.Currency == "ps1" then
            money = LocalPlayer():PS_GetPoints()
        end

        if BU3.Config.Currency == "ps2" then
            money = LocalPlayer().PS2_Wallet.points
        end

        if BU3.Config.Currency == "custom" then
            money = BU3.Config.GetAmount(ply)
        end

        --This function will create a display items using the itemData table
        local function CreateStoreItem(itemData, i, isFeatured)
            --Create the panel
            local p = vgui.Create("DPanel", scrollPanel)
            p:SetSize(self.mirrorPanel:GetWide() / 2 - 32, 80)
            p:SetPos(((i - 1) % 2) * (self.mirrorPanel:GetWide() / 2 - 20), math.ceil(i / 2) * 88 - (isFeatured and 50 or 0))
            p.quantity = 1
            local wide = p:GetWide()

            p.Think = function()
                if BU3.Config.Currency == "darkrp" then
                    money = LocalPlayer():getDarkRPVar("money")
                end

                if BU3.Config.Currency == "ps1" then
                    money = LocalPlayer():PS_GetPoints()
                end

                if BU3.Config.Currency == "ps2" then
                    money = LocalPlayer().PS2_Wallet.points
                end

                if BU3.Config.Currency == "custom" then
                    money = BU3.Config.GetAmount(ply)
                end
            end

            p.Paint = function(s, w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(36, 36, 36, 255))
                --Paint the name
                --draw.SimpleText("Name",BU3.UI.Fonts["smallest_reg"],200, 20, Color(255,255,255,25), 1, 1)
                local name = itemData.name

                if string.len(name) >= 20 then
                    name = string.sub(name, 1, 17) .. "..."
                end

                draw.SimpleText(name, "aMenu20", 85, h / 2, Color(255, 255, 255, 100), 0, 1)
                draw.SimpleText("$" .. string.Comma(itemData.price * s.quantity), "aMenu18", w - 128, h / 2, money < itemData.price * s.quantity and Color(185, 46, 46, 255) or Color(200, 255, 75, 150), 2, 1)
            end

            p.PaintOver = function(s, w, h)
                if (itemData.isNew) then
                    surface.SetTexture(new)
                    surface.SetDrawColor(color_white)
                    surface.DrawTexturedRect(56, 8, 32, 32)
                end
            end

            if itemData.type == "case" then
                --Preview Button
                --itemData
                local preview = vgui.Create("DButton", p)
                preview:SetPos(wide / 2 + 24, 40 - 20)
                preview:SetSize(40, 40)
                preview:SetText("")

                preview.Paint = function(s, w, h)
                    surface.SetMaterial(BU3.UI.Materials.iconHelp)

                    if s:IsHovered() then
                        surface.SetDrawColor(Color(255, 255, 255, 150))
                    else
                        surface.SetDrawColor(Color(255, 255, 255, 50))
                    end

                    surface.DrawTexturedRect(10, 10, w - 20, h - 20)
                end

                preview.DoClick = function(s)
                    contentFrame:LoadPage("preview", itemData.itemID)
                end
            end

            --Create the buy button
            local buy = vgui.Create("DButton", p)
            buy:Dock(RIGHT)
            buy:SetWide(96)
            buy:DockMargin(0, 20, 16, 20)
            buy:SetText("")

            buy.Paint = function(s, w, h)
                if not s:IsHovered() then
                    draw.RoundedBox(8, 0, 0, w, h, Color(56, 56, 56))
                else
                    draw.RoundedBox(8, 0, 0, w, h, Color(66 * 1.1, 66 * 1.1, 66 * 1.1))
                end

                draw.SimpleText("Buy", BU3.UI.Fonts["small_reg"], w / 2, h / 2, Color(255, 255, 255, 100), 1, 1)
            end

            buy.DoClick = function(s)
                BU3.UI.Elements.PurchasePrompt(itemData.itemID, p.quantity or 1, function()
                    net.Start("BU3:PurchaseItem")
                    net.WriteInt(itemData.itemID, 32)
                    net.WriteInt(p.quantity or 1, 32)
                    net.SendToServer()
                end, function() end)
            end

            --Create the item preview
            local iconPreview = nil

            if itemData.iconIsModel then
                iconPreview = BU3.UI.Elements.ModelView(itemData.iconID, itemData.zoom, p)
            else
                iconPreview = BU3.UI.Elements.IconView(itemData.iconID, itemData.color, p, false)
            end

            iconPreview:SetPos(2, 2)
            iconPreview:SetSize(76, 76)
            iconPreview.zoom = itemData.zoom
            --Create the quantity button
            local quantity = vgui.Create("DPanel", p)
            quantity:SetPos(wide / 2 - 30, 10)
            quantity:SetSize(60, 60)

            quantity.Paint = function(s, w, h)
                draw.SimpleText(p.quantity, "aMenuJob", w / 2, h / 2, Color(255, 255, 255, 255), 1, 1)
            end

            --Plus and minus buttons
            local minus = vgui.Create("DButton", quantity)
            minus:SetPos(0, 0)
            minus:SetSize(20, 60)
            minus:SetText("")

            minus.Paint = function(s, w, h)
                draw.SimpleText("-", "aMenuJob", w / 2, h / 2, Color(255, 100, 0, s:IsHovered() and 255 or 150), 1, 1)
            end

            minus.DoClick = function()
                if p.quantity > 1 then
                    p.quantity = p.quantity - 1
                end
            end

            local plus = vgui.Create("DButton", quantity)
            plus:SetPos(40, 0)
            plus:SetSize(20, 60)
            plus:SetText("")

            plus.Paint = function(s, w, h)
				draw.SimpleText("+", "aMenuJob", w / 2, h / 2, Color(50, 175, 255, s:IsHovered() and 255 or 150), 1, 1)
            end

            plus.DoClick = function()
                if p.quantity < 16 then
                    p.quantity = p.quantity + 1
                end
            end

            --Add to the offset
            numberOfItemsCreated = numberOfItemsCreated + 1
        end

        local lastFeatured = 0
        if table.Count(storeItems) > 0 then
            local i = -1
            local fid = #featuredItems > 0 and 1 or 1
            if (#featuredItems > 0) then
                for k, v in pairs(featuredItems) do
                    CreateStoreItem(v, fid, true)
                    fid = fid + 1
                end
                --fid = fid - 1
            end
            i = fid + ((fid + 1) % 2)
            lastFeatured = i
            -- i = -1 + fid + 1
            for k, v in pairs(storeItems) do
                 CreateStoreItem(v, i)
                 i = i + 1
             end
        else
            --No items found in filter, show no text
            local noItemsText = vgui.Create("DPanel", scrollPanel)
            noItemsText:SetSize(400, 75)
            noItemsText:SetPos(scrollPanel:GetWide() / 2 - 200, 9)

            noItemsText.Paint = function(s, w, h)
                draw.SimpleText("No items found.", BU3.UI.Fonts["large_bold"], w / 2, h / 2, Color(255, 255, 255, 20), 1, 1)
            end
        end

        scrollPanel:GetCanvas().Paint = function()
            local count = #featuredItems
            if (count > 0) then
                draw.SimpleText("Featured Items", BU3.UI.Fonts["small_bold"], 4, 0, Color(255, 200, 75))
                draw.SimpleText("Shop", BU3.UI.Fonts["small_bold"], 4, math.ceil(lastFeatured / 2) * 84 - 20, Color(175, 175, 175))
            end
        end
    end

    --Create the search box
    local searchBox = BU3.UI.Elements.CreateTextEntry("Search...", self.mirrorPanel, true, true)
    searchBox:SetPos(520, 75)
    searchBox:SetSize(280, 37)
    searchBox:SetUpdateOnType(true)

    searchBox.OnValueChange = function(s)
        DisplayStoreItems(s:GetText())
    end

    self.search = searchBox
    --Load the items
    DisplayStoreItems()
    self.init = true
end

--This is called when the page should unload
function PAGE:Unload(contentFrame, direction)
    self.mirrorPanel:Remove() --Remove all the UI we added to the content frame
end

--This can be called by anything to pass a message to the page
function PAGE:Message(message, data)
end

--Register the page
BU3.UI.RegisterPage("shop", PAGE)