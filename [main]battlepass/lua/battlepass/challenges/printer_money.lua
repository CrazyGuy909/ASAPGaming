local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Printer money")
CHALLENGE:SetIcon("battlepass/tiers.png") -- <- ??
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Withdraw :goal more from your own printer")
CHALLENGE:SetFinishedDesc("Withdrew :goal from your own printer")
CHALLENGE:SetID("printer_money")
CHALLENGE:SetFormatting(function(str, goal)
  if (goal >= 1000000) then -- Million
    goal = DarkRP.formatMoney(goal / 1000000) .. "mil"
  elseif (goal > 10000) then
    goal = DarkRP.formatMoney(goal / 1000) .. "k"
  else
    goal = DarkRP.formatMoney(goal)
  end

  return str:Replace(":goal", goal)
end) 
CHALLENGE:AddHook("ASAPPrinters.WithdrawMoney", function(self, ply, _ply, ent, money, xp)
  if (!IsValid(ent)) then return end
  if IsValid( _ply ) and IsValid(ply) and ply == _ply and ent:Getowning_ent() == ply then
    self:AddProgress(money)
    self:NetworkProgress()
  end
end)
BATTLEPASS:RegisterChallenge(CHALLENGE)