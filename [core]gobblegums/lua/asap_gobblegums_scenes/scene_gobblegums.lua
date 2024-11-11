local SCENE = {}
SCENE.Description = "Here you can purchase permanant powerups to outmatch your enemies."
local MATERIAL_TEST = Material("asap_gumballs/balls/Aftertaste.png", "smooth")
local MATERIAL_LOGO = Material("asap_gumballs/logo1.png", "noclamp smooth")

--Switches the left panel to show infomation about the gobble gum
function SCENE:PreviewGumball(gumballID, rightPanel)
    local rotation = 360
    local scale = 0.1
    local alpha = 0
    local gumball = ASAP_GOBBLEGUMS.Gumballs[gumballID]
    local doesOwn = false

    if ASAP_GOBBLEGUMS.gumballs[gumballID] == true or (ASAP_GOBBLEGUMS.gumballs[gumballID] or 0) > 0 then
        doesOwn = true
    end

    --Clear previous infomation here!
    for k, v in pairs(rightPanel:GetChildren()) do
        v:Remove()
    end

    local p = vgui.Create("DPanel", rightPanel)
    p:SetPos(0, 0)
    p:SetSize(rightPanel:GetWide(), rightPanel:GetTall())

    p.Paint = function(s, w, h)
        draw.RoundedBox(8, 5, 5, w - 10, h - 10 - 35, Color(36, 36, 36))
        draw.RoundedBox(8, 5, 5, w - 10, 30, ASAP_GOBBLEGUMS.TYPE_TO_COLOR[gumball.type]) --Color(230, 100, 74))
        --Draw the name
        draw.SimpleText(gumball.name, "Arena.Small", w / 2, 20, Color(255, 255, 255, 255), 1, 1)
        --Draw the gumball
        surface.SetDrawColor(Color(255, 255, 255, alpha))
        surface.SetMaterial(gumball.icon)
        surface.DrawTexturedRectRotated(w / 2, 120, 128 * scale, 128 * scale, rotation)
    end

    p.Think = function(s)
        rotation = Lerp(10 * FrameTime(), rotation, 0)
        scale = Lerp(10 * FrameTime(), scale, 1)
        alpha = Lerp(4 * FrameTime(), alpha, 255)
    end

    --Create the right preview for the gumball
    --Start with the name
    --Description
    local richText = vgui.Create("RichText", p)
    richText:SetPos(10, 210)
    richText:SetVerticalScrollbarEnabled(false)

    function richText:PerformLayout()
        self:SetFontInternal("XeninUI.TextEntry")
        self:SetFGColor(Color(255, 255, 255))
    end

    richText:SetSize(p:GetWide() - 20, 400)
    richText:AppendText(gumball.description)

    if gumball.type == ASAP_GOBBLEGUMS.GUM_TYPE.Green and doesOwn == false then
        local purchaseButton = vgui.Create("DButton", p)
        purchaseButton:SetPos(5, p:GetTall() - 35)
        purchaseButton:SetText("")
        purchaseButton:SetSize(p:GetWide() - 10, 30)

        purchaseButton.Paint = function(s, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(29, 80, 46))
            draw.SimpleText("Purchase", "XeninUI.TextEntry", w - 10, h / 2, Color(255, 255, 255, 255), 2, 1)
            draw.SimpleText(gumball.price, "XeninUI.TextEntry", h + 2, h / 2, Color(255, 255, 255, 255), 0, 1)
            surface.SetDrawColor(Color(255, 255, 255, 255))
            surface.SetMaterial(MATERIAL_LOGO)
            surface.DrawTexturedRect(4, 4, h - 8, h - 8)
        end

        purchaseButton.DoClick = function(s)
            net.Start("ASAPGGOBBLEGUMS:Buy")
            net.WriteInt(gumballID, 32)
            net.SendToServer()
        end
    else
        if ASAP_GOBBLEGUMS.gumballs[gumball.id] == true or (ASAP_GOBBLEGUMS.gumballs[gumball.id] or 0) > 0 then
            local purchaseButton = vgui.Create("DButton", p)
            purchaseButton:SetPos(5, p:GetTall() - 35)
            purchaseButton:SetText("")
            purchaseButton:SetSize(p:GetWide() - 10, 30)

            purchaseButton.Paint = function(s, w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(29, 80, 46))

                if not isbool(ASAP_GOBBLEGUMS.gumballs[gumball.id]) then
                    draw.SimpleText(ASAP_GOBBLEGUMS.gumballs[gumball.id] .. " Owned", "GOBBLEGUMS:Buttons4", 10, h / 2, Color(255, 255, 255, 255), 0, 1)
                else
                    draw.SimpleText("Owned", "XeninUI.TextEntry", 10, h / 2, Color(255, 255, 255, 255), 0, 1)
                end

                draw.SimpleText("Equip", "XeninUI.TextEntry", w - 10, h / 2, Color(255, 255, 255, 255), 2, 1)
            end

            purchaseButton.DoClick = function(s)
                ASAP_GOBBLEGUMS.Scenes.Scenes["equip"].GumballToEquip = gumball.id
                SCENE.contentFrame:LoadScene("equip")
            end
        else
            local purchaseButton = vgui.Create("DPanel", p)
            purchaseButton:SetPos(5, p:GetTall() - 35)
            purchaseButton:SetSize(p:GetWide() - 10, 30)

            purchaseButton.Paint = function(s, w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(29, 80, 46, 50))
                draw.SimpleText("0 Owned", "XeninUI.TextEntry", 10, h / 2, Color(255, 255, 255, 50), 0, 1)
                draw.SimpleText("Equip", "XeninUI.TextEntry", w - 10, h / 2, Color(255, 255, 255, 50), 2, 1)
            end
        end

        if (gumball.purchasable) then
            local purchaseButton = vgui.Create("DButton", p)
            purchaseButton:SetPos(5, p:GetTall() - 70)
            purchaseButton:SetText("")
            purchaseButton:SetSize(p:GetWide() - 10, 30)

            purchaseButton.Paint = function(s, w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(29, 80, 46))
                draw.SimpleText("Purchase", "XeninUI.TextEntry", w - 10, h / 2, Color(255, 255, 255, 255), 2, 1)
                draw.SimpleText(gumball.price, "XeninUI.TextEntry", h + 2, h / 2, Color(255, 255, 255, 255), 0, 1)
                surface.SetDrawColor(Color(255, 255, 255, 255))
                surface.SetMaterial(MATERIAL_LOGO)
                surface.DrawTexturedRect(4, 4, h - 8, h - 8)
            end

            purchaseButton.DoClick = function(s)
                net.Start("ASAPGGOBBLEGUMS:Buy")
                net.WriteInt(gumballID, 32)
                net.SendToServer()
            end
        end
    end
