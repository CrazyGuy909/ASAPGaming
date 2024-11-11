local PANEL = {}

PANEL.Editing = false
PANEL.Display = "?"

function util.NiceKey(code)
    if (code < 36) then
        if (code <= 10) then
            return string.char(code + 48)
        else
            return string.char(code + 64)
        end
    elseif (code >= 92 && code <= 103) then
        return "F" .. string.char(code - 43)
    end
    local conts = table.KeysFromValue(_G, code)
    for k,v in pairs(conts) do
        if (string.StartWith(v, "KEY")) then
            return v, true
        end
    end
end

function PANEL:Init()

    self:Dock(TOP)
    self:SetTall(36)
    
    self.Input = vgui.Create("DButton", self)
    self.Input:Dock(RIGHT)
    self.Input:SetWide(96)
    self.Input:SetText("")
    self.Input:DockMargin(0, 6, 12, 6)

    self.Input.Paint = function(s,w,h)
        
        if (self.IsError) then
            surface.SetDrawColor(255, 0, 0, 50)
        else
            surface.SetDrawColor(255, 255, 255, 50)
        end
        
        surface.DrawOutlinedRect(0, 0, w, h)

        if (self.Editing) then
            draw.SimpleText("?", "aMenuJob", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            for key=1, 159 do
                if (input.IsKeyDown(key)) then
                    local shouldChange = self.Bind.key != key
                    keybinds.setBind(self.Bind.id, key, true)
                    
                    if (shouldChange) then
                        keybinds.setBind(self.Bind.id, key)
                    end
                    keybinds.saveBinds()
                    self.Editing = false
                    break
                end
            end
        elseif(self.Bind) then
            local niceKey, big = "",""
            if (self.Bind.key) then
                niceKey, big = input.GetKeyName(self.Bind.key)
            else
                niceKey = "..."
            end
            draw.SimpleText(niceKey, big && "aMenu10" || "aMenuJob", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    self.Input.DoClick = function()
        self.Editing = true
    end
end

function PANEL:Paint(w,h)
    if (self.Bind) then
        local tx,_ = draw.SimpleText(self.Bind.help, "aMenu22", 12, h / 2, Color( 255, 255, 255, 75 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(255, 255, 255, 5)
        surface.DrawRect(12, h - 1, w - 24, 1)

        if (self.IsError) then
            draw.SimpleText("key already in use", "aMenu14", tx + 24, h / 2 - 4, Color(255,0,0,100))
        end
    end
end

vgui.Register("ASAP.BindKey", PANEL, "DPanel")