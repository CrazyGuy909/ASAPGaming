local PANEL = {}

function PANEL:GetBattlePass()
    return self.battlePass
end

function PANEL:SetBattlePass(passId)
    self.battlePass = passId
end

function PANEL:Init()
    self.Finder = vgui.Create("XeninUI.TextEntry", self)
    self.Finder:Dock(TOP)
    self.Finder:SetTall(48)
    self.Finder:DockMargin(0, 8, 0, 8)
    self.Finder:SetPlaceholder("Search a challenge")
    self.Finder:SetUpdateOnType(true)

    self.Finder.OnValueChange = function(s, txt)
        self:Reload()
    end

    self.Scroll = self:Add("XeninUI.ScrollPanel")
    self.Scroll:Dock(FILL)
    self.Scroll:DockMargin(8, 8, 8, 8)
    self.Categories = {}
end

BATTLEPASS:CreateFont("BATTLEPASS_CategoryName", 24)
BATTLEPASS:CreateFont("BATTLEPASS_ChallengeProgress", 16)
BATTLEPASS:CreateFont("BATTLEPASS_Config_Challenges_Name", 18)
BATTLEPASS:CreateFont("BATTLEPASS_Config_Challenges_Desc", 16)
BATTLEPASS:CreateFont("BATTLEPASS_Star", 21)
local tokens = Material("pcshadowwz/flash.png")

