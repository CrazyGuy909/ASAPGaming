util.AddNetworkString("GangZones.Broadcast")
util.AddNetworkString("GangZones.Own")
util.AddNetworkString("GangZones.Notify")
util.AddNetworkString("GangZones.AcquireZone")
util.AddNetworkString("GangZones.AcquireUpgrade")
util.AddNetworkString("Gangs.StartRaid")
util.AddNetworkString("Gangs.StopRaid")
util.AddNetworkString("Gangs.ExitRaid")
util.AddNetworkString("Gangs.SendResult")
util.AddNetworkString("GangsMachine.UpdateResource")
util.AddNetworkString("Gangs.PickupDelivery")
util.AddNetworkString("Gangs.SendShaftPos")

function asapgangs:BroadcastZones(ply)
    net.Start("GangZones.Broadcast")
    net.WriteInt(table.Count(self.Zones), 8)

    for k, v in pairs(self.Zones or {}) do
        net.WriteString(k)
        net.WriteVector(v.Start)
        net.WriteVector(v.EndPos)
        net.WriteString(v.Gang or "")
    end

    if IsValid(ply) then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

function asapgangs:EvictBuilding(ply, force)
    if (ply:Team() == TEAM_GANGLEADER) then
        local zoneID

        for k, v in pairs(asapgangs.Zones) do
            if (v.Gang == ply:GetGang()) then
                zoneID = k
                break
            end
        end

        if (zoneID) then
            local zone = asapgangs.Zones[zoneID]
            local gangID = ply:GetGang()

            local found = false
            for k, v in pairs(asapgangs.GetPlayers(gangID)) do
                if (v != ply) then
                    found = true
                    break
                end
            end

            local time = force and 0 or (found and 300 or 0)
            
            if (found) then
                DarkRP.notify(asapgangs.GetMembers(gangID), 2, 10, "Leader has gone away, you have 5 minutes to get a leader or the zone will be abandoned")
            end

            timer.Create(zoneID .. "_cleanse", time, 1, function()
                for k, v in pairs(ents.FindInBox(zone.Start, zone.EndPos)) do
                    if (v:GetClass() ~= "sent_gang_computer" and string.StartWith(v:GetClass(), "sent_gang")) then
                        v:Remove()
                    end
                end

                asapgangs.Zones[zoneID].Gang = nil
                net.Start("GangZones.Own")
                net.WriteString(zoneID)
                net.WriteString("")
                net.Broadcast()
                
                for _, door in pairs(asapgangs.Doors[zoneID]) do
                    door:removeAllKeysExtraOwners()
                end
                if not found then return end
                DarkRP.notify(asapgangs.GetMembers(gangID), 2, 10, "You've lost access to your gang base")

            end)
        else
            DarkRP.notify(ply, 1, 10, "You don't own a zone")
        end
    end
end

function asapgangs:InitializeZones(tag, ply)
    local zone
    local zoneName

    for k, v in pairs(self.Zones) do
        if (v.Gang == tag) then
            zoneName = k
            zone = v
            break
        end
    end

    if not zone then return end

    timer.Simple(5, function()
        for door, _ in pairs(self.Doors[zoneName]) do
            if not door:getDoorData() then continue end
            door:addKeysDoorOwner(ply)
        end
    end)

    for k, v in pairs(ents.FindByClass("sent_gang_computer")) do
        if (tag == v:GetGang()) then
            ply.GangComputer = v
            break
        end
    end

    if IsValid(ply.GangComputer) then
        timer.Simple(3, function()
            ply.GangComputer:BroadcastResources(ply)
        end)
    end
end

function asapgangs:SetZoneOwner(zone, ply)
    if (self.Zones[zone]) then
        self.Zones[zone].Gang = ply:GetGang()
        net.Start("GangZones.Own")
        net.WriteString(zone)
        net.WriteString(ply:GetGang())
        net.Broadcast()
        local members = asapgangs.GetMembers(ply:GetGang())
        local computer

        for k, v in pairs(ents.FindByClass("sent_gang_computer")) do
            if (v:GetZone() == zone) then
                v:SetGang(ply:GetGang())
                self.Zones[zone].GangComputer = v
                computer = v
                break
            end
        end

        for b, door in pairs(self.Doors[zone]) do
            for _, gang in pairs(members) do
                door:addKeysDoorOwner(gang)
                door.Gang = ply:GetGang()
                ply.GangComputer = computer
            end
        end

        for k, v in pairs(ents.FindByClass("sent_gang_*")) do
            if (v:GetClass() == "sent_gang_computer") then continue end

            if (v.GetZone and v:GetZone() == zone) then
                v:Remove()
            end
        end

        net.Start("GangZones.Notify")
        net.WriteInt(1, 4)
        net.WriteString(zone)
        net.Send(members)
    end
