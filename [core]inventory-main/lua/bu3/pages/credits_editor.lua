local PAGE = {}

PAGE.ItemData = {}

PAGE.IsCreating = true --If false, this page will work as an editor instead of a creator
PAGE.page = 1 --Between 1 and four
PAGE.lerpedPos = 0


--This is called when the page is called to load
function PAGE:Load(contentFrame, itemData)
	PAGE.page = 1
	PAGE.ItemData = {}
	local isEditing = false

	if itemData ~= nil then
		isEditing = true
	end

	--Init some stuff
	PAGE.ItemData.name = ""
	PAGE.ItemData.desc = ""
	PAGE.ItemData.iconID = "credits"
	PAGE.ItemData.iconIsModel = false
	PAGE.ItemData.rankRestricted = false
	PAGE.ItemData.price = 0
	PAGE.ItemData.zoom = 0
	PAGE.ItemData.color = Color(255,255,255)
	PAGE.ItemData.canBeBought = false
	PAGE.ItemData.canBeSold = true
	PAGE.ItemData.perm = false
	PAGE.ItemData.ranks = {}
	PAGE.ItemData.itemColorCode = 1 --Gray
	PAGE.ItemData.creditsAmount = ""
	PAGE.ItemData.type = "credits"

	--Update the table to the correct info
	if isEditing then
		for k, v in pairs(itemData) do
			PAGE.ItemData[k] = itemData[k]
		end
		
	end

	self.mirrorPanel = vgui.Create("DScrollPanel", contentFrame)
	self.mirrorPanel:SetSize(contentFrame:GetWide(), contentFrame:GetTall()) --Multiple by five so we can move it to change slides
	self.mirrorPanel.Paint = function(s) 

	end --Clear background

	self.pages = vgui.Create("DPanel", self.mirrorPanel)
	self.pages:SetSize(contentFrame:GetWide() * 1, contentFrame:GetTall()) --Multiple by five so we can move it to change slides
	self.pages.Paint = function(s) 
		self.lerpedPos = Lerp(8 * FrameTime(), self.lerpedPos, -(contentFrame:GetWide() * (self.page - 1)))
		s:SetPos(self.lerpedPos, 0)
	end --Clear background


	local textPanel = vgui.Create("DPanel", self.mirrorPanel)
	textPanel:SetSize(400, 75)
	textPanel:SetPos(contentFrame:GetWide()/2 - 200,9)
	textPanel.Paint = function(s , w , h)
		draw.SimpleText("CREDITS EDITOR", BU3.UI.Fonts["large_bold"], w/2, h/2, Color(255,255,255,20),1 ,1)
	end


	local forwardButton = nil --Predefine to reduce errors


	local baseOffset = 0

	local previewImage = nil
	if not PAGE.ItemData.iconIsModel then
		previewImage = BU3.UI.Elements.IconView(PAGE.ItemData.iconID , PAGE.ItemData.color, self.pages, true)
		previewImage:SetPos(320, 150)
		previewImage:SetSize(170, 170)
		previewImage.placeholder = false
		previewImage.zoom = PAGE.ItemData.zoom
	else
		previewImage = BU3.UI.Elements.ModelView(PAGE.ItemData.iconID, PAGE.ItemData.zoom, self.pages)
		previewImage:SetPos(320, 150)
		previewImage:SetSize(170, 170)
		previewImage.zoom = PAGE.ItemData.zoom
	end

	local nameEntry = BU3.UI.Elements.CreateTextEntry("Name", self.pages, false, false)
	nameEntry:SetPos(85, 340)
	nameEntry:SetSize(300, 40)
	nameEntry:SetText(PAGE.ItemData.name)
	nameEntry.OnValueChange = function(s , val)
		PAGE.ItemData.name = val
	end

	local descEntry = BU3.UI.Elements.CreateMultilineTextEntry("Description", self.pages, false)
	descEntry:SetPos(85, 340 + 20 + 40)
	descEntry:SetSize(300, 235 - 40 - 5 - 40 - 40)
	descEntry:SetText(PAGE.ItemData.desc)
	descEntry.OnValueChange = function(s , val)
		PAGE.ItemData.desc = val
	end

	local weaponClassEntry = BU3.UI.Elements.CreateTextEntry("Credits Amount", self.pages, false, false)
	weaponClassEntry:SetPos(85, 340 + 20 + 40 + (235 - 40 - 5 - 40) + 20 - 40)
	weaponClassEntry:SetSize(300, 40)
	weaponClassEntry:SetText(PAGE.ItemData.creditsAmount)
	weaponClassEntry.OnValueChange = function(s , val)
		PAGE.ItemData.creditsAmount = val
	end

	local stringToSet = BU3.Items.RarityToString[PAGE.ItemData.itemColorCode]

	local iconColorCodeSelect = BU3.UI.Elements.CreateComboBox(stringToSet, self.pages)
	iconColorCodeSelect:SetPos(85, 340 + 20 + 40 + (235 - 40 - 5 - 40) + 20 + 20)
	iconColorCodeSelect:SetSize(300, 40)
	iconColorCodeSelect:AddChoice("Gray")
	iconColorCodeSelect:AddChoice("Blue")
	iconColorCodeSelect:AddChoice("Purple")
	iconColorCodeSelect:AddChoice("Pink")
	iconColorCodeSelect:AddChoice("Red")
	iconColorCodeSelect:AddChoice("Gold")
	iconColorCodeSelect.OnSelect = function( panel, index, value )
		PAGE.ItemData.itemColorCode = BU3.Items.StringToRarity[value]
	end

	local iconType = "Default Credits Icon"
	if PAGE.ItemData.iconIsModel then
		iconType = "Model"
	elseif PAGE.ItemData.iconID ~= "credits" then
		iconType = "Imgur ID"
	end

	local iconTypeSelect = BU3.UI.Elements.CreateComboBox(iconType, self.pages)
	iconTypeSelect:SetPos(430, 340)
	iconTypeSelect:SetSize(300, 40)

	--Pre define to make sure theres no errors
	local imgurIDEntry = nil

	local iconViewStartColor = Color(255,255,255,255)

	iconTypeSelect:AddChoice("Default Credits Icon")
	iconTypeSelect:AddChoice("Model")
	iconTypeSelect:AddChoice("Imgur ID")
	iconTypeSelect.OnSelect = function( panel, index, value )
		if value == "Default Credits Icon" then
			PAGE.ItemData.iconIsModel = false
			PAGE.ItemData.iconID = "credits"
			imgurIDEntry.canEdit = false
			previewImage:Remove()
			previewImage = BU3.UI.Elements.IconView("credits", iconViewStartColor, self.pages, true)
			previewImage:SetPos(320, 150)
			previewImage:SetSize(170, 170)
			previewImage.zoom = PAGE.ItemData.zoom
			previewImage.placeholder = false
		elseif value == "Model" then
			PAGE.ItemData.iconIsModel = true
			PAGE.ItemData.iconID = "credits"
			imgurIDEntry.canEdit = true
			previewImage:Remove()
			previewImage = BU3.UI.Elements.ModelView("error", PAGE.ItemData.zoom, self.pages)
			previewImage:SetPos(320, 150)
			previewImage:SetSize(170, 170)
			previewImage.zoom = PAGE.ItemData.zoom
		else
			PAGE.ItemData.iconIsModel = false
			imgurIDEntry.canEdit = true
			previewImage:Remove()
			previewImage = BU3.UI.Elements.IconView("placeholder", iconViewStartColor, self.pages, true)
			previewImage:SetPos(320, 150)
			previewImage:SetSize(170, 170)
			previewImage.zoom = PAGE.ItemData.zoom
			previewImage.placeholder = true				
		end
	end

	imgurIDEntry = BU3.UI.Elements.CreateImgurEntry("Model Or ID", self.pages, function(id)
		if iconTypeSelect:GetValue() == "Model" then
			previewImage:Remove()
			previewImage = BU3.UI.Elements.ModelView(id, PAGE.ItemData.zoom, self.pages)
			previewImage:SetPos(320, 150)
			previewImage:SetSize(170, 170)
			previewImage.zoom = PAGE.ItemData.zoom
			PAGE.ItemData.iconID = id
		else	
			previewImage:Remove()
			previewImage = BU3.UI.Elements.IconView(id, iconViewStartColor, self.pages, true)
			previewImage:SetPos(320, 150)
			previewImage:SetSize(170, 170)
			previewImage.placeholder = false
			previewImage.zoom = PAGE.ItemData.zoom
			PAGE.ItemData.iconID = id
		end
	end)

	if PAGE.ItemData.iconID ~= "credits" then
		imgurIDEntry:SetText(PAGE.ItemData.iconID)
	end
	imgurIDEntry:SetPos(430, 340 + 20 + 40)
	imgurIDEntry:SetSize(300, 40)

	local colorText = vgui.Create("DPanel", self.pages)
	colorText:SetSize(300, 40)
	colorText:SetPos(430, 340 + 20 + 40 + 42)
	colorText.Paint = function(s , w , h)
		draw.SimpleText("Icon Color", BU3.UI.Fonts["small_bold"], w/2, h/2, Color(210,210,210,255),1 ,1)
	end

	--RGB color sliders
	local sliderR = BU3.UI.Elements.CreateSlider(Color(204,31,26), 0, 255, self.pages, function(val)
		previewImage._color.r = val
		iconViewStartColor.r = val
		PAGE.ItemData.color.r = val
	end)
	sliderR.slideAmount = (PAGE.ItemData.color.r/255) * 100
	sliderR:SetPos(430, 485)
	sliderR:SetSize(300, 16)

	local sliderG = BU3.UI.Elements.CreateSlider(Color(31,157,85), 0, 255, self.pages, function(val)
		previewImage._color.g = val
		iconViewStartColor.g = val
		PAGE.ItemData.color.g = val
	end)
	sliderG.slideAmount = (PAGE.ItemData.color.g/255) * 100
	sliderG:SetPos(430, 485 + 25)
	sliderG:SetSize(300, 16)

	local sliderB = BU3.UI.Elements.CreateSlider(Color(39, 121, 189), 0, 255, self.pages, function(val)
		previewImage._color.b = val
		iconViewStartColor.b = val
		PAGE.ItemData.color.b = val
	end)
	sliderB.slideAmount = (PAGE.ItemData.color.b/255) * 100
	sliderB:SetPos(430, 485 + 25 + 25)
	sliderB:SetSize(300, 16)


	local zoomText = vgui.Create("DPanel", self.pages)
	zoomText:SetSize(300, 40)
	zoomText:SetPos(430,  485 + 25 + 25 + 25 + 4)
	zoomText.Paint = function(s , w , h)
		draw.SimpleText("Icon Zoom", BU3.UI.Fonts["small_bold"], w/2, h/2, Color(210,210,210,255),1 ,1)
	end

	local zoom = BU3.UI.Elements.CreateSlider(Color(215,215,215), 0, 200, self.pages, function(val)
		previewImage.zoom = (val / 200)
		PAGE.ItemData.zoom = (val / 200)
	end)
	zoom.slideAmount = PAGE.ItemData.zoom * 100
	zoom:SetPos(430, 485 + 25 + 25 + 25 + 25 + 25)
	zoom:SetSize(300, 16)

	local createCaseButton = BU3.UI.Elements.CreateStandardButton("Create/Update Credits", self.pages, function()
		contentFrame:ShowLoader()
		net.Start("BU3:CreateItem")
		net.WriteTable(PAGE.ItemData)
		net.SendToServer()
	end)

	createCaseButton:SetSize(340, 40)
	createCaseButton:SetPos((contentFrame:GetWide()/2) - 178, 250 + 400 - 10 + 30)
end

function PAGE:Unload(contentFrame, direction)
	self.mirrorPanel:Remove() --Remove all the UI we added to the content frame
end

function PAGE:Message(message, data)

end

BU3.UI.RegisterPage("creditseditor", PAGE)