end

function SCENE:OnLoad(contentFrame)
    SCENE.contentFrame = contentFrame
    --Create two seperate panels
    local leftScroll = vgui.Create("XeninUI.ScrollPanel", contentFrame)
    leftScroll:SetPos(0, 0)
    leftScroll:SetSize(contentFrame:GetWide() - 300 - 2, contentFrame:GetTall())

    local leftPanel = vgui.Create("DIconLayout", leftScroll)
    leftPanel:SetPos(0, 0)
    leftPanel:SetSize(contentFrame:GetWide() - 300 - 2, contentFrame:GetTall())

    leftPanel.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(16, 16, 16))
    end

    local rightPanel = vgui.Create("DPanel", contentFrame)
    rightPanel:SetPos(contentFrame:GetWide() - 300 + 3, 0)
    rightPanel:SetSize(300 - 3, contentFrame:GetTall())

    rightPanel.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(26, 26, 26, 255))
    end

    local x = 0
    local y = 0
    local panels = {}
    local i = 1

    --List all the gumballs
    for k, v in SortedPairsByMemberValue(ASAP_GOBBLEGUMS.Gumballs, "type") do
        local p = vgui.Create("DButton", leftPanel)
        p:SetText("")
        p:SetPos(180 * x, 127 * y)
        p:SetSize(180, 127)
        p.selected = false
        p.id = v.id

        if ASAP_GOBBLEGUMS.gumballs[k] == true or (ASAP_GOBBLEGUMS.gumballs[k] or 0) > 0 then
            p.owned = true
            p.amount = ASAP_GOBBLEGUMS.gumballs[k]
        else
            p.owned = false
        end

        p.alpha = 0

        p.Paint = function(s, w, h)
            local c = table.Copy(ASAP_GOBBLEGUMS.TYPE_TO_COLOR[v.type])

            if not s.owned then
                c.a = 25
            end

            draw.RoundedBox(8, 3, 3, w - 6, h - 6, Color(36, 36, 36))
            draw.RoundedBox(8, 8, 8, w - 16, h - 16 - 30, Color(22, 22, 22))

            if s.selected then
                surface.SetDrawColor(Color(80, 255, 80, 255))
                surface.DrawOutlinedRect(0, 0, w, h)
                surface.SetDrawColor(Color(80, 255, 80, 5))
                surface.DrawRect(0, 0, w, h)
            elseif s:IsHovered() then
                surface.SetDrawColor(Color(255, 255, 255, 100 * s.alpha))
                surface.DrawOutlinedRect(0, 0, w, h)
                surface.SetDrawColor(Color(255, 255, 255, 5 * s.alpha))
                surface.DrawRect(0, 0, w, h)
                s.alpha = Lerp(12 * FrameTime(), s.alpha, 1)
            else
                if s.alpha > 0.02 then
                    surface.SetDrawColor(Color(255, 255, 255, 100 * s.alpha))
                    surface.DrawOutlinedRect(0, 0, w, h)
                    surface.SetDrawColor(Color(255, 255, 255, 5 * s.alpha))
                    surface.DrawRect(0, 0, w, h)
                    s.alpha = Lerp(12 * FrameTime(), s.alpha, 0)
                else
                    s.alpha = 0
                end
            end

            --Draw the gobble gum
            if s.owned then
                surface.SetDrawColor(Color(255, 255, 255, 255))
            else
                surface.SetDrawColor(Color(255, 255, 255, 25))
            end

            surface.SetMaterial(v.icon)
            surface.DrawTexturedRectRotated(w / 2, h / 2 - 15, 64, 64, 0)

            if v.type == 0 or v.purchasable then
                surface.SetMaterial(MATERIAL_LOGO)
                surface.DrawTexturedRectRotated(w - 50, h - 50, 16, 16, 0)
                draw.SimpleText(v.price, "GOBBLEGUMS:Buttons3", w - 40, h - 50, Color(255, 255, 255, 100), 0, 1)
            end

            --Draw name
            draw.RoundedBox(8, 8, h - 34, w - 16, 25, c) --Color(230, 100, 74))

            if s.owned then
                draw.SimpleText(v.name, "Arena.Small", w / 2, h - 22, Color(255, 255, 255, 255), 1, 1)
            else
                draw.SimpleText(v.name, "Arena.Small", w / 2, h - 22, Color(255, 255, 255, 50), 1, 1)
            end

            if s.owned == true then
                if not isbool(s.amount) then
                    draw.SimpleText(s.amount .. " Owned", "GOBBLEGUMS:Buttons3", 10, 10, Color(255, 255, 255, 100), 0, 0)
                end
            end
        end

        p.DoClick = function(s)
            self:PreviewGumball(s.id, rightPanel)

            for k, v in pairs(panels) do
                v.selected = false
            end

            s.selected = true
        end

        panels[i] = p
        x = x + 1

        if x > 3 then
            x = 0
            y = y + 1
        end

        i = i + 1
    end
end

function SCENE:OnUnload(contentFrame)
end

function SCENE:Think(contentFrame)
end

ASAP_GOBBLEGUMS.Scenes:RegisterScene("gobblegums", SCENE)