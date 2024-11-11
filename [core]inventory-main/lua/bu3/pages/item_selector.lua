local PAGE = {}

--This is called when the page is called to load
function PAGE:Load(contentFrame)

	self.mirrorPanel = vgui.Create("DScrollPanel", contentFrame)
	self.mirrorPanel:SetSize(contentFrame:GetWide(), contentFrame:GetTall())
	self.mirrorPanel.Paint = function() end --Clear background

	local textPanel = vgui.Create("DPanel", self.mirrorPanel)
	textPanel:SetSize(400, 75)
	textPanel:SetPos(self.mirrorPanel:GetWide()/2 - 200,9)
	textPanel.Paint = function(s , w , h)
		draw.SimpleText("SETTINGS", BU3.UI.Fonts["large_bold"], w/2, h/2, Color(255,255,255,20),1 ,1)
	end

	local createWeapon = BU3.UI.Elements.CreateStandardButton("Create Weapon", self.mirrorPanel, function()
		contentFrame:LoadPage("weaponeditor")
	end)
	createWeapon:SetPos(self.mirrorPanel:GetWide()/4 - (240/2), 64)
	createWeapon:SetSize(240, 45)

	local createPS1PS2Points = BU3.UI.Elements.CreateStandardButton("Create PS1 Points", self.mirrorPanel, function()
		contentFrame:LoadPage("points1editor")
	end)
	createPS1PS2Points:SetPos(((self.mirrorPanel:GetWide()/4) * 3) - (240/2), 64)
	createPS1PS2Points:SetSize(240, 45)

	local createEntity = BU3.UI.Elements.CreateStandardButton("Create Entity", self.mirrorPanel, function()
		contentFrame:LoadPage("entityeditor")
	end)
	createEntity:SetPos(self.mirrorPanel:GetWide()/4 - (240/2), 128)
	createEntity:SetSize(240, 45)

	local _createPS1PS2Item = BU3.UI.Elements.CreateStandardButton("Create PS2 Points", self.mirrorPanel, function()
		contentFrame:LoadPage("points2editor")
	end)
	_createPS1PS2Item:SetPos(((self.mirrorPanel:GetWide()/4) * 3) - (240/2), 128)
	_createPS1PS2Item:SetSize(240, 45)

	local createRPCash = BU3.UI.Elements.CreateStandardButton("Create RP Cash", self.mirrorPanel, function()
		contentFrame:LoadPage("moneyeditor")
	end)
	createRPCash:SetPos(self.mirrorPanel:GetWide()/4 - (240/2), 196)
	createRPCash:SetSize(240, 45)

	local createLuaItem = BU3.UI.Elements.CreateStandardButton("Create Lua Item", self.mirrorPanel, function()
		contentFrame:LoadPage("luaeditor")
	end)
	createLuaItem:SetPos(((self.mirrorPanel:GetWide()/4) * 3) - (240/2), 196)
	createLuaItem:SetSize(240, 45)

	local createRPCash = BU3.UI.Elements.CreateStandardButton("Create PS1 Item", self.mirrorPanel, function()
		contentFrame:LoadPage("points1itemeditor")
	end)
	createRPCash:SetPos(self.mirrorPanel:GetWide()/4 - (240/2), 256)
	createRPCash:SetSize(240, 45)

	local createLuaItem = BU3.UI.Elements.CreateStandardButton("Create PS2 Item", self.mirrorPanel, function()
		contentFrame:LoadPage("points2itemeditor")
	end)
	createLuaItem:SetPos(((self.mirrorPanel:GetWide()/4) * 3) - (240/2), 256)
	createLuaItem:SetSize(240, 45)

	local createLuaItem = BU3.UI.Elements.CreateStandardButton("Create Attachment pack", self.mirrorPanel, function()
		contentFrame:LoadPage("attachmenteditor")
	end)
	createLuaItem:SetPos(((self.mirrorPanel:GetWide()/4) * 3) - (240/2), 256 + 64)
	createLuaItem:SetSize(240, 45)

	local createLuaItem = BU3.UI.Elements.CreateStandardButton("Create Suit", self.mirrorPanel, function()
		contentFrame:LoadPage("suiteditor")
	end)
	createLuaItem:SetPos(((self.mirrorPanel:GetWide()/4) * 3) - (240/2), 256 + 128)
	createLuaItem:SetSize(240, 45)

	local createRPCash = BU3.UI.Elements.CreateStandardButton("Create Accessory", self.mirrorPanel, function()
		contentFrame:LoadPage("accesory_editor")
	end)
	createRPCash:SetPos(self.mirrorPanel:GetWide()/4 - (240/2), 256 + 64)
	createRPCash:SetSize(240, 45)

	local createRPCash = BU3.UI.Elements.CreateStandardButton("Create Credits", self.mirrorPanel, function()
		contentFrame:LoadPage("creditseditor")
	end)
	createRPCash:SetPos(self.mirrorPanel:GetWide()/4 - (240/2), 256 + 128)
	createRPCash:SetSize(240, 45)

end

--This is called when the page should unload
function PAGE:Unload(contentFrame, direction)
	self.mirrorPanel:Remove() --Remove all the UI we added to the content frame
end

--This can be called by anything to pass a message to the page
function PAGE:Message(message, data)

end

--Register the page
BU3.UI.RegisterPage("itemselector", PAGE)