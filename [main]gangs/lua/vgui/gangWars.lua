local PANEL = {}
PANEL.Active = true
PANEL.Credits = false

local orange = Color(255, 126, 0)
local blue = Color(0, 180, 255)
function PANEL:Init()
    INFO_GANG = self
    self.Smoll = false
    self.GangA = "TEST"
    self.GangB = "SEEKS"
    self.Result = false
    self.Active = true
    self.Credits = false
    self:SetAlpha(0)
    self:SetSize(512 * .5, 256 * .5)
    self:SetPos(ScrW() / 2 - 128, 0)

    self:AlphaTo(255, .5, 0)
    self:SizeTo(512, 256, .5, 0, .5)
    self:MoveTo(ScrW() / 2 - 256, 32, .5, 0, .5, function()
        local size = .4
        self:SizeTo(512 * size, 256 * size, .5, 3, 1)
        timer.Simple(3, function()
            if not IsValid(self) then return end
            self.Smoll = true
            self:AlphaTo(100, .5, 0)
            surface.PlaySound("rm_c4/toss.wav")
        end)
        self:MoveTo(ScrW() - 512 * size, 0, .5, 3, 1)
    end)
    
    surface.PlaySound("botw/bomb/pickup.wav")
end

local lightWhite = Color(255, 255, 255, 50)
function PANEL:CreateCard(v, pnl, x, clr)
    local icon = vgui.Create("DPanel", pnl)
    icon:SetSize(36, 44)
    icon:SetPos(x, 0)
    icon:SetMouseInputEnabled(false)

    icon.avatar = vgui.Create("AvatarImage", icon)
    icon.avatar:SetPlayer(v, 32)
    icon.avatar:SetSize(32, 32)
    icon.avatar:SetPos(2, 2)
    icon.Paint = function(s, w, h)
        if not IsValid(v) then
            s:Remove()
            return
        end

        surface.SetDrawColor(lightWhite)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(clr)
        surface.DrawOutlinedRect(0, 0, w, h)

        surface.SetDrawColor(color_black)
        surface.DrawRect(2, h - 5, w - 4, 4)

        surface.SetDrawColor(clr)
        surface.DrawRect(2, h - 5, (w - 4) * math.Clamp(v:Health() / v:GetMaxHealth(), 0, 1), 4)
    end

    icon.valid = true
    icon.PaintOver = function(s, w, h)
        if s.valid then return end

        if (not v:Alive()) then
            s.valid = false
        end

        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(0, 0, w, h)
    end
end

function PANEL:SetupInfo(a, b)
    
    self.Attackers = asapgangs.GetMembers(a)
    self.Defenders = asapgangs.GetMembers(b)
    local totalWide = (#self.Attackers + #self.Defenders) * 38 + 32
    local x = ScrW() / 2 - totalWide / 2 + 8

    self.GangA = a
    self.GangB = b

    local pnl = vgui.Create("Panel")
    pnl:SetSize(ScrW(), 72)
    pnl:SetMouseInputEnabled(false)
    pnl:SetPos(0, 0)
    pnl:SetAlpha(0)
    pnl:AlphaTo(255, .25, .5)
    pnl:MoveTo(0, 48, .5, .5)
    pnl.Paint = function(s, w, h)
        draw.SimpleTextOutlined("ATT", XeninUI:Font(28), w / 2 - totalWide / 2, 4, orange, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 1, color_black)
        draw.SimpleTextOutlined("DEF", XeninUI:Font(28), w / 2 + totalWide / 2 + 8, 4, blue, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
        draw.SimpleTextOutlined("vs", XeninUI:Font(28), w / 2 + 4, 4, color_white, 1, TEXT_ALIGN_TOP, 1, color_black)
    end

    self.HUDPanel = pnl

    for _, v in pairs(self.Attackers) do
        self:CreateCard(v, pnl, x, orange)
        x = x + 36
    end
    x = x + 30
    for _, v in pairs(self.Defenders) do
        self:CreateCard(v, pnl, x, blue)
        x = x + 36
    end
end

function PANEL:OnRemove()
    if IsValid(self.HUDPanel) then
        self.HUDPanel:Remove()
    end
end

local icon = surface.GetTextureID("ui/gangs/computer/gangswar")

function PANEL:Paint(w, h)
    surface.SetDrawColor(color_white)
    surface.SetTexture(icon)
    surface.DrawTexturedRectRotated(w / 2, h / 2, w, h, math.cos(RealTime() * 2 ) * 4)

    if (self.Credits) then
        draw.SimpleText(self.TextResult, "Gangs.Medium", w / 2, h - 38, self.Result and orange or blue, 1)
        return
    end
    if not self.Smoll then
        draw.SimpleTextOutlined(self.GangA, "Gangs.Medium", w / 2 - 28, h - 32, orange, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP, 2, color_black)
        draw.SimpleTextOutlined("vs", "Gangs.Medium", w / 2, h - 38, Color(255, 255, 255, 150), 1, TEXT_ALIGN_TOP, 2, color_black)
        draw.SimpleTextOutlined(self.GangB, "Gangs.Medium", w / 2 + 28, h - 32, Color(0, 180, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, color_black)
    end
    if (self.Active and not LocalPlayer().RaidActive) then
        self.Active = false
        self:MoveTo(ScrW() - 128, -64, .5, 0, 1, function()
            self:Remove()
        end)
    end
end

function PANEL:Notify(won)
    self.Credits = true
    self.Result = won
    self.Smoll = false
    self.TextResult = (won and "Raiders" or "Defenders") .. " has won the raid."
    self:SizeTo(512, 256, .5, 0, -1)
    self:MoveTo(ScrW() / 2 - 256, 16, .5, 0, -1, function()
        local size = .1
        self:AlphaTo(255, .5)
        if IsValid(self.HUDPanel) then
            self.HUDPanel:AlphaTo(255, .4, 0, function()
                self.HUDPanel:Remove()
            end)
        end
        self:SizeTo(512 * size, 256 * size, .5, 3, 1)
        self:MoveTo(ScrW() / 2 - 256 * size, -256, .5, 3, 1, function()
            if IsValid(self) then
                self:Remove()
            end
        end)
    end)
end

vgui.Register("Gangs.WarsPanel", PANEL, "Panel")

net.Receive("Gangs.SendResult", function()
    local attWon = net.ReadBool()
    if IsValid(INFO_GANG) then
        INFO_GANG:Notify(attWon)
    end
end)

if IsValid(INFO_GANG) then
    INFO_GANG:Remove()
end