end

function asapgangs:SaveBase(base)
    local data = {}
    local zone = self.Zones[base]
    if not zone then return end
    local computer

    for _, ent in pairs(ents.FindInBox(zone.Start, zone.EndPos)) do
        if (ent.IsBase) then
            if (not IsValid(computer) and ent:GetClass() == "sent_gang_computer") then
                computer = ent
            end

            table.insert(data, {
                Pos = ent:GetPos(),
                Ang = ent:GetAngles(),
                Class = ent:GetClass()
            })
        end
    end

    http.Post(asapMarket.API .. "/gangs/upload", {
        ["key"] = "gonzo_made_it",
        ["data"] = util.TableToJSON(data),
        ["id"] = base
    }, function(b) end, function(err)
        MsgN(err)
    end)

    timer.Simple(1, function()
        if IsValid(computer) then
            computer:SetZone(base)
            computer:LoadBaseData(base)
        end
    end)
end

local function urlencode(url)
    if url == nil then return end
    url = string.Replace(url, " ", "%20")
    url = string.Replace(url, "'", "%27")

    return url
end

function asapgangs:LoadZones()
    self.Zones = util.JSONToTable(file.Read("gang_zones.txt") or "[]")
    self.Doors = {}

    for k, v in pairs(ents.FindByClass("sent_gang_computer")) do
        v:Remove()
    end

    for k, v in pairs(ents.FindByClass("sent_gang_dropoff")) do
        v:Remove()
    end

    asapgangs.BaseData = {}

    for k, v in pairs(self.Zones) do
        if not self.Doors[k] then
            self.Doors[k] = {}
        end

        for _, door in pairs(ents.FindInBox(v.Start, v.EndPos)) do
            if (door:isDoor()) then
                table.insert(self.Doors[k], door)
            end
        end

        if not asapgangs.BaseData[k] then
            asapgangs.BaseData[k] = {}
        end

        local computer = ents.Create("sent_gang_computer")
        computer:SetPos(v.Start + Vector(0, 0, 10))
        computer:Spawn()
        computer:DropToFloor()
        computer:SetZone(k)
        computer:SetGang(v.Gang or "")
        asapgangs.BaseData[k].Computer = computer

        for _, door in pairs(self.Doors[k]) do
            if (v.Gang) then
                door:Remove()
            end
        end
    end
end

function asapgangs:CreateMarker(ply)
    local shaft = table.Random(ents.FindByClass("sent_gang_dropoff"))
    net.Start("Gangs.SendShaftPos")
    net.WriteVector(shaft:GetPos())
    net.WriteUInt(table.Count(ply.Packages), 4)
    net.Send(ply)
    ply.shaftTarget = shaft
end

