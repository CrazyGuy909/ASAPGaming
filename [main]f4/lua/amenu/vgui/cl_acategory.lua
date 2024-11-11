------------------ Categories
local PANEL = {}

function PANEL:Init()

	self.Name 		= ""
	self.Children 	= {}
	self.Col 		= aMenu.Color
	self:Dock(TOP)

end

function PANEL:Paint(w, h)

	draw.RoundedBox(4, 5, 5, self:GetParent():GetWide()-7, h-5, Color(31, 31, 31, 255))
	draw.SimpleText(self.Name, "aMenuTitle", 10, 5, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	draw.RoundedBox(2, 10, 37, self:GetParent():GetWide()-20, 2, self.Col)

end

function PANEL:GetName()
	return self.Name
end

function PANEL:SetName(str)
	self.Name = str
end

function PANEL:AddChild(child)

	if not ValidPanel(child) then return end
	child:SetParent(self)
	table.insert(self.Children, child)

end

function PANEL:PerformLayout()

	local wide = (self:GetParent():GetWide()-15)
	local BarW, BarH = (wide/2)-6, 70
	local countx, county = 10, 45

	for k, v in pairs(self.Children) do --I guess it's kinda like text-wrapping but with vgui right?
		if countx >= wide then 
			countx = 10
			county = county + BarH + 5
		end

		v:SetPos(countx, county)
		v:SetSize(BarW, BarH)

		countx = countx + BarW + 5
	end
	self:SizeToChildren(false, true)
	self:SetTall(self:GetTall() + 5)
end

vgui.Register("aMenuCategory", PANEL, "DPanel")
