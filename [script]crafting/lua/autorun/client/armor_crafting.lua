local PANEL = {}
PANEL.Title = ""
PANEL.Color = color_white
local deg = surface.GetTextureID("vgui/gradient-d")

function PANEL:Init()
    if IsValid(CRAFTER) then
        CRAFTER:Remove()
    end

    CRAFTER = self
    self.Title = ""
    self.Color = color_white
    self.List = vgui.Create("DPanel", self)
    self.List:Dock(LEFT)
    self.List:SetWide(94 * 3 + 8)
    self.List:DockMargin(16, 16, 16, 16)

    self.List.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(16, 16, 16))
    end

    local lbl = Label("Upgrade Recipes:", self.List)
    lbl:Dock(TOP)
    lbl:SetFont("XeninUI.TextEntry")
    lbl:DockMargin(8, 8, 0, 0)
    self.Search = vgui.Create("XeninUI.TextEntry", self.List)
    self.Search:Dock(TOP)
    self.Search:DockMargin(8, 8, 8, 8)
    self.Search:SetUpdateOnType(true)

    self.Search.OnValueChange = function()
        self:PopulateRecipes()
    end

    self.Recipes = vgui.Create("XeninUI.ScrollPanel", self.List)
    self.Recipes:Dock(FILL)
    self.Recipes:DockMargin(8, 0, 8, 8)
    self.Right = vgui.Create("Panel", self)
    self.Right:Dock(RIGHT)
    self.Right:DockMargin(16, 16, 16, 16)
    self.Craft = vgui.Create("XeninUI.Button", self.Right)
    self.Craft:Dock(BOTTOM)
    self.Craft:SetTall(48)
    self.Craft:SetText("CRAFT")
    self.Craft.DoClick = function()
        if not self.Ingredients then return end
        if (LocalPlayer():getDarkRPVar("money", 0) < self.Ingredients["$"]) then
            Derma_Message("You cannot afford " .. DarkRP.formatMoney(self.Ingredients["$"]) .. " to craft this item!")
            return
        end
        for k, v in pairs(self.Ingredients) do
            if (k == "$") then continue end
            local item = BU3.Inventory.Inventory[k]
            if not item then
                Derma_Message("You don't have " .. BU3.Items.Items[k].name, "Error", "Ok")
                return
            elseif (item < v) then
                Derma_Message("You don't have enough " .. BU3.Items.Items[k].name .. " (Requires " .. v .. ")", "Error", "Ok")
                return
            end
        end
        Derma_Query("Do you want to craft " .. BU3.Items.Items[self.RecipeID].name .. "?", "Crafting", "Yes", function()
            net.Start("Crafting.Start")
            net.WriteInt(self.RecipeID, 16)
            net.WriteString(self.Kind == 0 and "Weapons" or self.Kind == 1 and "Suits" or "Entities")
            net.SendToServer()
        end, "No")
    end
    self.ModelController = vgui.Create("DModelPanel", self.Right)
    self.ModelController.oPaint = self.ModelController.Paint
    self.ModelController:Dock(FILL)
    self.ModelController.LayoutEntity = function() end
    self.ModelController:DockMargin(0, 0, 0, 16)

    self.Card = vgui.Create("Panel", self.ModelController)
    self.Card:Dock(FILL)
    self.Card:DockMargin(0, 0, 0, 16)

    self.Items = vgui.Create("Panel", self)
    self.Items:Dock(FILL)
    self.Items:DockMargin(0, 16, 0, 16)

    self.Items.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(16, 16, 16))
        if (self.Price) then
            draw.SimpleText("Upgrade Price", "Arena.Small", w / 2, h - 42, color_white, 1, TEXT_ALIGN_BOTTOM)
            draw.SimpleText(DarkRP.formatMoney(self.Price), "Arena.Medium", w / 2, h - 8, color_white, 1, TEXT_ALIGN_BOTTOM)
        end
    end

    self.ItemList = vgui.Create("DIconLayout", self.Items)
    self.ItemList:Dock(FILL)
    self.ItemList:SetSpaceX(8)
    self.ItemList:SetSpaceY(8)
    self.ItemList:DockMargin(16, 16, 16, 16)
    lbl = Label("Inventory:", self.Items)
    lbl:Dock(TOP)
    lbl:SetFont("XeninUI.TextEntry")
    lbl:DockMargin(8, 8, 0, 0)

    self.ModelController.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(16, 16, 16))
        self.ModelController:oPaint(w, h)
        surface.SetTexture(deg)
        surface.SetDrawColor(16, 16, 16)
        surface.DrawTexturedRect(0, h - 128, w, 128)
    end

    self:InvalidateLayout(true)

    self.ModelController.PaintOver = function(s, w, h)
        draw.SimpleText(self.Title, "Arena.Small", w / 2, 16, self.Color or color_white, 1)
    end

    self:PopulateRecipes()
