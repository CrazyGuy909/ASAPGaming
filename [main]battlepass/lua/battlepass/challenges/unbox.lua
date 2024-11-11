local CHALLENGE1 = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE1:SetName("Unbox Addict")
CHALLENGE1:SetIcon("battlepass/tiers.png")
CHALLENGE1:SetDesc("")
CHALLENGE1:SetProgressDesc("Unbox :goal crates")
CHALLENGE1:SetFinishedDesc("Damn addict!")
CHALLENGE1:SetID("unbox_addict")

CHALLENGE1:AddHook("onUnbox", function(self, owner, ply, id, item)
    if (ply == owner) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE1)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Lucky Bastard")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Unbox :goal legendary items from crates")
CHALLENGE:SetFinishedDesc("You're too damn lucky")
CHALLENGE:SetID("unbox_bastard")

CHALLENGE:AddHook("onUnbox", function(self, owner, ply, id, item)
    if (ply == owner and item.itemColorCode == 6) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)
local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Red's gambling luck")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Unbox :goal red items from crates")
CHALLENGE:SetFinishedDesc("You're really damn lucky")
CHALLENGE:SetID("unbox_red")

CHALLENGE:AddHook("onUnbox", function(self, owner, ply, id, item)
    if (ply == owner and item.itemColorCode == 5) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)
local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("You owe me your kidneys")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Gift :goal 5 red or gold rarity items to other players")
CHALLENGE:SetFinishedDesc("What a such space for love to spare")
CHALLENGE:SetID("unbox_kidney")

CHALLENGE:AddHook("onUnboxGift", function(self, owner, ply, target, id, item)
    if (ply == owner and item.itemColorCode >= 5) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)
local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Royal Blood")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Unbox a royal crate")
CHALLENGE:SetFinishedDesc("You've unboxed a royal crate!")
CHALLENGE:SetID("unbox_royal")

CHALLENGE:AddHook("onUnbox", function(self, owner, ply, id, item, caseID)
    if (ply == owner and caseID == 351) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)
BATTLEPASS:RegisterChallenge(CHALLENGE)


local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Good Luck :)")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Unbox :goal Holy Crates")
CHALLENGE:SetFinishedDesc("Damn hopefully you got something cool from it")
CHALLENGE:SetID("unbox_holy")

CHALLENGE:AddHook("onUnbox", function(self, owner, ply, id, item, caseID)
    if (ply == owner and caseID == 311) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)
BATTLEPASS:RegisterChallenge(CHALLENGE)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Arena Grind")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Unbox :goal Arena Crates")
CHALLENGE:SetFinishedDesc("Hopefully that didn't take too long")
CHALLENGE:SetID("unbox_arena")

CHALLENGE:AddHook("onUnbox", function(self, owner, ply, id, item, caseID)
    if (ply == owner and caseID == 366) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)
BATTLEPASS:RegisterChallenge(CHALLENGE)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Open 1 Ultimate VIP Crate")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Unbox :goal Ultimate VIP Crate")
CHALLENGE:SetFinishedDesc("That must have been pricy")
CHALLENGE:SetID("unbox_ultvip")

CHALLENGE:AddHook("onUnbox", function(self, owner, ply, id, item, caseID)
    if (ply == owner and caseID == 1128) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)
BATTLEPASS:RegisterChallenge(CHALLENGE)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Open 1 Suit Crate")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Unbox :goal Suit Crate")
CHALLENGE:SetFinishedDesc("Woah is that a suit woah so fucking cool poggers")
CHALLENGE:SetID("unbox_suitcrate")

CHALLENGE:AddHook("onUnbox", function(self, owner, ply, id, item, caseID)
    if (ply == owner and caseID == 554) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)
BATTLEPASS:RegisterChallenge(CHALLENGE)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Open Mystic Crates")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Unbox :goal Mystic Crate")
CHALLENGE:SetFinishedDesc("Hopefully you got something good")
CHALLENGE:SetID("unbox_mysticpog")

CHALLENGE:AddHook("onUnbox", function(self, owner, ply, id, item, caseID)
    if (ply == owner and caseID == 1127) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)
BATTLEPASS:RegisterChallenge(CHALLENGE)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Open Trivia Crates")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Unbox :goal Wookies Trivia Crate")
CHALLENGE:SetFinishedDesc("bookie wookie spooky o-o")
CHALLENGE:SetID("unbox_wookie")

CHALLENGE:AddHook("onUnbox", function(self, owner, ply, id, item, caseID)
    if (ply == owner and caseID == 1220) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)
BATTLEPASS:RegisterChallenge(CHALLENGE)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Open Weeb Crates")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Unbox :goal Weeb Crate")
CHALLENGE:SetFinishedDesc("bookie wookie spooky o-o")
CHALLENGE:SetID("unbox_weeebs")

CHALLENGE:AddHook("onUnbox", function(self, owner, ply, id, item, caseID)
    if (ply == owner and caseID == 385) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)
BATTLEPASS:RegisterChallenge(CHALLENGE)