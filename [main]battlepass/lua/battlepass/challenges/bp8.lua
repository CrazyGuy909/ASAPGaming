local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("All-In")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Coinflip :goal times")
CHALLENGE:SetFinishedDesc("Gambler")
CHALLENGE:SetID("coinflips_1")

CHALLENGE:AddHook("OnCoinflip", function(self, owner, a, b, w)
    if owner ~= a and owner ~= b then return end
    self:AddProgress(1)
    self:NetworkProgress()
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)
local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Chip Eater")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Coinflip and win :goal money")
CHALLENGE:SetFinishedDesc("That's a lot of luck")
CHALLENGE:SetID("coinflips_2")

CHALLENGE:AddHook("OnCoinflip", function(self, owner, a, b, winner, game)
    if (winner == owner) then
        local money = game.Money[1] + game.Money[2]
        self:AddProgress(money)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)
local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("My Precious!")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Win or Lose a permanent item in coinflips")
CHALLENGE:SetFinishedDesc("After all why shouldn't I keep it")
CHALLENGE:SetID("coinflips_3")

CHALLENGE:AddHook("OnCoinflip", function(self, owner, a, b, winner, game)
    if owner ~= a and owner ~= b then return end

    if (game.Items[1] and BU3.Items.Items[game.Items[1]].perm) then
        self:AddProgress(1)
        self:NetworkProgress()

        return
    end

    if (game.Items[2] and BU3.Items.Items[game.Items[2]].perm) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)
local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Problems with everyone")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Play :goal duels")
CHALLENGE:SetFinishedDesc("Do you ever sleep?")
CHALLENGE:SetID("duels_1")

CHALLENGE:AddHook("OnDuelFinished", function(self, owner, a, b, duel)
    if (a == owner or b == owner) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)
local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Gear Up")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Play :goal duels with armor suits")
CHALLENGE:SetFinishedDesc("OOF my armor suits")
CHALLENGE:SetID("duels_2")

CHALLENGE:AddHook("OnDuelFinished", function(self, owner, a, b, duel)
    if not duel.Suit then return end

    if (a == owner or b == owner) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)
local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Bounty Hunter")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Earn $:goal accross duels (Suits or without suits)")
CHALLENGE:SetFinishedDesc("THAT'S A LOT OF MONEY")
CHALLENGE:SetID("duels_3")

CHALLENGE:AddHook("OnDuelFinished", function(self, owner, a, b, duel)
    if (a == owner or b == owner) then
        self:AddProgress(duel.Bet)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)
local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Darkzone Colombus")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Reach the crate and open it")
CHALLENGE:SetFinishedDesc("The crate has been opened")
CHALLENGE:SetID("darkzone_1")

CHALLENGE:AddHook("DarkZone.Completed", function(self, owner, ply)
    if (ply == owner) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)
local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Keys and Eggs")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Pickup :goal crates around the map")
CHALLENGE:SetFinishedDesc("You shouldn't need more crates")
CHALLENGE:SetID("bp8_cratepick_1")

CHALLENGE:AddHook("BPCrate.Pickedup", function(self, owner, ply, rarity)
    if (ply == owner) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)
local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Who left this Gem here")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Pickup an orange crate")
CHALLENGE:SetFinishedDesc("Big reward for the big boys")
CHALLENGE:SetID("bp8_cratepick_2")

CHALLENGE:AddHook("BPCrate.Pickedup", function(self, owner, ply, rarity)
    if (ply == owner and rarity == 3) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)