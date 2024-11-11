local PANEL = {}
local slotSize = 64
PANEL.Slots = {}

function PANEL:Init()
    self:SetSize((slotSize + 4) * 12 + 8, (slotSize + 4) * 2 + 6)
    self:SetPos(ScrW() / 2 - self:GetWide() / 2, ScrH() - self:GetTall() - 48)
    self:SetMouseInputEnabled(true)
    self:PrepareSlots()
end

function PANEL:PrepareSlots()
    local savedStat = util.JSONToTable(cookie.GetString("Inventory:Hotbar", "[]"))

    for k, v in pairs(self.Slots) do
        v:Remove()
    end

    self.Slots = {}

    for k = 0, 23 do
        local slot = vgui.Create("DButton", self)
        slot:SetSize(slotSize, slotSize)
        slot:SetText("")
        slot:SetPos(6 + (k % 12) * (slotSize + 4), 6 + math.ceil((k + 1) / 12) * (slotSize + 4) - slotSize - 4)

        slot.Paint = function(s, w, h)
            if (not BU3.Items.Items[s.ID]) then
                surface.SetDrawColor(0, 0, 0, 175)
                surface.DrawOutlinedRect(0, 0, w, h)

                return
            end

            if (s.ID and BU3.Items.Items[s.ID]) then
                local borderColor = BU3.Items.Items[s.ID].itemColorCode or 1
                local borderColorRGB = BU3.Items.RarityToColor[borderColor]
                borderColorRGB = ColorAlpha(borderColorRGB, BU3.Inventory.Inventory[s.ID] and 255 or 15)
                draw.RoundedBox(16, 0, 0, w, h, borderColorRGB)
            else
                draw.RoundedBox(16, 0, 0, w, h, Color(66, 66, 66))
            end

            local alpha = BU3.Inventory.Inventory[s.ID] and 200 or 50
            if not IsValid(s.Content) then return end
            s.Content:SetAlpha(BU3.Inventory.Inventory[s.ID] and 255 or 200)
            draw.RoundedBox(16, 2, 2, w - 4, h - 4, Color(36, 36, 36, alpha))
            draw.SimpleText(k + 1, "XeninUI.TextEntry", 8, h - 8, Color(255, 255, 255, alpha / 2), TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)

            if (s.ID and BU3.Inventory.Inventory[s.ID]) then
                draw.SimpleText("x" .. BU3.Inventory.Inventory[s.ID], "XeninUI.TextEntry", w - 8, 8, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
            end

            if (k > 6) then return end

            DisableClipping(true)
            draw.SimpleTextOutlined("(" .. k + 1 .. ")", "XeninUI.TextEntry", w / 2, -12, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 1, color_black)
            DisableClipping(false)
        end

        slot.DoClick = function(s)
            if (s.Item.type == "suit" and LocalPlayer().armorSuit) then return end
            local menu = DermaMenu()

            menu:AddOption("Use " .. s.Item.name, function()
                if (s.Item.type == "entity") then
                    net.Start("BU3:UseItem")
                    net.WriteInt(s.ID, 32)
                    net.SendToServer()
                elseif (s.Item.type == "suit" or string.find(s.Item.className or "", "armor", 1, true)) then
                    net.Start("BU3:UseItemArmor")
                    net.WriteString(s.Item.className)
                    net.WriteUInt(s.ID, 16)
                    net.SendToServer()
                elseif (s.Item.type == "weapon") then
                    net.Start("BU3:UseItemWeapon")
                    net.WriteInt(s.ID, 32)
                    net.SendToServer()
                elseif (s.Item.type == "blueprint") then
                    net.Start("ASAP_WEPS_SpawnWeapon")
                    net.WriteString(s.Item.className)
                    net.SendToServer()
                end
            end):SetIcon("icon16/star.png")

            menu:AddOption("Cancel")
            menu:Open()
        end

        slot.Set = function(s, id, item, ignore)
            if (IsValid(s.Content)) then
                s.Content:Remove()
            end

            s:SetMouseInputEnabled(id ~= nil)
            s.ID = id
            s.Item = item

            if (id and item) then
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
                s:SetTooltip(item.name)
                if (item.type == "weapon") then
                    s.itemClass = item.className
                end
            else
                s:SetTooltip(nil)
            end
        end

        slot:SetMouseInputEnabled(false)

        k = k + 1
        if (savedStat[k]) then
            slot:Set(savedStat[k], BU3.Items.Items[savedStat[k]])
        end
        k = k - 1

        self.Slots[k] = slot
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, Color(16, 16, 16, 150))
    DisableClipping(true)
    draw.SimpleTextOutlined("ALT + ", "XeninUI.TextEntry", -8, -4, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, color_black)
    DisableClipping(false)
end

vgui.Register("Inventory.QuickMenu", PANEL, "Panel")

if IsValid(QUICK_INV) then
    QUICK_INV:Remove(true)
end

hook.Add("OnContextMenuOpen", "OpenInvMenu", function()
    if (LocalPlayer():InArena()) then return end

    if IsValid(QUICK_INV) then
        QUICK_INV:SetVisible(true)
        QUICK_INV:PrepareSlots()
    else
        QUICK_INV = vgui.Create("Inventory.QuickMenu", g_ContextMenu)
    end
end)

hook.Add("PlayerBindPress", "CancelItemry", function(ply, bind, pressed, code)
    if not pressed then return end
    if (not bind:StartsWith("slot") or not ply:KeyDown(IN_WALK)) then
        return
    end
    local savedStat = util.JSONToTable(cookie.GetString("Inventory:Hotbar", "[]"))
    local slot = tonumber(bind:sub(5))

    if not savedStat[slot] then return end

    local id = savedStat[slot]
    if not BU3.Items.Items[id] then return end
    local cs = BU3.Items.Items[id].className
    if (not LocalPlayer():HasWeapon(cs)) then
        chat.AddText("<color=red>You need to use this weapon first</color>")
        return true
    end
    RunConsoleCommand("use", BU3.Items.Items[id].className)
    return true
end)

hook.Add("OnContextMenuClose", "OpenInvMenu", function()
    if IsValid(QUICK_INV) then
        QUICK_INV:SetVisible(false)
    end
end)