local myGang = (asapgangs.myGang or {})
local PANEL = {}

function PANEL:Init()
    myGang = asapgangs.gangList[LocalPlayer():GetGang()] or {}
    local options = vgui.Create("DPanel", self)
    options:Dock(TOP)
    options:SetTall(32)
    options:DockMargin(12, 8, 0, 0)
    options.Paint = function() end
    options.Upgrades = vgui.Create("XeninUI.Button", options)
    options.Upgrades:SetText("Upgrades")
    options.Upgrades:Dock(LEFT)
    options.Upgrades:DockMargin(96, 0, 0, 0)
    options.Upgrades:SetWide(128)

    options.Upgrades.DoClick = function()
        self:PopulateUpgrades(1)
    end

    self.Upgrades = vgui.Create("XeninUI.ScrollPanel", self)
    self.Upgrades:Dock(FILL)
    self.Upgrades:DockMargin(8, 16, 16, 16)
    self:PopulateUpgrades(1)
end

function PANEL:PopulateUpgrades(id)
    self.Upgrades:Clear()

    if (id == 1) then
        for k, v in pairs(UPGRADE_TEST) do
            local card = vgui.Create("Gangs.Upgrade", self.Upgrades)
            card:SetData(v, k)
        end
    end
end

function PANEL:Paint(w, h)
    draw.SimpleText("Shop", "Gangs.Medium", 12, 8, color_white)
end

vgui.Register("Gangs.Shop", PANEL, "DPanel")
local UPG = {}

function UPG:Init()
    self:Dock(TOP)
    self:DockMargin(0, 0, 0, 4)
    self:SetTall(84)
end

function UPG:SetData(v, id)
    local gang = asapgangs.gangList[LocalPlayer():GetGang()]
    self.Data = v
    self.Icon = Material(v.Icon)
    self.Level = gang.Shop.Upgrades[id] or 0
    
    -- Ensure gang.Shop.Upgrades is a table
    if not istable(gang.Shop.Upgrades) then
        gang.Shop.Upgrades = {}
    end
    
    if not istable(gang.Shop.Upgrades[id]) then
        gang.Shop.Upgrades[id] = 0
    end

    local pay = vgui.Create("DPanel", self)
    pay:Dock(RIGHT)
    pay:SetWide(200)
    pay:DockMargin(8, 8, 8, 8)
    pay.Paint = function() end

    -- Ensure v.Credits is a number
    local credits = tonumber(v.Credits) or 0

    pay.Credits = vgui.Create("XeninUI.Button", pay)
    pay.Credits:Dock(TOP)
    pay.Credits:SetText(DarkRP.formatMoney(credits))
    pay.Credits:DockMargin(0, 0, 0, 4)
    pay.Credits:SetIcon("ui/gangs/currency")
    pay.Credits:SetTextInset(12)
    pay.Credits:SetColor(Color(16, 16, 16))
    pay.Credits.DoClick = function()
        if ((gang.Shop.Upgrades[id] or 0) >= self.Data.Levels) then
            Derma_Message("You can't upgrade this perk", "Max level reached", "Sorry")
            return
        end
        if ((gang.Credits or -1) >= credits) then
            Derma_Query("Are you sure do you want to upgrade this perk?", "Warning", "Yes", function()
                net.Start("Gangs.PurchaseUpgrade")
                net.WriteString(id)
                net.WriteBool(true)
                net.SendToServer()
                LocalPlayer():AddStoreCredits(-credits)
                gang.Credits = gang.Credits - credits
                self.Level = self.Level + 1
                gang.Shop.Upgrades[id] = (gang.Shop.Upgrades[id] or 0) + 1
            end, "No")
        else
            Derma_Message("Insufficient funds in gang account, deposit some money and try again!", "Get dosh", "Ok")
        end
    end

    local price = istable(v.Price) and v.Price[gang.Shop.Upgrades[id] or 1] or tonumber(v.Price) or 0
    self.pay = pay
    if (price == -1) then return end

    pay.Money = vgui.Create("XeninUI.Button", pay)
    pay.Money:Dock(TOP)
    pay.Money:SetTextInset(12)
    pay.Money:SetText(DarkRP.formatMoney(price))
    pay.Money:SetIcon("ui/gangs/wallet")
    pay.Money:SetColor(Color(16, 16, 16))
    pay.Money.DoClick = function()
        if ((gang.Shop.Upgrades[id] or 0) >= self.Data.Levels) then
            Derma_Message("You can't upgrade this perk", "Max level reached", "Sorry")
            return
        end
        local price = istable(self.Data.Price) and self.Data.Price[gang.Shop.Upgrades[id] or 1] or tonumber(self.Data.Price) or 0
        if (gang.Money >= price) then
            Derma_Query("Are you sure do you want to upgrade this perk?", "Warning", "Yes", function()
                net.Start("Gangs.PurchaseUpgrade")
                net.WriteString(id)
                net.WriteBool(false)
                net.SendToServer()
                gang.Money = gang.Money - price
                self.Level = self.Level + 1
                gang.Shop.Upgrades[id] = (gang.Shop.Upgrades[id] or 0) + 1
                if (self.Data.onUpgrade) then
                    self.Data.onUpgrade(gang)
                end
            end, "No")
        else
            Derma_Message("Insufficient funds in gang account, deposit some money and try again!", "Get dosh", "Ok")
        end
    end
end

function UPG:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, (self:IsHovered() or self:IsChildHovered()) and Color(36, 36, 36) or Color(26, 26, 26))

    if (self.Data) then
        draw.RoundedBox(28, 16, 16, 56, 56, Color(46, 46, 46))
        surface.SetDrawColor(color_white)
        surface.SetMaterial(self.Icon)
        surface.DrawTexturedRect(23, 23, 42, 42)
        if (self.Level >= self.Data.Levels) then
            draw.SimpleText("Max " .. self.Data.Name .. " Reached", "XeninUI.Navbar.Button", 84, 16, color_white)
        else
            if (self.Data.Levels == 1) then
                draw.SimpleText(self.Data.Name, "XeninUI.Navbar.Button", 84, 16, color_white)
            else
                draw.SimpleText("+" .. self.Data.Data[self.Level + 1] .. " " .. self.Data.Name, "XeninUI.Navbar.Button", 84, 16, color_white)
            end
        end
        local tx, _ = draw.SimpleText(self.Level .. "/" .. self.Data.Levels, "XeninUI.Query.Text", 84, 52, Color(255, 255, 255, 100))
        surface.SetDrawColor(6, 6, 6)
        surface.DrawRect(84 + tx + 8, 52, w - tx - 84 - self.pay:GetWide() - 24, 16)
        surface.SetDrawColor(200, 200, 200)
        surface.DrawRect(84 + tx + 8, 52, (w - tx - 84 - self.pay:GetWide() - 24) * (self.Level / self.Data.Levels), 16)
    end
end

vgui.Register("Gangs.Upgrade", UPG, "DPanel")