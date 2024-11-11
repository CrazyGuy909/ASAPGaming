local PANEL = {}

local filterModes = {
    [1] = {["Everything"] = function() return true end},
    [2] = {["Crates"] = function(item) return item.type == "case" end},
    [3] = {["Suits"] = function(item) return item.type and item.type == "suit" or (item.className and string.StartWith(item.className, "armor")) end},
    [4] = {["Weapons"] = function(item) return item.type == "weapon" end},
    [5] = {["Glitched"] = function(item) return item.itemColorCode == 10 end},
    [6] = {["Rainbow"] = function(item) return item.itemColorCode == 9 end},
    [7] = {["Fire"] = function(item) return item.itemColorCode == 8 end},
    [8] = {["Diamond"] = function(item) return item.itemColorCode == 7 end},
    [9] = {["Gold"] = function(item) return item.itemColorCode == 6 end},
    [10] = {["Red"] = function(item) return item.itemColorCode == 5 end},
    [11] = {["Pink"] = function(item) return item.itemColorCode == 4 end},
    [12] = {["Purple"] = function(item) return item.itemColorCode == 3 end},
    [13] = {["Blue"] = function(item) return item.itemColorCode == 2 end},
    [14] = {["White"] = function(item) return item.itemColorCode == 1 end},
    [15] = {["Blueprints"] = function(item) return item.itemColorCode == 11 end},
}

function PANEL:Init()
    GINV = self

    BU3_Categories = util.JSONToTable(cookie.GetString("inventory_categories", "{}"))
    BU3_DisplayWarning = cookie.GetNumber("save_prompt", 0) < 2
    self.InstalledItems = {}
    self.Categories = {}
    self._filter = function() return true end
    self.Header = vgui.Create("Panel", self)
    self.Header:Dock(TOP)
    self.Header:SetTall(32)
    self.Header:DockMargin(8, 8, 8, 8)

    self.Header.Paint = function(s, w, h)
        draw.SimpleText("Show:", "XeninUI.TextEntry", 4, h / 2, color_white, 0, 1)
    end

    self.Options = vgui.Create("XeninUI.Button", self.Header)
    self.Options:Dock(LEFT)
    self.Options:SetWide(142)
    self.Options:DockMargin(58, 0, 8, 0)
    self.Options:SetText("Everything")

    self.Options.DoClick = function(s)
        local x, y = s:LocalToScreen(0, s:GetTall())
        local menu = XeninUI:DropdownPopup(x, y)

        for k, v in SortedPairs(filterModes) do
            local txt = table.GetFirstKey(v)
            local func = table.GetFirstValue(v)
            menu:AddChoice(txt, function()
                self._filter = func
                s:SetText(txt)
                self:PopulateItems()
            end)
        end

    end

    self.Trade = vgui.Create("XeninUI.Button", self.Header)
    self.Trade:SetText("Trade")
    self.Trade:Dock(LEFT)
    self.Trade:SetWide(172)
    self.Trade:DockMargin(0, 0, 0, 0)
    self.Trade.DoClick = function()
        local sel = PlayerSelector()
        sel:Open()
        sel.OnSelect = function(s, ply)
            Derma_Query("Do you want to trade with " .. ply:Nick() .. "?", "Confirm human", "Yes", function()
                net.Start("BU3.Trade:SendInvitation")
                net.WriteEntity(ply)
                net.SendToServer()
            end, "No")
        end
    end

    self.History = vgui.Create("XeninUI.Button", self.Header)
    self.History:SetText("History")
    self.History:Dock(LEFT)
    self.History:SetWide(172)
    self.History:DockMargin(8, 0, 0, 0)
    self.History.DoClick = function()
        if IsValid(THISTORY) then
            THISTORY:Remove()
        end
        THISTORY = vgui.Create("Trade.History")
    end

    self.Delete = vgui.Create("XeninUI.Button", self.Header)
    self.Delete:SetText("Delete")
    self.Delete:Dock(LEFT)
    self.Delete:SetWide(172)
    self.Delete:DockMargin(8, 0, 0, 0)
    self.Delete.Items = {}
    self.Delete.DoClick = function(s)
        local count = table.Count(self.Delete.Items)
        Derma_Query("Are you sure do you want to delete " .. count .. " item(s) the selected items?\nEven stacked items will delete completely", "Confirm", "Yes", function()
            net.Start("BU3.Trade:DeleteBulk")
            net.WriteUInt(table.Count(self.Delete.Items), 8)
            for k, v in pairs(self.Delete.Items) do
                net.WriteUInt(k, 16)
            end
            net.SendToServer()
            self.Delete.Items = {}
            s:SetVisible(false)
        end, "No")
    end

    hook.Add("OnAddedForDeletion", self.Delete, function(s, id, b)
        s.Items[id] = b == true and b or nil
        s:SetVisible(not table.IsEmpty(s.Items))
    end)

    self.Search = vgui.Create("XeninUI.TextEntry", self.Header)
    self.Search:Dock(RIGHT)
    self.Search:SetWide(196)
    self.Search:SetPlaceholder("Search...")
    self.Search:SetUpdateOnType(true)
    self.Search:SetText(cookie.GetString("unbox_filter", ""))

    self.Search.OnValueChange = function(s)
        cookie.Set("unbox_filter", s:GetText())
        self:PopulateItems()
    end

    self:GenerateFooter()
    self:GenerateBody()
