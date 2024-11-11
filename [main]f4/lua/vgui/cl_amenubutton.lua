------------------- Custom DButton

local PANEL = {}



function PANEL:Init()

	self.Text 		= self:GetText()
	self.Col 		= aMenu.Color
	self.Disabled 	= false
	self:SetText("")

end

function PANEL:Paint(w, h)
	if self.Disabled then
		draw.RoundedBox(h, 0, 0, w, h, Color(46, 46, 46))
		draw.SimpleText(self.Text, "aMenu22", w/2, h/2, Color(120, 120, 120), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
	else
		draw.RoundedBox(h / 2, 0, 0, w, h, Color(36, 36, 36))
		if self:IsHovered() then
			draw.RoundedBox(h / 2, 0, 0, w, h, Color(255, 255, 255, 8))
		end
		draw.SimpleText(self.Text, "aMenu22", w/2, h/2, Color(255, 253, 252), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
	end
end

vgui.Register("aMenuButton", PANEL, "DButton")