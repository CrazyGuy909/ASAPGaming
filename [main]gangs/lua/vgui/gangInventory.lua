local PANEL = {}
PANEL.Items = {}
PANEL.ItemsGang = {}

local loading = surface.GetTextureID("sprites/cartfrag_exp")
function PANEL:Init()
    GangINV = self
    self.Items = {}
    self.ItemsGang = {}
    --self:Dock(FILL)
    --self:SetSize(ScrW() * .8, ScrH() * .8)
    --self:Center()
    --self:MakePopup()
    self:InvalidateParent(true)
    self:InvalidateLayout(true)
    self.Left = vgui.Create("Panel", self)
    self.Left:Dock(LEFT)
    self.Left:SetWide(108 * 4)
    self.Left:DockMargin(32, 16, 32, 32)
    self.History = vgui.Create("XeninUI.ScrollPanel", self.Left)
    self.History:SetTall(142)
    self.History:Dock(BOTTOM)

    self.History.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(36, 36, 36))
    end

    local lbl = Label("History:", self.Left)
    lbl:Dock(BOTTOM)
    lbl:SetFont("XeninUI.TextEntry")
    lbl:DockMargin(0, 8, 0, 4)
    local header = vgui.Create("Panel", self.Left)
    header:Dock(TOP)
    header:SetTall(32)
    header:DockMargin(0, 0, 0, 8)
    local lbl = Label("Your inventory:", header)
    lbl:Dock(LEFT)
    lbl:SetWide(148)
    lbl:SetFont("XeninUI.TextEntry")
    self.SearchOwn = vgui.Create("XeninUI.TextEntry", header)
    self.SearchOwn:Dock(RIGHT)
    self.SearchOwn:SetWide(256)
    self.SearchOwn:SetPlaceholder("Search...")
    self.SearchOwn:SetUpdateOnType(true)

    self.SearchOwn.OnValueChange = function(s)
        self:PopulateInventory()
    end

    self.Inventory = vgui.Create("XeninUI.ScrollPanel", self.Left)
    self.Inventory:Dock(FILL)

    self.Inventory.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(36, 36, 36))
    end

    header = vgui.Create("Panel", self)
    header:Dock(TOP)
    header:SetTall(32)
    header:DockMargin(0, 16, 32, 4)
    local lbl = Label("Gang's Inventory:", header)
    lbl:Dock(LEFT)
    lbl:SetWide(172)
    lbl:SetFont("XeninUI.TextEntry")
    lbl:DockMargin(0, 0, 0, 4)
    self.SearchGang = vgui.Create("XeninUI.TextEntry", header)
    self.SearchGang:Dock(RIGHT)
    self.SearchGang:SetWide(256)
    self.SearchGang:SetPlaceholder("Search...")
    self.SearchGang:SetUpdateOnType(true)

    self.SearchGang.OnValueChange = function(s)
        self:PopulateGang()
    end

    self.Right = vgui.Create("XeninUI.ScrollPanel", self)
    self.Right:Dock(FILL)
    self.Right:DockMargin(0, 4, 32, 32)

    self.Right.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(36, 36, 36))
        if not IsValid(self.GangLayout) then
            surface.SetTexture(loading)
            surface.SetDrawColor(color_white)
            surface.DrawTexturedRectRotated(w / 2, h / 2, 128, 128, math.cos(RealTime() * 4) * 15)
            draw.SimpleText("Loading...", "XeninUI.TextEntry", w / 2, h / 2 + 64, color_white, 1, 1)
        end
    end

    self:PopulateInventory()
    net.Start("Gangs.RequestInvHeader")
    net.SendToServer()
    self:InvalidateLayout(true)
end

