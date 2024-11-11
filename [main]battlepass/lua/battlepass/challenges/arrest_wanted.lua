local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Arrest wanted players")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Arrest :goal wanted players")
CHALLENGE:SetFinishedDesc("Arrested :goal wanted players")
CHALLENGE:SetID("arrest_wanted")
CHALLENGE:AddHook("playerArrested", function(self, ply, criminal, time, actor)
  if IsValid( actor ) and ply == actor and criminal:isWanted() then
    self:AddProgress(1)
    self:NetworkProgress()
  end
end)
BATTLEPASS:RegisterChallenge(CHALLENGE)