local PANEL = {}

function PANEL:Init()
    local options = vgui.Create("DPanel", self)
    options:Dock(TOP)
    options:SetTall(32)
    options:DockMargin(12, 8, 0, 0)
    options.Paint = function() end
    options.Upgrades = vgui.Create("XeninUI.Button", options)
    options.Upgrades:SetText("Currency")
    options.Upgrades:Dock(LEFT)
    options.Upgrades:DockMargin(86, 0, 0, 0)
    options.Upgrades:SetWide(128)

    options.Upgrades.DoClick = function()
        self:PopulateOptions(1)
    end

    options.Backgrounds = vgui.Create("XeninUI.Button", options)
    options.Backgrounds:SetText("Items")
    options.Backgrounds:Dock(LEFT)
    options.Backgrounds:DockMargin(16, 0, 0, 0)
    options.Backgrounds:SetWide(172)

    options.Backgrounds.DoClick = function()
        self:PopulateOptions(2)
    end

    self.Options = vgui.Create("XeninUI.ScrollPanel", self)
    self.Options:Dock(FILL)
    self.Options:DockMargin(8, 16, 16, 16)
    self:PopulateOptions(1)
end

function PANEL:PopulateOptions(id)
    self.Options:Clear()

    if (id == 1) then
        local pan = vgui.Create("DPanel", self.Options)
        pan:Dock(TOP)
        pan:SetTall(76 + 64)

        pan.Paint = function(s, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(26, 26, 26))
            draw.SimpleText("Deposit cash", "XeninUI.TextEntry", 8, 8, Color(255, 255, 255, 100))
            draw.SimpleText("Deposit credits", "XeninUI.TextEntry", 8, 72, Color(255, 255, 255, 100))
        end

        pan.con = vgui.Create("DPanel", pan)
        pan.con:Dock(TOP)
        pan.con:SetTall(36)
        pan.con:DockMargin(8, 32, 8, 26)
        pan.con.Paint = function() end
        pan.Pay = vgui.Create("XeninUI.Button", pan.con)
        pan.Pay:SetText("Deposit")
        pan.Pay:Dock(RIGHT)
        pan.Pay:SetRound(8)
        pan.Pay:DockMargin(8, 0, 0, 0)
        pan.Pay:SetColor(Color(36, 36, 36))
        pan.Pay:SetWide(128)

        pan.Pay.DoClick = function(s)
            local am = tonumber(pan.Cash:GetText())

            if (am and am > 0 and LocalPlayer():canAfford(am)) then
                Derma_Query("Are you sure do you want to deposit " .. DarkRP.formatMoney(am) .. "?", "Confirmation", "Yes", function()
                    net.Start("Gangs.Deposit")
                    net.WriteBool(false)
                    net.WriteUInt(am, 32)
                    net.SendToServer()
                    asapgangs.gangList[LocalPlayer():GetGang()].Money = (asapgangs.gangList[LocalPlayer():GetGang()].Money or 0) + am
                end, "Cancel")

                pan.Cash:SetText("0")
            end
        end

        pan.Cash = vgui.Create("XeninUI.TextEntry", pan.con)
        pan.Cash:Dock(FILL)
        pan.Cash:SetNumeric(true)

        pan.creco = vgui.Create("DPanel", pan)
        pan.creco:Dock(TOP)
        pan.creco:SetTall(36)
        pan.creco:DockMargin(8, 0, 8, 32)
        pan.creco.Paint = function() end

        pan.PayC = vgui.Create("XeninUI.Button", pan.creco)
        pan.PayC:SetText("Deposit")
        pan.PayC:Dock(RIGHT)
        pan.PayC:SetRound(8)
        pan.PayC:DockMargin(8, 0, 0, 0)
        pan.PayC:SetColor(Color(36, 36, 36))
        pan.PayC:SetWide(128)

        pan.PayC.DoClick = function()
            local am = tonumber(pan.Credits:GetText())
            if (am and am > 0 and LocalPlayer():GetStoreCredits() >= am) then
                Derma_Query("Are you sure do you want to deposit " .. am .. " CREDITS?", "Confirmation", "Yes", function()
                    net.Start("Gangs.Deposit")
                    net.WriteBool(true)
                    net.WriteInt(am, 32)
                    net.SendToServer()
                end, "Cancel")
                pan.Credits:SetText("0")
            else
                Derma_Message("Insufficient credits!", "Errors", "Ok")
            end

        end

        pan.Credits = vgui.Create("XeninUI.TextEntry", pan.creco)
        pan.Credits:Dock(FILL)
        pan.Credits:SetNumeric(true)

        if (LocalPlayer():GangsHasPermission("WITHDRAW")) then
            local gang = asapgangs.gangList[LocalPlayer():GetGang()]
            local pan = vgui.Create("DPanel", self.Options)
            pan:Dock(TOP)
            pan:DockMargin(0, 16, 0, 0)
            pan:SetTall(76 + 64)

            pan.Paint = function(s, w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(26, 26, 26))
                draw.SimpleText("Withdraw cash", "XeninUI.TextEntry", 8, 8, Color(255, 255, 255, 100))
            end

            pan.con = vgui.Create("DPanel", pan)
            pan.con:Dock(TOP)
            pan.con:SetTall(36)
            pan.con:DockMargin(8, 32, 8, 26)
            pan.con.Paint = function() end
            pan.Pay = vgui.Create("XeninUI.Button", pan.con)
            pan.Pay:SetText("Withdraw")
            pan.Pay:Dock(RIGHT)
            pan.Pay:SetRound(8)
            pan.Pay:DockMargin(8, 0, 0, 0)
            pan.Pay:SetColor(Color(36, 36, 36))
            pan.Pay:SetWide(128)

            pan.Pay.DoClick = function(s)
                local am = tonumber(pan.Cash:GetText())

                if (am and am > 0 and gang.Money >= am) then
                    Derma_Query("Are you sure do you want to Withdraw " .. DarkRP.formatMoney(am) .. "?", "Confirmation", "Yes", function()
                        net.Start("Gangs.Withdraw")
                        net.WriteBool(false)
                        net.WriteFloat(am)
                        net.SendToServer()
                        gang.Money = (gang.Money or 0) - am
                    end, "Cancel")

                    pan.Cash:SetText("0")
                end
            end

            pan.Cash = vgui.Create("XeninUI.TextEntry", pan.con)
            pan.Cash:Dock(FILL)
            pan.Cash:SetNumeric(true)

        end
    end

end

function PANEL:Paint(w, h)
    draw.SimpleText("Bank", "Gangs.Medium", 12, 8, color_white)
end

vgui.Register("Gangs.Bank", PANEL, "DPanel")

if IsValid(GANGS) then
    GANGS:Remove()
end
