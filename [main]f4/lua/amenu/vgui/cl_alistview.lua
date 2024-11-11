local PANEL = {}

function PANEL:PerformLayout()
	self.BaseClass.PerformLayout(self)
	for k, v in pairs(self.Columns) do
		if not v.Header.Text then
			v.Header.Text = v.Header:GetText()
			v.Header:SetText("")
		end
		v.Header.Paint = function(this, w, h)
			draw.RoundedBox(4, 2, 2, w - 4, h - 2, aMenu.Color)
			draw.SimpleText(v.Header.Text, "aMenu14", w / 2, h / 2, Color(255, 253, 252), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

	for k, v in pairs(self.Lines) do
		v:SetTall(v:GetTall() + 4)
		for i, e in pairs(v.Columns) do
			if not e.Text then
				e.Text = e:GetText()
				e:SetText("")
			end
			e.PaintOver = function(this, w, h)
				draw.SimpleText(e.Text, "aMenu14", 5, h / 2 -1, Color(255, 253, 252), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end
		end

		v.Paint = function(this, w, h)
			draw.RoundedBox(2, 2, 2, w - 4, h - 4, Color(51, 51, 51))
			if this:IsHovered() then
				draw.RoundedBox(2, 2, 2, w - 4, h - 4, aMenu.Color)
			end
		end
	end
end

function PANEL:Paint(w, h)
	draw.RoundedBox(4, 0, 0, w, h, Color(65, 65, 65))
end

vgui.Register("aListView", PANEL, "DListView")