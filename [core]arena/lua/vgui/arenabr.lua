local PANEL = {}
PANEL.IsFollowing = false
PANEL.HasSelect = false
function PANEL:Init()
    if IsValid(ARENA_RESP) then
        ARENA_RESP:Remove()
    end
    ARENA_RESP = self
    self:SetSize(ScrW(), ScrH())
    self:SetTitle("")
    self:Center()
    self:SetDraggable(false)
    self:ShowCloseButton(false)
    self._start = SysTime()
    self.IsFollowing = false
    self.HasSelect = false

    self.Continue = vgui.Create("XeninUI.Button", self)
    self.Continue:SetSize(256, 48)
    self.Continue:SetText("Spectate Match")
    self.Continue:Center()
    self.Continue.DoClick = function()
        net.Start("ASAP.Arena:SpectateBattleroyale")
        net.WriteBool(true)
        net.WriteEntity(LocalPlayer())
        net.SendToServer()
        self.Continue:Remove()
        self.Quit:Remove()
        self:InvalidateLayout(true)
        self:CreateVisor()
    end
    local x, y = self.Continue:GetPos()

    self.Quit = vgui.Create("XeninUI.Button", self)
    self.Quit:SetSize(256, 48)
    self.Quit:SetText("Leave Arena")
    self.Quit:SetPos(x, y + 72)
    self.Quit.DoClick = function()
        net.Start("ASAP.Arena:SpectateBattleroyale")
        net.WriteBool(false)
        net.SendToServer()
        self:Remove()
    end

    self:MakePopup()
end

function PANEL:CreateVisor()
    self.PlayerList = vgui.Create("DPanel", self)
    self.PlayerList:Dock(RIGHT)
    self.PlayerList:SetWide(200)

    self.Info = vgui.Create("DPanel", self)
    self.Info:Dock(BOTTOM)
    self.Info:SetTall(128)
    self.Info:DockMargin(64, 0, 64, 32)

    self.Quit = vgui.Create("XeninUI.Button", self)
    self.Quit:SetSize(128, 32)
    self.Quit:SetText("Leave Arena")
    self.Quit:SetPos(64, 64)
    self.Quit.DoClick = function()
        net.Start("ASAP.Arena:SpectateBattleroyale")
        net.WriteBool(false)
        net.SendToServer()
        self:Remove()
    end
end

function PANEL:Paint(w, h)
    if (self.IsFollowing and IsValid(self.IsFollowing) and self.IsFollowing:InArena()) then
    else
        Derma_DrawBackgroundBlur(self, self._start)
        if (self.HasSelect) then
            draw.SimpleText("You're death! Wanna keep watching?", "Arena.Medium", w / 2, h / 2 - 48, color_white, 1, 1)
        end
    end
end

vgui.Register("Arena:BR_Spectate", PANEL, "DFrame")