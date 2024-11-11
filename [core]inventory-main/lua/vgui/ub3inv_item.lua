local function createOVerlay()
    local pnl = vgui.Create("DFrame")
    over = pnl
    pnl:SetSize(ScrW(), ScrH())
    pnl.init = SysTime()
    pnl:ShowCloseButton(false)
    pnl:SetDrawOnTop(true)
    pnl:SetTitle("")
    pnl.life = 5

    pnl.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 225)
        surface.DrawRect(0, 0, w, h)
        Derma_DrawBackgroundBlur(s, s.init)
        s.life = s.life - FrameTime()

        if s.life <= 0 then
            s:Remove()
        end

        draw.NoTexture()
        local wide = 64
        local compass = math.ceil(RealTime() % 4)
        local percent = RealTime() % 1
        local ax, ay = 0, 0

        if compass == 1 then
            ax = Lerp(percent, -wide, wide)
            ay = -wide
        elseif compass == 2 then
            ax = wide
            ay = Lerp(percent, -wide, wide)
        elseif compass == 3 then
            ax = -Lerp(percent, -wide, wide)
            ay = wide
        elseif compass == 4 then
            ax = -wide
            ay = -Lerp(percent, -wide, wide)
        end

        local rot = (percent / 4) * 360
        local w_ = 24 + math.cos(percent * math.pi * 2) * 4
        surface.SetDrawColor(255, 255, 255, 50)
        surface.DrawLine(w / 2 + ax, h / 2 - ay, w / 2 + ax, h / 2 + ay)
        surface.DrawLine(w / 2 - ax, h / 2 + ay, w / 2 - ax, h / 2 - ay)
        surface.DrawLine(w / 2 + ax, h / 2 - ay, w / 2 - ax, h / 2 - ay)
        surface.DrawLine(w / 2 - ax, h / 2 + ay, w / 2 + ax, h / 2 + ay)
        surface.DrawLine(w / 2 + ax, h / 2 + ay, w / 2 - ax, h / 2 - ay)
        surface.DrawLine(w / 2 - ax, h / 2 + ay, w / 2 + ax, h / 2 - ay)
        surface.SetDrawColor(0, 104, 125)
        surface.DrawTexturedRectRotated(w / 2 + ax, h / 2 - ay, w_, w_, rot)
        surface.DrawTexturedRectRotated(w / 2 - ax, h / 2 + ay, w_, w_, rot)
        surface.SetDrawColor(0, 204, 255)
        surface.DrawTexturedRectRotated(w / 2 + ax, h / 2 + ay, w_, w_, rot)
        surface.DrawTexturedRectRotated(w / 2 - ax, h / 2 - ay, w_, w_, rot)
        surface.DrawTexturedRectRotated(w / 2, h / 2, w_ * 2, w_ * 2, rot)
        draw.SimpleText("Opening your crates!", "XeninUI.TextEntry", w / 2, h / 2 - wide - 64, color_white, 1, 1)
    end

    pnl:MakePopup()
end

local ITEM = {}
ITEM.GrabbingRT = nil
ITEM.CreateFrame = false
ITEM.Ready = false

function ITEM:Init()
    self:SetText("")
    self:SetSize(150, 190)
end

ITEM.HoverProgress = 0