function asapgangs:StartRaid(gang, attacker)
    if (attacker:GetGang() == "") then return end
    if (attacker:GetGang() == gang) then return end
    if (attacker.GangRaiding) then return end

    local hasPC = false
    for k, v in pairs(ents.FindByClass("sent_gang_computer")) do
        if v:GetGang() == gang then
            hasPC = true
            break
        end
    end
    if not hasPC then
        attacker:ChatPrint("This gang does not have a computer to raid! (They may have been raided already)")
        return
    end
    if not self.Raids then
        self.Raids = {}
    end

    if (self.Raids[gang]) then return end

    local attackerGang = attacker:GetGang()

    if not self.Raids then
        self.Raids = {}
    end

    local insiders, attackers = {}, {}

    for k, v in pairs(player.GetAll()) do
        local gng = v:GetGang()
        if gng == "" then continue end

        if (gng == gang) then
            table.insert(insiders, v)
        elseif (gng == attacker:GetGang()) then
            table.insert(attackers, v)
        end
    end

    local players = {}
    table.Add(players, insiders)
    table.Add(players, attackers)

    self.Raids[gang] = {
        Attacker = attackerGang,
        Defender = gang,
        StartAt = CurTime(),
        Lifes = table.Count(attackers),
        A = attackers,
        B = insiders,
        All = players,
        Score = {0, 0}
    }

    for k, v in pairs(ents.FindByClass("sent_gang_computer")) do
        if (v:GetGang() == gang) then
            self.Raids[gang].GangComputer = v
            v:SetStealing(true)
            break
        end
    end

    for k, v in pairs(self.Raids[gang].A) do
        if not IsValid(v) then continue end
        v.GangRaiding = gang
    end

    for k, v in pairs(self.Raids[gang].B) do
        if not IsValid(v) then continue end
        v.GangRaiding = gang
    end

    net.Start("Gangs.StartRaid")
    net.WriteString(attackerGang)
    net.WriteString(gang)
    net.Send(players)

    hook.Run("OnGangRaidStart", gang, attackerGang, players)

    timer.Create(gang .. "_Raid", 5, 0, function()
        if not self.Raids[gang] then
            self:DispatchRaid(gang)
        end

        if not IsValid(self.Raids[gang].GangComputer) then
            for k, v in pairs(ents.FindByClass("sent_gang_computer")) do
                if (v:GetGang() == gang) then
                    self.Raids[gang].GangComputer = v
                    break
                end
            end

            if not IsValid(self.Raids[gang].GangComputer) then return end
        end

        for k, v in pairs(self.Raids[gang].A or {}) do
            local cpuDist = v:GetPos():Distance(self.Raids[gang].GangComputer:GetPos())

            if (cpuDist > 1500) then
                self.Raids[gang].Lifes = self.Raids[gang].Lifes - 1
                table.RemoveByValue(self.Raids[gang].A, v)
                v.GangRaiding = nil
                net.Start("Gangs.ExitRaid")
                net.WriteInt(0, 4)
                net.Send(v)
            end
        end

        if (self.Raids[gang].Lifes <= 0) then
            net.Start("Gangs.SendResult")
            net.WriteBool(false)
            net.Send(self.Raids[gang].All)
            local data = asapgangs.Raids[gang]
            hook.Run("OnGangRaidEnd", data.Defender, data.Attacker, false, data)
            self:DispatchRaid(gang)
            self:DoScore(attackerGang, -6)
        end
    end)
end

function asapgangs:DispatchRaid(gang, attacker)
    if not self.Raids[gang] then return end
    local endWar = {}

    for k, v in pairs(player.GetAll()) do
        if (v:GetGang() == gang or v:GetGang() == self.Raids[gang].Attacker) then
            v.GangRaiding = nil
            table.insert(endWar, v)
        end
    end

    if IsValid(self.Raids[gang].GangComputer) then
        self.Raids[gang].GangComputer:SetStealing(false)
    end
    asapgangs:SaveRanked(gang, self.Raids[gang].Attacker)
    self.Raids[gang] = nil
    net.Start("Gangs.StopRaid")
    net.Send(endWar)
    timer.Remove(gang .. "_Raid")
end


hook.Add("OnGangComputerDestroyed", "GangWarFinished", function(ent, gang, dmg)
    if not asapgangs.Raids or not asapgangs.Raids[gang] then return end
    net.Start("Gangs.SendResult")
    net.WriteBool(true)
    net.Send(asapgangs.Raids[gang].All)
    hook.Run("OnGangRaidEnd", gang, asapgangs.Raids[gang].Attacker, true, asapgangs.Raids[gang])
    asapgangs:DoScore(dmg:GetAttacker(), 25)
    asapgangs:DoScore(asapgangs.Raids[gang].B[1], 10)
    asapgangs:DispatchRaid(gang)
end)

hook.Add("PlayerDeath", "asapGangs.RaidStatus", function(ply, att)
    if (att ~= ply and att:IsPlayer() and ply.GangRaiding and asapgangs.Raids[ply.GangRaiding]) then
        asapgangs:DoScore(att, 3)
        asapgangs.Raids[ply.GangRaiding].Lifes = asapgangs.Raids[ply.GangRaiding].Lifes - 1
        table.RemoveByValue(asapgangs.Raids[ply.GangRaiding].A, ply)
        net.Start("Gangs.ExitRaid")
        net.WriteInt(1, 4)
        net.Send(ply)

        if (asapgangs.Raids[ply.GangRaiding].Lifes <= 0) then
            net.Start("Gangs.SendResult")
            net.WriteBool(false)
            net.Send(asapgangs.Raids[ply.GangRaiding].All)
            local data = asapgangs.Raids[ply.GangRaiding]
            hook.Run("OnGangRaidEnd", data.Defender, data.Attacker, false, data)

            asapgangs:DoScore(ply, -12)
            asapgangs:DoScore(asapgangs.Raids[ply.GangRaiding].B[1], 10)
            asapgangs:DispatchRaid(ply.GangRaiding)
        end
    end
end)