function PANEL:PopulateInventory()
    if IsValid(self.ItemsLayout) then
        self.ItemsLayout:Remove()
    end

    self.ItemsLayout = vgui.Create("DIconLayout", self.Inventory)
    self.ItemsLayout:SetSpaceX(8)
    self.ItemsLayout:DockMargin(8, 8, 2, 0)
    self.ItemsLayout:DockPadding(4, 4, 0, 8)
    self.ItemsLayout:SetSpaceY(8)
    self.ItemsLayout:Dock(FILL)
    local filter = string.lower(self.SearchOwn:GetText() or "")
    local itemTable = BU3.Inventory.Inventory

    for id, lam in pairs(itemTable) do
        local item = BU3.Items.Items[id]
        if not item then
            continue
        end
        if (item.type ~= "weapon" and item.type ~= "suit" and item.type ~= "entity") then continue end
        if (item.perm) then continue end
        if (item.itemColorCode > 6) then continue end

        if (string.find(string.lower(item.name), filter, 1, true)) then
            local itemUI = self:CreateItemSlot(id, lam, self.ItemsLayout, totalWide)
            self.Items[id] = itemUI
        end
    end
end

function PANEL:PopulateGang()
    if not self.Ready then return end

    if IsValid(self.GangLayout) then
        self.GangLayout:Remove()
    end

    self.GangLayout = vgui.Create("DIconLayout", self.Right)
    self.GangLayout:SetSpaceX(8)
    self.GangLayout:DockMargin(8, 8, 2, 0)
    self.GangLayout:DockPadding(4, 4, 0, 8)
    self.GangLayout:SetSpaceY(8)
    self.GangLayout:Dock(FILL)
    local filter = string.lower(self.SearchGang:GetText() or "")

    for id, lam in pairs(GangInventory or {}) do
        local item = BU3.Items.Items[id]

        if (string.find(string.lower(item.name), filter, 1, true)) then
            local itemUI = self:CreateItemSlot(id, lam, self.GangLayout)
            itemUI.IsGang = true
            self.ItemsGang[id] = itemUI
        end
    end
end

function PANEL:Update(id, am, owner)
    self.Left:InvalidateLayout(true)
    self.Inventory:InvalidateLayout(true)

    if (owner) then
        if IsValid(self.Items[id]) then
            self.Items[id].Amount = am
        else
            local itemUI = self:CreateItemSlot(id, am, self.ItemsLayout)
            self.Items[id] = itemUI
        end

        return
    end

    if (IsValid(self.ItemsGang[id])) then
        self.ItemsGang[id].Amount = am
    else
        local totalWide = (self.Right:GetWide() - 8) / 6 - 8
        local itemUI = self:CreateItemSlot(id, am, self.GangLayout)
        itemUI.IsGang = true
        self.ItemsGang[id] = itemUI
    end
end

