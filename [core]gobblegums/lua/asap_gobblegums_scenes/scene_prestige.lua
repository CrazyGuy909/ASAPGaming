local SCENE = {}
SCENE.Description = "Here you can see your statistics and they can allows you to pretige to gain rewards."
local MATERIAL_LOGO = Material("asap_gumballs/logo1.png", "noclamp smooth")
local MATERIAL_LOADING = Material("asap_gumballs/loading.png", "noclamp smooth")

function SCENE:OnLoad(contentFrame)
    SCENE.contentFrame = contentFrame
    local hasLevel = ASAP_GOBBLEGUMS.level >= 50
    local hasMoney = LocalPlayer():canAfford(1000000)
    --Create two seperate panels
    local leftPanel = vgui.Create("DScrollPanel", contentFrame)
    leftPanel:SetPos(0, 0)
    leftPanel:SetSize(contentFrame:GetWide() - 300 - 2, contentFrame:GetTall())

    leftPanel.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(26, 26, 26))
        --Draw header
        draw.RoundedBox(4, 0, 0, w, 35, Color(36, 36, 36))
        --Draw title
        draw.SimpleText("Statistics", XeninUI:Font(24), 10, 35 / 2, Color(255, 255, 255, 255), 0, 1)
        --Draw the money
        draw.SimpleText("Money", XeninUI:Font(20), 10, 60, Color(255, 255, 255, 255), 0, 1)
        draw.SimpleText("£" .. string.Comma(LocalPlayer():getDarkRPVar("money")), XeninUI:Font(20), 10 + 150, 60, Color(120, 255, 120, 255), 0, 1)
        draw.SimpleText("Level", XeninUI:Font(20), 10, 60 + 35, Color(255, 255, 255, 255), 0, 1)
        draw.SimpleText("XP", XeninUI:Font(20), 10, 60 + 35 + 35, Color(255, 255, 255, 255), 0, 1)
        draw.SimpleText("Points", XeninUI:Font(20), 10, 60 + 35 + 35 + 35, Color(255, 255, 255, 255), 0, 1)
        surface.SetDrawColor(Color(255, 255, 255, 255))
        surface.SetMaterial(MATERIAL_LOGO)
        surface.DrawTexturedRect(10 + 150, 60 + 35 + 35 + 35 - 11, 24, 24)
        draw.SimpleText(string.Comma(ASAP_GOBBLEGUMS.gobblegumcredits), XeninUI:Font(20), 10 + 150 + 26, 60 + 35 + 35 + 35, Color(255, 255, 255, 255), 0, 1)
        --draw.SimpleText("Prestige", XeninUI:Font(20), 10, 60 + 35 + 35 + 35 + 35, Color(255,255,255,255), 0, 1)
        --draw.SimpleText("21", XeninUI:Font(20), 10 + 150, 60 + 35 + 35 + 35 + 35, Color(120,255,120,255), 0, 1)
        draw.SimpleText("Slots", XeninUI:Font(20), 10, 60 + 35 + 35 + 35 + 35, Color(255, 255, 255, 255), 0, 1)
        surface.SetDrawColor(Color(255, 255, 255, 255))
        surface.SetMaterial(MATERIAL_LOGO)
        surface.DrawTexturedRect(10 + 150, 60 + 35 + 35 + 35 + 35 - 11, 24, 24)
        draw.SimpleText("-" .. string.Comma(ASAP_GOBBLEGUMS.spentOnSlots), XeninUI:Font(20), 10 + 150 + 26, 60 + 35 + 35 + 35 + 35, Color(255, 120, 120, 255), 0, 1)
    end

    local rightPanel = vgui.Create("DPanel", contentFrame)
    rightPanel:SetPos(contentFrame:GetWide() - 300 + 3, 0)
    rightPanel:SetSize(300 - 3, contentFrame:GetTall())

    rightPanel.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(26, 26, 26))
        --Draw header
        draw.RoundedBox(4, 0, 0, w, 35, Color(36, 36, 36, 255))
        --Draw title
        draw.SimpleText("Requirments", XeninUI:Font(24), 10, 35 / 2, Color(255, 255, 255, 255), 0, 1)
        draw.SimpleText("Money", XeninUI:Font(24), 10, 60, Color(255, 255, 255, 255), 0, 1)

        if hasMoney then
            draw.SimpleText("£" .. string.Comma(1000000), XeninUI:Font(24), 10 + 150, 60, Color(120, 255, 120, 255), 0, 1)
        else
            draw.SimpleText("£" .. string.Comma(1000000), XeninUI:Font(24), 10 + 150, 60, Color(255, 120, 120, 255), 0, 1)
        end

        draw.SimpleText("Levels", XeninUI:Font(24), 10, 60 + 35, Color(255, 255, 255, 255), 0, 1)

        if hasLevel then
            draw.SimpleText("50", XeninUI:Font(24), 10 + 150, 60 + 35, Color(120, 255, 120, 255), 0, 1)
        else
            draw.SimpleText("50", XeninUI:Font(24), 10 + 150, 60 + 35, Color(255, 120, 120, 255), 0, 1)
        end
    end

    local purchaseButton = vgui.Create("DButton", rightPanel)
    purchaseButton:SetPos(4, rightPanel:GetTall() - 68)
    purchaseButton:SetText("")
    purchaseButton:SetSize(rightPanel:GetWide() - 10, 64)

    purchaseButton.Paint = function(s, w, h)
        if hasLevel and hasMoney then
            draw.RoundedBox(8, 0, 0, w, h, Color(255, 145, 0))
            draw.SimpleText("PRESTIGE", XeninUI:Font(24), w / 2, h / 2, Color(255, 255, 255, 255), 1, 1)
        else
            draw.RoundedBox(8, 0, 0, w, h, Color(255, 145, 0, 162))
            draw.SimpleText("PRESTIGE", XeninUI:Font(24), w / 2, h / 2, Color(255, 255, 255, 100), 1, 1)
        end
    end

    purchaseButton.DoClick = function()
        if hasLevel and hasMoney then
            net.Start("ASAPGGOBBLEGUMS:Prestige")
            net.SendToServer()
        end
    end

    local pBar = vgui.Create("DPanel", leftPanel)
    pBar:SetPos(10 + 150, 60 + 20)
    pBar.progress = 0
    pBar.percent = 0.2

    pBar.Think = function(s)
        s.progress = s.progress + (FrameTime() * 0.03)
        pBar.percent = Lerp(4 * FrameTime(), pBar.percent, ASAP_GOBBLEGUMS.xp / ASAP_GOBBLEGUMS.xpToNextLevel)

        if s.progress > 1 then
            s.progress = s.progress - 1
        end
    end

    pBar:SetSize(leftPanel:GetWide() - 180, 22)

    pBar.Paint = function(s, w, h)
        --Draw the background image
        surface.SetDrawColor(Color(255, 145, 0))
        surface.SetMaterial(MATERIAL_LOADING)
        surface.DrawTexturedRect(w * s.progress, 0, w, h)
        surface.DrawTexturedRect(0 - w + (w * s.progress) + 10, 0, w, h)
        surface.DrawTexturedRect(0 - (w * 2) + (w * s.progress) + 10, 0, w, h)
        draw.RoundedBox(0, w - (w * (1 - s.percent)), 0, w * (1 - s.percent), h, Color(23, 31, 41, 255))
        --Draw center text
        draw.SimpleText("Level " .. ASAP_GOBBLEGUMS.level, XeninUI:Font(16), w / 2, h / 2, Color(255, 255, 255, 255), 1, 1)
        draw.SimpleText("Level " .. (ASAP_GOBBLEGUMS.level - 1), XeninUI:Font(16), 5, h / 2, Color(255, 255, 255, 150), 0, 1)
        draw.SimpleText("Level " .. (ASAP_GOBBLEGUMS.level + 1), XeninUI:Font(16), w - 5, h / 2, Color(255, 255, 255, 150), 2, 1)
        surface.SetDrawColor(Color(255, 255, 255, 255))
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    local pBar2 = vgui.Create("DPanel", leftPanel)
    pBar2:SetPos(10 + 150, 60 + 20 + 35)
    pBar2.progress = 0
    pBar2.percent = 0.2

    pBar2.Think = function(s)
        s.progress = s.progress + (FrameTime() * 0.03)
        pBar2.percent = Lerp(4 * FrameTime(), pBar2.percent, ASAP_GOBBLEGUMS.xp / ASAP_GOBBLEGUMS.xpToNextLevel)

        if s.progress > 1 then
            s.progress = s.progress - 1
        end
    end

    pBar2:SetSize(leftPanel:GetWide() - 180, 22)

    pBar2.Paint = function(s, w, h)
        --Draw the background image
        surface.SetDrawColor(Color(255, 145, 0))
        surface.SetMaterial(MATERIAL_LOADING)
        surface.DrawTexturedRect(w * s.progress, 0, w, h)
        surface.DrawTexturedRect(0 - w + (w * s.progress) + 10, 0, w, h)
        surface.DrawTexturedRect(0 - (w * 2) + (w * s.progress) + 10, 0, w, h)
        draw.RoundedBox(0, w - (w * (1 - s.percent)), 0, w * (1 - s.percent), h, Color(23, 31, 41, 255))
        draw.SimpleText(ASAP_GOBBLEGUMS.xp, XeninUI:Font(16), w / 2, h / 2, Color(255, 255, 255, 255), 1, 1)
        draw.SimpleText("0 XP", XeninUI:Font(16), 5, h / 2, Color(255, 255, 255, 150), 0, 1)
        draw.SimpleText(ASAP_GOBBLEGUMS.xpToNextLevel .. " XP", XeninUI:Font(16), w - 5, h / 2, Color(255, 255, 255, 150), 2, 1)
        surface.SetDrawColor(Color(255, 255, 255, 255))
        surface.DrawOutlinedRect(0, 0, w, h)
    end
end

function SCENE:OnUnload(contentFrame)
end

function SCENE:Think(contentFrame)
end

ASAP_GOBBLEGUMS.Scenes:RegisterScene("prestige", SCENE)