hook.Add("onLockpickCompleted", "asapGangs.onLockpickCompleted", function(ply, succ, ent)
    if (succ and ent.Gang and ply:GetGang() ~= ent.Gang) then
        asapgangs:StartRaid(ent.Gang, ply)
    end
end)

hook.Add("OnFadeDoorDeactived", "asapGangs.OnFadeDoorDeactived", function(ply, ent)
    if (ply:GetGang() == "" or not ent.Gang) then return end
    asapgangs:StartRaid(ent.Gang, ply)
end)

hook.Add("lockpickStarted", "asapGangs.lockpickStarted", function(ply, ent, tr)
    if (ent.Gang and ent.Gang ~= ply:GetGang()) then
        DarkRP.notify(ply, 1, 5, "This will start a Gang war! Proceed carefully")
    end
end)

hook.Add("InitPostEntity", "asapGangs.InitiateComputers", function()
    timer.Simple(5, function()
        asapgangs:LoadZones()
    end)
end)

hook.Add("PlayerInitialSpawn", "asapGangs.Zones", function(ply)
    print("YOUR GANG IS " .. ply:GetGang())
end)

hook.Add("PlayerDisconnected", "asapGangs.ZonesLeader", function(ply)
    if (ply:GetGang() == "") then return end

    if (ply.GangRaiding and asapgangs.Raids[ply.GangRaiding]) then
        asapgangs.Raids[ply.GangRaiding].Lifes = asapgangs.Raids[ply.GangRaiding].Lifes - 1
        table.RemoveByValue(asapgangs.Raids[ply.GangRaiding].A, ply)

        if (asapgangs.Raids[ply.GangRaiding].Lifes <= 0) then
            net.Start("Gangs.SendResult")
            net.WriteBool(false)
            net.Send(asapgangs.Raids[ply.GangRaiding].All)
            local data = asapgangs.Raids[ply.GangRaiding]
            hook.Run("OnGangRaidEnd", data.Defender, data.Attacker, false, data)
            asapgangs:DispatchRaid(ply.GangRaiding)
        end
    end

    asapgangs:EvictBuilding(ply)
end)

function asapgangs:Update(gang, types)
    -- Check if the gang variable is a string or number
    if type(gang) ~= "string" and type(gang) ~= "number" then
        print("Error: Gang identifier should be a string or number, got:", type(gang), tostring(gang))
        return
    end

    -- Check if gang exists in gangList
    if not asapgangs.gangList[gang] then
        print("Error: Gang " .. tostring(gang) .. " does not exist in gangList")
        return
    end

    -- Navigate through nested types
    local value = asapgangs.gangList[gang]
    for _, t in ipairs(types) do
        if not value[t] then
            print("Error: Type " .. tostring(t) .. " does not exist in " .. tostring(value))
            return
        end
        value = value[t]
    end

    -- Debug print to see what values are being posted
    print("Updating gang:", gang, "Types:", table.concat(types, " > "), "Value:", value)

    http.Post(asapMarket.API .. "/gangs/update", {
        ["key"] = "gonzo_made_it",
        ["id"] = gang,
        ["type"] = table.concat(types, ","),
        ["value"] = value
    }, function(result)
        print("Update successful:", result)
    end, function(failed)
        print("Update failed:", failed)
    end)
end

function asapgangs:GetPlayers(gang)
    local players = {}

    for k, v in pairs(player.GetAll()) do
        if (v:GetGang() == gang) then
            table.insert(players, v)
        end
    end

    return players
end

function asapgangs:GetMembers(gang)
    local members = {}

    for k, v in pairs(asapgangs.GetPlayers(gang)) do
        table.insert(members, v)
    end

    return members
end

