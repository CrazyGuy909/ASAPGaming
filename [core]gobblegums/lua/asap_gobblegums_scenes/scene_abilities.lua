local SCENE = {}
SCENE.Description = "Purchase abilities to unlock new skills and features."

local MATERIAL_LOGO = Material("asap_gumballs/logo1.png", "noclamp smooth")


--Switches the left panel to show infomation about the gobble gum
function SCENE:PreviewAbility(abilityID, rightPanel)
	local rotation = 360
	local scale = 0.1
	local alpha = 0

	local ability = ASAP_GOBBLEGUMS.Abilities[abilityID]

	--Clear previous infomation here!
	for k, v in pairs(rightPanel:GetChildren()) do
		v:Remove()
	end

	local p = vgui.Create("DPanel", rightPanel)
	p:SetPos(0,0)
	p:SetSize(rightPanel:GetWide(), rightPanel:GetTall())
	p.Paint = function(s , w, h)
		draw.RoundedBox(0,5,5,w - 10,h - 10 - 35, Color(36, 36, 36))

		draw.RoundedBox(8,5,5,w - 10,30, Color(255, 136, 0, 255))--Color(230, 100, 74))

		--Draw the name
		draw.SimpleText(ability.name, "GOBBLEGUMS:Buttons5", w/2, 20, Color(255,255,255,255), 1, 1)

	end

	--Description
	local richText = vgui.Create( "RichText", p)
	richText:SetPos(10, 40)
	richText:SetVerticalScrollbarEnabled(false)
	function richText:PerformLayout()
		self:SetFontInternal( "GOBBLEGUMS:Buttons6" )
		self:SetFGColor( Color( 255, 255, 255 ) )
	end
	
	richText:SetSize(p:GetWide() - 20, 400)
	richText:AppendText(ability.description) 

	if ASAP_GOBBLEGUMS.gobblegumabilities[abilityID] ~= true then
		local purchaseButton = vgui.Create("DButton",p)
		purchaseButton:SetPos(5,p:GetTall() - 35)
		purchaseButton:SetText("")
		purchaseButton:SetSize(p:GetWide() - 10, 30)
		purchaseButton.Paint = function(s , w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(29, 80, 46))

			draw.SimpleText("Purchase", "GOBBLEGUMS:Buttons5", w - 10, h/2, Color(255,255,255,255), 2, 1)
			draw.SimpleText(ability.price, "GOBBLEGUMS:Buttons4", h + 2, h/2, Color(255,255,255,255), 0, 1)

			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(MATERIAL_LOGO)
			surface.DrawTexturedRect(4, 4, h-8, h-8)
		end
		purchaseButton.DoClick = function()
			net.Start("ASAPGGOBBLEGUMS:BuyAbility")
			net.WriteInt(abilityID,32)
			net.SendToServer()
		end
	else
		local purchaseButton = vgui.Create("DButton",p)
		purchaseButton:SetPos(5,p:GetTall() - 35)
		purchaseButton:SetText("")
		purchaseButton:SetSize(p:GetWide() - 10, 30)
		purchaseButton.Paint = function(s , w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(29, 80, 46))

			draw.SimpleText("Already Owned", "GOBBLEGUMS:Buttons5", w - 10, h/2, Color(255,255,255,75), 2, 1)
			draw.SimpleText(ability.price, "GOBBLEGUMS:Buttons4", h + 2, h/2, Color(255,255,255,75), 0, 1)

			surface.SetDrawColor(Color(255,255,255,255))
			surface.SetMaterial(MATERIAL_LOGO)
			surface.DrawTexturedRect(4, 4, h-8, h-8)
		end
	end
end