end

function PANEL:UpdateInventory()
    for k, v in pairs(self.InstalledItems) do
        if not IsValid(v) then continue end
        v.Amount = BU3.Inventory.Inventory[v.ID] or 0
        if (v.Amount <= 0) then
            v:Remove()
        end
    end
end

function PANEL:GenerateFooter()
    self.Footer = vgui.Create("Panel", self)
    self.Footer:Dock(BOTTOM)
    self.Footer:SetTall(64)
    self.Footer:DockMargin(8, 0, 8, 8)
    self.HotbarData = util.JSONToTable(cookie.GetString("Inventory:Hotbar", "[]"))
    self.HotbarSlots = {}
    self.QuickInv = vgui.Create("DIconLayout", self.Footer)
    self.QuickInv:Dock(LEFT)
    self.QuickInv:SetWide(68 * 12)
    self.QuickInv:SetSpaceX(8)
    self.QuickInv:DockMargin(0, 4, 0, 0)
    self.QuickInv:SetSpaceY(8)

    for k = 1, 24 do
        local btn = vgui.Create("DButton", self.Footer)
        btn:SetSize(58, 58)
        self.QuickInv:Add(btn)
        btn:SetText("")
        btn.Slot = k

        btn.Paint = function(s, w, h)
            if IsValid(s.Content) then
                s.Color = s.Color or Color(0 , 0 , 0)
                draw.RoundedBox(8, 0, 0, w, h, s.Color)
            end

            draw.RoundedBox(8, 0, 0, w, h, Color(255, 255, 255, 100))
            draw.RoundedBox(8, 1, 1, w - 2, h - 2, Color(16, 16, 16))

            if (not IsValid(self.Content)) then
                draw.SimpleText(k, "XeninUI.TextEntry", w - 8, h - 4, Color(255, 255, 255, 15), 2, TEXT_ALIGN_BOTTOM)
            end
        end

        btn:Receiver("BU3:Item", function(pnl, tbl, dropped)
            if (dropped) then
                local id = tbl[1].ID
                local collection = {}

                for i, v in pairs(self.HotbarSlots) do
                    if (IsValid(v) and v.ID == id) then
                        v:Set(nil)
                    end

                    collection[k] = v.ID
                end

                pnl:Set(id, tbl[1].Item)
            end
        end)

        btn.Set = function(s, id, item, ignore)
            if not item then return end
            if (IsValid(s.Content)) then
                s.Content:Remove()
            end

            s.ID = id
            s:SetTooltip(nil)

            if not item then
                s.ID = nil
            end

            if (id) then
                local iconPreview = nil

                if item.iconIsModel then
                    iconPreview = BU3.UI.Elements.ModelView(item.iconID, item.zoom, s)
                else
                    iconPreview = BU3.UI.Elements.IconView(item.iconID, item.color, s, false)
                end

                iconPreview:Dock(FILL)
                iconPreview:DockMargin(2, 6, 2, 4)
                iconPreview.zoom = item.zoom
                iconPreview:SetMouseInputEnabled(false)
                s.Content = iconPreview
                s.Color = BU3.Items.RarityToColor[item.itemColorCode]
                s:SetTooltip(item.name)
            end

            if (ignore) then return end
            self.HotbarData[s.Slot] = id
            cookie.Set("Inventory:Hotbar", util.TableToJSON(self.HotbarData))
        end

        btn.DoClick = function(s)
            local menu = DermaMenu()

            menu:AddOption("Remove item from favorites", function()
                self.HotbarData[s.Slot] = nil
                s:Set(nil)
            end)

            menu:AddOption("Cancel")
            menu:Open()
        end

        self.HotbarSlots[k] = btn

        if (self.HotbarData[k]) then
            if not BU3.Items.Items[self.HotbarData[k]] then
                return
            end
            btn:Set(self.HotbarData[k], BU3.Items.Items[self.HotbarData[k]], true)
        end
    end

    self.ShowMore = vgui.Create("XeninUI.Button", self.Footer)
    self.ShowMore:SetText("Show More")
    self.ShowMore:Dock(LEFT)
    self.ShowMore:SetWide(148)
    self.ShowMore:DockMargin(0, 12, 8, 8)
    self.ShowingMore = false

    self.ShowMore.DoClick = function(s)
        self.ShowingMore = not self.ShowingMore
        s:SetText(self.ShowingMore and "Show Less" or "Show More")
        self.Footer:SetTall(self.ShowingMore and 128 or 64)
    end
    
    self.Remaining = vgui.Create("DPanel", self.Footer)
    self.Remaining:Dock(FILL)
    self.Remaining:DockMargin(0, 0, 8, 0)
    self.Remaining:SetTooltip("Scrap 35 items to receive the Scrap Crate!")
    local a, b, c = Color(255, 255, 255), Color(35, 35, 35), Color(235, 129, 16)
    self.Remaining.Paint = function(s, w, h)
        draw.SimpleText("Scrap'O Meter " .. (BU3.ScrapLeft or 0) .. "/" .. 35, XeninUI:Font(24), w / 2, 16, color_white, 1, 1)
        draw.RoundedBox(8, 0, 32, w, 24, a)
        draw.RoundedBox(8, 1, 33, w - 2, 22, b)
        draw.RoundedBox(8, 2, 34, (w - 4) * ((BU3.ScrapLeft or 0) / 35), 20, c)
    end
