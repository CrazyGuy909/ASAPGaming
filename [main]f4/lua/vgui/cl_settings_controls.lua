local CHECK = {}

function CHECK:Init()
    self:Dock(TOP)
    self:SetTall(36)
    self:DockMargin(0,0,0,0)
    
    self.Input = vgui.Create("DCheckBox", self)
    self.Input:Dock(RIGHT)
    self.Input:SetWide(28)
    self.Input:SetText("")
    self.Input:DockMargin(0, 4, 12, 4)

    self.Input.Paint = function(s,w,h)
        
        surface.SetDrawColor(255, 255, 255, 50)
        surface.DrawOutlinedRect(0, 0, w, h)

        draw.SimpleText(s:GetChecked() && "✖" or "", "aMenuJob", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.Input.DoClick = function(s)
        s:SetChecked(!s:GetChecked())
        s:OnChange(s:GetChecked())
    end

    self.Input.OnChange = function(s,val)
        if (self.cvar) then
            RunConsoleCommand(self.cvar, val && 1 or 0)
        end

        if (self.perform) then
            self.perform(val)
        end
    end
end

function CHECK:SetChecked(b)
    self.Input:SetChecked(b)
end

function CHECK:GetChecked()
    return self.Input:GetChecked()
end

function CHECK:Paint(w,h)

    draw.SimpleText(self.name, "aMenu22", 12, h / 2, Color( 255, 255, 255, 75 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    surface.SetDrawColor(255, 255, 255, 5)
    surface.DrawRect(12, h - 1, w - 24, 1)
end

vgui.Register("ASAP.Settings.Checkbox", CHECK, "DPanel")

local BUTTON = {}

function BUTTON:Init()

    self:Dock(TOP)
    self:SetTall(36)
    self:DockMargin(2,2,0,2)
    
    self.Button = vgui.Create("DButton", self)
    self.Button:Dock(RIGHT)
    self.Button:SetWide(96)
    self.Button:SetText("")
    self.Button:DockMargin(0, 4, 12, 4)

    self.Button.Paint = function(s,w,h)
        
        surface.SetDrawColor(255, 255, 255, 50)
        surface.DrawOutlinedRect(0, 0, w, h)

        draw.SimpleText(self.Option or "...", "aMenuJob", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.Button.DoClick = function(s)
        self:perform()
    end

end

function BUTTON:DoClick()
end

function BUTTON:Paint(w, h)
    draw.SimpleText(self.name, "aMenu22", 12, h / 2, Color( 255, 255, 255, 75 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    surface.SetDrawColor(255, 255, 255, 5)
    surface.DrawRect(12, h - 1, w - 24, 1)
end

vgui.Register("ASAP.Settings.Button", BUTTON, "DPanel")

local SLIDER = {}

function SLIDER:Init()
    self:Dock(TOP)
    self:SetTall(36)
    self:DockMargin(0,0,0,0)
    
    self.Input = vgui.Create("DNumSlider", self)

    self.Input.TextArea:Dock(LEFT)
    self.Input.TextArea:SetFont("aMenu18")
    self.Input.TextArea.Paint = function(s,w,h)
        surface.SetDrawColor(255, 255, 255, 50)
        surface.DrawOutlinedRect(0, 0, w, h)
        s:DrawTextEntryText(Color(255, 255, 255, 75), Color(255, 200, 75), color_white)
    end

    self.Input:Dock(RIGHT)
    self.Input:SetWide(172)
    self.Input:SetText("")
    self.Input:DockMargin(0, 4, 12, 4)

    self.Input.Slider.Paint = function(s,w,h)
        surface.SetDrawColor(255, 255, 255, 50)
        surface.DrawRect(4, h / 2 - 2, w - 8, 2)

        surface.DrawRect(w - 3, h / 2 + 2, 2, 8)
        surface.DrawRect(1, h / 2 - 10, 2, 8)

        surface.DrawRect(w - 3, h / 2 - 10, 2, 8)
        surface.DrawRect(1, h / 2 + 0, 2, 8)

        surface.DrawRect(w / 2 - 1, h / 2 - 10, 2, 6)
        surface.DrawRect(w / 2 - 1, h / 2 + 2, 2, 6)
    end

    self.Input.OnChange = function(s,val)
        s.TextArea:SetText(math.Round(val, 1))
        if (self.cvar) then
            RunConsoleCommand(self.cvar, val && 1 or 0)
        end

        if (self.perform) then
            self.perform(val)
        end
    end

    self.Input.Slider.Knob.Paint = function(s, w, h)
        derma.SkinHook( "Paint", "SliderKnob", s, w, h )
    end
    self.Input.Slider:DockMargin(8,0,0,0)

    self.Input.Label:SetVisible(false)
    self.Input:SetDecimals(1)

    
end

function SLIDER:Paint(w, h)
    draw.SimpleText(self.name, "aMenu22", 12, h / 2, Color( 255, 255, 255, 75 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    surface.SetDrawColor(255, 255, 255, 5)
    surface.DrawRect(12, h - 1, w - 24, 1)
end

vgui.Register("ASAP.Settings.Slider", SLIDER, "DPanel")

local COLOR = {}
function COLOR:Init()
    self.Button.Paint = function(s, w, h)
        if (self.cvar) then
            surface.SetDrawColor(255, 255, 255, 50)
            surface.DrawOutlinedRect(0, 0, w, h)
            surface.SetDrawColor(GetConVar(self.cvar.."_r"):GetInt(), GetConVar(self.cvar.."_g"):GetInt(), GetConVar(self.cvar.."_b"):GetInt())
            surface.DrawRect(4, 4, w - 8, h - 8)
        end
    end

    self.Button.DoClick = function()
        local panel = vgui.Create("XeninUI.Frame")
        panel:MakePopup()
        panel:SetSize(256,256)
        panel:SetTitle("Select a color")
        panel:SetPos(gui.MouseX() - 256, gui.MouseY() - 256)

        panel.Select = vgui.Create("DButton", panel)
        panel.Select:Dock(BOTTOM)
        panel.Select:SetTall(28)
        panel.Select:SetText("Select")
        panel.Select:SetFont("aMenu22")
        panel.Select:SetTextColor(color_white)
        panel.Select:DockMargin(4, 0, 4, 4)
        panel.Select.Paint = function(s,w,h)
            draw.RoundedBox(8, 0, 0, w, h, s:IsHovered() && Color(26,26,26) or Color(16,16,16))
        end

        panel.Select.DoClick = function()
            self:OnSelect(panel.Cube:GetColor())
            panel:Remove()
        end

        panel.Cube = vgui.Create("DColorMixer", panel)
        panel.Cube:SetAlphaBar(false)
        panel.Cube:SetWangs(false)
        panel.Cube:SetPalette(false)
        panel.Cube:Dock(FILL)
        panel.Cube:DockMargin(4, 4, 4, 4)

        panel.Cube:SetColor(Color(GetConVar(self.cvar.."_r"):GetInt(), GetConVar(self.cvar.."_g"):GetInt(), GetConVar(self.cvar.."_b"):GetInt()))
    end
end

function COLOR:OnSelect(val)
    if (self.cvar) then
        RunConsoleCommand(self.cvar.."_r", val.r)
        RunConsoleCommand(self.cvar.."_g", val.g)
        RunConsoleCommand(self.cvar.."_b", val.b)
    end
end

vgui.Register("ASAP.Settings.Color", COLOR, "ASAP.Settings.Button")

local DROP = {}
DROP.Selected = 1
DROP.Options = {}
function DROP:Init()

    self:Dock(TOP)
    self:SetTall(36)
    self:DockMargin(2,2,0,2)
    
    self.Button = vgui.Create("DButton", self)
    self.Button:Dock(RIGHT)
    self.Button:SetWide(96)
    self.Button:SetText("")
    self.Button:DockMargin(0, 4, 12, 4)

    self.Button:SetWide(200)
    self.Button.Paint = function(s, w, h)
        if (self.cvar) then
            local tx= 0
            if (self.Options[self.Selected]) then
                tx,_ = draw.SimpleText(self.Options[self.Selected], "aMenu18", w - 4, h / 2, Color( 255, 255, 255, 100 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end

            surface.SetDrawColor(255, 200, 75, s:IsHovered() && 255 or 100)
            surface.DrawRect(w - tx - 4, h - 2, tx, 2)
        end
    end

    self.Button.DoClick = function()
        local menu = DermaMenu()
        for k,v in pairs(self.Options) do
            menu:AddOption(v, function()
                self.Selected = k
                RunConsoleCommand(self.cvar, k)
            end)
        end
        menu:AddOption("Cancel")
        menu:Open()
        menu:MakePopup()
    end
end

function DROP:Paint(w, h)
    draw.SimpleText(self.name, "aMenu22", 12, h / 2, Color( 255, 255, 255, 75 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    surface.SetDrawColor(255, 255, 255, 5)
    surface.DrawRect(12, h - 1, w - 24, 1)
end

vgui.Register("ASAP.Settings.Dropdown", DROP, "DPanel")