hook.Add("OnPlayerChangedTeam", "asapGangs.ZoneAcquire", function(ply, old, new)
    if (new == TEAM_GANGLEADER) then
        local today = os.date("*t").yday
        local lastDay = ply:GetPData("LastConnectionDay", today)

        if not asapgangs.gangList[ply:GetGang()].MMR then
            asapgangs.gangList[ply:GetGang()].MMR = 0
        end

        if (today - lastDay == 1) then
            asapgangs.gangList[ply:GetGang()].MMR = asapgangs.gangList[ply:GetGang()].MMR + 2
            asapgangs.Update(ply:GetGang(), "MMR")
        elseif (today - lastDay > 2) then
            asapgangs.gangList[ply:GetGang()].MMR = asapgangs.gangList[ply:GetGang()].MMR - math.min(today - lastDay, 7)
            asapgangs.Update(ply:GetGang(), "MMR")
        end

        ply:SetPData("LastConnectionDay", today)

        for k, v in pairs(asapgangs.Zones) do
            if (v.Gang == ply:GetGang()) then
                timer.Remove(k .. "_cleanse")
                DarkRP.notify(ply, 3, 5, "You've saved the zone from being abandoned")
                break
            end
        end
    end
end)

net.Receive("GangZones.AcquireZone", function(l, ply)
    local id = net.ReadString()
    local zone = asapgangs.Zones[id]

    if (ply:Team() != TEAM_GANGLEADER) then
        DarkRP.notify(ply, 0, 5, "You must be a gang leader job to purchase a zone")

        return
    end

    if (zone and zone.Gang and zone.Gang ~= "") then
        DarkRP.notify(ply, 0, 5, "You cannot purchase an owned building")

        return
    end

    for k, v in pairs(asapgangs.Zones) do
        if (v.Gang and v.Gang == ply:GetGang()) then
            DarkRP.notify(ply, 0, 5, "Your gang already owns a building, write !evict to remove your base as Leader")
            return
        end
    end

    if (ply:canAfford(asapgangs.War.ZonePrice)) then
        ply:addMoney(-asapgangs.War.ZonePrice)
        asapgangs:SetZoneOwner(id, ply)
    end
end)

hook.Add("PlayerSay", "EvictHome", function(ply, text)
    if (text == "!evict") then
        if not ply.evictWarning then
            ply.evictWarning = true
            DarkRP.notify(ply, 0, 5, "Write !evict again to confirm the eviction of your gang base")
            return
        end

        asapgangs:EvictBuilding(ply, true)
        ply.evictWarning = nil
        DarkRP.notify(asapgangs.GetMembers(ply:GetGang()), 1, 5, ply:Nick() .. " Has evicted your base!")

        return ""
    end
end)

net.Receive("GangZones.AcquireUpgrade", function(l, ply)
    local id = net.ReadString()
    local upg = net.ReadString()
    local computer = net.ReadEntity()
    local zone = asapgangs.Zones[id]
    local base = asapgangs.BaseData[id]

    if not zone or not base then
        error("Zone " .. id .. " doesn't exists or base data has not been loaded!")

        return
    end

    local level = asapgangs.Zones[id][upg] or 0

    if (level >= table.Count(base[upg])) then
        //error("Zone " .. id .. " already reached max upgrade level for " .. upg .. "!")

        return
    end

    local price = asapgangs.War.Prices[upg][math.min(level + 1, table.Count(asapgangs.War.Prices[upg]))]

    if (ply:canAfford(price)) then
        asapgangs.Zones[id][upg] = (asapgangs.Zones[id][upg] or 0) + 1
        local data = base[upg][asapgangs.Zones[id][upg]]
        if (not data) then return end
        ply:addMoney(-price)
        local ent = ents.Create(upg)
        ent:SetPos(data.Pos)
        ent:SetAngles(data.Ang)
        ent:SetGang(ply:GetGang())
        ent:SetZone(id)
        ent:Spawn()
        ent.GangComputer = computer

        if (upg == "sent_gang_delivery") then
            if (not computer.Deliveries) then
                computer.Deliveries = {}
            end

            table.insert(computer.Deliveries, ent)
        end

        if not computer.Upgrades then
            computer.Upgrades = {
                [upg] = {}
            }
        elseif (not computer.Upgrades[upg]) then
            computer.Upgrades[upg] = {}
        end

        table.insert(computer.Upgrades[upg], ent)
        ply:EmitSound("jewelry_robbery/money.wav")
        net.Start("GangZones.AcquireUpgrade")
        net.WriteString(id)
        net.WriteString(upg)
        net.WriteInt(asapgangs.Zones[id][upg], 4)
        net.Send(ply)

        if (level >= table.Count(base[upg])) then
            asapgangs.gangList[ply:GetGang()].MMR = asapgangs.gangList[ply:GetGang()].MMR + 1
            asapgangs.Update(ply:GetGang(), "MMR")
        end
    end
end)