end

function PANEL:GenerateRT(child)
    child.Alpha = 0
    self.RTChild = child
    self.RTImage = RT.Create("INV_RT_DSlot_" .. os.time(), child:GetWide(), child:GetTall())

    hook.Add("DrawOverlay", self, function()
        if not RT.Material(self.RTImage) then return end
        if not IsValid(self.RTChild) then return end
        local w, h = self.RTChild:GetSize()
        local x, y = self.RTChild:LocalToScreen(0, 0)
        surface.SetMaterial(RT.Material(self.RTImage))
        surface.SetDrawColor(color_white)

        if IsValid(self.RTChild) then
            local hovered = (self.RTChild:IsHovered() or self.RTChild:IsChildHovered())
            self.RTChild.Alpha = Lerp(FrameTime() * 5, self.RTChild.Alpha or 0, hovered and 255 or 0)
            if (not hovered and self.RTChild.Alpha <= 5) then
                self:ClearRT()
                return
            end
            surface.DrawTexturedRectRotated(x + w / 2, y + h / 2, w + 32 * self.RTChild.Alpha / 255, h + 32 * self.RTChild.Alpha / 255, 0)
        else
            self:ClearRT()
        end
    end)

end

function PANEL:ClearRT()
    self.RTChild = nil
    self.RTImage = nil

    hook.Remove("DrawOverlay", self)
end


