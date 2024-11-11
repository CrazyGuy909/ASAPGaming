asapArena.GameVotes = {}

net.Receive("Arena.Votes:SelectWinner", function()
    local winner = net.ReadString()
    if IsValid(VOTE) then
        VOTE:SetWinnerAnim(winner)
    end
end)

net.Receive("Arena.Votes:Sync", function()
    local total = net.ReadBool()
    if (total) then
        asapArena.GameVotes = {}
        local gamemodes = {}
        for k = 1, 3 do
            local gm = net.ReadString()
            gamemodes[gm] = asapArena.Gamemodes[gm]
            asapArena.GameVotes[gm] = 0
        end

        local vote = vgui.Create("arena.vote")
        vote:CreateOptions(gamemodes)
    else
        local gm = net.ReadString()
        local amount = net.ReadUInt(8)
        asapArena.GameVotes[gm] = amount
    end
end)

net.Receive("ASAP.Arena:RequestDrone", function()
    LocalPlayer()._droneRequested = net.ReadBool()
end)

net.Receive("ASAP.Arena:Perk", function(l, ply)
    local field = net.ReadString()
    local state = net.ReadBool()
    local isEntity = net.ReadBool()
    local target = isEntity and net.ReadEntity() or LocalPlayer()
    target[field] = state
end)