end

function PANEL:PopulateRecipes()
    self.Recipes:Clear()
    local filter = string.lower(self.Search:GetText())
    local i = 0

    for k, v in pairs(Armor.Crafting.Weapons) do
        local item = BU3.Items.Items[k]
        if not item then continue end
        if (filter and filter ~= "" and not string.find(string.lower(item.name), filter, 1, true)) then continue end
        self:CreateRecipe(i, k, v, item, 0)
        i = i + 1
    end

    for k, v in pairs(Armor.Crafting.Entities) do
        local item = BU3.Items.Items[k]
        if not item then continue end
        if (filter and filter ~= "" and not string.find(string.lower(item.name), filter, 1, true)) then continue end
        self:CreateRecipe(i, k, v, item, 2)
        i = i + 1
    end
end

function PANEL:CreateRecipe(i, k, v, item, kind, target)
    local pnl = vgui.Create("DButton", self.Recipes)
    pnl:SetPos((i % 3) * 86, math.ceil((i + 1) / 3) * 86 - 86)
    pnl:SetText("")
    pnl:SetSize(82, 82)
    local iconPreview = nil

    if item.iconIsModel then
        iconPreview = BU3.UI.Elements.ModelView(item.iconID, item.zoom, pnl)
    else
        iconPreview = BU3.UI.Elements.IconView(item.iconID, item.color, pnl, false)
    end

    iconPreview:SetParent(pnl)
    iconPreview:Dock(FILL)
    iconPreview.zoom = item.zoom * 1.5
    iconPreview:SetMouseInputEnabled(false)
    iconPreview:DockMargin(8, 8, 8, 8)
    pnl:SetTooltip(item.name)
    pnl.Content = iconPreview
    pnl.Border = item.itemColorCode

	pnl.Paint = function(s, w, h)
		if BU3.Items.RarityToColor[s.Border] then
			draw.RoundedBox(4, 0, 0, w, h, BU3.Items.RarityToColor[s.Border])
		end
		draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(26, 26, 26))
	end

    pnl.DoClick = function(s)
        self.Selected = s
        self.RecipeID = k
        self.IsSuit = kind == 1
        self.Kind = kind
        self:SetupView(k, v, item, kind)
    end

    if not self.Selected then
        self.Selected = true
        timer.Simple(0.1, function()
            pnl:DoClick()
        end)
    end
end

