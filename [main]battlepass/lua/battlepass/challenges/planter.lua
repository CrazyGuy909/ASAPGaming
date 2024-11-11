local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("#TeamTrees")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Grow :goal fruits and harvest them from the Tree Grower.")
CHALLENGE:SetFinishedDesc("Mr beast would be proud")
CHALLENGE:SetID("teamtrees")

CHALLENGE:AddHook("planter_pickFruit", function(self, bpOwner, ply, ent)
	if bpOwner ~= ply then return end
    self:AddProgress(1)
    self:NetworkProgress()
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)