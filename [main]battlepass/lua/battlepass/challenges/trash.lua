local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Trash King")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Recycle :goal KG of trash")
CHALLENGE:SetFinishedDesc("You've kept the world clean, #TeamTrash!")
CHALLENGE:SetID("team_trash")

CHALLENGE:AddHook("OnTrashRecycled", function(self, owner, ply, amount)
    if (owner == ply) then
        self:AddProgress(amount)
        self:NetworkProgress()
    end
end)
BATTLEPASS:RegisterChallenge(CHALLENGE)

hook.Add("ztm_configLoaded", "trash_challenges", function()
	for k, v in pairs(ztm.config.Recycler.recycle_types) do
		local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
		CHALLENGE:SetName(v.name)
		CHALLENGE:SetIcon("battlepass/tiers.png")
		CHALLENGE:SetDesc("")
		CHALLENGE:SetProgressDesc("Recycle :goal block(s) of " .. v.name)
		CHALLENGE:SetFinishedDesc("That's a lot of " .. v.name)
		CHALLENGE:SetID("trash_" .. k)

		CHALLENGE:AddHook("ztm_OnTrashBlockCreation", function(self, bpOwner, ply, _, ent)
			if bpOwner ~= ply || ent:GetRecycleType() ~= k then return end
		    self:AddProgress(1)
		    self:NetworkProgress()
		end)
		BATTLEPASS:RegisterChallenge(CHALLENGE)
	end
end)

if (ztm) then
	hook.Run("ztm_configLoaded")
end