function PANEL:CreateItemSlot(id, lam, parent)
    local item = BU3.Items.Items[id]
    local it = vgui.Create("DButton", parent)
    it:SetSize(96, 96)
    it:SetText("")
    it.Item = item
    it.ID = id
    it.Amount = lam
    it.Color = BU3.Items.RarityToColor[item.itemColorCode]
    it:SetTooltip(item.name)

    it.DoClick = function(s)
        local menu = DermaMenu()

        if (s.IsGang) then
            if (s.Item.perm) then
                menu:AddOption("Equip Weapon", function()
                    net.Start("Gangs.UsePerma")
                    net.WriteInt(s.ID, 16)
                    net.SendToServer()
                end)
            end
            menu:AddOption("Take", function()
                if (s.Item.perm and LocalPlayer():GetNWString("Gang.Rank", "User") == "User") then
                    Derma_Message("You don't have permission to take this item", "Error", "Ok")

                    return
                end
                if (s.Amount > 1) then
                    Derma_StringRequest("How many do you want to take", "Take", "1", function(text)
                        local num = math.Round(tonumber(text) or 0)

                        if (num < 1) then
                            Derma_Message("That's not a valid value...", "Error", "Ok")

                            return
                        elseif (num > s.Amount) then
                            Derma_Message("You wish having that amount of items", "Error", "Ok")

                            return
                        end

                        net.Start("Gangs.TakeItem")
                        net.WriteInt(s.ID, 16)
                        net.WriteInt(num, 16)
                        net.SendToServer()

                        if (num >= s.Amount) then
                            s:Remove()
                        else
                            s.Amount = s.Amount - num
                        end
                    end)
                else
                    Derma_Query("Are you sure do you want to take " .. item.name .. "?", "Deposit", "Yes", function()
                        net.Start("Gangs.TakeItem")
                        net.WriteInt(s.ID, 16)
                        net.WriteInt(1, 16)
                        net.SendToServer()
                        s:Remove()
                    end, "No")
                end
            end)
        else
            menu:AddOption("Deposit", function()
                if (s.Amount > 1) then
                    Derma_StringRequest("How many do you want to deposit", "Deposit", "1", function(text)
                        local num = math.Round(tonumber(text) or 0)

                        if (num < 1) then
                            Derma_Message("That's not a valid value...", "Error", "Ok")

                            return
                        elseif (num > s.Amount) then
                            Derma_Message("You wish having that amount of items", "Error", "Ok")

                            return
                        end

                        net.Start("Gangs.PutItem")
                        net.WriteInt(s.ID, 16)
                        net.WriteInt(num, 16)
                        net.SendToServer()

                        if (num >= s.Amount) then
                            s:Remove()
                        else
                            s.Amount = s.Amount - num
                        end
                    end)
                else
                    Derma_Query("Are you sure do you want to deposit " .. item.name .. "?", "Deposit", "Yes", function()
                        net.Start("Gangs.PutItem")
                        net.WriteInt(s.ID, 16)
                        net.WriteInt(1, 16)
                        net.SendToServer()
                        s:Remove()
                    end, "No")
                end
            end)
        end

        menu:AddOption("Cancel")
        menu:Open()
    end

    it.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, ColorAlpha(s.Color or color_white, s:IsHovered() and 200 or 50))
        draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(26, 26, 26))

        if (not s.InitPreview) then
            s.InitPreview = true
            local iconPreview = nil

            if item.iconIsModel then
                iconPreview = BU3.UI.Elements.ModelView(item.iconID, item.zoom, s)
            else
                iconPreview = BU3.UI.Elements.IconView(item.iconID, item.color, s, false)
            end

            iconPreview:Dock(FILL)
            iconPreview:DockMargin(2, 2, 2, 2)
            iconPreview.zoom = item.zoom
            iconPreview:SetMouseInputEnabled(false)
            s.Content = iconPreview
            s.IsModel = item.iconIsModel
        end
    end

    it.PaintOver = function(s, w, h)
        if (s.Amount > 1) then
            draw.SimpleText("x" .. s.Amount, "XeninUI.TextEntry", w - 6, h - 4, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        end
    end

    parent:Add(it)

    return it
end

vgui.Register("gangInventory", PANEL, "Panel")

net.Receive("Gangs.SyncChange", function(l)
    local id = net.ReadInt(16)
    local val = net.ReadInt(16)
    local islocal = net.ReadBool()

    if not islocal then
        if not GangInventory then
            GangInventory = {}
        end

        if (val == 0) then
            GangInventory[id] = nil
        else
            GangInventory[id] = val
        end
    end

    if IsValid(GangINV) then
        GangINV:Update(id, val, islocal)
    end
end)

net.Receive("Gangs.RequestInvHeader", function()
    local result = net.ReadBool()

    if not result then
        if IsValid(GangINV) then
            GangINV.Ready = true
            GangINV:PopulateGang()
        end

        return
    end

    GangVersion = net.ReadInt(16)
    GangInventory = {}

    for k = 1, net.ReadInt(16) do
        GangInventory[net.ReadInt(16)] = net.ReadInt(16)
    end

    if IsValid(GangINV) then
        GangINV.Ready = true
        GangINV:PopulateGang()
    end
end)


if IsValid(GANGS) then
    GANGS:Remove()
end