net.Receive("ASAP.Gangs:RequestSteal", function(l, ply)
    local ent = net.ReadEntity()
    if (ply:GetGang() == "") then return end

    if (ent:GetGang() == ply:GetGang() and ent:GetStealing()) then
        ent:SetStealing(false)

        timer.Create(ent:EntIndex() .. "_DrillWaiting", asapgangs.War.CaptureTime / 2, 1, function()
            if IsValid(ent) then
                ent:SetStealingTime(0)
                asapgangs:DoScore(asapgangs.Raids[ply:GetGang()].B[1], 7)
                asapgangs:DoScore(asapgangs.Raids[ply:GetGang()].A[1], -6)
                net.Start("Gangs.SendResult")
                net.WriteBool(false)
                net.Send(asapgangs.Raids[ent:GetGang()].All)
                
                local data = asapgangs.Raids[ply:GetGang()]
                hook.Run("OnGangRaidEnd", data.Defender, data.Attacker, false, data)
                asapgangs:DispatchRaid(ent:GetGang())
            end
        end)

        return
    end

    if (ply:GetEyeTrace().Entity ~= ent) then return end
    if (ply:GetPos():Distance(ent:GetPos()) > 300) then return end
    timer.Remove(ent:EntIndex() .. "_DrillWaiting")
    ent:SetStealing(true)
    ent:SetStealingTime(CurTime() + asapgangs.War.CaptureTime)
    ent.StealingBy = ply
end)

net.Receive("GangsMachine.UpdateResource", function(l, ply)
    local isFull = net.ReadBool()
    if (isFull and ply:GetGang() == ply.GangComputer:GetGang()) then end
end)

local ranks = {
    trialmoderator = true,
    moderator = true,
    admin = true,
    senioradmin = true,
    superadmin = true,
    owner = true
}

concommand.Add("gang_removezone", function(ply, cmd, args)
    if (IsValid(ply) and not ranks[ply:GetUserGroup()]) then return end

    if (asapgangs.Zones[args[1]]) then
        asapgangs.Zones[args[1]] = nil

        http.Post(asapMarket.API .. "/gangs/removezone", {
            id = args[1],
            key = "gonzo_made_it"
        })

        file.Write("gang_zones.txt", util.TableToJSON(asapgangs.Zones, true))
        //asapgangs:BroadcastZones()
    end
end)

concommand.Add("gang_safeshafts", function(ply, cmd, args)
    if IsValid(ply) then return end
    local data = {}

    for k, v in pairs(ents.FindByClass("sent_gang_dropoff")) do
        table.insert(data, {
            Pos = v:GetPos(),
            Ang = v:GetAngles()
        })
    end

    http.Post(asapMarket.API .. "/gangs/saveshafts", {
        shafts = util.TableToJSON(data),
        key = "gonzo_made_it"
    }, function(res)
        MsgN("Shafts saved!")
    end)
end)

net.Receive("Gangs.PickupDelivery", function(l, ply)
    local result = true

    if (not IsValid(ply.GangComputer)) then
        result = false
    end

    local resourceTable = {}

    if (result) then
        local limit = net.ReadUInt(4)

        for k = 1, limit do
            local resType = net.ReadUInt(4)
            local value = net.ReadUInt(32)

            if ((ply.GangComputer.Resources[resType] or 0) < value) then
                result = false
                break
            else
                resourceTable[resType] = value
            end
        end
    end

    if (result) then
        for k, v in pairs(resourceTable) do
            ply.GangComputer:AddResource(k, -v)
        end

        ply:EmitSound("npc/combine_soldier/gear2.wav")
        ply:ChatPrint("<color=green>Delivery picked up! Carry it into the designed area!</color>")
        ply.Packages = table.Copy(resourceTable)
        ply.ShippingPost = ply._tempOutpost
        ply:SetNWInt("Delivery.Packages", table.Count(resourceTable))
        asapgangs:CreateMarker(ply)
    end

    net.Start("Gangs.PickupDelivery")
    net.WriteBool(result)
    net.Send(ply)
end)