local SCENE = {}
SCENE.Description = "Here you can test your luck on the gobble gum slot. It costs 500 credits per spin."
local MATERIAL_SLOT = Material("asap_gumballs/slot.png", "smooth")
local MATERIAL_GLOW = Material("asap_gumballs/slot_glow.png", "smooth")
local MATERIAL_TEST = Material("asap_gumballs/balls/Aftertaste.png", "smooth")

local function Sinerp(s, e, v)
    return Lerp(v * v * (3 - 2 * v), s, e)
end

--Returns a number between 0 and 1 based on the time which is also between 0 and 1
local function SlotScaleToTimeline(time)
    if (time < 0.5) then
        return Sinerp(0, 1, time * 2)
    else
        return Sinerp(1, 0, (time * 2) - 1)
    end
end

local function SlotPosToTimeline(time)
    if (time < 0.5) then
        return Sinerp(0, 0.5, time * 2)
    else
        return Sinerp(0.5, 1, ((time * 2) - 1))
    end
end

local function SlotGlowAlphaToTimeline(time)
    if (time < 0.25) then
        return 0
    elseif (time < 0.75) then
        local t = (time - 0.25) * 2

        if t < 0.5 then
            return Sinerp(0, 1, t * 2)
        else
            return Sinerp(1, 0, (t * 2) - 1)
        end
    else
        return 0
    end
end

--Stores a reference to the reels
SCENE.reels = {}

net.Receive("ASAPGGOBBLEGUMS:SlotSpin", function()
    if SCENE.OPEN then
        for k, v in pairs(SCENE.reels) do
            v:Start()
        end
    end
end)

net.Receive("ASAPGGOBBLEGUMS:StopReel", function()
    if SCENE.OPEN then
        local reelID = net.ReadUInt(4)
        local gumballID = net.ReadInt(32)
        SCENE.reels[reelID]:Stop(gumballID)
    end
end)

--Stores all the previous gobblegums they were rewarded from the slot
SCENE.history = {}

net.Receive("ASAPGGOBBLEGUMS:DisplayReward", function()
    local reward = net.ReadInt(32)
    table.insert(SCENE.history, 1, reward)

    if SCENE.OPEN then
        SCENE:RefreshRewards()
        SCENE.showWin = true
        SCENE.lastWin = ASAP_GOBBLEGUMS.Gumballs[reward].name
    end
end)

function SCENE:RefreshRewards()
    --Clear previous  rewards
    if not IsValid(self.rightPanel) then return end

    for k, v in pairs(self.rightPanel:GetChildren()) do
        v:Remove()
    end

    local sPanel = vgui.Create("XeninUI.ScrollPanel", self.rightPanel)
    sPanel:SetPos(5, 40)
    sPanel:SetSize(self.rightPanel:GetWide() - 10, self.rightPanel:GetTall() - 45)
    
    local y = 0

    for k, v in pairs(SCENE.history) do
        local p = vgui.Create("DPanel", sPanel)
        p:SetSize(sPanel:GetWide(), 40)
        p:SetPos(0, y)

        p.Paint = function(s, w, h)
            local gb = ASAP_GOBBLEGUMS.Gumballs[v]
            local c = table.Copy(ASAP_GOBBLEGUMS.TYPE_TO_COLOR[gb.type])
            c.a = 25
            draw.RoundedBox(8, 0, 0, w, h, c)
            surface.SetDrawColor(Color(255, 255, 255, 255))
            surface.SetMaterial(gb.icon)
            surface.DrawTexturedRect(5, 5, h - 10, h - 10)
            --Draw the name
            draw.SimpleText(gb.name, "GOBBLEGUMS:Buttons4", w / 2, h / 2, Color(255, 255, 255, 255), 1, 1)
        end

        y = y + 45
    end
end