function PANEL:SetupView(k, v, item, kind)
    self.Title = item.name
    self.Color = BU3.Items.RarityToColor[item.itemColorCode]
    if self.Card:IsVisible() then
        self.Card:SetVisible(false)
        if IsValid(self.Card.Content) then
            self.Card.Content:Remove()
        end
    end
    if (kind == 1) then
        local armor = Armor:GetByID(item.className)
        self.ModelController:SetModel(armor.Model)
        local att = self.ModelController:GetEntity():GetAttachment(self.ModelController:GetEntity():LookupAttachment("eyes"))
        local cycle = self.ModelController:GetEntity():GetCycle()
        self.ModelController:GetEntity():SetSequence("menu_combine")
        self.ModelController:GetEntity():SetCycle(cycle)
        self.ModelController:SetFOV(45)
        self.ModelController.aLookAngle = nil
        self.ModelController:SetCamPos(Vector(40, 0, att.Pos.z - 10))
        self.ModelController:SetLookAt(Vector(0, 0, att.Pos.z - 10))
        self.ModelController:SetSkin(0)
    else
        self.ModelController:SetModel("")
        local iconPreview
        if item.iconIsModel then
            iconPreview = BU3.UI.Elements.ModelView(item.iconID, item.zoom, self.Card)
        else
            iconPreview = BU3.UI.Elements.IconView(item.iconID, item.color, self.Card, false)
        end
        
        self.Card.Content = iconPreview
        iconPreview:SetSize(300, 300)
        iconPreview:Center()
        self.Card:SetVisible(true)
    end

    for k, v in pairs(self.ItemList:GetChildren()) do
        v:Remove()
    end

    local size = (self.ItemList:GetWide()) / 3 - 8
    self.Ingredients = table.Copy(v)
    for k, v in pairs(v) do
        if (k == "$") then
            self.Price = v
            continue
        end

        local pnl = vgui.Create("Panel", self.ItemList)
        pnl:SetSize(size, size)
        local _item = BU3.Items.Items[k]
        local iconPreview = nil

        if item.iconIsModel then
            iconPreview = BU3.UI.Elements.ModelView(_item.iconID, _item.zoom, pnl)
        else
            iconPreview = BU3.UI.Elements.IconView(_item.iconID, _item.color, pnl, false)
        end

        iconPreview:SetParent(pnl)
        iconPreview:Dock(FILL)
        iconPreview.zoom = _item.zoom * 1.5
        iconPreview:SetMouseInputEnabled(false)
        iconPreview:DockMargin(8, 8, 8, 8)
        pnl:SetTooltip(_item.name)
        pnl.Content = iconPreview
        pnl.Border = _item.itemColorCode

        pnl.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, BU3.Items.RarityToColor[s.Border])
            draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(26, 26, 26))
        end

        pnl.PaintOver = function(s, w, h)
            draw.SimpleText((BU3.Inventory.Inventory[k] or 0) .. "/" .. v, "XeninUI.TextEntry", w - 8, h - 8, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        end

        pnl.DoClick = function(s)
            self.Selected = s
            self:SetupView(k, v, item, isSuit)
        end

        if not self.Selected then
            pnl:DoClick()
        end
    end
end

function PANEL:PerformLayout(w, h)
    self.Right:SetWide(w / 3)
end

function PANEL:PopulateItems()
    for id, lam in pairs(itemTable) do
        local item = BU3.Items.Items[id]

        if (string.find(string.lower(item.name), filter, 1, true)) then
            self:CreateItemSlot(id, lam, self.ItemsLayout, totalWide)
        end
    end
end

function PANEL:CreateItemSlot(id, lam, parent, totalWide)
    local item = BU3.Items.Items[id]
    local it = vgui.Create("DButton", parent)
    it:SetSize(totalWide, totalWide)
    it:SetText("")
    it:Droppable("tradeTarget")
    it.Item = item
    it.ID = id
    it.Amount = lam
    it.Color = BU3.Items.RarityToColor[item.itemColorCode]
    it:SetTooltip(item.name)

    it.DoClick = function(s)
        local menu = DermaMenu()

        menu:AddOption("See Price", function()
            if IsValid(REQ_DIALOG) then
                REQ_DIALOG:Remove()
            end

            REQ_DIALOG = vgui.Create("DMarket.Stat")
            REQ_DIALOG:Request(s.ID)
        end)

        if (s.IsTrade) then
            menu:AddOption("Retrieve", function()
                self.ImTrading[s.ID] = nil
                net.Start("BU3.Trade:InsertItem")
                net.WriteInt(s.ID, 16)
                net.WriteInt(0, 16)
                net.SendToServer()
                s:Remove()
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

vgui.Register("DCrafting.Main", PANEL, "Panel")

--if IsValid(CRAFTER) then
    --CRAFTER:Remove()
--end

--CRAFTER = vgui.Create("DCrafting.Main")
local PAGE = {}
PAGE.CaseData = {}
PAGE.IsCreating = true --If false, this page will work as an editor instead of a creator
PAGE.page = 1 --Between 1 and four
PAGE.lerpedPos = 0

--This is called when the page is called to load
function PAGE:Load(contentFrame, itemData)
    if IsValid(self.Content) then
        self.Content:SetVisible(true)
    else
        self.Content = vgui.Create("DCrafting.Main", contentFrame)
        self.Content:Dock(FILL)
    end
end

function PAGE:Unload()
    if IsValid(self.Content) then
        self.Content:SetVisible(false)
    end
end

timer.Simple(1, function()
    BU3.UI.RegisterPage("crafting", PAGE)
end)