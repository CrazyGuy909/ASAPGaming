local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("M1N3R")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Mine :goal bitcoins")
CHALLENGE:SetFinishedDesc("You've mined :goal bitcoins")
CHALLENGE:SetID("bitminer_1")

CHALLENGE:AddHook("onBitmine", function(self, owner, ply, am)
    if owner ~= ply then return end

    if IsValid(ply) then
        self:AddProgress(am)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)

for k = 0, 6 do
    CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
    CHALLENGE:SetName("Techymist")
    CHALLENGE:SetIcon("battlepass/tiers.png")
    CHALLENGE:SetDesc("")
    CHALLENGE:SetProgressDesc("Get Upgrade kit tier " .. (k + 1))
    CHALLENGE:SetFinishedDesc("You got the upgrade kit!")
    CHALLENGE:SetID("upgrade_kit_" .. (k + 1))

    CHALLENGE:AddHook("onBU3AddItem_Kit", function(self, owner, ply, id, am)
        if owner ~= ply then return end

        if IsValid(ply) then
            if (k == 6) then
                k = 7
            end

            if not (id ~= 1163 + k) then return end
            self:AddProgress(1)
            self:NetworkProgress()
        end
    end)

    BATTLEPASS:RegisterChallenge(CHALLENGE)
end

CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("THE ULTIMATE HOBO PARTY IN THE BAHAMAS")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Dance with 50 hobos on the ocean island :goal")
CHALLENGE:SetFinishedDesc("YOU'VE CLAPPED THOSE CHECKS")
CHALLENGE:SetID("bom_box")

CHALLENGE:AddHook("onDanceFinished", function(self, owner, ply, am)
    if owner ~= ply then return end

    if IsValid(ply) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)