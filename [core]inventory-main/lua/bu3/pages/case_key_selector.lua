local PAGE = {}

--This is called when the page is called to load
function PAGE:Load(contentFrame)

	self.mirrorPanel = vgui.Create("DPanel", contentFrame)
	self.mirrorPanel:SetSize(contentFrame:GetWide(), contentFrame:GetTall())
	self.mirrorPanel.Paint = function() end --Clear background

	local textPanel = vgui.Create("DPanel", self.mirrorPanel)
	textPanel:SetSize(400, 75)
	textPanel:SetPos(self.mirrorPanel:GetWide()/2 - 200,9)
	textPanel.Paint = function(s , w , h)
		draw.SimpleText("SETTINGS", BU3.UI.Fonts["large_bold"], w/2, h/2, Color(255,255,255,20),1 ,1)
	end

	local createCaseKeyText = vgui.Create("DPanel", self.mirrorPanel)
	createCaseKeyText:SetSize(400, 75)
	createCaseKeyText:SetPos((self.mirrorPanel:GetWide()/4) - 200, 165 - 32)
	createCaseKeyText.Paint = function(s , w , h)
		draw.SimpleText("CREATE CASE", BU3.UI.Fonts["med_bold"], w/2, h/2, Color(255,255,255,200),1 ,1)
	end

	local createItemText = vgui.Create("DPanel", self.mirrorPanel)
	createItemText:SetSize(400, 75)
	createItemText:SetPos(((self.mirrorPanel:GetWide()/4) * 3) - 200, 165 - 32)
	createItemText.Paint = function(s , w , h)
		draw.SimpleText("CREATE KEY", BU3.UI.Fonts["med_bold"], w/2, h/2, Color(255,255,255,200),1 ,1)
	end

	local createCaseKeyDescription = vgui.Create("RichText", self.mirrorPanel)
	createCaseKeyDescription:SetSize(315, 150)
	createCaseKeyDescription:SetPos((self.mirrorPanel:GetWide()/4) - (315/2) + 5, 235 - 32)
	createCaseKeyDescription:SetVerticalScrollbarEnabled(false)
	function createCaseKeyDescription:PerformLayout()
		self:SetFontInternal(BU3.UI.Fonts["smallest_reg"])
	end
	createCaseKeyDescription:SetText("Select this to create a case. A case is basicly a container that requires (or not) a key to open it. You have a chance of getting a random item.")

	local createItemDescription = vgui.Create("RichText", self.mirrorPanel)
	createItemDescription:SetSize(315, 150)
	createItemDescription:SetPos(((self.mirrorPanel:GetWide()/4) * 3) - (315/2) + 5, 235 - 32)
	createItemDescription:SetVerticalScrollbarEnabled(false)
	function createItemDescription:PerformLayout()
		self:SetFontInternal(BU3.UI.Fonts["smallest_reg"])
	end
	createItemDescription:SetText("Select this to create a key. A key is used for open containers/cases in order to receive a random item.")

	local createCaseKeyButton = BU3.UI.Elements.CreateStandardButton("CREATE CASE", self.mirrorPanel, function(s)
		contentFrame:LoadPage("caseeditor")
	end)
	createCaseKeyButton:SetSize(180, 45)
	createCaseKeyButton:SetPos((self.mirrorPanel:GetWide()/4) - (180/2), 385 - 32)

	local createItemButton = BU3.UI.Elements.CreateStandardButton("CREATE KEY", self.mirrorPanel, function(s)
		contentFrame:LoadPage("keyeditor")
	end)
	createItemButton:SetSize(180, 45)
	createItemButton:SetPos(((self.mirrorPanel:GetWide()/4) * 3) - (180/2), 385 - 32)

end

--This is called when the page should unload
function PAGE:Unload(contentFrame, direction)
	self.mirrorPanel:Remove() --Remove all the UI we added to the content frame
end

--This can be called by anything to pass a message to the page
function PAGE:Message(message, data)

end

--Register the page
BU3.UI.RegisterPage("casekeyselector", PAGE)