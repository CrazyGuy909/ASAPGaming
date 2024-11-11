local SCENE = {}
SCENE.Description = "Select a slot to place the gobblegum in"

local MATERIAL_SLOT = Material("asap_gumballs/slot.png", "smooth")
local MATERIAL_GLOW = Material("asap_gumballs/slot_glow.png", "smooth")
local MATERIAL_TEST = Material("asap_gumballs/balls/Aftertaste.png", "smooth")

SCENE.GumballToEquip = -1
local MATERIAL_UNKNOWN = Material("asap_gumballs/balls/questionmark.png", "smooth")
local function drawCircle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -370.0 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	--local a = math.rad( 0.1 ) -- This is needed for non absolute segment counts
	--table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end


function SCENE:OnLoad(contentFrame)

	SCENE.showWin = false
	SCENE.lastWin = ""

	SCENE.contentFrame = contentFrame

	local outwardsScale = 175

	--Create two seperate panels
	local centerPanel = vgui.Create("DPanel", contentFrame)
	centerPanel:SetPos(0,0)
	centerPanel:SetSize(contentFrame:GetWide(), contentFrame:GetTall())
	centerPanel.Paint = function(s , w, h)
		draw.RoundedBox(0,0,0,w,h,Color(23, 31, 41, 255))

		render.ClearStencil()
		render.SetStencilEnable(true)
		render.SetStencilTestMask(255)
		render.SetStencilWriteMask(255)
		render.SetStencilReferenceValue(5)
		render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
		render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
		render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
			surface.SetDrawColor(Color(0,0,0,1))
			drawCircle(w/2, h/2,190 * (outwardsScale/200), 100)
		render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)
		render.SetStencilPassOperation(STENCILOPERATION_KEEP)
		render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
		render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
			draw.NoTexture()
			surface.SetDrawColor(Color(22, 30, 40, 255))
			drawCircle(w/2, h/2, 220 * (outwardsScale/200), 100)
			surface.SetDrawColor(Color(36, 50, 67, 255))
			drawCircle(w/2, h/2, 210 * (outwardsScale/200), 100)
			surface.SetDrawColor(Color(22, 30, 40, 255))
			drawCircle(w/2, h/2, 200 * (outwardsScale/200), 100)
		render.SetStencilEnable( false )

	end
		local rotation = 0
	local buttons = {}
	local count = ASAP_GOBBLEGUMS.gobblegumsslotcount
	for i = 1 , count do
		local b = vgui.Create("DButton", centerPanel)
		b:SetSize(128, 128)
		b:SetText("")
		b.ID = ASAP_GOBBLEGUMS.slots[i] 
		b.scale = 1
		b.alpha = 0
		if ASAP_GOBBLEGUMS.slots[i] ~= nil then
			for k, v in pairs(ASAP_GOBBLEGUMS.cooldowns) do
				if k == ASAP_GOBBLEGUMS.slots[i] then
					b.cooldown = v
					break
				end
			end
		end
		b.startTime = CurTime()
		b.rotation = 360 - (((360.0/count) * i) + 180 - (360/count))
		b.Think = function(s)
			if(s:IsHovered()) then
				s.scale = Lerp(10 * FrameTime(), s.scale, 1.3)
			else
				s.scale = Lerp(6 * FrameTime(), s.scale, 1)
			end

			s:SetSize(math.floor(128 * s.scale), math.floor(128 * s.scale))
		end
		b.Paint = function(s, w, h)
			draw.NoTexture()
			surface.SetDrawColor(Color(22, 30, 40, 255))
			drawCircle(w/2, h/2, w/2, 42)
			if s.ID ~= nil and s.ID ~= -1 then
				local col = ASAP_GOBBLEGUMS.TYPE_TO_COLOR[ASAP_GOBBLEGUMS.Gumballs[s.ID].type]
				surface.SetDrawColor(col)
			else
				surface.SetDrawColor(Color(36, 50, 67, 255))
			end
			drawCircle(w/2, h/2, w/2 - 5, 42)
			surface.SetDrawColor(Color(22, 30, 40, 255))
			drawCircle(w/2, h/2, w/2 - 10, 42)

			if s.ID == nil or s.ID == -1 then
				surface.SetDrawColor(Color(100,100,100,150))
				surface.SetMaterial(MATERIAL_UNKNOWN)
				surface.DrawTexturedRectRotated(w/2, h/2, w - 30, h-30, 0)				
			else	
				surface.SetDrawColor(Color(255,255,255,Lerp(s.alpha/255, 50, 255)))
				surface.SetMaterial(ASAP_GOBBLEGUMS.Gumballs[s.ID].icon)
				surface.DrawTexturedRectRotated(w/2, h/2, w - 30, h-30, 180 - (rotation * 3) + 180)
			end

			--Draw the cooldown if there is one
			if s.cooldown ~= nil then
				--On a cooldown, draw a red circle
				if s.cooldown.activeTime < CurTime() then
					local timeLeft = s.cooldown.cooldown - CurTime()
					local text = timeLeft
					if timeLeft >= 0 then
						if timeLeft > 60 then
							local mins = math.floor(timeLeft / 60)
							text = mins.." MINS"
						else
							local seconds = math.floor(timeLeft)
							text = seconds.." SECS"
						end
					else
						s.cooldown = nil
						return
					end

					draw.NoTexture()
					surface.SetDrawColor(Color(230, 70, 40, 50))
					drawCircle(w/2, h/2, w/2 - 10, 42)

					--Draw the text
					draw.SimpleText(text, "GOBBLEGUMS:Buttons5", w/2 + 2, h/2 + 2, Color(0,0,0,255 - s.alpha), 1, 1)
					draw.SimpleText(text, "GOBBLEGUMS:Buttons5", w/2, h/2, Color(255,255,255,255 - s.alpha), 1, 1)
				else --In use, draw a green circle
					local timeLeft = s.cooldown.activeTime - CurTime()
					local text = timeLeft
					if timeLeft >= 0 then
						
						if timeLeft > 60 then
							local mins = math.floor(timeLeft / 60)
							text = mins.." MINS"
						else
							local seconds = math.floor(timeLeft)
							text = seconds.." SECS"
						end
					else
                        s.cooldown = nil
                        return
					end

					draw.NoTexture()
					surface.SetDrawColor(Color(40, 255, 70, 50))
					drawCircle(w/2, h/2, w/2 - 10, 42)

					--Draw the text
					draw.SimpleText(text, "GOBBLEGUMS:Buttons5", w/2 + 2, h/2 + 2, Color(0,0,0,255 - s.alpha), 1, 1)
					draw.SimpleText(text, "GOBBLEGUMS:Buttons5", w/2, h/2, Color(255,255,255,255 - s.alpha), 1, 1)
				end
				s.alpha = Lerp(10 * FrameTime(), s.alpha, 0)
			else
				if not s:IsHovered() then
					s.alpha = Lerp(10 * FrameTime(), s.alpha, 255)
				else
					s.alpha = Lerp(10 * FrameTime(), s.alpha, 0)
				end

				draw.SimpleText(i, "GOBBLEGUMS:Buttons10", (w/2) + 2, (h/2) + 2, Color(0,0,0,255 - s.alpha), 1, 1)
				draw.SimpleText(i, "GOBBLEGUMS:Buttons10", w/2, h/2, Color(255,255,255,255 - s.alpha), 1, 1)
			end
		end
		b.DoClick = function(s, w, h)
			net.Start("ASAPGGOBBLEGUMS:Equip")
			net.WriteUInt(i, 4)
			net.WriteInt(SCENE.GumballToEquip, 32)
			net.SendToServer()

			SCENE.contentFrame:LoadScene("gobblegums")
		end

		function b:OnCursorEntered()

		end

		function b:OnCursorExited()

		end

		buttons[i] = b
	end

	centerPanel.Think = function(s)
		for i = 1, count do 
			local b = buttons[i]

			local offsetX = math.sin(math.rad(b.rotation + rotation)) * outwardsScale
			local offsetY = math.cos(math.rad(b.rotation + rotation)) * outwardsScale

			b:SetPos(centerPanel:GetWide()/2 + offsetX - math.floor(b:GetWide()/2), centerPanel:GetTall()/2 + offsetY - math.floor(b:GetTall()/2))
		end
	end

end

function SCENE:OnUnload(contentFrame)

end

function SCENE:Think(contentFrame)
	
end

ASAP_GOBBLEGUMS.Scenes:RegisterScene("equip", SCENE)
