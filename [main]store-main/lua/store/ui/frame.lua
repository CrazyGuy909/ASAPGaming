local PANEL = {}
Store:CreateFont("Store.Credits", 24)

function PANEL:Init()
    self.topNavbar = vgui.Create("Panel", self)
    self.topNavbar:Dock(TOP)
    self.playerPanel = vgui.Create("DButton", self.topNavbar)
    self.playerPanel:Dock(RIGHT)
    self.playerPanel:SetText("")

    self.playerPanel.Paint = function(pnl, w, h)
        surface.SetDrawColor(XeninUI.Theme.Navbar)
        surface.DrawRect(0, 0, w, h)
    end

    self.playerPanel.DoClick = function(pnl)
        gui.OpenURL(Store.StoreURL)
    end

    self.playerPanel.avatar = vgui.Create("XeninUI.Avatar", self.playerPanel)
    self.playerPanel.avatar:SetPlayer(LocalPlayer(), 64)
    self.playerPanel.avatar:SetVertices(90)
    self.playerPanel.avatar:SetMouseInputEnabled(false)
    self.playerPanel.credits = vgui.Create("DLabel", self.playerPanel)
    self.playerPanel.credits:SetText("Tokens: " .. LocalPlayer():GetStoreCredits())
    self.playerPanel.credits:SetFont("Store.Credits")
    self.playerPanel.credits:SetTextColor(color_white)
    if (LocalPlayer()._oldCredits and LocalPlayer()._oldCredits > 0) then
        self.playerPanel:SetTooltip("You cannot trade old tokens (" .. LocalPlayer()._oldCredits .. ")")
    end

    hook.Add("Store.CreditsChanged", "Store.Frame", function(ply, amt)
        self.playerPanel.credits:SetText("Tokens: " .. amt)
        if (LocalPlayer()._oldCredits and LocalPlayer()._oldCredits > 0) then
            self.playerPanel:SetTooltip("You cannot trade old tokens (" .. LocalPlayer()._oldCredits .. ")")
        end
        self:InvalidateLayout()
    end)

    self.navbar = vgui.Create("XeninUI.Navbar", self.topNavbar)
    self.navbar:Dock(FILL)
    self.navbar:SetBody(self)
    self.navbar:AddTab("PACKAGES", "Store.Packages")
    self.navbar:AddTab("WEAPONS", "Store.Weapons")
    self.navbar:AddTab("PRINTERS", "Printers.Main")
    --self.navbar:AddTab("ACCESSORIES", "Store.Misc")
    --self.navbar:AddTab("MISCELLANEOUS", "Store.Misc")
    self.navbar:SetActive(cookie.GetString("store_lastPage", "PACKAGES"))

    self.navbar.Gift = vgui.Create("XeninUI.Button", self.navbar)
    self.navbar.Gift:Dock(RIGHT)
    self.navbar.Gift:SetText("Send Tokens")
    self.navbar.Gift:SetWide(142)
    self.navbar.Gift:DockMargin(16, 12, 8, 12)
    self.navbar.Gift.DoClick = function()
        vgui.Create("XeninUI.Trade")
    end

    self.navbar.OnTabSelected = function(s, name)
        cookie.Set("store_lastPage", name)
    end
end

function PANEL:OnRemove()
    hook.Remove("Store.CreditsChanged", "Store.Frame")
end

function PANEL:PerformLayout(w, h)
    self.BaseClass.PerformLayout(self, w, h)
    self.topNavbar:SetTall(56)
    self.playerPanel.credits:SizeToContents()
    surface.SetFont(self.playerPanel.credits:GetFont())
    local tw = surface.GetTextSize(self.playerPanel.credits:GetText())
    self.playerPanel:SetWide(56 + 12 + tw)
    self.playerPanel.avatar:SetSize(40, 40)
    self.playerPanel.avatar:SetPos(self.playerPanel:GetWide() - self.playerPanel.avatar:GetWide() - 8, self.playerPanel:GetTall() - self.playerPanel.avatar:GetTall() - 8)
    self.playerPanel.credits:SetPos(self.playerPanel.avatar.x - 16 - tw)
    self.playerPanel.credits:CenterVertical()
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(16, 16, 16)
    draw.RoundedBoxEx(16, 0, 0, w, h, Color(26, 26, 26), false, false, false, true)
end

local DPanel = table.Copy(PANEL)
vgui.Register("Store.Frame", PANEL, "XeninUI.Frame")
vgui.Register("Store.Frame_F4", DPanel, "DPanel")

hook.Add("OnPopulateF4Categories", "StoreFrame", function(pnl)
    pnl.StorePanel = vgui.Create("Store.Frame_F4", pnl)
    pnl:AddCat("Store", Material("asapf4/donate.png"), pnl.StorePanel, {Color(125, 15, 50), Color(190, 27, 110)})
    pnl.StorePanel:Dock(FILL)
end)