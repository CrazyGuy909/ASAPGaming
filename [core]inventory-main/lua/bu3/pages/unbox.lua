local PAGE = {}
--When set to true it will start spinning the tape
PAGE.startSpinning = false
PAGE.open = false

--This is called when the page is called to load
function PAGE:Load(contentFrame, caseID)
    if (contentFrame.NavBar) then
        contentFrame.NavBar:SelectButton("unknown") --Deselects all the buttons
    end
    self.previousSoundTime = CurTime()
    self.previousSoundPosition = 0
    local case = BU3.Items.Items[caseID]
    self.startSpinning = false
    self.open = true
    self.mirrorPanel = vgui.Create("DPanel", contentFrame)
    self.mirrorPanel:Dock(FILL)
    self.mirrorPanel.Paint = function(s, w, h) end --Draw seperator --draw.RoundedBox(0,0, 318 , w, 2, Color(40,40,45)) --Clear background
    self.mirrorPanel.PaintOver = function(s, w, h)
        if input.IsKeyDown(KEY_F) then
            surface.SetDrawColor(0, 0, 0, 225)
            surface.DrawRect(0, 0, w, h)
            draw.SimpleText("In honour of all 'It doesnt feel right...' moments", "Gangs.Medium", w / 2, h / 3, color_white, 1, 1)
        end
    end
    if case == nil or case.type ~= "case" then
        local textPanel = vgui.Create("DPanel", self.mirrorPanel)
        textPanel:Dock(TOP)
        textPanel:SetTall(75)

        textPanel.Paint = function(s, w, h)
            draw.SimpleText("ERROR : CASE INVALID", BU3.UI.Fonts["large_bold"], w / 2, h / 2, Color(255, 255, 255, 20), 1, 1)
        end

        return
    end

    local textPanel = vgui.Create("DPanel", self.mirrorPanel)
    textPanel:Dock(TOP)
    textPanel:SetTall(64)

    textPanel.Paint = function(s, w, h)
        draw.SimpleText("Unboxing: " .. case.name, BU3.UI.Fonts["large_bold"], w / 2, h / 2, Color(255, 255, 255, 175), 1, 1)
    end

    local scrollWindowPanel = vgui.Create("DPanel", self.mirrorPanel)
    scrollWindowPanel:Dock(TOP)
    scrollWindowPanel:SetTall(140)
    scrollWindowPanel:DockMargin(0, 32, 0, 0)
    scrollWindowPanel.Paint = function() end
    --Magic number is 72
    local tapePanel = vgui.Create("DPanel", scrollWindowPanel)
    tapePanel:SetSize(132 * 80, 140)
    tapePanel.soundPlayed = false
    tapePanel.Paint = function(s, w, h)
    end

    contentFrame:InvalidateLayout(true)
	local fixed = math.ceil((self.mirrorPanel:GetWide() / 2 - 32) / 132)
 	tapePanel.targetPos = -(72 - fixed) * 132 + (math.random(-16, 16))
    local speed = 1
    local lerpedPos = 0

    tapePanel.Think = function(s)
        if self.startSpinning then
            if self.soundPlayed == false then
                surface.PlaySound("buttons/lever1.wav")
                self.soundPlayed = true
            end

            lerpedPos = Lerp(speed * FrameTime(), lerpedPos, s.targetPos)
            s:SetPos(lerpedPos, 0)

            if lerpedPos - s.targetPos < 5 then
                --s.Think = function() end
                self.startSpinning = false
                surface.PlaySound("buttons/lever6.wav")
                s.targetPos = -(132 / 2 - fixed) * 132 + (math.random(-16, 16))
                speed = 1
                lerpedPos = 0

                timer.Simple(0.5, function()
                    if IsValid(contentFrame) then
                        contentFrame:LoadPage("inventory")
                    end
                end)
            end

            local newSoundPos = math.floor((lerpedPos + 96) / (20 + (132)))

            if newSoundPos ~= self.previousSoundPosition then
                if CurTime() - self.previousSoundTime > 0.15 then
                    surface.PlaySound("ub3/click.wav")
                    self.previousSoundTime = CurTime()
                    self.previousSoundPosition = newSoundPos
                end
            end
        else
            self.soundPlayed = false
        end
    end

    --Display all the items
    local itemPanels = {}
    local randomItems = BU3.Chances.GenerateList(case.itemID, 80)

    for i = 1, 80 do
        local item = BU3.Items.Items[randomItems[i]]
        local xpos = 20 + ((i - 1) * 132)
        local xsize = 130
        if item == nil then continue end
        local borderColor = item.itemColorCode or 1
        local borderColorRGB = BU3.Items.RarityToColor[borderColor]
        local p = vgui.Create("DPanel", tapePanel)
        p:SetPos(xpos, 0)
        p:SetSize(xsize, 140)

        p.Paint = function(s, w, h)
            BU3.Items.RarityToFrame[borderColor](0, 0, w, h)
            --Draw the item name
            local name = item.name

            if string.len(name) >= 15 then
                name = string.sub(name, 1, 12) .. "..."
            end

            draw.SimpleText(name, BU3.UI.Fonts["small_reg"], w / 2, 17, Color(200, 200, 200, 255), 1, 1)
        end

        p.PaintOver = function(s, w, h)
            if (isnumber(case.items[item.itemID]) or not case.items[item.itemID].quantity or case.items[item.itemID].quantity == 1) then return end
            draw.SimpleText("x" .. case.items[item.itemID].quantity, BU3.UI.Fonts["small_reg"], w - 4, h - 2, Color(200, 200, 200, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        end

        itemPanels[i] = p
        --Create the item preview
        local iconPreview = nil

        if item.iconIsModel then
            iconPreview = BU3.UI.Elements.ModelView(item.iconID, item.zoom, p)
        else
            iconPreview = BU3.UI.Elements.IconView(item.iconID, item.color, p, false)
        end

        iconPreview:Dock(FILL)
        iconPreview:DockMargin(16, 32, 16, 12)
        iconPreview.zoom = item.zoom
        p.iconPreview = iconPreview
    end

    local gradientWindow = vgui.Create("DPanel", scrollWindowPanel)
    gradientWindow:Dock(FILL)

    gradientWindow.Paint = function(s, w, h)
        --Draw left size gradient
        surface.SetDrawColor(Color(255, 255, 255, 255))
        surface.SetMaterial(BU3.UI.Materials.gradient)
        surface.DrawTexturedRectRotated(w - 98, h / 2, 200, h, 180)
        surface.DrawTexturedRect(0, 0, 200, h)
    end

    local marker1 = vgui.Create("DPanel", self.mirrorPanel)
    marker1:SetPos(self.mirrorPanel:GetWide() / 2 - (22 / 2), 66)
    marker1:SetSize(22, 20)

    marker1.Paint = function(s, w, h)
        surface.SetDrawColor(Color(39, 121, 189))
        surface.SetMaterial(BU3.UI.Materials.marker)
        surface.DrawTexturedRectRotated(w / 2, h / 2, h, w, -90)
    end

    local marker2 = vgui.Create("DPanel", self.mirrorPanel)
    marker2:SetPos(self.mirrorPanel:GetWide() / 2 - (22 / 2), 246)
    marker2:SetSize(22, 20)

    marker2.Paint = function(s, w, h)
        surface.SetDrawColor(Color(39, 121, 189))
        surface.SetMaterial(BU3.UI.Materials.marker)
        surface.DrawTexturedRectRotated(w / 2, h / 2, h, w, 90)
    end

    --Unbox button
    --350
    local unboxButton = BU3.UI.Elements.CreateStandardButton("Open Case", self.mirrorPanel, function()
        net.Start("BU3:AttemptUnbox")
        net.WriteInt(case.itemID, 32)
        net.SendToServer()
    end)

    unboxButton:Dock(TOP)
    unboxButton:SetTall(42)
    unboxButton:DockMargin(self.mirrorPanel:GetWide() * .4, 42, self.mirrorPanel:GetWide() * .4, 8)
    local textPanel2 = vgui.Create("DPanel", self.mirrorPanel)
    textPanel2:Dock(TOP)
    textPanel2:SetTall(36)

    textPanel2.Paint = function(s, w, h)
        draw.SimpleText("Items contained inside: " .. case.name, BU3.UI.Fonts["med_bold"], w / 2, h / 2, Color(255, 255, 255, 175), 1, 1)
    end

    local itemContainedPanel = vgui.Create("DScrollPanel", self.mirrorPanel)
    itemContainedPanel:Dock(FILL)
    itemContainedPanel:DockMargin(16, 8, 16, 8)
    local sbar = itemContainedPanel:GetVBar()

    function sbar:Paint(w, h)
        --draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
    end

    function sbar.btnUp:Paint(w, h)
        --draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 100, 0 ) )
    end

    function sbar.btnDown:Paint(w, h)
        --draw.RoundedBox( 0, 0, 0, w, h, Color( 200, 100, 0 ) )
    end

    sbar.btnGrip:NoClipping(true)

    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(8, 4, -10, w - 4, h + 20, Color(39, 121, 189, 255))
    end

    --Create the list of items
    --for k, v in pairs(items) do
    local x, y = 0, 0
    local wider = 0
    local items = table.Copy(case.items)
	local target = {}
	for k, v in pairs(items) do
		table.insert(target, k)
	end
	local wider = 0
	table.sort(target, function(a, b)
		return (BU3.Items.Items[a].itemColorCode or 0) < (BU3.Items.Items[b].itemColorCode or 0)
	end)

	for _, k in SortedPairs(target) do
        local item = BU3.Items.Items[k]
        local xpos = x * 132
        local xsize = 130
        local borderColor = item.itemColorCode or 1
        local borderColorRGB = BU3.Items.RarityToColor[borderColor]
        local p = vgui.Create("DPanel", itemContainedPanel)
        p:SetPos(xpos, y * 155)
        p:SetSize(xsize, 140)

        p.Paint = function(s, w, h)
            BU3.Items.RarityToFrame[borderColor](0, 0, w, h)
            --Draw the item name
            local name = item.name

            if string.len(name) >= 15 then
                name = string.sub(name, 1, 12) .. "..."
            end

            draw.SimpleText(name, BU3.UI.Fonts["small_reg"], w / 2, 17, Color(200, 200, 200, 255), 1, 1)
        end

        p.PaintOver = function(s, w, h)
            if (isnumber(k) or k.quantity == 1) then return end
            draw.SimpleText("x" .. k.quantity, BU3.UI.Fonts["small_reg"], w - 4, h - 2, Color(200, 200, 200, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        end

        --Create the item preview
        local iconPreview = nil

        if item.iconIsModel then
            iconPreview = BU3.UI.Elements.ModelView(item.iconID, item.zoom, p)
        else
            iconPreview = BU3.UI.Elements.IconView(item.iconID, item.color, p, false)
        end

        iconPreview:Dock(FILL)
        iconPreview:DockMargin(16, 32, 16, 12)
        iconPreview.zoom = item.zoom

        --Increment offet
        if ((wider + 132) > self.mirrorPanel:GetWide() - 132) then
            y = y + 1
            wider = 0
            x = 0
        else
            wider = wider + 132
            x = x + 1
        end
    end

    local gradientWindow2 = vgui.Create("DPanel", self.mirrorPanel)
    gradientWindow2:SetPos(125, 490)
    gradientWindow2:SetSize(580, 240)

    gradientWindow2.Paint = function(s, w, h)
        --Draw left size gradient
        --draw.RoundedBox(0,0,0,w,h,Color(255,255,255))
        surface.SetDrawColor(Color(255, 255, 255, 255))
        surface.SetMaterial(BU3.UI.Materials.gradient)
        --surface.DrawTexturedRectRotated(w/2, 5, 10, w, -90)
        surface.DrawTexturedRectRotated(w / 2, h - 20, 40, w, 90)
    end

    --surface.DrawTexturedRect(0,0,200,h)
    net.Receive("BU3:TriggerUnboxAnimation", function()
        local itemID = net.ReadInt(32)

        --Lets check if the page is still valid, if so set up the last item
        --and play the animation
        if self.open and IsValid(itemPanels[72]) then
            local i = 72
            --Set up the item
			local x, y = itemPanels[i]:GetPos()
            itemPanels[i]:Remove()
            local item = BU3.Items.Items[itemID]
            local xpos = 20 + ((i - 1) * 132)
            local xsize = 130
            local borderColor = item.itemColorCode or 1
            local borderColorRGB = BU3.Items.RarityToColor[borderColor]
            local p = vgui.Create("DPanel", tapePanel)
            p:SetPos(x, y)
            p:SetSize(xsize, 140)

            p.Paint = function(s, w, h)
                BU3.Items.RarityToFrame[borderColor](0, 0, w, h)
                --Draw the item name
                local name = item.name

                if string.len(name) >= 15 then
                    name = string.sub(name, 1, 12) .. "..."
                end

                draw.SimpleText(name, BU3.UI.Fonts["small_reg"], w / 2, 17, Color(200, 200, 200, 255), 1, 1)
            end

            itemPanels[i] = p
            --Create the item preview
            local iconPreview = nil

            if item.iconIsModel then
                iconPreview = BU3.UI.Elements.ModelView(item.iconID, item.zoom, p)
            else
                iconPreview = BU3.UI.Elements.IconView(item.iconID, item.color, p, false)
            end

            iconPreview:Dock(FILL)
            iconPreview:DockMargin(16, 32, 16, 12)
            --iconPreview:SetPos(12, 25 + 3)
            --iconPreview:SetSize(130 - 24, 130 - 24)
            iconPreview.zoom = item.zoom
            p.iconPreview = iconPreview
            --Begin spinning
            self.startSpinning = true
        end
    end)
end

--This is called when the page should unload
function PAGE:Unload(contentFrame, direction)
    if IsValid(self.mirrorPanel) then
        self.mirrorPanel:Remove() --Remove all the UI we added to the content frame
    end
    self.open = false
end

--This can be called by anything to pass a message to the page
function PAGE:Message(message, data)
end

--Register the page
BU3.UI.RegisterPage("unbox", PAGE)