function PANEL:CreateCategory(name, height)
    local panel = self.Scroll:Add("BATTLEPASS_Button")
    panel:SetText("")
    panel:SetDisableHoverDraw(true)
    panel.Alpha = 80
    panel.Height = 60
    panel.StartHeight = panel.Height
    panel.Expanded = false
    panel.Color = 51
    panel.Drag = 0
    panel.Name = name

    panel.Paint = function(pnl, w, h)
        draw.RoundedBox(6, 0, 0, w, pnl.StartHeight, BATTLEPASS:GetTheme("Categories.Title"))
        draw.SimpleText(name, "BATTLEPASS_CategoryName", 16, pnl.StartHeight / 2, Color(255, 255, 255, pnl.Alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        if (pnl.Count) then
            draw.SimpleText(pnl.Count .. " Challenges", XeninUI:Font(20), w - 16, pnl.StartHeight / 2, Color(255, 255, 255, pnl.Alpha), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end

    if height then
        panel.Height = height
        panel.Expanded = true
    end

    panel.DoClick = function(pnl)
        local children = math.ceil(#pnl.Layout:GetChildren() / 2)
        if children == 0 then return end
        local expandHeight = 60 + 8 + children * 80 + (8 * children - 1)

        if not pnl.Expanded then
            pnl:Lerp("Alpha", 255, 0.3)

            pnl:Lerp("Height", expandHeight, 0.3, function()
                pnl.Expanded = true
                pnl.Think = nil
            end)

            pnl.Think = function(pnl)
                self:InvalidateLayout()
            end
        elseif pnl.Expanded then
            pnl:Lerp("Alpha", 80, 0.3)

            pnl:Lerp("Height", pnl.StartHeight, 0.3, function()
                pnl.Expanded = false
                pnl.Think = nil
            end)

            pnl.Think = function(pnl)
                self:InvalidateLayout()
            end
        end
    end

    panel.OnCursorEntered = function(pnl)
        pnl:Lerp("Color", 63)
    end

    panel.OnCursorExited = function(pnl)
        pnl:Lerp("Color", 51)
    end

    panel.Layout = panel:Add("DIconLayout")
    panel.Layout:SetSpaceX(8)
    panel.Layout:SetSpaceY(8)

    panel.Layout.Paint = function(pnl, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(0, 0, 0, 200))
    end

    panel.PerformLayout = function(pnl, w, h)
        pnl.Layout:SetWide(w - 16)
        pnl.Layout:SetTall(h - pnl.StartHeight - 16)
        pnl.Layout:SetPos(8, 8 + pnl.StartHeight)
    end

    return panel
end

local matTiers = Material("battlepass/tiers.png", "smooth")

function PANEL:CreateChallenge(tbl, parent, id, pinpoint, cat)
    --[[
	DO SOMETHING HERE - NO CLUE
	]]
    local challengeTbl = BATTLEPASS.Challenges[tbl.id]

    if not challengeTbl then
        MsgN("No challenges?")
        MsgN(tbl.id)

        return
    end

    local name = tbl.name or challengeTbl.name
    local desc = tbl.desc or challengeTbl.progressDesc
    local icon = Material("ui/bpicons/" .. string.lower(cat))
    local goal = tbl.goal or challengeTbl.goal
    local stars = tbl.reward
    local finishedDesc = challengeTbl:GetFinishedDesc()
    local catName = tbl.catName
    LocalPlayer().ActiveChallenges = LocalPlayer().ActiveChallenges or {}
    --if !stars then return end
    local panel = parent.Layout:Add("BATTLEPASS_Button")
    panel.Id = id
    panel.Parent = pinpoint or parent
    panel:SetSize(ScrW() * .47, 80)
    panel:SetText("")
    panel:SetDisableHoverDraw(true)
    panel.BackgroundColor = BATTLEPASS:GetTheme("Background.Accent")
    panel.FinishedColor = BATTLEPASS:GetTheme("Pass.CurrentTiers.Filled")

    panel.DoClick = function(s)
        if not PinpointChallenges then
            PinpointChallenges = util.JSONToTable(cookie.GetString("BattlepassPin", "{}"))
        end

        PinpointChallenges[tbl.id] = not (PinpointChallenges[tbl.id] or false)

        if PinpointChallenges[tbl.id] == false then
            PinpointChallenges[tbl.id] = nil

            if pinpoint then
                s:Remove()
            end
        end

        for k, _ in pairs(PinpointChallenges) do
            PinpointChallenges[k] = true
        end

        cookie.Set("BattlepassPin", util.TableToJSON(PinpointChallenges))
        RenegerateChallengesUI()

        timer.Simple(0, function()
            self:BuildPinned(true)
        end)
    end

    local realTbl
    local parentName = pinpoint or parent.Name

    if LocalPlayer().ActiveChallenges[parentName] then
        realTbl = LocalPlayer().ActiveChallenges[parentName][panel.Id]
    end

    panel.Paint = function(pnl, w, h)
        if not realTbl then return end
        local progress = 0
        local challenge = LocalPlayer().ActiveChallenges

        if challenge then
            challenge = challenge[parentName]

            if challenge then
                challenge = challenge[panel.Id]

                if challenge then
                    progress = math.Round(challenge.progress, 2)
                end
            end
        end

        surface.SetAlphaMultiplier(.25)
        draw.RoundedBox(6, 0, 0, w, h, pnl.BackgroundColor)
        surface.SetAlphaMultiplier(1)
        draw.RoundedBox(6, 10, 10, 60, 60, Color(0, 0, 0, 130))
        surface.SetMaterial(icon)
        surface.SetDrawColor(finished and color_black or color_white)
        surface.DrawTexturedRect(10 + math.ceil(60 / 4 - 60 / 8), 10 + math.ceil(60 / 4 - 60 / 8), math.ceil(60 / 2 + 60 / 4), math.ceil(60 / 2 + 60 / 4))
        local currentStage = realTbl.stage
        local description
        description = desc:Replace(":goal", realTbl:GetGoal())
        local realName = PinpointChallenges and (PinpointChallenges[tbl.id] and "★ " .. name) or name
        local tx, _ = draw.SimpleText(realName .. " - ", "BATTLEPASS_Config_Challenges_Name", 10 + 60 + 10, 10, Color(220, 220, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("Stage " .. (currentStage + 1), "BATTLEPASS_Config_Challenges_Name", 10 + 60 + 10 + tx, 10, Color(255, 174, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(description, "BATTLEPASS_Config_Challenges_Desc", 10 + 60 + 10, 10 + draw.GetFontHeight("BATTLEPASS_Config_Challenges_Name") - 2, Color(163, 163, 163), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        local y = 10 + draw.GetFontHeight("BATTLEPASS_Config_Challenges_Name") - 2 + draw.GetFontHeight("BATTLEPASS_Config_Challenges_Desc") + 5
        local progressPercentage = math.min(progress / realTbl:GetGoal(), 1)
        draw.RoundedBox(6, 10 + 60 + 10, y, w - (10 + 60 + 10) - 10, 18, ColorAlpha(BATTLEPASS:GetTheme("Pass.CurrentTiers.Filled"), 100))
        draw.RoundedBox(6, 10 + 60 + 10, y, progressPercentage * (w - (10 + 60 + 10) - 10), 18, BATTLEPASS:GetTheme("Pass.CurrentTiers.Filled"))
        draw.SimpleText(progress .. "/" .. realTbl:GetGoal(), "BATTLEPASS_ChallengeProgress", (w + (10 + 60 + 10) - 10) / 2, y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    panel.OnCursorEntered = function(pnl)
        pnl:LerpColor("BackgroundColor", BATTLEPASS:GetTheme("Background.AccentHover"))
    end

    panel.OnCursorExited = function(pnl)
        pnl:LerpColor("BackgroundColor", BATTLEPASS:GetTheme("Background.Accent"))
    end

    local progress = 0
    local challenge = LocalPlayer().ActiveChallenges

    if challenge then
        challenge = challenge[parent.Name]

        if challenge then
            challenge = challenge[panel.Id]

            if challenge then
                progress = math.Round(challenge.progress, 2)
            end
        end
    end

    panel.Star = panel:Add("DPanel")
    panel.Star.Stars = realTbl and tonumber(realTbl:GetRewardByStage(realTbl.stage or 1)) or "?"
    panel.Star.Color = Color(220, 220, 220)
    panel.Star.Font = "BATTLEPASS_Star"

    panel.Star.Paint = function(pnl, w, h)
        draw.SimpleText("+" .. pnl.Stars, pnl.Font, 0, h / 2, pnl.Color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(matTiers)
        surface.DrawTexturedRect(w - h, 0, h, h)
    end

    panel.Star.OnCursorEntered = function(pnl)
        panel:OnCursorEntered()
    end

    panel.Star.OnCursorExited = function(pnl)
        panel:OnCursorExited()
    end

    panel.Star:AddTooltip("Stars granted by completing this challenge")
    panel.Tokens = panel:Add("DPanel")
    panel.Tokens.Tokens = realTbl and tonumber(realTbl:GetTokenReward((realTbl.stage or 1) + 1)) or "?"
    panel.Tokens.Color = Color(220, 220, 220)
    panel.Tokens.Font = "BATTLEPASS_Star"

    panel.Tokens.Paint = function(pnl, w, h)
        draw.SimpleText("+" .. pnl.Tokens, pnl.Font, 0, h / 2, pnl.Color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(tokens)
        surface.DrawTexturedRect(w - h - 8, 0, h, h)
    end

    panel.Tokens.OnCursorEntered = function(pnl)
        panel:OnCursorEntered()
    end

    panel.Tokens.OnCursorExited = function(pnl)
        panel:OnCursorExited()
    end

    panel.Tokens:AddTooltip("Tokens granted by completing this challenge")

    panel.PerformLayout = function(pnl, w, h)
        surface.SetFont(pnl.Star.Font)
        local width = surface.GetTextSize(pnl.Star.Stars)
        pnl.Star:SetSize(width + 3 + 40, 28)
        pnl.Star:SetPos(w - pnl.Star:GetWide() - 10, 10)
        width = surface.GetTextSize(pnl.Tokens.Tokens)
        pnl.Tokens:SetSize(width + 3 + 40, 28)
        pnl.Tokens:SetPos(w - pnl.Tokens:GetWide() - 10 - pnl.Star:GetWide(), 10)
    end

    return panel
end

function PANEL:Reload(heightTbl)
    local filter = self.Finder:GetText()
    local tbl = BATTLEPASS.Pass.challenges

    for i, v in pairs(self.Categories) do
        self.Categories[i]:Remove()
        self.Categories[i] = nil
    end

    self:BuildPinned()

    for i, v in pairs(tbl) do
        self.Categories[i] = self:CreateCategory(i, heightTbl and heightTbl[i])
        local found = false

        local count = 0
        for k, challenge in SortedPairsByMemberValue(v, "reward") do
            if filter ~= "" then
                local chall = BATTLEPASS.Challenges[challenge.id]
                local desc = chall.progressDesc
                if not string.find(string.lower(chall.name), string.lower(filter)) and not string.find(string.lower(desc), string.lower(filter)) then continue end
            end

            found = true
            self:CreateChallenge(challenge, self.Categories[i], k, nil, i)
            count = count + 1
        end

        self.Categories[i].Count = count

        local cat = self.Categories[i]

        if not found then
            cat:Remove()
            self.Categories[i] = nil
            continue
        end

        local children = math.ceil(#cat.Layout:GetChildren() / 2)
        if children == 0 then continue end
        local expandHeight = 60 + 8 + (children * 80) + (8 * children - 1)
        cat.Height = expandHeight
        cat.Expanded = true
        cat.Alpha = 255
    end

    self:InvalidateLayout()
end

function PANEL:BuildPinned(b)
    local tbl = BATTLEPASS.Pass.challenges

    if not IsValid(self.Categories["Pinned"]) then
        self.Categories["Pinned"] = self:CreateCategory("Pinned", heightTbl and heightTbl.Pinned)
    else
        for k, v in pairs(self.Categories["Pinned"].Layout:GetChildren()) do
            v:Remove()
        end
    end

    PinpointChallenges = util.JSONToTable(cookie.GetString("BattlepassPin", "{}"))

    for k, _ in pairs(PinpointChallenges) do
        PinpointChallenges[k] = false

        for group, challs in pairs(LocalPlayer().ActiveChallenges or {}) do
            for i, chall in pairs(challs) do
                if chall.uid == k then
                    PinpointChallenges[k] = chall
                    break
                end
            end

            if PinpointChallenges[k] ~= false then break end
        end

        if PinpointChallenges[k] ~= false then
            local chall = PinpointChallenges[k]
            self:CreateChallenge(tbl[chall.cat][chall.index], self.Categories.Pinned, chall.index, chall.cat, chall.cat)
        end
    end

    self:UpdatePinnedSize(b)
end

function PANEL:UpdatePinnedSize(b)
    local count = 0

    for k, v in pairs(self.Categories.Pinned.Layout:GetChildren()) do
        if IsValid(v) then
            count = count + 1
        end
    end

    local children = math.ceil(count / 2)

    if children == 0 then
        self.Categories.Pinned.Height = 60
        self.Categories.Pinned.Expanded = true
        self:InvalidateLayout()

        return
    end

    local expandHeight = 60 + 8 + (children * 80) + (8 * children - 1)
    self.Categories.Pinned.Height = expandHeight
    self.Categories.Pinned.Expanded = true
    self.Categories.Pinned.Alpha = 255
    self:InvalidateLayout()
end

function PANEL:PerformLayout(w, h)
    local catWidth = w - 16 - (self.Scroll:GetVBar():IsVisible() and 20 or 0)
    local y = 0
    local references = {}

    for k, v in pairs(self.Categories) do
        if k == "Pinned" then continue end

        table.insert(references, {
            __key = k,
            __value = v
        })
    end

    table.sort(references, function(a, b) return a.__key < b.__key end)

    table.insert(references, 1, {
        __key = "Pinned",
        __value = self.Categories.Pinned
    })

    for i, v in pairs(references) do
        v.__value:SetPos(0, y)
        v.__value:SetSize(catWidth, v.__value.Height)
        y = y + v.__value.Height + 8
    end
end

vgui.Register("BATTLEPASS_Challenges_Tab", PANEL)

function RenegerateChallengesUI()
    if not LocalPlayer().ActiveChallenges then
        timer.Simple(3, function()
            RenegerateChallengesUI()
        end)

        return
    end

    if IsValid(CHALL_UI) then
        CHALL_UI:Remove()
    end

    if not PinpointChallenges then
        PinpointChallenges = util.JSONToTable(cookie.GetString("BattlepassPin", "{}"))
    end

    local panel = vgui.Create("DPanel")
    CHALL_UI = panel
    local dark = Color(0, 0, 0, 180)
    local gray = Color(255, 255, 255, 100)
    local rows = 0

    for k, _ in pairs(PinpointChallenges) do
        PinpointChallenges[k] = false

        for group, challs in pairs(LocalPlayer().ActiveChallenges or {}) do
            for i, chall in pairs(challs) do
                if chall.uid == k then
                    PinpointChallenges[k] = chall
                    break
                end
            end

            if PinpointChallenges[k] ~= false then
                rows = rows + 1
                break
            end
        end
    end

    if rows == 0 then
        panel:Remove()

        return
    end

    panel:SetSize(320, 40 + rows * 40 + 8)
    panel:AlignRight(8)
    panel:AlignBottom(128)

    panel.Paint = function(s, w, h)
        if table.IsEmpty(PinpointChallenges) then
            s:Remove()

            return
        end

        s:SetDrawOnTop(LocalPlayer():GetModel() == "models/editor/playerstart.mdl")
        draw.RoundedBox(8, 0, 0, w, h, dark)
        local _, ty = draw.SimpleText("Battlepass Challenges", "Arena.Small", w / 2, 14, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(255, 255, 255, 150)
        surface.DrawRect(8, 18 + ty / 2, w - 16, 1)
        local i = 0

        for k, v in pairs(PinpointChallenges) do
            local chall = v or BATTLEPASS.Challenges[k]
            if not chall or chall == true then continue end
            local currentStage = chall:GetStage()
            local progressPercentage = math.Clamp(chall.progress / chall:GetGoal(), 0, 1)
            local description = chall.progressDesc:Replace(":goal", math.Round(chall:GetGoal() - chall.progress, 2))
            draw.SimpleText(chall.name .. " - Stage " .. (chall.stage + 1), "BATTLEPASS_ItemAmount", 8, 42 + i * 40, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(description, "BATTLEPASS_ItemAmountSmall", 8, 42 + i * 40 + 12, gray, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            surface.SetDrawColor(61, 145, 13, 100)
            surface.DrawRect(8, 42 + i * 40 + 20, w - 16, 12)
            surface.SetDrawColor(88, 223, 10, 180)
            surface.DrawRect(9, 42 + i * 40 + 21, (w - 18) * progressPercentage, 10)
            draw.SimpleText(chall.progress .. "/" .. chall:GetGoal(), "BATTLEPASS_ItemAmountSmall", w / 2, 42 + i * 40 + 19, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            i = i + 1
        end
    end
end

hook.Add("InitPostEntity", "BattlepassChallenges", function()
    if not BATTLEPASS then return end

    timer.Simple(10, function()
        RenegerateChallengesUI()
    end)
end)

if IsValid(CHALL_UI) then
    CHALL_UI:Remove()

    if IsValid(LocalPlayer()) then
        RenegerateChallengesUI()
    end
end