function ITEM:Paint(w, h)
    if not self.Ready then return end

    if not self.DisableEffects and not self:IsDragging() and GINV.RTChild == self and GINV.RTImage then
        RT.Pop(GINV.RTImage)
        surface.SetDrawColor(color_black)
        surface.DrawRect(0, 0, w, h)
    end

    if not self.MarkedForDeletion then
        BU3.Items.RarityToFrame[self.Border or 1](0, 0, w, h, Color(255, 255, 255, self:IsHovered() and 255 or 150))
    else
        local vibrate = math.abs(math.cos(RealTime() * 4) * 16)
        BU3.Items.RarityToFrame[4](vibrate / 2, 0, w - vibrate, h, Color(255, 0, 0, self:IsHovered() and 255 or 150))
    end

    local item = self.Item
    local name = item.name
    local tx, _ = draw.SimpleText(name, BU3.UI.Fonts["small_reg"], w / 2 + self.HoverProgress, 20, Color(200, 200, 200, 255), 1, 1)

    if not input.IsMouseDown(MOUSE_LEFT) and tx > w and self:IsHovered() then
        self.HoverProgress = math.cos(RealTime() * 2) * (tx - w + 16) / 2
    else
        self.HoverProgress = 0
    end

    if fav then
        draw.SimpleText("★", BU3.UI.Fonts["small_reg"], w - 12, 40, Color(255, 200, 75, 255), 2, 1)
    end

    if item.type ~= "blueprint" and item.perm then
        draw.SimpleText("★ PERMANENT ★", "aMenu14", w / 2, h - 20, Color(255, 200, 75, 255), 1, 1)
        draw.SimpleText((LocalPlayer()._permaWeapons and LocalPlayer()._permaWeapons[k]) and "Equipped" or "", "aMenu14", w / 2, 42, Color(150, 255, 75, 255), 1, 1)
    elseif item.type == "blueprint" then
        draw.SimpleText("★ BLUEPRINT ★", "aMenu14", w / 2, h - 20, Color(75, 255, 195), 1, 1)
    end

    if item.rankRestricted then
        draw.SimpleText("NON-TRADABLE", "aMenu14", w / 2, h - 32, Color(189, 189, 189), 1, 1)
    end

    if item.price > 0 then end --draw.SimpleText("£" .. string.Comma(item.price), BU3.UI.Fonts["small_bold"], w / 2, h - 24, Color(200, 200, 200, 255), 1, 1)

    if not self.InitPreview then
        self.InitPreview = true
        local iconPreview = nil

        if item.iconIsModel then
            iconPreview = BU3.UI.Elements.ModelView(item.iconID, item.zoom, self)
        else
            iconPreview = BU3.UI.Elements.IconView(item.iconID, item.color, self, false)
        end

        iconPreview:Dock(FILL)
        iconPreview:DockMargin(11, 32, 11, 24)
        iconPreview.zoom = item.zoom
        iconPreview:SetMouseInputEnabled(false)
        iconPreview:SetPaintedManually(true)
        self.Content = iconPreview
        self.IsModel = item.iconIsModel
    end

    if IsValid(self.Content) then
        self.Content:PaintManual()
    end

    local amount = self.ignoreAmount and 0 or BU3.Inventory.Inventory[self.ID]

    if amount and amount > 1 then
        draw.SimpleText("x" .. amount, BU3.UI.Fonts["small_bold"], w - 16, h - (item.perm and 32 or 8), color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    end

    if self.customPaint then
        self:customPaint(w, h)
    end

    if not self.DisableEffects and not self:IsDragging() and GINV.RTChild == self and GINV.RTImage then
        if IsValid(self.Content) then
            self.Content:SetMouseInputEnabled(false)
            cam.IgnoreZ(true)
            self.Content:PaintAt(11, 32)

            if amount and amount > 1 then
                draw.SimpleText("x" .. amount, BU3.UI.Fonts["small_bold"], w - 16, h - (item.perm and 32 or 8), color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
            end

            cam.IgnoreZ(false)
            self.Content:SetMouseInputEnabled(false)
        end

        RT.Push()
    end
end

ITEM.Badge = nil
ITEM.Alpha = 0

function ITEM:OnCursorEntered()
    if IsValid(GINV) then
        GINV:GenerateRT(self)
    end
end

function ITEM:SetItem(id, am)
    self.ID = id
    self.Amount = am
    self.Item = BU3.Items.Items[id]

    if not self.Item then
        self:Remove()

        return
    end

    self.Border = self.Item.itemColorCode
    self.Ready = true
    self.type = self.Item.type

    if self.type == "weapon" or self.type == "suit" or self.type == "entity" or self.type == "blueprint" then
        self:Droppable("BU3:Item", false)
    end
end

local checkingOn

function ITEM:DoClick()
    if input.IsKeyDown(KEY_LCONTROL) then
        self.MarkedForDeletion = not (self.MarkedForDeletion or false)
        hook.Run("OnAddedForDeletion", self.ID, self.MarkedForDeletion)

        return
    end

    self:DoMenu()
    checkingOn:SetMouseInputEnabled(false)
    net.Start("ASAP.CheckConnection")
    net.SendToServer()
end

net.Receive("ASAP.CheckConnection", function()
    if IsValid(checkingOn) then
        checkingOn:SetMouseInputEnabled(true)
    end

    checkingOn = nil
end)

function ITEM:DoMenu()
    if IsValid(checkingOn) then
        checkingOn:Remove()
    end

    local type = self.Item.type
    local amount = BU3.Inventory.Inventory[self.ID] or 0
    local Menu = DermaMenu()
    checkingOn = Menu
    if not self.ID then return end

    if type == "case" then
        Menu:AddOption("Open Crate", function()
            GINV.ContentFrame:LoadPage("unbox", self.ID)
        end)

        if amount > 1 and table.Count(BU3.Items.Items[self.ID].items) > 0 then
            Menu:AddOption("Open Multiple Crates", function()
                Derma_StringRequest("Bulk opening", "How many crates would do you like to open (Max " .. math.min(amount, 5) .. ")", math.min(amount, 5), function(txt)
                    local nmb = tonumber(txt)
                    if BU3.Inventory.Inventory[self.ID] < nmb then return end

                    if not nmb then
                        Derma_Message("Are you crazy? Only numbers!", "Error", "Ok")

                        return
                    end

                    if nmb > amount then
                        Derma_Message("You don't have that many crates to open", "Error", "Ok")

                        return
                    end

                    if nmb > 5 then
                        Derma_Message("You cannot unbox above 5 crates in bulk", "Error", "Ok")

                        return
                    end

                    net.Start("BU3:BulkOpening")
                    net.WriteInt(self.ID, 16)
                    net.WriteInt(nmb or 1, 16)
                    net.SendToServer()
                    BU3.Inventory.Inventory[self.ID] = BU3.Inventory.Inventory[self.ID] - nmb

                    if BU3.Inventory.Inventory[self.ID] <= 0 then
                        BU3.Inventory.Inventory[self.ID] = nil
                    end

                    if not LocalPlayer():IsDonator(4) then
                        createOVerlay()
                    end
                end, function() end)
            end)
        end
    end

    if type == "blueprint" then
        Menu:AddOption("Craft Weapon " .. (self.Item.price or 50) .. "GC", function()
            net.Start("ASAP_WEPS_SpawnWeapon")
            net.WriteString(self.Item.className)
            net.SendToServer()
        end)

        Menu:AddOption("Customize Blueprint", function()
            local gcs = aMenu.Base.Categories["Gun Customs"]
            if not IsValid(gcs) then return end
            gcs:DoClick()

            timer.Simple(.1, function()
                WEP_CUSTOM_REF:ForceSelect(self.Item.className)
            end)
        end)

        Menu:AddOption("Deconstruct +" .. (5 * (self.Item.price or 50)) .. "GC", function()
            net.Start("ASAP_WEPS_Deconstructy")
            net.WriteString(self.Item.className)
            net.SendToServer()
        end)
    end

    local isArmor = self.Item.type == "suit" or string.find(self.Item.className or "", "armor", 1, true)

    if not isArmor and type == "entity" then
        Menu:AddOption("Spawn Entity", function()
            if (BU3.Inventory.Inventory[self.ID] or 0) <= 0 then return end
            net.Start("BU3:UseItem")
            net.WriteInt(self.ID or -1, 32)
            net.SendToServer()
            BU3.Inventory.Inventory[self.ID] = BU3.Inventory.Inventory[self.ID] - 1

            if BU3.Inventory.Inventory[self.ID] <= 0 then
                BU3.Inventory.Inventory[self.ID] = nil
            end
        end)
    elseif isArmor then
        if not LocalPlayer().armorSuit then
            Menu:AddOption("Equip Armor", function()
                if (BU3.Inventory.Inventory[self.ID] or 0) <= 0 then return end
                net.Start("BU3:UseItemArmor")
                net.WriteString(self.Item.className)
                net.WriteUInt(self.ID, 16)
                net.SendToServer()
                BU3.Inventory.Inventory[self.ID] = BU3.Inventory.Inventory[self.ID] - 1

                if BU3.Inventory.Inventory[self.ID] <= 0 then
                    BU3.Inventory.Inventory[self.ID] = nil
                end
            end)
        end

        Menu:AddOption("Drop a Suit", function()
            if (BU3.Inventory.Inventory[self.ID] or 0) <= 0 then return end
            net.Start("BU3:DropItem")
            net.WriteString(self.Item.className)
            net.WriteInt(self.ID, 32)
            net.SendToServer()
            BU3.Inventory.Inventory[self.ID] = BU3.Inventory.Inventory[self.ID] - 1

            if BU3.Inventory.Inventory[self.ID] <= 0 then
                BU3.Inventory.Inventory[self.ID] = nil
            end
        end)
    end

    if type == "money" then
        Menu:AddOption("Add Money", function()
            if (BU3.Inventory.Inventory[self.ID] or 0) <= 0 then return end
            net.Start("BU3:UseItem")
            net.WriteInt(self.ID, 32)
            net.SendToServer()
            BU3.Inventory.Inventory[self.ID] = BU3.Inventory.Inventory[self.ID] - 1

            if BU3.Inventory.Inventory[self.ID] <= 0 then
                BU3.Inventory.Inventory[self.ID] = nil
            end
        end)
    end

    if type == "credits" then
        Menu:AddOption("Add Credits", function()
            if (BU3.Inventory.Inventory[self.ID] or 0) <= 0 then return end
            net.Start("BU3:UseItem")
            net.WriteUInt(self.ID, 32)
            net.SendToServer()
            BU3.Inventory.Inventory[self.ID] = BU3.Inventory.Inventory[self.ID] - 1

            if BU3.Inventory.Inventory[self.ID] <= 0 then
                BU3.Inventory.Inventory[self.ID] = nil
            end
        end)
    end

    if type == "weapon" then
        local isProhibited = asapArena.BlacklistWeapons[self.Item.className]

        Menu:AddOption("Equip Weapon", function()
            if (BU3.Inventory.Inventory[self.ID] or 0) <= 0 then return end
            net.Start("BU3:UseItemWeapon")
            net.WriteInt(self.ID, 32)
            net.SendToServer()

            if not self.Item.perm and not GetGlobalBool("Purge.Active", false) then
                BU3.Inventory.Inventory[self.ID] = BU3.Inventory.Inventory[self.ID] - 1
            end

            if BU3.Inventory.Inventory[self.ID] <= 0 then
                BU3.Inventory.Inventory[self.ID] = nil
            end
        end)

        if self.Item.perm then
            if not LocalPlayer()._permaWeapons then
                LocalPlayer()._permaWeapons = {}
            end

            Menu:AddOption(LocalPlayer()._permaWeapons[self.ID] and "Unequip Perma" or "Equip Permanently", function()
                if LocalPlayer()._permaWeapons[self.ID] then
                    LocalPlayer()._permaWeapons[self.ID] = nil
                else
                    LocalPlayer()._permaWeapons[self.ID] = true
                end

                net.Start("BU3:EquipPerma")
                net.WriteInt(self.ID, 32)
                net.SendToServer()
            end)
        end
    end

    if type == "lua" then
        Menu:AddOption("Use Item", function()
            net.Start("BU3:UseItem")
            net.WriteInt(self.ID, 32)
            net.SendToServer()
        end)
    end

    if type == "accesory" then
        Menu:AddOption("Use it", function()
            Derma_Message("To equip this item, go to 'Accessories' tab", "New item", "Ok")
            net.Start("BU3:UseItem")
            net.WriteInt(self.ID, 32)
            net.SendToServer()
        end)
    end

    Menu:AddSpacer()

    if not self.Item.rankRestricted then
        if type == "weapon" and asapArena.BlacklistWeapons[self.Item.className] then return end

        local sub = Menu:AddOption("Gift To Player" .. (amount > 1 and " x1" or "..."), function()
            local pSel = PlayerSelector()
            pSel:Open()

            pSel.OnSelect = function(s, v)
                Derma_Query("Are you sure do you wanna gift '" .. self.Item.name .. "' item to " .. v:Nick() .. "?", "Gifting", "Yes", function()
                    net.Start("BU3:GiftItem")
                    net.WriteInt(self.ID, 32)
                    net.WriteEntity(v)
                    net.WriteInt(1, 8)
                    net.SendToServer()
                end, "No")
            end
        end)

        if amount > 1 then
            local sub = Menu:AddOption("Gift Custom Amount", function()
                local pSel = PlayerSelector()
                pSel:Open()

                pSel.OnSelect = function(s, v)
                    Derma_StringRequest("Gift", "How many items do you want to gift", 1, function(txt)
                        local num = tonumber(txt)

                        if not num then
                            Derma_Message("That's not a number!", "Error", "Ok")

                            return
                        end

                        if num < 1 then
                            Derma_Message("That's the best you got?", "Error", "Ok")

                            return
                        end

                        if num > amount then
                            Derma_Message("You don't have that many items", "Error", "Ok")

                            return
                        end

                        net.Start("BU3:GiftItem")
                        net.WriteInt(self.ID, 32)
                        net.WriteEntity(v)
                        net.WriteInt(num, 8)
                        net.SendToServer()
                    end, "Cancel")
                end
            end)
        end
    end

    Menu:AddSpacer()

    Menu:AddOption("Scrap Item", function()
        Derma_Query("Are you sure do you wanna scrap this item?\nEvery 35 items you get an Scrap Crate", "Scrapping", "Yes", function()
            net.Start("BU3:DeleteItem")
            net.WriteInt(self.ID, 32)
            net.SendToServer()
        end, "No")
    end)

    if amount > 1 then
        Menu:AddOption("Scrap in Bulk", function()
            Derma_StringRequest("Bulk Delete", "How many items would do you like to Scrap (Max " .. amount .. ")", amount, function(txt)
                local nmb = tonumber(txt)

                if not nmb or nmb < 1 then
                    Derma_Message("Are you crazy? Only numbers!", "Error", "Ok")

                    return
                end

                if nmb > amount then
                    Derma_Message("You don't have that many to delete", "Error", "Ok")

                    return
                end

                net.Start("BU3:BulkDelete")
                net.WriteInt(self.ID, 16)
                net.WriteInt(nmb, 16)
                net.SendToServer()

                if nmb == amount then
                    self:Remove()
                end
            end, function() end)
        end)
    end

    Menu:AddOption("Cancel")

    Menu:Open()
end

vgui.Register("gInventory.Item", ITEM, "DButton")
local ITEM2 = {}

function ITEM2:Init()
    self:SetText("")
end

function ITEM2:DoClick()
end

function ITEM2:SetItem(id, am)
    self.ID = id
    self.Amount = am
    self.Item = BU3.Items.Items[id]
    if not self.Item then return end
    self.Border = self.Item.itemColorCode
    self.Ready = true
    self:SetTooltip(self.Item.name)
    self.type = self.Item.type
end

function ITEM2:Paint(w, h)
    self.HoverProgress = 0
    local item = self.Item
    draw.RoundedBox(4, 0, 0, w, h, not item and Color(66, 66, 66) or BU3.Items.RarityToColor[item.itemColorCode or 1])
    draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(16, 16, 16))
    if not self.Ready then return end
    local name = item.name

    if item.perm then
        draw.SimpleText("★", "aMenu14", w / 2, h - 20, Color(255, 200, 75, 255), 1, 1)
    end

    if not self.InitPreview then
        self.InitPreview = true
        local iconPreview = nil

        if item.iconIsModel then
            iconPreview = BU3.UI.Elements.ModelView(item.iconID, item.zoom, self)
        else
            iconPreview = BU3.UI.Elements.IconView(item.iconID, item.color, self, false)
        end

        iconPreview:Dock(FILL)
        iconPreview:DockMargin(2, 2, 2, 2)
        iconPreview.zoom = item.zoom
        iconPreview:SetMouseInputEnabled(false)
        iconPreview:SetPaintedManually(true)
        self.Content = iconPreview
        self.IsModel = item.iconIsModel
    end

    self.Content:PaintManual()
    local amount = self.Amount or 1

    if amount and amount > 1 then
        draw.SimpleText("x" .. amount, BU3.UI.Fonts["small_bold"], w - 16, h - ((item.perm or item.price > 0) and 32 or 8), color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    end
end

vgui.Register("gInventory.ItemIcon", ITEM2, "DButton")