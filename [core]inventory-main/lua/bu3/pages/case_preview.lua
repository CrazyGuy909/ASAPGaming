local PAGE = {}

--When set to true it will start spinning the tape
PAGE.startSpinning = false
PAGE.open = false
--This is called when the page is called to load
function PAGE:Load(contentFrame, caseID)
	contentFrame.NavBar:SelectButton("unknown") --Deselects all the buttons

	self.previousSoundTime = CurTime()
	self.previousSoundPosition = 0

	local case = BU3.Items.Items[caseID]
	self.startSpinning  = false
	self.open = true

	self.mirrorPanel = vgui.Create("DPanel", contentFrame)
	self.mirrorPanel:Dock(FILL)
	self.mirrorPanel.Paint = function(s,w,h)
	end --Clear background

	if case == nil or case.type ~= "case" then
		local textPanel = vgui.Create("DPanel", self.mirrorPanel)
		textPanel:Dock(TOP)
		textPanel:SetTall(75)
		textPanel:DockMargin(0, 4, 0, 0)
		textPanel.Paint = function(s , w , h)
			draw.SimpleText("ERROR : CASE INVALID", BU3.UI.Fonts["large_bold"], w/2, h/2, Color(255,255,255,20),1 ,1)
		end

		return		
	end

	local textPanel = vgui.Create("DPanel", self.mirrorPanel)
	textPanel:Dock(TOP)
	textPanel:SetTall(75)
	textPanel:DockMargin(0, 4, 0, 0)
	textPanel.Paint = function(s , w , h)
		draw.SimpleText("Preview: "..case.name, BU3.UI.Fonts["large_bold"], w/2, h/2, Color(255,255,255,20),1 ,1)
	end

	local scrollWindowPanel = vgui.Create("DPanel", self.mirrorPanel)
	scrollWindowPanel:Dock(TOP)
	scrollWindowPanel:SetTall(140)
	scrollWindowPanel:DockMargin(38, 16, 38, 0)
	scrollWindowPanel.Paint = function() end

	--Magic number is 72

	local tapePanel = vgui.Create("DPanel", scrollWindowPanel)
	tapePanel:Dock(TOP)
	tapePanel:SetTall(140)
	tapePanel.soundPlayed = false
	tapePanel.Paint = function(s, w, h) end
	contentFrame:InvalidateLayout(true)

	--Display all the items
	local itemPanels = {}
	local randomItems = BU3.Chances.GenerateList(case.itemID, 80)
	for i = 1, 80 do
		local xpos = 20 + ((i-1) * 132)
		local xsize = 130

		local borderColorRGB = BU3.Items.RarityToColor[1]


		local p = vgui.Create("DPanel", tapePanel)
		p:SetPos(xpos, 0)
		p:SetSize(xsize, 140)
		p.Paint = function(s, w, h)
			BU3.Items.RarityToFrame[1](0, 0, w, h)

			--Draw the item name
			local name = "Preview"
			if string.len(name) >= 15 then
				name = string.sub(name,1,12).."..." 
			end

			draw.SimpleText(name, BU3.UI.Fonts["small_reg"], w/2, 17, Color(200,200,200,255),1 ,1)
		end

		itemPanels[i] = p

		--Create the item preview
		local iconPreview = nil

		iconPreview = BU3.UI.Elements.IconView("help", Color(255,255,255, 100), p, false)
		iconPreview:Dock(BOTTOM)
		iconPreview:SetTall(96)
		iconPreview:DockMargin(17, 0, 17, 8)
		iconPreview.zoom = 0

		p.iconPreview = iconPreview
	end

	local gradientWindow = vgui.Create("DPanel", tapePanel)
	gradientWindow:Dock(FILL)
	gradientWindow.Paint = function(s, w, h)
		--Draw left size gradient
		surface.SetDrawColor(Color(0,255,255,255))
		surface.SetMaterial(BU3.UI.Materials.gradient)
		surface.DrawTexturedRectRotated(w - 98, h/2, 200, h, 180)
		surface.DrawTexturedRect(0,0,200,h)

	end

	local marker1 = vgui.Create("DPanel",self.mirrorPanel)
	marker1:SetPos(self.mirrorPanel:GetWide() / 2 - (22/2), 70 - 4)
	marker1:SetSize(22, 20)
	marker1.Paint = function(s , w , h)
		surface.SetDrawColor(Color(39, 121, 189))
		surface.SetMaterial(BU3.UI.Materials.marker)
		surface.DrawTexturedRectRotated(w/2,h/2,h, w, -90)
	end

	local marker2 = vgui.Create("DPanel",self.mirrorPanel)
	marker2:SetPos(self.mirrorPanel:GetWide() / 2 - (22/2), 250 - 4)
	marker2:SetSize(22, 20)
	marker2.Paint = function(s , w , h)
		surface.SetDrawColor(Color(39, 121, 189))
		surface.SetMaterial(BU3.UI.Materials.marker)
		surface.DrawTexturedRectRotated(w/2,h/2,h, w, 90)
	end

	--Unbox button
	--350
	
	local textPanel2 = vgui.Create("DPanel", self.mirrorPanel)
	textPanel2:Dock(TOP)
	textPanel2:SetTall(75)
	textPanel2:DockMargin(0, 12, 0, 0)
	textPanel2.Paint = function(s , w , h)
		draw.SimpleText("Items contained inside: "..case.name, BU3.UI.Fonts["med_bold"], w/2, h/2, Color(255,255,255,20),1 ,1)
	end

	local itemContainedPanel = vgui.Create("DScrollPanel", self.mirrorPanel)
	itemContainedPanel:Dock(FILL)
	itemContainedPanel:DockMargin(16, 16, 16, 16)

	local sbar = itemContainedPanel:GetVBar()

	function sbar:Paint( w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
	end
	function sbar.btnUp:Paint( w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 100, 0 ) )
	end
	function sbar.btnDown:Paint( w, h )
		--draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 100, 0 ) )
	end
	sbar.btnGrip:NoClipping(true)
	function sbar.btnGrip:Paint( w, h )
		draw.RoundedBox( 8, 4, -10, w - 4, h + 20, Color(39, 121, 189, 255) )
	end

	--Create the list of items
	--for k, v in pairs(items) do
	local x, y = 0, 0

	local items = table.Copy(case.items)
	local target = {}
	for k, v in pairs(items) do
		table.insert(target, k)
	end
	local wider = 0
	table.sort(target, function(a, b)
		return (BU3.Items.Items[a].itemColorCode or 0) < (BU3.Items.Items[b].itemColorCode or 0)
	end)

	for k, temp in SortedPairs(target) do
		local v = case.items[temp]
		local item = BU3.Items.Items[temp]
		local xpos = x * 130
		local xsize = 130

		local borderColor = item.itemColorCode or 1
		local borderColorRGB = BU3.Items.RarityToColor[borderColor]

		local p = vgui.Create("DPanel", itemContainedPanel)
		p:SetPos(xpos, y * 138)
		p:SetSize(xsize, 130)
		p.Paint = function(s, w, h)
			BU3.Items.RarityToFrame[borderColor](0, 0, w, h)

			--Draw the item name
			local name = item.name
			if string.len(name) >= 15 then
				name = string.sub(name,1,12).."..." 
			end

			draw.SimpleText(name, BU3.UI.Fonts["small_reg"], w/2, 17, Color(200,200,200,255),1 ,1)
		end

		--Create the item preview
		local iconPreview = nil

		if item.iconIsModel then
			iconPreview = BU3.UI.Elements.ModelView(item.iconID, item.zoom, p)
		else
			iconPreview = BU3.UI.Elements.IconView(item.iconID, item.color, p, false)
		end
		
		iconPreview:Dock(FILL)
        iconPreview:DockMargin(18, 32, 18, 12)
		iconPreview.zoom = item.zoom

		if ((wider + 142) > self.mirrorPanel:GetWide() - 142) then
            y = y + 1
            wider = 0
            x = 0
        else
            wider = wider + 132
            x = x + 1
        end
	end
end


--This is called when the page should unload
function PAGE:Unload(contentFrame, direction)
	self.mirrorPanel:Remove() --Remove all the UI we added to the content frame
	self.open = false
end

--This can be called by anything to pass a message to the page
function PAGE:Message(message, data)

end

--Register the page
BU3.UI.RegisterPage("preview", PAGE)