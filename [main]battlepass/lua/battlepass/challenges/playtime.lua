local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Playtime")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Play :goal more minutes on this server")
CHALLENGE:SetFinishedDesc("Played over :goal minutes")
CHALLENGE:SetID("playtime")
CHALLENGE:AddTimer( 5 * 60, function( self, ply )
	if IsValid( ply ) and ply:Alive() then
		self:AddProgress(5)
		self:NetworkProgress()
	end
end )

BATTLEPASS:RegisterChallenge(CHALLENGE)