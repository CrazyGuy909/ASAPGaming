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
		draw.SimpleText("HELP", BU3.UI.Fonts["large_bold"], w/2, h/2, Color(255,255,255,20),1 ,1)
	end

	local createCaseKeyText = vgui.Create("DPanel", self.mirrorPanel)
	createCaseKeyText:SetSize(400, 75)
	createCaseKeyText:SetPos((self.mirrorPanel:GetWide()/4) - 200, 165 - 32)
	createCaseKeyText.Paint = function(s , w , h)
		draw.SimpleText("USERS", BU3.UI.Fonts["med_bold"], w/2, h/2, Color(255,255,255,200),1 ,1)
	end

	local createItemText = vgui.Create("DPanel", self.mirrorPanel)
	createItemText:SetSize(400, 75)
	createItemText:SetPos(((self.mirrorPanel:GetWide()/4) * 3) - 200, 165 - 32)
	createItemText.Paint = function(s , w , h)
		draw.SimpleText("DEVELOPERS", BU3.UI.Fonts["med_bold"], w/2, h/2, Color(255,255,255,200),1 ,1)
	end

	local createCaseKeyDescription = vgui.Create("RichText", self.mirrorPanel)
	createCaseKeyDescription:SetSize(315, 400)
	createCaseKeyDescription:SetPos((self.mirrorPanel:GetWide()/4) - (315/2) + 5, 235 - 32)
	createCaseKeyDescription:SetVerticalScrollbarEnabled(false)
	function createCaseKeyDescription:PerformLayout()
		self:SetFontInternal(BU3.UI.Fonts["small_reg"])
	end
	createCaseKeyDescription:SetText("Hello and welcome to Blue's Unboxing 3! This addon is designed to replicate a simular experience to unboxing crates on CSGO. The difference is you can do more than just unboxing weapons using this, you can unbox anything! To start visit the store on the left, then purchase a case and a key that matches it. Once you have both go to the inventory and click on the case to open it using the key. This will grant you a random item, then go to the inventory to equip it. You can also send item to each other and soon the addon will support a full community market for you to sell and exchange items that way too!")

	local createItemDescription = vgui.Create("RichText", self.mirrorPanel)
	createItemDescription:SetSize(315, 400)
	createItemDescription:SetPos(((self.mirrorPanel:GetWide()/4) * 3) - (315/2) + 5, 235 - 32)
	createItemDescription:SetVerticalScrollbarEnabled(false)
	function createItemDescription:PerformLayout()
		self:SetFontInternal(BU3.UI.Fonts["small_reg"])
	end
	createItemDescription:SetText("If you are a developer then first thanks for the purchase! In order to create anything you can access it in the settings menu on the bottom left. If you cannot see this settings button then its because you are not the correct rank to access it. To do so, edit the Lua config in the lua directory, there you can also set up MySQL and other important settings to improve the unboxing experience. You can create cases, keys and items all using the settings menu. It's pretty self explanatory but there is a video included in the top of the config that can help further if you are still struggling. Enjoy your addon!")
end

--This is called when the page should unload
function PAGE:Unload(contentFrame, direction)
	self.mirrorPanel:Remove() --Remove all the UI we added to the content frame
end

--This can be called by anything to pass a message to the page
function PAGE:Message(message, data)

end

--Register the page
BU3.UI.RegisterPage("help", PAGE)