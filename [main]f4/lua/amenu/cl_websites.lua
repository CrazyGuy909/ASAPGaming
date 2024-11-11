------------------ Website link page
local PANEL = {}

function PANEL:Init()
	self.Type 		= 0
	self.Link 		= ""		self.IsSitePage = true

	self:Dock(FILL)
end

function PANEL:OpenPage()
	gui.OpenURL(self.Link)
end

function PANEL:SetLink(link)
	self.Link = link
end

vgui.Register("aMenuWebBase", PANEL, "DPanel")