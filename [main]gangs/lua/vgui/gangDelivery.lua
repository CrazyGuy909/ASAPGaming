local PANEL = {}
PANEL.Resources = {}
PANEL.Dispatched = false
local delivery_panel

function PANEL:Init()
    delivery_panel = self
    self.Dispatched = false
    self.Resources = {}
    self:SetSize(450, 600)
    self:Center()
    self:SetTitle("Delivery Pallets")
    self:MakePopup()
    self.Bot = vgui.Create("XeninUI.Button", self)
    self.Bot:SetText("Pickup")
    self.Bot:SetColor(Color(46, 46, 46))
    self.Bot:SetSize(self:GetWide() * .4, 32)
    self.Bot:SetPos(self:GetWide() - self.Bot:GetWide() - 16, self:GetTall() - 48)

    self.Bot.DoClick = function()
        if (self.Dispatched) then return end

        Derma_Query("Are you sure do you want to pick up those packages?", "Picking up", "Yes", function()
            self.Dispatched = true

            for k, v in pairs(self.Resources) do
                if (LocalPlayer().GangComputer.Resources[k] < v) then
                    Derma_Message("You don't have enough " .. asapgangs.War.Craftables[k].Name .. " to make this supply, try again!")

                    return
                end
            end

            net.Start("Gangs.PickupDelivery")
            net.WriteUInt(table.Count(self.Resources), 4)

            for k, v in pairs(self.Resources) do
                net.WriteUInt(k, 4)
                net.WriteUInt(v, 32)
            end

            net.SendToServer()
        end, "No")
    end

    self.Info = Label("Select what materials do you want to deliver. If you die while you have the shipments,  you will lose everything you had on you! So ask a friend to protect you or equip with cool gears!", self)
    self.Info:SetSize(self:GetWide() - 32, 128)
    self.Info:SetPos(16, self:GetTall() - 142)
    self.Info:SetWrap(true)
    self.Inner = vgui.Create("XeninUI.ScrollPanel", self)
    self.Inner:Dock(FILL)
    self.Inner:DockMargin(16, 16, 16, 128)

    self.Inner.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(16, 16, 16))
    end

    self:GenerateContent()
end

local colors = {
    [0] = Color(100, 100, 100),
    [1] = Color(235, 235, 235),
    [2] = Color(108, 200, 238),
    [3] = Color(126, 238, 108),
    [4] = Color(214, 77, 77),
    [5] = Color(219, 61, 229)
}

function PANEL:GenerateContent()
    for k, v in SortedPairsByMemberValue(asapgangs.War.Craftables, "Difficulty") do
        local btn = vgui.Create("DPanel", self.Inner)
        btn:Dock(TOP)
        btn:DockMargin(4, 4, 4, 0)
        btn:SetTall(64)
        local max = (LocalPlayer().GangComputer.Resources or {})[k] or 0

        btn.Paint = function(s, w, h)
            draw.RoundedBoxEx(8, 0, 0, w, h, Color(36, 36, 36), false, true, false, true)
            draw.SimpleText(v.Name, "Arena.Small", 72, 10, colors[v.Difficulty])
            if not LocalPlayer().GangComputer then return end
            draw.SimpleText("Available: " .. max, "XeninUI.TextEntry", 72, 36, Color(255, 255, 255, 150))
            local res = self.Resources[k] or 0
            local tx, ty = draw.SimpleText(res, "Arena.Small", w - 16, 36, color_white, TEXT_ALIGN_RIGHT)
            surface.SetDrawColor(255, 255, 255, 100)
            surface.DrawOutlinedRect(w - 16 - tx - 8, 36, tx + 16, ty)
            draw.SimpleText(DarkRP.formatMoney(res * v.Price), "Arena.Small", w - 12, 10, color_white, TEXT_ALIGN_RIGHT)
        end

        btn.Icon = vgui.Create("SpawnIcon", btn)
        btn.Icon:Dock(LEFT)
        btn.Icon:SetWide(64)
        btn.Icon:DockMargin(0, 0, 4, 0)
        btn.Icon:SetModel(v.Model)
        btn.Icon:SetTooltip(v.Name)
        btn.Icon:SetMouseInputEnabled(false)
        btn.Icon.OnCursorEntered = function() end
        btn.Icon.opaint = btn.Icon.Paint
        btn.Icon.Paint = function(s, w, h)
            surface.SetDrawColor(colors[v.Difficulty])
            surface.DrawOutlinedRect(0, 0, w, h)
            surface.SetDrawColor(ColorAlpha(colors[v.Difficulty], 5))
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(color_white)
            s:opaint(w, h)
        end
        btn.Select = vgui.Create("XeninUI.Slider", btn)
        btn.Select:Dock(BOTTOM)
        btn.Select:DockMargin(128, 16, 56, 8)
        btn.Select:SetMax(max)
        btn.Select:SetMin(0)
        btn.Select:SetValue(0)

        btn.Select.OnValueChanged = function(s, val)
            val = val * s:GetMax()
            local maxb = (LocalPlayer().GangComputer.Resources or {})[k] or 0
            val = math.Round(val)
            if (maxb >= val and val > 0) then
                self.Resources[k] = val
            else
                self.Resources[k] = nil
            end
        end
    end
end

vgui.Register("Gangs.Delivery", PANEL, "XeninUI.Frame")

net.Receive("Gangs.OpenDeliveryMenu", function()
    vgui.Create("Gangs.Delivery")
end)

net.Receive("Gangs.PickupDelivery", function()
    local success = net.ReadBool()

    if (not success) then
        Derma_Message("You couldn't pick up the delivery, maybe some took the stuff from your back before you knew it", "Oh noes!")
    end

    if IsValid(delivery_panel) then
        delivery_panel:Remove()
    end
end)