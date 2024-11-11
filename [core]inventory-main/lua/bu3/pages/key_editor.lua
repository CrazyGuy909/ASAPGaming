local PAGE = {}
PAGE.CaseData = {}
PAGE.IsCreating = true --If false, this page will work as an editor instead of a creator
PAGE.page = 1 --Between 1 and four
PAGE.lerpedPos = 0

--This is called when the page is called to load
function PAGE:Load(contentFrame, itemData)
    local isEditing = false
    PAGE.CaseData = {}

    if itemData ~= nil then
        isEditing = true
    end

    PAGE.page = 1
    --Init some stuff
    PAGE.CaseData.name = ""
    PAGE.CaseData.desc = ""
    PAGE.CaseData.iconID = "key"
    PAGE.CaseData.rankRestricted = false
    PAGE.CaseData.price = 0
    PAGE.CaseData.zoom = 0
    PAGE.CaseData.color = Color(255, 255, 255)
    PAGE.CaseData.canBeBought = true
    PAGE.CaseData.isFeatured = false
	PAGE.CaseData.isNew = false
    PAGE.CaseData.ranks = {}
    PAGE.CaseData.items = {}
    PAGE.CaseData.type = "key"

    --Update the table to the correct info
    if isEditing then
        for k, v in pairs(itemData) do
            PAGE.CaseData[k] = itemData[k]
        end
    end

    self.mirrorPanel = vgui.Create("DScrollPanel", contentFrame)
    self.mirrorPanel:SetSize(contentFrame:GetWide(), contentFrame:GetTall()) --Multiple by five so we can move it to change slides
    self.mirrorPanel.Paint = function(s) end --Clear background
    self.pages = vgui.Create("DPanel", self.mirrorPanel)
    self.pages:SetSize(contentFrame:GetWide() * 3, contentFrame:GetTall()) --Multiple by five so we can move it to change slides

    self.pages.Paint = function(s)
        self.lerpedPos = Lerp(8 * FrameTime(), self.lerpedPos, -(contentFrame:GetWide() * (self.page - 1)))
        s:SetPos(self.lerpedPos, 0)
    end

    --Clear backgroundFramnk
    local textPanel = vgui.Create("DPanel", self.mirrorPanel)
    textPanel:SetSize(400, 75)
    textPanel:SetPos(contentFrame:GetWide() / 2 - 200, 9)

    textPanel.Paint = function(s, w, h)
        draw.SimpleText("KEY EDITOR", BU3.UI.Fonts["large_bold"], w / 2, h / 2, Color(255, 255, 255, 20), 1, 1)
    end

    local stepCounter = BU3.UI.Elements.CreateStepCounter(3, self.mirrorPanel)
    stepCounter.selectedStage = 1
    stepCounter:SetPos(contentFrame:GetWide() / 2 - 200 + 30, 80)
    stepCounter:SetSize(400, 50)
    local forwardButton = nil --Predefine to reduce errors

    --Back and forward buttons
    local backButton = BU3.UI.Elements.CreateArrowButton(-90, self.mirrorPanel, function(s)
        if self.page == 1 then return false end
        self.page = self.page - 1

        if self.page < 3 then
            forwardButton.buttonActive = true
        end

        if self.page == 1 then
            s.buttonActive = false
        end

        stepCounter.selectedStage = self.page
    end)

    backButton.buttonActive = false
    backButton:SetPos(85, 680)
    backButton:SetSize(50, 50)

    --Back and forward buttons
    forwardButton = BU3.UI.Elements.CreateArrowButton(90, self.mirrorPanel, function(s)
        if self.page == 3 then return false end
        self.page = self.page + 1

        if self.page > 1 then
            backButton.buttonActive = true
        end

        if self.page == 3 then
            s.buttonActive = false
        end

        stepCounter.selectedStage = self.page
    end)

    forwardButton:SetPos(680, 680)
    forwardButton:SetSize(50, 50)
    --[[-------------------------------------------------------------------------
	Stage 1, case name and description
	---------------------------------------------------------------------------]]
    local baseOffset = 0
    local previewImage = BU3.UI.Elements.IconView(PAGE.CaseData.iconID, PAGE.CaseData.color, self.pages, true)
    previewImage:SetPos(320, 150)
    previewImage:SetSize(170, 170)
    previewImage.placeholder = false
    previewImage.zoom = PAGE.CaseData.zoom
    local nameEntry = BU3.UI.Elements.CreateTextEntry("Name", self.pages, false, false)
    nameEntry:SetPos(85, 340)
    nameEntry:SetSize(300, 40)

    nameEntry.OnValueChange = function(s, val)
        PAGE.CaseData.name = val
    end

    nameEntry:SetText(PAGE.CaseData.name)
    local descEntry = BU3.UI.Elements.CreateMultilineTextEntry("Description", self.pages, false)
    descEntry:SetPos(85, 340 + 20 + 40)
    descEntry:SetSize(300, 235)

    descEntry.OnValueChange = function(s, val)
        PAGE.CaseData.desc = val
    end

    descEntry:SetText(PAGE.CaseData.desc)
    local option = "Default Key Icon"

    if PAGE.CaseData.iconID ~= "key" then
        option = "Imgur ID"
    end

    local iconTypeSelect = BU3.UI.Elements.CreateComboBox(option, self.pages)
    iconTypeSelect:SetPos(430, 340)
    iconTypeSelect:SetSize(300, 40)
    --Pre define to make sure theres no errors
    local imgurIDEntry = nil
    local iconViewStartColor = Color(255, 255, 255, 255)
    iconTypeSelect:AddChoice("Default Key Icon")
    iconTypeSelect:AddChoice("Imgur ID")

    iconTypeSelect.OnSelect = function(panel, index, value)
        if value == "Default Key Icon" then
            PAGE.CaseData.iconID = "key"
            imgurIDEntry.canEdit = false
            previewImage:Remove()
            previewImage = BU3.UI.Elements.IconView("key", iconViewStartColor, self.pages, true)
            previewImage:SetPos(320, 150)
            previewImage:SetSize(170, 170)
            previewImage.zoom = PAGE.CaseData.zoom
            previewImage.placeholder = false
        else
            imgurIDEntry.canEdit = true
            previewImage:Remove()
            previewImage = BU3.UI.Elements.IconView("placeholder", iconViewStartColor, self.pages, true)
            previewImage:SetPos(320, 150)
            previewImage:SetSize(170, 170)
            previewImage.zoom = PAGE.CaseData.zoom
            previewImage.placeholder = true
        end
    end

    imgurIDEntry = BU3.UI.Elements.CreateImgurEntry("Imgur ID (eg oYTS30r)", self.pages, function(id)
        previewImage:Remove()
        previewImage = BU3.UI.Elements.IconView(id, iconViewStartColor, self.pages, true)
        previewImage:SetPos(320, 150)
        previewImage:SetSize(170, 170)
        previewImage.placeholder = false
        previewImage.zoom = PAGE.CaseData.zoom
        PAGE.CaseData.iconID = id
    end)

    imgurIDEntry:SetPos(430, 340 + 20 + 40)
    imgurIDEntry:SetSize(300, 40)

    if PAGE.CaseData ~= "key" then
        imgurIDEntry:SetText(PAGE.CaseData.iconID)
        imgurIDEntry.canEdit = true
    end

    local colorText = vgui.Create("DPanel", self.pages)
    colorText:SetSize(300, 40)
    colorText:SetPos(430, 340 + 20 + 40 + 42)

    colorText.Paint = function(s, w, h)
        draw.SimpleText("Icon Color", BU3.UI.Fonts["small_bold"], w / 2, h / 2, Color(210, 210, 210, 255), 1, 1)
    end

    --RGB color sliders
    local sliderR = BU3.UI.Elements.CreateSlider(Color(204, 31, 26), 0, 255, self.pages, function(val)
        previewImage._color.r = val
        iconViewStartColor.r = val
        PAGE.CaseData.color.r = val
    end)

    sliderR:SetPos(430, 485)
    sliderR:SetSize(300, 16)
    sliderR.slideAmount = (100 / 255) * PAGE.CaseData.color.r

    local sliderG = BU3.UI.Elements.CreateSlider(Color(31, 157, 85), 0, 255, self.pages, function(val)
        previewImage._color.g = val
        iconViewStartColor.g = val
        PAGE.CaseData.color.g = val
    end)

    sliderG:SetPos(430, 485 + 25)
    sliderG:SetSize(300, 16)
    sliderG.slideAmount = (100 / 255) * PAGE.CaseData.color.g

    local sliderB = BU3.UI.Elements.CreateSlider(Color(39, 121, 189), 0, 255, self.pages, function(val)
        previewImage._color.b = val
        iconViewStartColor.b = val
        PAGE.CaseData.color.b = val
    end)

    sliderB:SetPos(430, 485 + 25 + 25)
    sliderB:SetSize(300, 16)
    sliderB.slideAmount = (100 / 255) * PAGE.CaseData.color.b
    local zoomText = vgui.Create("DPanel", self.pages)
    zoomText:SetSize(300, 40)
    zoomText:SetPos(430, 485 + 25 + 25 + 25 + 4)

    zoomText.Paint = function(s, w, h)
        draw.SimpleText("Icon Zoom", BU3.UI.Fonts["small_bold"], w / 2, h / 2, Color(210, 210, 210, 255), 1, 1)
    end

    local zoom = BU3.UI.Elements.CreateSlider(Color(215, 215, 215), 0, 200, self.pages, function(val)
        previewImage.zoom = (val / 200)
        PAGE.CaseData.zoom = (val / 200)
    end)

    zoom:SetPos(430, 485 + 25 + 25 + 25 + 25 + 25)
    zoom:SetSize(300, 16)
    zoom.slideAmount = 100 * PAGE.CaseData.zoom
    --[[-------------------------------------------------------------------------
	Stage 2, can sell, price, and rank limits
	---------------------------------------------------------------------------]]

    baseOffset = contentFrame:GetWide()
    local isNewCheckbox = BU3.UI.Elements.CreateCheckBox(true, self.pages)
	isNewCheckbox:SetPos(baseOffset + 525 + 300,260 + 32)
	isNewCheckbox:SetSize(40 * 1, 20 * 1)
	isNewCheckbox.Think = function(s)
		PAGE.CaseData.isNew = s.state
	end
	isNewCheckbox.state = PAGE.CaseData.isNew

	local isNewText = vgui.Create("DPanel", self.pages)
	isNewText:SetSize(200, 40)
	isNewText:SetPos(baseOffset + 235 + 370, 260 + 32)
	isNewText.Paint = function(s , w , h)
		draw.SimpleText("Is New?", BU3.UI.Fonts["small_bold"], 0, 0, Color(210,210,210,255),0 ,0)
	end	

    local isFeaturedText = vgui.Create("DPanel", self.pages)
	isFeaturedText:SetSize(200, 40)
	isFeaturedText:SetPos(baseOffset + 235 + 370, 260)
	isFeaturedText.Paint = function(s , w , h)
		draw.SimpleText("Is featured?", BU3.UI.Fonts["small_bold"], 0, 0, Color(210,210,210,255),0 ,0)
	end	

	local isFeaturedCheckbox = BU3.UI.Elements.CreateCheckBox(true, self.pages)
	isFeaturedCheckbox:SetPos(baseOffset + 525 + 300,260)
	isFeaturedCheckbox:SetSize(40 * 1, 20 * 1)
	isFeaturedCheckbox.Think = function(s)
		PAGE.CaseData.isFeatured = s.state
	end
	isFeaturedCheckbox.state = PAGE.CaseData.isFeatured

    local globalOptionsText = vgui.Create("DPanel", self.pages)
    globalOptionsText:SetSize(200, 40)
    globalOptionsText:SetPos(baseOffset + 400 - 100, 182)

    globalOptionsText.Paint = function(s, w, h)
        draw.SimpleText("Global Options", BU3.UI.Fonts["small_bold"], w / 2, h / 2, Color(210, 210, 210, 50), 1, 1)
    end

    local canBeBougthText = vgui.Create("DPanel", self.pages)
    canBeBougthText:SetSize(200, 40)
    canBeBougthText:SetPos(baseOffset + 235, 260)

    canBeBougthText.Paint = function(s, w, h)
        draw.SimpleText("Can be bought?", BU3.UI.Fonts["small_bold"], 0, 0, Color(210, 210, 210, 255), 0, 0)
    end

    local priceText = vgui.Create("DPanel", self.pages)
    priceText:SetSize(150, 40)
    priceText:SetPos(baseOffset + 235, 260 + 35)

    priceText.Paint = function(s, w, h)
        draw.SimpleText("Price?", BU3.UI.Fonts["small_bold"], 0, 0, Color(210, 210, 210, 255), 0, 0)
    end

    local canBeBougthCheckbox = BU3.UI.Elements.CreateCheckBox(true, self.pages)
    canBeBougthCheckbox:SetPos(baseOffset + 525 + 10, 260)
    canBeBougthCheckbox:SetSize(40 * 1, 20 * 1)

    canBeBougthCheckbox.Think = function(s)
        PAGE.CaseData.canBeBought = s.state
    end

    canBeBougthCheckbox.state = PAGE.CaseData.canBeBought
    local priceEntryBox = BU3.UI.Elements.CreateTextEntry("'100'", self.pages, false, false)
    priceEntryBox:SetSize(50 + 15, 25)
    priceEntryBox:SetPos(baseOffset + 525 - 15, 260 + 35)

    priceEntryBox.OnValueChange = function(s, val)
        PAGE.CaseData.price = tonumber(val)
    end

    priceEntryBox:SetText(PAGE.CaseData.price)
    local priceText = vgui.Create("DPanel", self.pages)
    priceText:SetSize(150, 40)
    priceText:SetPos(baseOffset + 235, 340 + 30)

    priceText.Paint = function(s, w, h)
        draw.SimpleText("Non Tradeable", BU3.UI.Fonts["small_bold"], 0, 0, Color(210, 210, 210, 255), 0, 0)
    end

    local selectingRanks = BU3.UI.Elements.CreateCheckBox(true, self.pages)
    selectingRanks:SetPos(baseOffset + 235 + 340 - 40, 340 + 30)
    selectingRanks:SetSize(40 * 1, 20 * 1)
    selectingRanks.state = false

    selectingRanks.Think = function(s)
        PAGE.CaseData.rankRestricted = s.state
    end

    selectingRanks.state = PAGE.CaseData.rankRestricted
    --These are rank limitations
    local rankEntry = BU3.UI.Elements.CreateMultilineTextEntry("Seperate ranks by a new line", self.pages, false)
    rankEntry:SetPos(baseOffset + 235, 370 + 30)
    rankEntry:SetSize(340, 245)
    local __string = ""

    for k, v in pairs(PAGE.CaseData.ranks) do
        __string = __string .. v .. "\n"
    end

    rankEntry:SetText(__string)

    rankEntry.OnValueChange = function(s, val)
        local ranks = string.Split(val, "\n")
        PAGE.CaseData.ranks = ranks or {}
    end

    --[[-------------------------------------------------------------------------
	Stage 3, Add items to the case
	---------------------------------------------------------------------------]]
    baseOffset = contentFrame:GetWide() * 2
    --Create the scroll panel
    local scrollPanel = vgui.Create("DScrollPanel", self.pages)
    scrollPanel:SetPos(baseOffset + 150, 156)
    scrollPanel:SetSize(contentFrame:GetWide() - 300, 400)
    local sbar = scrollPanel:GetVBar()

    function sbar:Paint(w, h)
        --draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
    end

    function sbar.btnUp:Paint(w, h)
        --draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 100, 0 ) )
    end

    function sbar.btnDown:Paint(w, h)
        --draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 100, 0 ) )
    end

    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(8, 0, 0, w - 4, h, Color(40, 40, 45, 255))
    end

    local priceText = vgui.Create("DPanel", self.pages)
    priceText:SetSize(150, 32)
    priceText:SetPos(baseOffset + 180, 128)

    priceText.Paint = function(s, w, h)
        draw.SimpleText("Case Name", BU3.UI.Fonts["small_bold"], 0, 0, Color(210, 210, 210, 255), 0, 0)
    end

    local itemListPanels = {}
    local itemListIndex = 0

    local function refreshPanels()
        --Now re-arange all the panels to fit on the scroll panel
        local scrollPanelOffset = 0

        for k, v in pairs(itemListPanels) do
            v:SetPos(25, scrollPanelOffset)
            scrollPanelOffset = scrollPanelOffset + 45
        end
    end

    local function CreateItemPanel(itemName, id, setCaseData)
        if PAGE.CaseData.items[id] ~= nil and setCaseData ~= false then return end
        local p = vgui.Create("DPanel", scrollPanel)
        p:SetSize(contentFrame:GetWide() - 300 - 50, 40)
        p.itemListIndex = itemListIndex
        p.id = id
        p.Paint = function() end
        itemListPanels[itemListIndex] = p
        itemListIndex = itemListIndex + 1
        PAGE.CaseData.items[id] = id
        local subPan = vgui.Create("DPanel", p)
        subPan:SetSize(p:GetWide() - 30, p:GetTall())

        subPan.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 45, 255))
            draw.SimpleText(itemName, BU3.UI.Fonts["small_bold"], 5, (h / 2) - 2, Color(149, 152, 154), 0, 1)
        end

        local removeButton = vgui.Create("DButton", p)
        removeButton:SetText("")
        removeButton:SetPos(p:GetWide() - 30, 5)
        removeButton:SetSize(30, 30)

        removeButton.Paint = function(s, w, h)
            if s:IsHovered() then
                draw.SimpleText("-", BU3.UI.Fonts["large_bold"], w / 2, h / 2 - 4, Color(149, 152, 154), 1, 1)
            else
                draw.SimpleText("-", BU3.UI.Fonts["small_bold"], w / 2, h / 2 - 3, Color(149, 152, 154), 1, 1)
            end
        end

        removeButton.DoClick = function(s)
            itemListPanels[p.itemListIndex] = nil
            PAGE.CaseData.items[id] = nil --Remove the item from the case data
            p:Remove()
            refreshPanels()
        end

        refreshPanels()

        return p
    end

    --Load from editor
    for k, v in pairs(PAGE.CaseData.items) do
        local item = BU3.Items.Items[k]

        if item ~= nil then
            local itemName = item.name .. " (" .. k .. ")"
            local panel = CreateItemPanel(itemName, k, false)
            --panel.chance = chance
        end
    end

    --Creates a pop up to add an item
    local addItemButton = BU3.UI.Elements.CreateStandardButton("Add Case", self.pages, function()
        local f = vgui.Create("DFrame")
        f:SetSize(200, 300)
        f:Center()
        f:ShowCloseButton(false)
        f:SetTitle("")

        f.Paint = function(s, w, h)
            draw.RoundedBox(3, 0, 0, w, h, Color(40, 40, 45, 255))
        end

        f:MakePopup()
        local itemList = vgui.Create("DListView", f)
        itemList:SetPos(10, 10)
        itemList:SetSize(200 - 20, 200 - 50 - 10)
        itemList:SetMultiSelect(false)
        itemList:AddColumn("Case Name")

        for k, v in pairs(BU3.Items.Items) do
            if v.type == "case" then
                local p = itemList:AddLine(v.name .. " (" .. v.itemID .. ")")
                p.itemID = v.itemID
            end
        end

        itemList.OnRowSelected = function(lst, index, pnl)
            CreateItemPanel(pnl:GetColumnText(1), pnl.itemID)
            f:Close()
        end

        local cancelButton = BU3.UI.Elements.CreateStandardButton("Cancel", f, function()
            f:Close()
        end)

        cancelButton:SetPos(10, 10 + 400 - 50)
        cancelButton:SetSize(200 - 20, 30)
    end)

    addItemButton:SetSize(200, 40)
    addItemButton:SetPos(baseOffset + (contentFrame:GetWide() / 2) - 200 - 30, 250 + 200 + 15)

    --Creates a pop up to add an item
    local createCaseButton = BU3.UI.Elements.CreateStandardButton("Create/Update Key", self.pages, function()
        contentFrame:ShowLoader()
        net.Start("BU3:CreateItem")
        net.WriteTable(PAGE.CaseData)
        net.SendToServer()
    end)

    createCaseButton:SetSize(200, 40)
    createCaseButton:SetPos(baseOffset + (contentFrame:GetWide() / 2) + 50 - 30, 250 + 200 + 15)
end

--This is called when the page should unload
function PAGE:Unload(contentFrame, direction)
    self.mirrorPanel:Remove() --Remove all the UI we added to the content frame
end

--This can be called by anything to pass a message to the page
function PAGE:Message(message, data)
end

--Register the page
BU3.UI.RegisterPage("keyeditor", PAGE)