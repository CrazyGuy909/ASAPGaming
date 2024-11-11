util.AddNetworkString("Arena.Votes:DoVote")
util.AddNetworkString("Arena.Votes:Update")
util.AddNetworkString("Arena.Votes:Sync")
util.AddNetworkString("Arena.Votes:SelectWinner")
util.AddNetworkString("ASAP.Arena:RequestDrone")
util.AddNetworkString("ASAP.Arena:Perk")

function asapArena:StartGamemodeVote()
    asapArena:SetGamemode("deathmatch")
    if true then return end
    self.Votes = {}
    local options = {}

    for k = 1, 3 do
        local data, key = table.Random(self.Gamemodes)
        local tries = 15
        while (tries > 0 and (data.NoVote or options[key])) do
            tries = tries - 1
            data, key = table.Random(self.Gamemodes)
            if (tries <= 0) then
                key = "deathmatch"
                break
            end
        end

        table.insert(options, key)
        self.Votes[key] = 0
    end

    for k, v in pairs(player.GetAll()) do
        v.lastVote = nil
    end

    net.Start("Arena.Votes:Sync")
    net.WriteBool(true)

    for k = 1, 3 do
        net.WriteString(options[k])
    end

    net.Broadcast()

    timer.Remove("Arena.SetGamemodeVote")
    timer.Create("Arena.SetGamemodeVote", 15, 1, function()
        local winners = {}
        local max
        local rem = 2
        for k, v in SortedPairs(self.Votes) do
            if (!max) then
                max = v
            end
            rem = rem - 1
            table.insert(winners, k)
            if (rem <= 0) then
                break
            end
        end

        local percent = asapArena.Votes[winners[2]] / max
        local selected = winners[math.random(1, 100) <= percent * 100 and 2 or 1]
        net.Start("Arena.Votes:SelectWinner")
        net.WriteString(selected)
        net.Broadcast()
        timer.Simple(4, function()
            asapArena:SetGamemode(selected)
        end)
    end)
end

net.Receive("Arena.Votes:DoVote", function(l, ply)
    local vote = net.ReadString()

    if (ply.lastVote) then
        asapArena.Votes[ply.lastVote] = (asapArena.Votes[ply.lastVote] or 1) - 1
        net.Start("Arena.Votes:Sync")
        net.WriteBool(false)
        net.WriteString(ply.lastVote)
        net.WriteUInt(asapArena.Votes[ply.lastVote], 8)
        net.Broadcast()
    end

    ply.lastVote = vote
    asapArena.Votes[vote] = (asapArena.Votes[vote] or 0) + 1
    net.Start("Arena.Votes:Sync")
    net.WriteBool(false)
    net.WriteString(vote)
    net.WriteUInt(asapArena.Votes[vote], 8)
    net.Broadcast()
end)

--asapArena:StartGamemodeVote()