function PANEL:GenerateBody()
    self.Body = vgui.Create("XeninUI.ScrollPanel", self)
    self.Body:Dock(FILL)

    self.Body.Paint = function(s, w, h)
        surface.SetDrawColor(6, 6, 6)
        surface.DrawRect(0, 0, w, h)
    end

    self:InvalidateLayout(true)
    self.Container = vgui.Create("DIconLayout", self.Body)
    self.Container:DockMargin(8, 8, 8, 8)
    self.Container:Dock(FILL)
    self.Container:DockPadding(0, 0, 0, 8)
    self:PopulateItems()
end

PANEL.IsSized = false

function PANEL:PerformLayout(w, h)
    if (w ~= 64 and not self.IsSized) then
        self.IsSized = true
        local columns = math.floor(w / 150) - 1
        local extra = w % (columns * 150) / columns
        self.Container:SetSpaceX(extra - 2)
        self.Container:SetSpaceY(extra - 2)
    end
end

PANEL.InstalledItems = {}

local cog, circle, delete = Material("bu3/gear-b.png"), Material("ui/asap/logo_circle"), Material("ui/bpicons/arena")


function PANEL:SortFunction(items)
    table.sort(items, function(a, b)
        local itemA, itemB = BU3.Items.Items[a[1]], BU3.Items.Items[b[1]]
        local ccA, ccB = itemA.itemColorCode or 0, itemB.itemColorCode or 0

        if (ccA == ccB) then

            return itemA.name < itemB.name
        else
            if (ccA == 11 and ccB != 11) then return false end
            if (ccA != 11 and ccB == 11) then return true end
            return ccA > ccB
        end
    end)
end

function PANEL:PopulateItems()
    local items = table.Copy(BU3.Inventory.Inventory)
    local filter = self.Search:GetText()

    for id, am in pairs(items or {}) do
        local item = table.Copy(BU3.Items.Items[id])
        if (not item) then continue end
        if (item.className and not BU3.Dictionary[item.className]) then
            BU3.Dictionary[item.className] = id
        end
        if (filter ~= "" and not string.find(string.lower(item.name), string.lower(filter), 1, true)) then
            items[id] = nil
            continue
        end

        local res = self._filter(item)

        if (not res) then
            items[id] = nil
        end
    end

    for id, pnl in pairs(self.InstalledItems) do
        if (items and not items[id]) then
            pnl:Remove()
            self.InstalledItems[id] = nil
        end
    end

    local presort = {}
    for k, v in pairs(items or {}) do
        table.insert(presort, {k, v})
    end

    self:SortFunction(presort)

    local savedItems = {}
    for name, data in pairs(BU3_Categories) do
        if (table.IsEmpty(data.Items)) then
            continue
        end

        for id, _ in pairs(data.Items) do
            savedItems[id] = name
        end

        if not self.Categories[name] then
            self.Categories[name] = self:CreateCategory(name, data.Color)
            MsgN("Created category here")
        end
    end

    for _, v in pairs(presort) do
        local id, am = v[1], v[2]
        if IsValid(self.InstalledItems[id]) then continue end
        local item = vgui.Create("gInventory.Item")
        item:SetItem(id, am)
        item.Papa = self
        item:Droppable("BU3.Sorting")
        item:Receiver("BU3.Sorting", function(pnl, list, dropped, index, x, y)
            if not dropped then return end
            local newItem = list[1]

            if (pnl.isInCategory) then
                BU3_Categories[pnl.isInCategory].Items[newItem.ID] = true
                self.Categories[pnl.isInCategory]:Insert(newItem)
                cookie.Set("inventory_categories", util.TableToJSON(BU3_Categories))
                self:PopulateItems()
                return
            end
        end)
        if (savedItems[id]) then
            self.Categories[savedItems[id]]:Insert(item)
        else
            self.Container:Add(item)
        end
        self.InstalledItems[id] = item
    end
end

vgui.Register("gInventory", PANEL, "Panel")
if IsValid(GINV) then end --GINV:Remove()
--GINV = vgui.Create("gInventory")