function SCENE:OnLoad(contentFrame)
 
	SCENE.contentFrame = contentFrame

	--Create two seperate panels
	local leftPanel = vgui.Create("DScrollPanel", contentFrame)
	leftPanel:SetPos(0,0)
	leftPanel:SetSize(contentFrame:GetWide() - 300 - 2, contentFrame:GetTall())
	leftPanel.Paint = function(s , w, h)
		draw.RoundedBox(0,0,0,w,h,Color(16, 16, 16, 255))
	end
	--[[
	local sbar = leftPanel:GetVBar()
	function sbar:Paint( w, h )
		draw.RoundedBox( 0, 0,0,w,h, Color(36, 36, 36, 255))
	end
	function sbar.btnUp:Paint( w, h )
		draw.RoundedBox( 0, 2, 2, w - 4, h - 4, Color(230, 100, 74,255))
	end
	function sbar.btnDown:Paint( w, h )
		draw.RoundedBox( 0, 2, 2, w - 4, h - 4, Color(230, 100, 74,255))
	end
	function sbar.btnGrip:Paint( w, h )
		draw.RoundedBox( 0, 2, 2, w - 4, h - 4, Color(230, 100, 74,255))
	end]]--

	local rightPanel = vgui.Create("DPanel", contentFrame)
	rightPanel:SetPos(contentFrame:GetWide() - 300 + 3,0)
	rightPanel:SetSize(300 - 3, contentFrame:GetTall())
	rightPanel.Paint = function(s , w, h)
		draw.RoundedBox(0,0,0,w,h,Color(26, 26, 26, 255))
	end

	local y = 5

	local buttons = {}
	local i = 0
	for k, v in pairs(ASAP_GOBBLEGUMS.Abilities) do
		local owns = ASAP_GOBBLEGUMS.Abilities

		local p = vgui.Create("DPanel", leftPanel)
		p:SetPos(5, y)
		p:SetSize(leftPanel:GetWide() - 5,51)
		p.Paint = function(s, w, h)
			draw.RoundedBox(8, 0, 0, w - 100 - 5 - 5, h, Color(36,36,36,255))
			if s.selected then
				local unlocked = true
				for k, v in pairs(v.requiredUnlocks) do
					if ASAP_GOBBLEGUMS.gobblegumabilities[v] ~= true then
						unlocked = false
					end
				end

				if unlocked then
					draw.RoundedBox(8, 0, 0, w - 100 - 5 - 5, h, Color(74, 230, 82,25))
				else
					draw.RoundedBox(8, 0, 0, w - 100 - 5 - 5, h, Color(105, 230, 74,5))
				end
			end

			if ASAP_GOBBLEGUMS.gobblegumabilities[k] then
				draw.SimpleText(v.name,"Arena.Small", 8, 5, Color(70,255,70,255), 0, 0)
			else
				draw.SimpleText(v.name,"Arena.Small", 8, 5, Color(255,255,255,255), 0, 0)
			end

			local text = v.description

			if string.len(text) > 80 then
				text = string.sub(text, 1, 80).."..."
			end

			draw.SimpleText(text,"ASAP.HUD.Mont16", 8, h/2 + 3, Color(255,255,255,100), 0, 0)

		end
		p.selected = false

		buttons[i] = p

		local b = vgui.Create("DButton",p)
		b:SetPos(p:GetWide() - 5 - 100, 0)
		b:SetText("")
		b:SetSize(100, p:GetTall())
		b.id = i
		b.Paint = function(s, w, h)
			--Check if its locked
			local unlocked = true
			for k, v in pairs(v.requiredUnlocks) do
				if ASAP_GOBBLEGUMS.gobblegumabilities[v] ~= true then
					unlocked = false
				end
			end

			if unlocked then
				if ASAP_GOBBLEGUMS.gobblegumabilities[k] then
					draw.RoundedBox(8, 0, 0, w, h, Color(255, 136, 0, 255))
					draw.SimpleText("OWNED", "Arena.Small", w/2, h/2, color_white, 1, 1)				
				else
					local f = s:IsHovered() and 66 or 46
					draw.RoundedBox(8, 0, 0, w, h, Color(f, f, f))
					draw.SimpleText("GET", "Arena.Small", w/2, h/2, Color(255,255,255,255), 1, 1)
				end
			else
				draw.RoundedBox(8, 0, 0, w, h, Color(36, 36, 36,255))
				draw.SimpleText("LOCKED", "Arena.Small", w/2, h/2, Color(255,255,255,75), 1, 1)			
			end
		end
		b.DoClick = function(s)
			SCENE:PreviewAbility(k, rightPanel)
			for k, v in pairs(buttons) do
				v.selected = false
			end
			buttons[s.id].selected = true
		end

		y = y + 51 + 5
		i = i + 1
	end
end

function SCENE:OnUnload(contentFrame)

end

function SCENE:Think(contentFrame)
	
end

ASAP_GOBBLEGUMS.Scenes:RegisterScene("abilities", SCENE)

