local PAGE = {}
PAGE.toolTipPanel = nil
local itemCollection = {}
local slotCollection = {}

function PAGE:ShowTooltip(parent, title, text, xPos, yPos)
    if self.toolTipPanel ~= nil then
        self.toolTipPanel:Remove()
    end

    self.toolTipPanel = vgui.Create("DPanel", parent)
    self.toolTipPanel:Dock(FILL)
    --self.toolTipPanel:SetSize(parent:GetWide(), parent:GetTall())
    --if xPos + 140 + 10 > ScrW() then
    --	xPos = xPos - 145 - 10
    --else
    --	xPos = xPos + 140 + 10
    --end
    --if yPos + 190 >  ScrH() then
    --	yPos = yPos - 190
    --end
    --Size of panel p:SetSize(140, 190)
    --self.toolTipPanel:MakePopup()
    self.toolTipPanel:SetMouseInputEnabled(false)
    self.toolTipPanel.Paint = function() end
    local richtext = vgui.Create("RichText", self.toolTipPanel)
    richtext:DockMargin(8, 32, 8, 8)
    richtext:Dock(FILL)
    richtext:SetText(text)
    richtext:SetVerticalScrollbarEnabled(false)
end

function PAGE:HideTooltip()
    if self.toolTipPanel ~= nil then
        self.toolTipPanel:Remove()
    end
end

--This is called when the page is called to load
function PAGE:Load(contentFrame)
    if table.Count(BU3.Items.Items) == 0 then
        RunConsoleCommand("bu3_fetchitems")

        return
    end

    if IsValid(self.Inventory) then
        self.Inventory:SetVisible(true)
        self.Inventory.ContentFrame = contentFrame
        return
    end
    self.Inventory = vgui.Create("gInventory", contentFrame)
    self.Inventory:Dock(FILL)
    self.Inventory.ContentFrame = contentFrame
end

--This is called when the page should unload
function PAGE:Unload(contentFrame, direction)
    if IsValid(self.Inventory) then
        self.Inventory:SetVisible(false)
    end
end

--This can be called by anything to pass a message to the page
function PAGE:Message(message, data)
end

--Register the page
BU3.UI.RegisterPage("inventory", PAGE)

hook.Add("InitPostEntity", "FetchItems", function()
    RunConsoleCommand("bu3_fetchitems")
end)

local function setupPerma(data)
    if IsValid(LocalPlayer()) then
        LocalPlayer()._permaWeapons = data
    else
        timer.Simple(1, function()
            setupPerma(data)
        end)
    end
end

net.Receive("BU3:EquipPerma", function()
    setupPerma(net.ReadTable())
end)

local function showUnboxedItems(items)
    local frame = vgui.Create("XeninUI.Frame")
    frame:MakePopup()
    frame:SetTitle("Unbox Result")
    frame:SetSize(32 + #items * 208, 300)
    frame:Center()
    frame.Body = vgui.Create("DPanel", frame)
    frame.Body:Dock(FILL)
    frame.Body:DockMargin(16, 16, 16, 16)

    frame.Body.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(6, 6, 6))
    end

    for k, v in pairs(items) do
        local btn = vgui.Create("DPanel", frame.Body)
        btn:Dock(LEFT)
        btn:SetWide(200)
        btn:DockMargin(4, 4, 4, 4)
        local item = BU3.Items.Items[v]
        local borderColor = item.itemColorCode or 1

        btn.Paint = function(s, w, h)
            BU3.Items.RarityToFrame[borderColor](0, 0, w, h)
            --Draw the item name
            local name = item.name

            if string.len(name) >= 16 then
                name = string.sub(name, 1, 14) .. "..."
            end

            draw.SimpleText(name, BU3.UI.Fonts["small_reg"], w / 2, 20, Color(200, 200, 200, 255), 1, 1)
        end

        local iconPreview = nil

        if item.iconIsModel then
            iconPreview = BU3.UI.Elements.ModelView(item.iconID, item.zoom, btn)
        else
            iconPreview = BU3.UI.Elements.IconView(item.iconID, item.color, btn, false)
        end

        iconPreview:Dock(FILL)
        iconPreview:DockMargin(11, 32, 11, 24)
        iconPreview.zoom = item.zoom
        iconPreview:SetMouseInputEnabled(false)
    end
end

net.Receive("BU3:BulkOpening", function()
    local itemsWon = net.ReadTable()
    showUnboxedItems(itemsWon)
end)

timer.Simple(1, function()
    -- Button down func
    keybinds.RegisterBind("openInventory", "Opens Inventory menu", KEY_I, function()
        if (LocalPlayer():InArena()) then return end

        if IsValid(aMenu.Base) then
            aMenu.Base:SetCategory("Inventory")
        else
            aMenu.Base = vgui.Create("aMenuBase")
            aMenu.Base:SetCategory("Inventory")
        end
    end, function() end)
end)