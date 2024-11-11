local PAGE = {}

--This is called when the page is called to load
function PAGE:Load(contentFrame)

	self.mirrorPanel = vgui.Create("DPanel", contentFrame)
	self.mirrorPanel:Dock(FILL)
	self.mirrorPanel.Paint = function() end --Clear background
	self.mirrorPanel.PerformLayout = function(s, w, h)
		self.textPanel:SetSize(w, 75)
		self.textPanel:SetPos(0, 4)

		self.invValue:SetSize(w / 2 - 32, 96)
		self.invValue:SetPos(16, 80)

		self.otherVal:SetSize(w / 2 - 32, 96)
		self.otherVal:SetPos(16 + w / 2 - 16, 80)

		self.numOfItems:SetSize(w / 2 - 32, 96)
		self.numOfItems:SetPos(16, 80 + 112)

		self.itemsSold:SetSize(w / 2 - 32, 96)
		self.itemsSold:SetPos(16 + w / 2 - 16, 80 + 112)

		self.textPanel2:SetSize(w - 32, 75)
		self.textPanel2:SetPos(16, 80 + 204)

		self.panel:SetTall(h - 80 - 112 - 176)
	end

	local textPanel = vgui.Create("DPanel", self.mirrorPanel)
	textPanel.Paint = function(s , w , h)
		draw.SimpleText("ASAP Unboxing", BU3.UI.Fonts["large_bold"], w/2, h/2, Color(255,255,255,175),1 ,1)
		surface.SetDrawColor(255, 255, 255, 50)
		surface.DrawRect(12, h - 10, w - 32, 1)
	end

	self.textPanel = textPanel

	--Now do all the text info
	local invValue = BU3.UI.Elements.CreateInfoPanel(BU3.Inventory.ItemCount(), "Number Of Items", self.mirrorPanel)
	self.invValue = invValue

	local stats = BU3.Stats

	--Now do all the text info
	local val = "?"
	if stats["gift"] ~= nil then
		val = stats["gift"]
	end
	local otherVal = BU3.UI.Elements.CreateInfoPanel(val, "Numbers Of Items Traded", self.mirrorPanel)
	self.otherVal = otherVal

	--Now do all the text info
	local val = "?"
	if stats["case"] ~= nil then
		val = stats["case"]
	end
	local numOfItems = BU3.UI.Elements.CreateInfoPanel(val, "Opened Cases", self.mirrorPanel)
	self.numOfItems = numOfItems

	--Now do all the text info
		local val = "?"
	if stats["purchase"] ~= nil then
		val = stats["purchase"]
	end
	local itemsSold = BU3.UI.Elements.CreateInfoPanel(val, "Items Purchased", self.mirrorPanel)
	self.itemsSold = itemsSold

	local textPanel = vgui.Create("DPanel", self.mirrorPanel)
	textPanel:SetSize(400, 75)
	textPanel:SetPos(25, 85 + 155  +120)
	textPanel.Paint = function(s , w , h)
		draw.SimpleText("Activity", BU3.UI.Fonts["large_bold"], w / 2, h/2, Color(255,255,255,175),1 ,1)
	end

	self.textPanel2 = textPanel

	local panel = vgui.Create("XeninUI.ScrollPanel", self.mirrorPanel)
	panel:Dock(BOTTOM)
	panel:DockMargin(16, 0, 32, 16)
	panel:GetCanvas():DockPadding(8, 8, 8, 8)
	panel.Paint = function(s, w, h)
		draw.RoundedBox(8, 0, 0, w, h, Color(36, 36, 36))
	end
	for i = 1 , #BU3.UI.EventHistory do
		local text = BU3.UI.EventHistory[i]
		if text ~= nil then
			local label = Label(text, panel)
			label:SetFont("aMenu18")
			label:SetTall(32)
			label:Dock(TOP)
			label:DockMargin(4, 0, 4, 8)
		end
	end
	self.panel = panel

end

--This is called when the page should unload
function PAGE:Unload(contentFrame, direction)
	self.mirrorPanel:Remove() --Remove all the UI we added to the content frame
end
--385 130
--This can be called by anything to pass a message to the page
function PAGE:Message(message, data)

end

--Register the page
BU3.UI.RegisterPage("stats", PAGE)