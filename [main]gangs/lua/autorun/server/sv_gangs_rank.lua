
util.AddNetworkString("Gangs.SendRanking")

asapgangs.NextUpdate = 0
function asapgangs.FetchRank(ply)
    if (asapgangs.RankCache and IsValid(ply)) then
        net.Start("Gangs.SendRanking")
        net.WriteTable(asapgangs.RankCache)
        net.Send(ply)
        return
    end

    ASAPDriver:MySQLQuery("SELECT Tag, Name, Members, Money, Experience, Icon FROM gangs_list ORDER BY Experience DESC LIMIT 15;", function(data)
        asapgangs.RankCache = data
        if IsValid(ply) then
            asapgangs.FetchRank(ply)
        end
    end)
end

timer.Create("Gangs.UpdateRanking", 120, 0, function()
    asapgangs.FetchRank()
end)

net.Receive("Gangs.SendRanking", function(l, ply)
    asapgangs.FetchRank(ply)
end)