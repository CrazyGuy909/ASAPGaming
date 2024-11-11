local PAGE = {}

--This is called when the page is called to load
function PAGE:Load(contentFrame)

	self.mirrorPanel = vgui.Create("DPanel", contentFrame)
	self.mirrorPanel:Dock(FILL)
	self.mirrorPanel.Paint = function() end --Clear background

	local textPanel_top = vgui.Create("DPanel", self.mirrorPanel)
	textPanel_top:SetSize(400, 75)
	textPanel_top:Dock(TOP)
	textPanel_top:SetTall(75)
	textPanel_top:SetPos(self.mirrorPanel:GetWide()/2 - 200,9)
	textPanel_top.Paint = function(s , w , h)
		draw.SimpleText("SETTINGS", BU3.UI.Fonts["large_bold"], w/2, h/2, Color(255,255,255,20),1 ,1)
	end

	contentFrame:InvalidateLayout(true)
	local containers = vgui.Create("Panel", self.mirrorPanel)
	containers:Dock(TOP)
	containers:SetTall(self.mirrorPanel:GetTall() * .4)

	self.mirrorPanel:InvalidateChildren(true)
	local wide, tall = containers:GetSize()
	local createCaseKeyText = vgui.Create("DPanel", containers)
	createCaseKeyText:SetSize(wide / 2, 32)
	createCaseKeyText:SetPos(16, 0)
	createCaseKeyText.Paint = function(s , w , h)
		draw.SimpleText("CREATE CASE/KEY", BU3.UI.Fonts["med_bold"], w/2, h/2, Color(255,255,255,200),1 ,1)
	end

	local createItemText = vgui.Create("DPanel", containers)
	createItemText:SetSize(wide / 2, 32)
	createItemText:SetPos(wide / 2 + 16, 0)
	createItemText.Paint = function(s , w , h)
		draw.SimpleText("CREATE ITEM", BU3.UI.Fonts["med_bold"], w/2, h/2, Color(255,255,255,200),1 ,1)
	end

	local createCaseKeyDescription = vgui.Create("RichText", containers)
	createCaseKeyDescription:SetSize(wide / 2 - wide / 12, 150)
	createCaseKeyDescription:SetPos(16 + wide / 24, 64)
	createCaseKeyDescription:SetVerticalScrollbarEnabled(false)
	function createCaseKeyDescription:PerformLayout()
		self:SetFontInternal(BU3.UI.Fonts["smallest_reg"])
	end
	createCaseKeyDescription:SetText("This tool is used to create keys or cases. By using it you will have the ability to set an item's picture, color, name, description, ranks and alot more. Using the same tool you can create keys and determin which keys open which cases. You can also determin weater or not an item can be purchased in the store, and if so which ranks are allowed to purchase it.")

	local createItemDescription = vgui.Create("RichText", containers)
	createItemDescription:SetSize(wide / 2 - wide / 12, 150)
	createItemDescription:SetPos(wide / 2 + 16 + wide / 24, 64)
	createItemDescription:SetVerticalScrollbarEnabled(false)
	function createItemDescription:PerformLayout()
		self:SetFontInternal(BU3.UI.Fonts["smallest_reg"])
	end
	createItemDescription:SetText("This tool is used to create items. Item are unboxed in crates, using this tool you can create items and set there picture, color, name, description, ranks and alot more. To specify which items go in which crates please use the edit feature below and edit the crate, not the item itself. ")

	local createCaseKeyButton = BU3.UI.Elements.CreateStandardButton("CREATE CASE/KEY", containers, function(s)
		contentFrame:LoadPage("casekeyselector")
	end)
	createCaseKeyButton:SetSize(wide / 3, 48)
	createCaseKeyButton:SetPos(wide / 2 - wide / 3 - wide / 12, tall - 52)

	local createItemButton = BU3.UI.Elements.CreateStandardButton("CREATE ITEM", containers, function(s)
		contentFrame:LoadPage("itemselector")
	end)
	createItemButton:SetSize(wide / 3, 48)
	createItemButton:SetPos(wide / 2 + wide / 12, tall - 52)

	local scrollPanel1 = nil
	local scrollPanel2 = nil

	--Create items list so you can select one for editing
	local function CreateItemList(filter)
		local skipFilter = false
		if filter == nil or string.len(filter) < 1 then
			skipFilter = true
		end

		local items = BU3.Items.Items

		--Filter the items
		if not skipFilter then
			local filteredTable = {}
			for k ,v in pairs(items) do
				if string.match(string.lower(v.name), string.lower(filter), 1) then
					filteredTable[k] = v
				end
			end
			items = filteredTable
		else
			return
		end


		--Sort the tables
		local sortedItems = {}
		local sortedCratesKeys = {}

		for k, v in pairs(items) do
			if v.type == "case" or v.type == "key" then
				table.insert(sortedCratesKeys, v)
			else
				table.insert(sortedItems, v)
			end
		end

		--Create the scroll panels
		if scrollPanel1 ~= nil then
			scrollPanel1:Remove()
			scrollPanel1 = nil
		end

		if scrollPanel2 ~= nil then
			scrollPanel2:Remove()
			scrollPanel2 = nil
		end

		local panels = vgui.Create("Panel", self.mirrorPanel)
		panels:Dock(FILL)

		scrollPanel1 = vgui.Create("DScrollPanel", panels)
		scrollPanel1:Dock(LEFT)
		scrollPanel1:SetWide(self.mirrorPanel:GetWide() / 2)
		scrollPanel1:DockMargin(16, 16, 16, 16)
		local sbar = scrollPanel1:GetVBar()
		function sbar:Paint( w, h )
		end
		function sbar.btnUp:Paint( w, h )
		end
		function sbar.btnDown:Paint( w, h )
		end
		sbar.btnGrip:NoClipping(true)
		function sbar.btnGrip:Paint( w, h )
			draw.RoundedBox( 8, 4, -10, w - 4, h + 20, Color(39, 121, 189, 255) )
		end

		scrollPanel2 = vgui.Create("DScrollPanel", panels)
		scrollPanel2:Dock(FILL)
		scrollPanel2:DockMargin(0, 16, 16, 16)
		sbar = scrollPanel2:GetVBar()
		function sbar:Paint( w, h )
		end
		function sbar.btnUp:Paint( w, h )
		end
		function sbar.btnDown:Paint( w, h )
		end
		sbar.btnGrip:NoClipping(true)
		function sbar.btnGrip:Paint( w, h )
			draw.RoundedBox( 8, 4, -10, w - 4, h + 20, Color(39, 121, 189, 255) )
		end

		--Now start by creating the cases list
		local x = 0
		local y = 0
		local wider = 0
		for k, v in pairs(sortedCratesKeys) do
			local item = v

			local borderColor = item.itemColorCode or 1
			local borderColorRGB = BU3.Items.RarityToColor[borderColor]

			--Create the panel
			local p = vgui.Create("DPanel", scrollPanel1)
			p.id = item.itemID
			p:SetPos((125 * x), (125 * y))
			p.Item = item
			p:SetSize(120, 120)
			p.Paint = function(s, w, h)
				draw.RoundedBox(4, 0, 0, w, h, borderColorRGB)
				draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(40,40,45, 255))

				--Draw the item name
				local name = item.name
				if string.len(name) >= 15 then
					name = string.sub(name,1,12).."..." 
				end

				draw.SimpleText(name, BU3.UI.Fonts["small_reg"], w/2, 17, Color(200,200,200,255),1 ,1)
				--draw.SimpleText("$"..string.Comma(item.price), BU3.UI.Fonts["small_bold"], w/2, h - 18, Color(200,200,200,255),1 ,1)
			end
			p.PaintOver = function(s, w, h)
				draw.SimpleText(item.itemID, BU3.UI.Fonts["small_reg"], 8, h - 8, Color(200,200,200,255),0 ,TEXT_ALIGN_BOTTOM)
			end

			--Create the item preview
			local iconPreview = nil

			if item.iconIsModel then
				iconPreview = BU3.UI.Elements.ModelView(item.iconID, item.zoom, p)
			else
				iconPreview = BU3.UI.Elements.IconView(item.iconID, item.color, p, false)
			end
			
			iconPreview:SetPos(15 + 3, 25 + 3)
			iconPreview:SetSize(90 - 6, 90 - 6)
			iconPreview.zoom = item.zoom

			--Interaction button
			local button = vgui.Create("DButton", p)
			button:SetSize(120, 120)
			button:SetText("")
			button.LerpValue = 0
			button.Paint = function(s , w , h)
				if s:IsHovered() then
					s.LerpValue = Lerp(12 * FrameTime(), s.LerpValue, 255)
				else
					s.LerpValue = Lerp(12 * FrameTime(), s.LerpValue, 0)
				end

				draw.RoundedBox(4,0,0,w,h,Color(0,0,0,s.LerpValue / 1.5))
				draw.SimpleText("Press to edit",BU3.UI.Fonts["small_reg"],w/2 - 1, h/2 + 1, Color(0,0,0,s.LerpValue), 1, 1)
				draw.SimpleText("Press to edit",BU3.UI.Fonts["small_reg"],w/2, h/2,Color(222,222,222,s.LerpValue), 1, 1)
			end
			button.DoClick = function()
				if item.type == "case" then
					BU3.UI.ContentFrame:LoadPage("caseeditor", BU3.Items.Items[p.id])
				else
					BU3.UI.ContentFrame:LoadPage("keyeditor", BU3.Items.Items[p.id])
				end
			end

			--Delete button
			local deleteButton = vgui.Create("DButton", p)
			deleteButton:SetSize(32, 32)
			deleteButton:SetPos(120 - 32, 120 - 32)
			deleteButton:SetText("")
			deleteButton.LerpValue = 0
			deleteButton.Paint = function(s , w , h)
				draw.SimpleText("X",BU3.UI.Fonts["small_reg"],w/2 - 1, h/2 + 1, Color(0,0,0,255), 1, 1)
				draw.SimpleText("X",BU3.UI.Fonts["small_reg"],w/2, h/2,Color(222,0,0,255), 1, 1)
			end
			deleteButton.DoClick = function()
				BU3.UI.Elements.DeletePrompt(item.itemID)
			end	


			if ((wider + 128) > self.mirrorPanel:GetWide() / 2 - 128) then
				y = y + 1
				wider = 0
				x = 0
			else
				wider = wider + 128
				x = x + 1
			end
		end

		--Item list

		x = 0
		y = 0
		wider = 0
		for k, v in pairs(sortedItems) do
			local item = v

			local borderColor = item.itemColorCode or 1
			local borderColorRGB = BU3.Items.RarityToColor[borderColor]

			--Create the panel
			local p = vgui.Create("DPanel", scrollPanel2)
			p:SetPos((125 * x), (125 * y))
			p:SetSize(120, 120)
			p.Paint = function(s, w, h)
			p.id = item.itemID
				draw.RoundedBox(4, 0, 0, w, h, borderColorRGB)
				draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(40,40,45, 255))

				--Draw the item name
				local name = item.name
				if string.len(name) >= 15 then
					name = string.sub(name,1,12).."..." 
				end

				draw.SimpleText(name, BU3.UI.Fonts["small_reg"], w/2, 17, Color(200,200,200,255),1 ,1)
				--draw.SimpleText("$"..string.Comma(item.price), BU3.UI.Fonts["small_bold"], w/2, h - 18, Color(200,200,200,255),1 ,1)
			end
			p.PaintOver = function(s, w, h)
				draw.SimpleText(item.itemID, BU3.UI.Fonts["small_reg"], 8, h - 8, Color(200,200,200,255),0 ,TEXT_ALIGN_BOTTOM)
			end

			--Create the item preview
			local iconPreview = nil

			if item.iconIsModel then
				iconPreview = BU3.UI.Elements.ModelView(item.iconID, item.zoom, p)
			else
				iconPreview = BU3.UI.Elements.IconView(item.iconID, item.color, p, false)
			end
			
			iconPreview:SetPos(15 + 3, 25 + 3)
			iconPreview:SetSize(90 - 6, 90 - 6)
			iconPreview.zoom = item.zoom

			--Interaction button
			local button = vgui.Create("DButton", p)
			button:SetSize(120, 120)
			button:SetText("")
			button.LerpValue = 0
			button.Paint = function(s , w , h)
				if s:IsHovered() then
					s.LerpValue = Lerp(12 * FrameTime(), s.LerpValue, 255)
				else
					s.LerpValue = Lerp(12 * FrameTime(), s.LerpValue, 0)
				end

				draw.RoundedBox(4,0,0,w,h,Color(0,0,0,s.LerpValue / 1.5))
				draw.SimpleText("Press to edit",BU3.UI.Fonts["small_reg"],w/2 - 1, h/2 + 1, Color(0,0,0,s.LerpValue), 1, 1)
				draw.SimpleText("Press to edit",BU3.UI.Fonts["small_reg"],w/2, h/2,Color(222,222,222,s.LerpValue), 1, 1)
			end
			button.DoClick = function()
				if item.type == "weapon" then
					contentFrame:LoadPage("weaponeditor", item)
				elseif item.type == "entity" then
					contentFrame:LoadPage("entityeditor", item)
				elseif item.type == "money" then
					contentFrame:LoadPage("moneyeditor", item)
				elseif item.type == "points1" then
					contentFrame:LoadPage("points1editor", item)
				elseif item.type == "points2" then
					contentFrame:LoadPage("points2editor", item)
				elseif item.type == "points1item" then
					contentFrame:LoadPage("points1itemeditor", item)
				elseif item.type == "points2item" then
					contentFrame:LoadPage("points2itemeditor", item)
				elseif item.type == "lua" then
					contentFrame:LoadPage("luaeditor", item)
				elseif item.type == "accesory" then
					contentFrame:LoadPage("accesory_editor", item)
				elseif item.type == "credits" then
					contentFrame:LoadPage("creditseditor", item)
				elseif item.type == "suit" then
					contentFrame:LoadPage("suiteditor", item)
				end
			end


			--Delete button
			local deleteButton = vgui.Create("DButton", p)
			deleteButton:SetSize(32, 32)
			deleteButton:SetPos(120 - 32, 120 - 32)
			deleteButton:SetText("")
			deleteButton.LerpValue = 0
			deleteButton.Paint = function(s , w , h)
				draw.SimpleText("X",BU3.UI.Fonts["small_reg"],w/2 - 1, h/2 + 1, Color(0,0,0,255), 1, 1)
				draw.SimpleText("X",BU3.UI.Fonts["small_reg"],w/2, h/2,Color(222,0,0,255), 1, 1)
			end
			deleteButton.DoClick = function()
				BU3.UI.Elements.DeletePrompt(item.itemID)
			end	

			--Increment offet
			if ((wider + 128) > self.mirrorPanel:GetWide() / 2 - 96) then
				y = y + 1
				wider = 0
				x = 0
			else
				wider = wider + 150
				x = x + 1
			end
		end
	end

		--Search box for items in the bottom
	local searchBox = BU3.UI.Elements.CreateTextEntry("Search...", textPanel_top, true, true)
	searchBox:Dock(RIGHT)
	searchBox:SetWide(256)
	searchBox:DockMargin(0, 16, 16, 16)
	searchBox:SetUpdateOnType(true)
	searchBox.OnValueChange = function(s)
		CreateItemList(s:GetText())
	end

	--Create the item list
	CreateItemList()

end

--This is called when the page should unload
function PAGE:Unload(contentFrame, direction)
	self.mirrorPanel:Remove() --Remove all the UI we added to the content frame
end

--This can be called by anything to pass a message to the page
function PAGE:Message(message, data)

end

--Register the page
BU3.UI.RegisterPage("settings", PAGE)