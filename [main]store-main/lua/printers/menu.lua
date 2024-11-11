local PANEL = {}
PANEL.PrinterButtons = {}
PANEL.SelectedPrinter = ""
local printerModel = "models/ogl/ogl_oneprint_nebula.mdl"

function PANEL:Init()
    PRINTER_PANEL = self

    self.Side = vgui.Create("DPanel", self)
    self.Side:Dock(RIGHT)
    self.Side:SetWide(228)
    self.Side:DockPadding(8, 48, 16, 0)
    self.Side.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, color_black)
        draw.SimpleText("Skins: ", XeninUI:Font(32), 8, 8, color_white)
    end

    self.List = vgui.Create("XeninUI.ScrollPanel", self.Side)
    self.List:Dock(FILL)

    self.Model = vgui.Create("DModelPanel", self)
    self.Model:Dock(FILL)
    self.Model:SetModel(printerModel)
    self.Model:SetFOV(75)
    self.Model:SetCamPos(Vector(140, 140, 40))
    self.Model:SetLookAt(Vector(0, 0, 0))
    self.Model.LayoutEntity = function(s, ent)
        ent:SetLocalAngles(Angle(0, 45 + math.cos(RealTime() / 2) * 45, 0))
    end

    for k = 1, 10 do
        local ent = self.Model.Entity
        if (not IsValid(ent)) then return end

        ent:SetBodygroup(k, math.random(0, 2))
    end

    self:PopulateSkins()
end

local bought, equipped = Color(0, 157, 255), Color(255, 136, 0)
local cannotAfford = Color(150, 0, 0)
function PANEL:CreateButton(k, v)
    local pnl = vgui.Create("XeninUI.Button", self.List)
    pnl:SetText("")
    pnl:SetTall(40)
    pnl:SetRound(8)
    pnl.PaintOver = function(s, w, h)
        draw.SimpleText(k, XeninUI:Font(24), 8, h / 2, s.hasSkin and bought or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        if (s.hasSkin) then
            draw.SimpleText(s.isEquipped and "Equipped" or "Equip", XeninUI:Font(24), w - 8, h / 2, s.isEquipped and equipped or bought, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        elseif (v > 0) then
            draw.SimpleText(string.Comma(v), XeninUI:Font(24), w - 8, h / 2, LocalPlayer():GetStoreCredits() < v and cannotAfford or color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end
    pnl:Dock(TOP)
    pnl:DockMargin(0, 0, 0, 8)
    pnl.OnCursorEntered = function()
        self:UpdatePrinter(k)
    end

    pnl.DoClick = function(s)
        if (not s.hasSkin) then
            if LocalPlayer():GetStoreCredits() < v then
                Derma_Message("You cannot afford enough credits to buy this printer skin", "Error", "Ok")
                return
            end
            Derma_Query("Are you sure do you want to buy this printer skin for " .. DarkRP.formatMoney(v) .. " credits?", "Buy printer skin", "Yes", function()
                net.Start("Store.Printers:Buy")
                net.WriteString(k)
                net.SendToServer()
                Store.Printers.SelectedPrinter = k
                for _, but in pairs(self.PrinterButtons) do
                    but.isEquipped = false
                end
                s.hasSkin = true
                s.isEquipped = true
                Store.Printers.Local[k] = true
            end, "No", function() end)
            return
        else
            net.Start("Store.Printers:Select")
            net.WriteString(k)
            net.SendToServer()
            Store.Printers.SelectedPrinter = k
            for _, but in pairs(self.PrinterButtons) do
                but.isEquipped = false
            end
            s.isEquipped = true
        end
    end

    return pnl
end

function PANEL:UpdatePrinter(sk)
    if sk == "random" then
        sk = table.Random(table.GetKeys(Store.Printers.Local))
        if (not sk) then
            return
        end
    end
    local mat_a, mat_b = "printer_skins/" .. sk .. "/printer", "printer_skins/" .. sk .. "/rack"
    local ent = self.Model:GetEntity()
    if (not IsValid(ent)) then return end

    ent:SetSubMaterial(0, mat_b)
    ent:SetSubMaterial(3, mat_a)
end

function PANEL:PopulateSkins()
    self.PrinterButtons = {}
    for k, v in pairs(Store.Printers.Skins) do
        local pnl = self:CreateButton(k, v)
        pnl.hasSkin = Store.Printers.Local[k]
        pnl.isEquipped = Store.Printers.SelectedPrinter == k
        self.PrinterButtons[k] = pnl
    end

    local ran = self:CreateButton("Random", 0)
    ran.DoClick = function(s)
        for k, v in pairs(self.PrinterButtons) do
            v.isEquipped = false
        end
        Store.Printers.SelectedPrinter = "random"
        net.Start("Store.Printers:Select")
        net.WriteString("random")
        net.SendToServer()
    end
end

function PANEL:Paint(w, h)
    draw.SimpleText("*Skins will apply next time you spawn a printer*", XeninUI:Font(24), w / 2 - 112, h - 32, color_white, 1, 1)
end

vgui.Register("Printers.Main", PANEL, "Panel")

if IsValid(PRINTER_PANEL) then
    PRINTER_PANEL:Remove()
end

net.Receive("Store.Printers:Sync", function()
    Store.Printers.Local = {}
    for k = 1, net.ReadUInt(6) do
        Store.Printers.Local[net.ReadString()] = true
    end
    Store.Printers.SelectedPrinter = net.ReadString()
end)
