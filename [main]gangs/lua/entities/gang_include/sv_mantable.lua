util.AddNetworkString("Manufacture:Message")
util.AddNetworkString("Manufacture:Minigame")

local randomWords = {"Gluon Gun", "Fire Drill", "Speed Suit", "Dracula Suit", "Simulator Suit", "Confetti Gun", "Poison Gun", "Hell Chaser", "Storm Giant", "Shadow Hammer", "Poison Drill", "Magnum Drill", "Infinite Gun", "Rail Gun", "Orange Suit", "Psycho Suit",}

function ENT:ProcessNetworking(kind, ply, data, index)
    index = index or 1
    local dice = math.random(1, 100)
    local skill = dice < 10 + index * 5 and 2 or dice < 40 + index * 5 and 1 or 0

    if not ply.m_skill then
        ply.m_skill = skill
    end

    ply.m_playing = index

    if (kind == "RequestFull") then
        net.Start("Manufacture:Message")

        for k, v in pairs(self.Ingredients) do
            net.WriteInt(k, 4)
            net.WriteInt(v, 16)
        end

        net.Send(IsValid(ply) and ply or asapgangs.GetMembers(self:GetGang()))
    elseif (kind == "SyncUnique") then
    elseif (kind == "MinigameA") then
        net.Start("Manufacture:Minigame")
        net.WriteUInt(1, 4)
        net.WriteBool(true)

        for k, v in RandomPairs({1, 2, 3, 4, 5, 6, 7, 8, 9, 10}) do
            net.WriteInt(v, 8)
        end

        local life = 10 + 5 * skill
        net.WriteInt(life, 8)
        net.WriteInt(skill, 3)
        net.Send(ply)
        ply.m_lifeEnd = CurTime() + life
        ply.m_computer = self
        ply.m_counter = 0
    elseif (kind == "MinigameB") then
        net.Start("Manufacture:Minigame")
        net.WriteUInt(2, 4)
        net.WriteBool(true)
        ply.m_word = table.Random(randomWords)
        local split = string.Explode(" ", ply.m_word, false)
        local wordsplit = math.random(1, 2)
        local hidden = split[wordsplit]
        local letters = {}

        for k = 1, string.len(hidden) do
            table.insert(letters, hidden[k])
        end

        for k = 2, string.len(hidden) do
            hidden = string.sub(hidden, 1, k - 1) .. "_"
        end

        net.WriteString(table.concat(letters))
        net.WriteString(wordsplit == 1 and (hidden .. " " .. split[2]) or split[1] .. " " .. hidden)
        local life = 10 + skill * 5
        net.WriteInt(life, 8)
        net.WriteInt(skill, 3)
        net.Send(ply)
        ply.m_lifeEnd = CurTime() + life
        ply.m_computer = self
    elseif (kind == "MinigameC") then
        local initial = {}

        if (skill == 0) then
            initial = {1, 2, 3}
        elseif (skill == 1) then
            initial = {1, 2, 3, 4, 5}
        else
            initial = {1, 2, 3, 4, 5, 6, 7}
        end

        local a, b = {}, {}

        for k, v in RandomPairs(initial) do
            table.insert(a, v)
        end

        for k, v in RandomPairs(initial) do
            table.insert(b, v)
        end

        ply.m_cabbles = {a, b}

        ply.m_counter = 0
        local maxCabbles = table.Count(initial)
        ply.m_maxcounter = maxCabbles
        net.Start("Manufacture:Minigame")
        net.WriteUInt(3, 4)
        net.WriteBool(true)
        net.WriteUInt(maxCabbles, 4)

        for k = 1, maxCabbles do
            net.WriteUInt(a[k], 4)
            net.WriteUInt(b[k], 4)
        end

        local life = 10 + skill * 5
        ply.m_lifeEnd = CurTime() + life
        net.WriteInt(life, 8)
        net.WriteInt(skill, 3)
        net.Send(ply)
    elseif (kind == "MinigameD") then
        local diff = 3 + skill
        local isOdd = (diff * diff) % 2 == 0
        local limit = (diff * diff) - (isOdd and 0 or 1)
        local values = {}
        local time = 25 + skill * 20

        print(skill, time, limit)
        for k = 1, limit do
            table.insert(values, math.random(1, k), k)
        end

        net.Start("Manufacture:Minigame")
        net.WriteUInt(4, 4)
        net.WriteBool(true)
        net.WriteUInt(limit, 6)

        for k = 1, limit do
            values[k] = values[k] - (values[k] > limit / 2 and limit / 2 or 0)
            net.WriteUInt(values[k], 6)
        end

        net.WriteUInt(time, 6)
        net.WriteUInt(skill, 3)
        net.Send(ply)
        ply.m_computer = self
        ply.m_lifeEnd = CurTime() + time
        ply.m_counter = 0
        ply.m_cabbles = limit
    elseif (kind == "Failed") then
        net.Start("Manufacture:Minigame")
        net.WriteUInt(8, 4)
        net.Send(ply)
        ply:EmitSound("buttons/button2.wav")
        ply.m_lifeEnd = nil
        ply.m_computer = Anil
        ply.m_counter = nil
        ply.m_cabbles = nil
        ply.m_skill = nil
    end
