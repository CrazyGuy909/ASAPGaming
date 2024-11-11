
local PANEL = {}

local search = Material("xenin/search.png")

function PANEL:Init()
    self:Dock(FILL)

	self.Num 			= 1
	self.Key 			= 0

	self.Contents 		= {}
	self.Categories 	= {}
	self.Type 			= 0
	self.Placeholder 	= {}
	self.Placeholder.name = "None"
	self.Placeholder.price = ""
	self.Placeholder.description = ""
	self.Placeholder.model 		= ""

	self.ShouldEnable 	= true

    self.List = vgui.Create("DScrollPanel", self)
    self.List:Dock(FILL)
    self.List.Paint = function(this, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 16, 16, 255))
    end

    aMenu.PaintScroll(self.List)

	local cat = self:CreateNewCategory("Keybinds", self.List)

    for k, v in pairs(keybinds.cache) do
        local option = vgui.Create("ASAP.BindKey", cat)
        option.Bind = v
		option.Bind.id = k
		cat:AddChild(option, true)
    end

	hook.Run("PopulateSettings", self)
	
end


function PANEL:AddCheckbox(name, cvar, category, func)
	local convar = GetConVar(cvar)
	if not convar then return end
	local cat = self:CreateNewCategory(category or "Other", self.List)
	local option = vgui.Create("ASAP.Settings.Checkbox", cat)
	option.cvar = cvar
	option.perform = func
	option.name = name
	option:SetChecked(convar:GetInt() > 0)
	cat:AddChild(option, true)
end

function PANEL:AddButton(name, button, category, func)
	local cat = self:CreateNewCategory(category or "Other", self.List)
	local option = vgui.Create("ASAP.Settings.Button", cat)
	option.perform = func
	option.name = name
	option.button = button
	cat:AddChild(option, true)
end

function PANEL:AddSlider(name, cvar, min, max, category, func)
	local cat = self:CreateNewCategory(category or "Other", self.List)
	local option = vgui.Create("ASAP.Settings.Slider", cat)
	option.perform = func
	option.name = name
	option.Input:SetConVar(cvar)
	option.Input:SetMin(min)
	option.Input:SetMax(max)
	option.Input:SetDecimals(2)
	timer.Simple(0, function()
		if IsValid(option.Input) then
			option.Input.TextArea:SetText(math.Round(GetConVar(cvar):GetFloat(), 2))
			option.Input:SetValue(math.Round(GetConVar(cvar):GetFloat(), 2))
		end
	end)
	
	cat:AddChild(option, true)
end


function PANEL:AddColor(name, cvar, category, func)
	local cat = self:CreateNewCategory(category or "Other", self.List)
	local option = vgui.Create("ASAP.Settings.Color", cat)
	option.perform = func
	option.name = name
	option.cvar = cvar
	//option.Input:SetConVar(cvar)
	//option.Input:SetMin(min)
	//option.Input:SetMax(max)
	cat:AddChild(option, true)
end

function PANEL:AddCombo(name, items, cvar,category)
	local cat = self:CreateNewCategory(category or "Other", self.List)
	local option = vgui.Create("ASAP.Settings.Dropdown", cat)
	option.name = name
	option.cvar = cvar
	option.Selected = GetConVar(cvar):GetInt()
	
	option.Options = {}
	for k,v in pairs(items) do
		option.Options[k] = v
	end

	cat:AddChild(option, true)

end

function PANEL:AddTextbox(name, cvar, category, func)

end

function PANEL:CreateNewCategory(name, parent)

	for k, v in pairs(self.Categories) do
		if v:GetName() == name then
			return v
		end
	end

	local category = vgui.Create("aMenuCategory", parent)
	category:SetName(name)
	category:DockPadding(0, 56, 0, 0)
	table.insert(self.Categories, category)
	return category

end

function PANEL:Paint(w,h)
    draw.RoundedBoxEx(16, 0, 0, w, h, Color(6,6,6), false, false, false, true)  
end

vgui.Register("ASAP.Settings", PANEL, "DPanel")

timer.Simple(1, function()
	keybinds.RegisterBind("openSettings", "Opens settings menu", KEY_F8, // Button down func
		function()
			if (LocalPlayer():InArena()) then return end
			if IsValid(aMenu.Base) then
				aMenu.Base:SetCategory("Settings")
			else
				aMenu.Base = vgui.Create("aMenuBase")
				aMenu.Base:SetCategory("Settings")
			end
		end,
		function()
	end)
end)