function SCENE:OnLoad(contentFrame)
    SCENE.showWin = false
    SCENE.lastWin = ""
    --Create two seperate panels

    local rightPanel = vgui.Create("DPanel", contentFrame)
    rightPanel:Dock(RIGHT)
    rightPanel:SetWide(300)

    rightPanel.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(26, 26, 26, 255))
        --Draw the title
        draw.RoundedBox(8, 0, 0, w, 35, Color(230, 74, 196))
        draw.SimpleText("Rewards", "Arena.Small", w / 2, 35 / 2, Color(255, 255, 255, 255), 1, 1)
    end

    SCENE.rightPanel = rightPanel

    local leftPanel = vgui.Create("DScrollPanel", contentFrame)
    leftPanel:Dock(FILL)

    leftPanel.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(16, 16, 16, 255))

        draw.SimpleText("Hold CTRL to spin multiple times", "Arena.Small", w / 2, 64, Color(255, 255, 255, 255), 1, 1)

        if SCENE.showWin then
            draw.SimpleText("You received : '" .. SCENE.lastWin .. "'", "Arena.Medium", w / 2, h * 0.90, Color(255, 255, 255, 255), 1, 1)
        end
    end

    leftPanel.PerformLayout = function(s, w, h)
        local origin = w / 2 - (160 * 3) / 2

        for k, v in pairs(s:GetCanvas():GetChildren()) do
            if (v.btn) then
                v:SetPos(w / 2 - (160 * 3) / 2 - 32, h / 2 - 200)
                continue
            end
            v:SetPos(origin, h / 2 - 200)
            v:SetSize(160, 324)
            origin = origin + 160
        end

    end

    local function createReel(id)
        --Create the slot panel
        local reel = vgui.Create("DPanel", leftPanel)
        reel.slotPanel = leftPanel

        reel.speed = 0
        reel.targetSpeed = 3.5
        reel.progress = 0
        reel.icons = {}

        for i = 1, 6 do
            reel.randNum = math.random(1, 22)

            while (ASAP_GOBBLEGUMS.Gumballs[reel.randNum].Unobtainable) do
                reel.randNum = math.random(1, ASAP_GOBBLEGUMS.MaxGum)
            end

            reel.icons[i] = {
                randNum = reel.randNum,
                icon = ASAP_GOBBLEGUMS.Gumballs[reel.randNum],
                progress = reel.progress + ((1 / 6) * (i - 1))
            }
        end

        reel.stopping = true

        function reel:Stop(gumballID)
            self.stopping = true
            self.progress = 0.1
            self.icons[4].icon = ASAP_GOBBLEGUMS.Gumballs[gumballID]
        end

        function reel:Start()
            self.speed = 0
            self.stopping = false
            self.targetSpeed = 3.5
        end

        reel.Paint = function(s, w, h)
            for i = 1, 6 do
                local p = s.progress + ((1 / 6) * (i - 1))

                if p > 2 then
                    p = p - 2
                end

                if p > 1 then
                    p = p - 1
                end

                local c = table.Copy(ASAP_GOBBLEGUMS.TYPE_TO_COLOR[s.icons[i].icon.type])
                c.a = SlotGlowAlphaToTimeline(p) * 50
                surface.SetDrawColor(c)
                surface.SetMaterial(MATERIAL_GLOW)
                surface.DrawTexturedRectRotated(w / 2 + 12, ((h + 200) * p) - 100, 86 * SlotScaleToTimeline(p) * 1.5, 86 * SlotScaleToTimeline(p) * 1.5, 0)
                surface.SetDrawColor(Color(255, 255, 255))
                surface.SetMaterial(s.icons[i].icon.icon)
                surface.DrawTexturedRectRotated(w / 2 + 12, ((h + 200) * p) - 100, 80 * SlotScaleToTimeline(p), 80 * SlotScaleToTimeline(p), 0)

                if s.icons[i].progress > p and not s.stopping then
                    --Create another random one
                    s.icons[i] = {
                        icon = ASAP_GOBBLEGUMS.Gumballs[math.random(3, 18)],
                        progress = p
                    }
                else
                    s.icons[i].progress = p
                end
            end
        end

        reel.Think = function(s)
            if not s.stopping then
                reel.progress = reel.progress + (FrameTime() * s.speed)

                if reel.progress > 1 then
                    reel.progress = 0
                end
            else
                s.progress = Lerp(45 * FrameTime(), s.progress, 0)
            end

            if not s.stopping and s.speed < s.targetSpeed then
                s.speed = s.speed + FrameTime() * 5
            end
        end

        SCENE.reels[id] = reel
    end

    createReel(1)
    createReel(2)
    createReel(3)

    local button = vgui.Create("DButton", leftPanel)
    button.btn = true
    button:SetText("")
    button:SetSize(609, 324)

    button.Paint = function(s, w, h)
        surface.SetDrawColor(Color(255, 255, 255, 255))
        surface.SetMaterial(MATERIAL_SLOT)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    button.DoClick = function(s)
        if (input.IsKeyDown(KEY_LALT) or input.IsKeyDown(KEY_LCONTROL)) then
            Derma_StringRequest("Multiple spin", "How many spins do you want to make (Each one costs 500 credits)\nBut every spin gives you 3 gumballs", "1", function(text)
                local num = tonumber(text)

                if num and num > 0 and num <= 20 then
                    net.Start("ASAPGGOBBLEGUMS:SlotSpin")
                    net.WriteUInt(num, 5)
                    net.SendToServer()
                else
                    Derma_Message("Invalid number", "Error", "OK")
                end
            end)
            return    
        end
        net.Start("ASAPGGOBBLEGUMS:SlotSpin")
        net.WriteUInt(0, 5)
        net.SendToServer()
        SCENE.showWin = false
    end

    --Create the overlay button
    SCENE:RefreshRewards()
end

function SCENE:OnUnload(contentFrame)
end

function SCENE:Think(contentFrame)
end

ASAP_GOBBLEGUMS.Scenes:RegisterScene("slots", SCENE)