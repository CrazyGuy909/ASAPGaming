local PANEL = {}local accent_col = Color(0, 195, 165)local accent_col_dark = Color(0, 125, 95)function PANEL:Init()    self.Col = Color(16, 16, 16)    self:Dock(FILL)    self.Paint = function(this, w, h)        draw.RoundedBoxEx(16, 0, 0, w, h, Color(6, 6, 6), false, false, false, true)    end    -- Create the panel for daily rewards    self.DailyRewardsPanel = vgui.Create("DPanel", self)    self.DailyRewardsPanel:Dock(FILL)    self.DailyRewardsPanel:DockMargin(5, 5, 5, 5)    self.DailyRewardsPanel.Paint = function(this, w, h)        -- Customize the appearance of the panel if needed        draw.RoundedBox(8, 0, 0, w, h, Color(50, 50, 50))    end    -- Sync daily rewards data with the server    net.Start("luctus_dayward_sync")    net.SendToServer()    -- Explanation label for the daily rewards panel    local explanation = vgui.Create("DLabel", self.DailyRewardsPanel)    explanation:SetText("Put [Galaxium] in front of your name to get "..LUCTUS_DAYWARD_NAME_MULTIPLIER.."x rewards!")    explanation:SetFont("DermaLarge")    explanation:SetTextColor(Color(255, 255, 255))    explanation:SetPos(ScrW() * 0.1, ScrH() * 0.05)    explanation:SizeToContents()    -- Check if the reward has been claimed today    local hasClaimed = os.date("%Y%m%d", LUCTUS_DAYWARD_LAST) == os.date("%Y%m%d") and LUCTUS_DAYWARD_STREAK > 0    if hasClaimed then        -- Hide the explanation label if it exists        if IsValid(explanation) then            explanation:SetVisible(false)        end        -- Display countdown timer until midnight        local timerPanel = vgui.Create("DLabel", self.DailyRewardsPanel)        timerPanel:SetText("Next Daily Reward In: " .. GetTimeUntilMidnight())        timerPanel:SetFont("DermaLarge")        timerPanel:SetTextColor(Color(255, 255, 255))        timerPanel:SetContentAlignment(5) -- Center align text        timerPanel:Dock(TOP) -- Dock to the top of the panel        timerPanel:DockMargin(0, 10, 0, 0) -- Add some margin from the top    else        -- Display claim button        local claimButton = vgui.Create("DButton", self.DailyRewardsPanel)        claimButton:SetText("Claim")        claimButton:SetTextColor(Color(255, 255, 255))        claimButton:SetSize(300, 80) -- Set the size of the button        claimButton:SetPos((ScrW() - 300) / 2, (ScrH() - 80) / 2) -- Center the button on the screen        claimButton.DoClick = function()            net.Start("luctus_dayward")            net.SendToServer()            claimButton:SetEnabled(false)            claimButton:SetText("- Claimed -")            LUCTUS_DAYWARD_LAST = os.time()            LUCTUS_DAYWARD_STREAK = LUCTUS_DAYWARD_STREAK + 1        end        claimButton.Paint = function(self, w, h)            draw.RoundedBox(8, 0, 0, w, h, self:IsEnabled() and accent_col or accent_col_dark)        end    endend-- Register your custom panel class with VGUIvgui.Register("DailyReward", PANEL)-- Function to get time until midnightfunction GetTimeUntilMidnight()    local now = os.time()    local midnight = os.date("*t", now)    midnight.hour = 23    midnight.min = 59    midnight.sec = 59    local midnightTimestamp = os.time(midnight)    local timeUntilMidnight = midnightTimestamp - now    local hours = math.floor(timeUntilMidnight / 3600)    local minutes = math.floor((timeUntilMidnight % 3600) / 60)    local seconds = timeUntilMidnight % 60    return string.format("%02d:%02d:%02d", hours, minutes, seconds)end