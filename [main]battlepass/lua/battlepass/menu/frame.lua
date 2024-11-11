BATTLEPASS:CreateFont("BATTLEPASS_HeaderTitle", 24)
BATTLEPASS:CreateFont("BATTLEPASS_SeasonTitle", 18)
local PANEL = {}
local matAdmin = Material("battlepass/admin.png", "noclamp smooth")
local matFilled = Material("battlepass/admin_filled.png", "smooth")

function PANEL:Init()
    local ply = LocalPlayer()
    BATTLEPASS:SetupPass(ply)
    self:SetSize(ScrW(), ScrH())
    self:DockPadding(self:GetWide() * .01, self:GetTall() * .01, self:GetWide() * .01, self:GetTall() * .01)
    self.Settings = vgui.Create("Panel", self.Header)
    self.Settings:Dock(TOP)

    if not BATTLEPASS.Config then
        include("battlepass/shared/pass.lua")
    end

    self.Navbar = self:Add("BATTLEPASS_NavbarDouble")
    self.Navbar:Dock(FILL)

    self.Navbar.Top.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, BATTLEPASS:GetTheme("Background.Accent"))
    end

    self.Navbar.Side.Paint = function(pnl, w, h)
        draw.RoundedBoxEx(6, 0, 0, w, h, BATTLEPASS:GetTheme("Primary"), false, false, true, false)
    end

    self.Navbar:AddTopButton("Battle Pass")
    self.Navbar:AddTopButton("Challenges")
    self.Navbar:AddTopButton("Help")

    self.Navbar:AddPanel("BATTLEPASS_Pass", 0, 0, function(pnl)
        pnl:SetOwned(ply.BattlePass.Owned.owned)
        pnl:SetTitle(BATTLEPASS.Pass.name)
        pnl:Reload()
    end)

    self.Navbar:AddPanel("BATTLEPASS_Challenges_Tab", 1, 0, function(pnl)
        pnl:Reload()
    end)

    self.Navbar:AddPanel("BATTLEPASS.Help", 2, 0, function(pnl) end)
    self.Navbar.Side:SetVisible(false)
    BATTLEPASS_MENU = self

    if camClaimBPReward then
        camClaimBPReward = nil
        RunConsoleCommand("bp_notice")
    end
end

function PANEL:CreateRewardPanel(rewards)
    local pnl = vgui.Create("DPanel")
    pnl:SetSize(ScrW(), ScrH())
    pnl:SetAlpha(255)
    pnl:SetDrawOnTop(true)
    pnl.Start = SysTime()

    pnl:AlphaTo(255, .5, 0, function()
        pnl:AlphaTo(0, .5, 2.5, function()
            if IsValid(pnl) then
                pnl:Remove()
            end
        end)
    end)

    pnl.Paint = function(s, w, h)
        Derma_DrawBackgroundBlur(s, s.Start)
        draw.SimpleText("A small aid for you!", XeninUI:Font(64), w / 2, h * .25, Color(220, 140, 14), 1, 1)
    end

    pnl.Body = vgui.Create("Panel", pnl)
    local mx, my = ScrW() * .1, ScrH() * .1
    pnl.Body:Dock(FILL)
    pnl.Body:DockMargin(mx, my, mx, my)
    local rowSize = ((ScrW() * .8) / #rewards) - 8
    local h = ScrH()

    for k, v in pairs(rewards) do
        local item = vgui.Create("DPanel", pnl.Body)
        item:Dock(LEFT)
        item:SetWide(rowSize)
        item:DockMargin(4, 0, 4, 0)
        local iconPreview = nil
        local itemDef = BU3.Items.Items[v]

        if not itemDef then
            item:Remove()

            return
        end

        if itemDef.iconIsModel then
            iconPreview = BU3.UI.Elements.ModelView(itemDef.iconID, itemDef.zoom, item)
        else
            iconPreview = BU3.UI.Elements.IconView(itemDef.iconID, itemDef.color, item, false)
        end

        local max = math.min(rowSize, 256, ScrH() / 2)

        item.Paint = function(s, w, h)
            draw.SimpleText(itemDef.name, XeninUI:Font(48), w / 2, h / 2 + max / 2 + 42, color_white, 1, 1)
        end

        iconPreview:SetParent(item)
        iconPreview:SetSize(max, max)
        iconPreview:SetPos((rowSize - max) / 2, (h - max) / 2 - 64)
        iconPreview:SetAlpha(0)
        iconPreview:AlphaTo(255, .3, .1 * k)
        iconPreview:MoveTo((rowSize - max) / 2, (h - max) / 2 - 128, .3, .1 * k)
    end
end

function PANEL:OnKeyCodePressed(key)
    if (key == KEY_F7) then
        bpcooldown = CurTime() + .5
        self:Close()
    end
end

function PANEL:OnRemove()
    BATTLEPASS_MENU = nil
end

function PANEL:Close()
    self:Remove()
end

function PANEL:PerformLayout(w, h)
    self.BaseClass.PerformLayout(self, w, h)
    self.Settings:SetTall(64)
end

vgui.Register("BATTLEPASS_Menu", PANEL, "BATTLEPASS_Frame")

if IsValid(BP_PANEL) then
    BP_PANEL:Remove()
end

concommand.Add("battlepass", function()
    if bpcooldown and bpcooldown > CurTime() then return end
    local theme = BATTLEPASS.Theme
    local w, h = ScrW(), ScrH()
    local frame = vgui.Create("BATTLEPASS_Menu")
    frame:SetSize(w, h)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle(BATTLEPASS.Config.SeasonTitle)
    frame:SetDefaultWidth(w)
    frame:SetDefaultHeight(h)
    frame:SetHeaderHeight(0)
    frame:SetPrimaryColorVariant(BATTLEPASS:GetTheme("Primary.Variant"))
    frame:SetPrimaryColor(BATTLEPASS:GetTheme("Primary"))
    frame._start = SysTime()

    frame.Paint = function(s, w, h)
        Derma_DrawBackgroundBlur(s, s._start)
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(0, 0, w, h)
    end

    BP_PANEL = frame
end)