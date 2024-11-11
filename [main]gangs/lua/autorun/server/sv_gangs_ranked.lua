
function asapgangs:DoScore(ply, score)
    local raid = self.Raids[ply.GangRaiding or ""]
    if not raid then return end
    local target = ply:GetGang() == ply.GangRaiding and 2 or 1
    raid.Score[target] = raid.Score[target] + (score or 1)
end

function asapgangs:SaveRanked(gang, att)
    local raid = self.Raids[gang]
    asapgangs.gangList[att].MMR = (asapgangs.gangList[att].MMR or 0) + (raid.Score[1] or 0)
    asapgangs.gangList[gang].MMR = (asapgangs.gangList[gang].MMR or 0) + (raid.Score[2] or 0)
    asapgangs.Update(gang, "MMR")
    asapgangs.Update(att, "MMR")
end