end

function ENT:GiveReward(s, id, skill, ply)
    local data = asapgangs.War.Craftables[id]
    if not data then return end

    if (s) then
        self.GangComputer:AddResource(id, 2 + (skill or 0), ply)
    end

    //for k, v in pairs(data.Needs or {}) do
        //self.GangComputer:AddResource(k, -v)
    //end

    hook.Run("OnMinigameSuccess", ply, id, 2 + (skill or 0), self)
end

net.Receive("Manufacture:Minigame", function(l, ply)
    local id = net.ReadInt(4)

    if (id == 1) then
        local counter = net.ReadInt(8)

        if (ply.m_lifeEnd < CurTime()) then
            ply.m_computer:GiveReward(false, ply.m_playing, -1, ply)
            ply.m_computer:ProcessNetworking("Failed", ply)

            return
        end

        if (counter - ply.m_counter == 1) then
            net.Start("Manufacture:Minigame")
            net.WriteInt(1, 4)
            net.WriteBool(false)
            net.WriteBool(counter == 10)
            net.Send(ply)

            if (counter == 10) then
                ply:EmitSound("buttons/button24.wav")
                ply.m_computer:GiveReward(true, ply.m_playing, ply.m_skill, ply)
            else
                ply.m_counter = counter
            end
        end
    elseif (id == 2) then
        local word = string.lower(net.ReadString())
        local win = string.lower(ply.m_word or "") == word and ply.m_lifeEnd >= CurTime()
        net.Start("Manufacture:Minigame")
        net.WriteInt(2, 4)
        net.WriteBool(false)
        net.WriteBool(win)
        net.Send(ply)

        if (win) then
            ply:EmitSound("buttons/button24.wav")
            ply.m_computer:GiveReward(true, ply.m_playing, ply.m_skill, ply)
        else
            ply.m_computer:GiveReward(false, ply.m_playing, ply.m_skill, ply)
            ply.m_computer:ProcessNetworking("Failed", ply)
        end
    elseif (id == 3) then
        local a = net.ReadUInt(4)
        local b = net.ReadUInt(4)
        local success = ply.m_cabbles[1][a] == ply.m_cabbles[2][b]

        if (success) then
            ply.m_counter = ply.m_counter + 1
        end

        local finish = ply.m_maxcounter <= ply.m_counter and ply.m_lifeEnd >= CurTime()
        net.Start("Manufacture:Minigame")
        net.WriteInt(3, 4)
        net.WriteBool(false)
        net.WriteBool(success)
        net.WriteBool(finish)
        net.Send(ply)

        if (not success) then
            ply.m_computer:GiveReward(false, ply.m_playing, ply.m_skill, ply)
            ply.m_computer:ProcessNetworking("Failed", ply)
        elseif (finish) then
            ply:EmitSound("buttons/button24.wav")
            ply.m_computer:GiveReward(true, ply.m_playing, ply.m_skill, ply)
        end
    elseif (id == 4) then
        if ((ply.m_lifeEnd or 0) < CurTime()) then
            ply.m_computer:GiveReward(false, ply.m_playing, ply.m_skill, ply)
            ply.m_computer:ProcessNetworking("Failed", ply)

            return false
        end

        ply.m_counter = ply.m_counter + 2
        if (ply.m_counter >= ply.m_cabbles) then
            ply:EmitSound("buttons/button24.wav")
            ply.m_computer:GiveReward(true, ply.m_playing, ply.m_skill, ply)
        end
    end
end)

net.Receive("Manufacture:Message", function(l, ply)
    local kind = net.ReadString()
    local machine = net.ReadEntity()
    local index = net.ReadUInt(4)

    if (ply:GetGang() == machine:GetGang()) then

        local canPlay = true
        local pc = ply.GangComputer

        if kind ~= "Failed" then
            local data = asapgangs.War.Craftables[index]

            for k, v in pairs(data.Needs or {}) do
                if ((pc.Resources[k] or 0) < v) then
                    canPlay = false
                    break
                end
            end

            for k, v in pairs(data.Needs or {}) do
                pc:AddResource(k, -v, ply)
            end
        end

        if not canPlay then
            DarkRP.notify(ply, 1, 5, "You don't have enough resources to play this game!")
            return
        end
        machine:ProcessNetworking(kind, ply, nil, index)
    end
end)