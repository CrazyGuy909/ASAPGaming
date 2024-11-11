util.AddNetworkString("ASAP.Arena.JoinArena")
util.AddNetworkString("ASAP.Arena.RequestInfo")
util.AddNetworkString("ASAP.Arena.SendData")
util.AddNetworkString("ASAP.Arena.RequestSpawn")
util.AddNetworkString("ASAP.Arena.ShowDeathScreen")
util.AddNetworkString("ASAP.Arena.EquipWeapon")
util.AddNetworkString("ASAP.Arena.EquipTaunt")
util.AddNetworkString("ASAP.Arena.EquipModel")
util.AddNetworkString("ASAP.Arena.XP")
util.AddNetworkString("ASAP.Arena.Leave")
util.AddNetworkString("ASAP.Arena.ShowLoadout")
util.AddNetworkString("ASAP.Arena.VoiceChannel")
util.AddNetworkString("ASAP.Arena.SendShaft")
util.AddNetworkString("ASAP.Arena.RequestStats")
util.AddNetworkString("ASAP.UpdateStats")
util.AddNetworkString("ASAP.Arena.CrateInfo")
util.AddNetworkString("ASAP.Arena.GotReward")
util.AddNetworkString("ASAP.Arena:Notify")
util.AddNetworkString("ASAP.Arena.Score")
asapArena.Players = asapArena.Players or {}
asapArena.VoiceChannel = asapArena.VoiceChannel or {}
asapArena.BanList = util.JSONToTable(file.Read("event_winners.txt") or "[]")

function net.SendArena()
    net.Send(asapArena:GetPlayers())
end

function asapArena:StartCaseEvent(active)
    if IsValid(BIG_CASE) then
        BIG_CASE:Remove()
    end

    if (not active) then return end
    BIG_CASE = ents.Create("sent_asap_drop")
    BIG_CASE:SetPos(Vector(-3150.145020, -2945.482178, -9632.912109))
    BIG_CASE:Spawn()
    --self:SetGamemode("gungame", true)
end

function asapArena:EndCaseEvent()
    SetGlobalBool("Arena.CaseEvent", false)
    net.Start("ASAP.Arena.RareCrateInfo")
    net.WriteBool(false)
    net.Broadcast()
end


function asapArena:StartRareCaseEvent(active)
    if IsValid(BIG_CASE) then
        BIG_CASE:Remove()
    end

    if (not active) then return end
    BIG_CASE = ents.Create("sent_asap_drop_rare")
    BIG_CASE:SetPos(Vector(-3150.145020, -2945.482178, -9632.912109))
    BIG_CASE:Spawn()
    --self:SetGamemode("gungame", true)
end

function asapArena:EndCaseEvent()
    SetGlobalBool("Arena.RareCaseEvent", false)
    net.Start("ASAP.Arena.RareCrateInfo")
    net.WriteBool(false)
    net.Broadcast()
end

local meta = FindMetaTable("Player")

local commands = {
    cl_arenacbob_compensation = {1, 0},
    cl_arenacbob_intensity = {1.5, 0},
    cl_arena_legs = {1, 0},
    cl_tfa_viewbob_intensity = {4.5, 1},
    cl_tfa_viewbob_animated = {1, 1},
    cl_tfa_gunbob_intensity = {1.5, 1}
}

local canJoinCVAR = CreateConVar("arena_enable", 1, FCVAR_ARCHIVE)

cvars.AddChangeCallback("arena_enable", function(name, old, new)
    if (tonumber(new) and tonumber(new) == 0) then
        for k, v in pairs(asapArena:GetPlayers()) do
            v:LeaveArena()
        end
    end
end)

util.AddNetworkString("ASAP.Arena:SyncNWVars")

local bannedModes = {
    gungame = true,
    suits = true
}

function RecursiveSetPreventTransmit(ent, ply, stopTransmitting)
    if ent ~= ply and IsValid(ent) and IsValid(ply) then
        ent:SetPreventTransmit(ply, stopTransmitting)
        local tab = ent:GetChildren()
        for i = 1, #tab do
            RecursiveSetPreventTransmit(tab[ i ], ply, stopTransmitting)
        end
    end
end

local minPlayers = CreateConVar("asap_arena_minplayers_queue", 5, FCVAR_ARCHIVE, "Minimum players to start arena queue")
function meta:JoinArena(force)

    if (self:InVehicle()) then
        self:ExitVehicle()
    end

    if not force then
        if (not canJoinCVAR:GetBool()) then return false end
        if (self._arenaData and self._arenaData.Banned) then return false end --DarkRP.notify(self, 1, 6, "You has been banned from arena!")
        local id = asapArena.ActiveGamemode.id

        if (player.GetCount() > minPlayers:GetInt() and bannedModes[id] and asapArena.BanList[self:SteamID()] and asapArena.BanList[self:SteamID()][id]) then
            DarkRP.notify(self, 1, 5, "You need to wait " .. asapArena.BanList[self:SteamID()][id] .. " event/s to play again")

            return
        end

        local canJoin, reason = hook.Run("CanPlayerJoinArena", self)
        if (not self:IsBot() and canJoin == false) then
            if (reason) then
                DarkRP.notify(self, 1, 4, reason)
            end
            return
        end
    end


    if (LSAC and LSAC.detections) then
        timer.Simple(0, function()
            LSAC.detections:ExtIgnorePlayerForSeconds(self, "NoArena", false)
        end)
    end

    hook.Run("OnArenaJoin", self, id)
    self:StripWeapons()
    asapArena.Players[self] = true
    asapArena:InitPlayer(self)

    self.oldJob = self:Team()
    self:SetTeam(TEAM_ARENA or TEAM_CITIZEN)

    if (self.removeArmorSuit) then
        self:removeArmorSuit()
    end

    net.Start("ASAP.Arena:SyncNWVars")
    net.Send(self)
    self:SetNWInt("GGLevel", 1)
    self:SetFrags(0)
    self:SetNWBool("InArena", true)
    self:SetFrags(0)

    for k, v in pairs(commands) do
        self:ConCommand(k .. " " .. v[1])
    end

    self._arenaSession = {
        Damage = 0
    }

    local ply = self

    for k, v in pairs(ply.gobblegums or {}) do
        local data = ASAP_GOBBLEGUMS.Gumballs[k]

        if (data and data.OnGumballDequip) then
            data.OnGumballDequip(self)
        end
    end

    for k, v in pairs(ply.gobblegumscooldown or {}) do
        if v.activeTime == -1 then
            local cooldown = ASAP_GOBBLEGUMS.GlobalCooldown

            if ply.gobblegumabilties[2] then
                cooldown = cooldown / 2
            end

            ply.gobblegumscooldown[k] = {
                activatedFunc = false,
                activeTime = 0,
                cooldown = CurTime() + cooldown,
                startTime = CurTime()
            }
        end
    end

    --self.gobblegums = {}
    self.gobblegumscooldown = {}
    self.asap_perks = {}

    if (self.NetworkGobblegumCooldowns) then
        self:NetworkGobblegumCooldowns()
    end

    if (self.NetworkASAPPerks) then
        self:NetworkASAPPerks()
    end

    self:GetHands():SetModel("models/weapons/c_arms_cstrike.mdl")
    self.arenaSpawnTime = CurTime()

    if (ply:IsBot()) then
        ply:GodDisable()
        ply:SetNoDraw(false)
    end
end

function meta:ShowMessage(msg, clr)
    net.Start("ASAP.Arena:Notify")
    net.WriteString(msg)
    net.WriteInt(clr, 4)
    net.Send(self)
end

function meta:LeaveArena()
    if (not self:InArena()) then return end

    if (LSAC and LSAC.detections) then
        LSAC.detections:ExtIgnorePlayerForSeconds(self, "NoArena", 3600 * 16)
        LSAC.detections:ExtIgnorePlayerForSeconds(self, "NoArena", nil)
    end

    if (self:IsDueling()) then
        local duel = asapArena.Duels[self.DuelStamp]

        if duel then
            asapArena:FinishDuel(self.DuelStamp, duel.A == self and duel.B or duel.A)
        end
    end

    for k, v in pairs(player.GetAll()) do
        if (v == self) then continue end
        RecursiveSetPreventTransmit(v, self, v:InArena())
        if (v:InArena()) then
            RecursiveSetPreventTransmit(self, v, true)
        end
    end

	self:removeArmorSuit()
    asapArena.Players[self] = nil
    hook.Run("OnArenaLeave", self)

    if (self:IsDueling()) then
        local duel = asapArena.Duels[self.DuelStamp]

        if duel ~= nil then
            local other = duel.A == self and duel.B or duel.A
            asapArena:FinishDuel(self.DuelStamp, other)
        end
    end

    self:SetNWBool("InArena", false)
    asapArena:Run("PlayerLeave", nil, self)
    asapArena:SavePlayer(self)
	if (self.oldJob) then
        self:SetTeam(self.oldJob)
        self.oldJob = nil
    else
        self:SetTeam(TEAM_CITIZEN)
    end
    self:StripWeapons()
    self:Spawn()
    self:SendLua("RunConsoleCommand('stopsound')")

    for k, v in pairs(commands) do
        self:ConCommand(k .. " " .. v[2])
    end

    self:ConCommand("-attack")
    local tbl = player_manager.TranslatePlayerHands(self:GetModel())
    self:GetHands():SetModel(tbl.model)
    net.Start("ASAP.UpdateStats")
    net.WriteTable(self._arenaData or {})
    net.Send(self)

    for slot, val in pairs(self._arenaEquipment.Perks or {}) do
        asapArena.Perks[slot][val].OnEquip(self)
    end
end

hook.Add("OnPlayerChangedTeam", "ArmorSuitsArena", function(ply)
    ply:SendLua("RunConsoleCommand('stopsound')")
    ply:ConCommand("-attack")
end)

hook.Add("PlayerInitialSpawn", "Arena.NOAC", function(ply)
    if (LSAC and LSAC.detections) then
        timer.Simple(1, function()
            LSAC.detections:ExtIgnorePlayerForSeconds(ply, "NoArena", 3600 * 16)
            LSAC.detections:ExtIgnorePlayerForSeconds(ply, "NoArena", nil)
        end)
    end
end)

function meta:SaveArena()
end

function meta:AddArenaScore(am)
    self._arenaScore = (self._arenaScore or 0) + am
    net.Start("ASAP.Arena.Score")
    net.WriteUInt(self._arenaScore, 24)
    net.Send(self)
end

function meta:GiveArenaXP(am, reason, rep)

    local xp = self:GetArenaXP()
    local level = self:GetArenaLevel()
    local target = (level + 1) * 100

    if (xp + am >= target) then
        self._arenaLevel = level + 1
        self._arenaXP = 0
        self:GiveArenaXP((xp + am) - target, "", true)
        hook.Run("OnArenaLevelUp", self, level + 1)
    else
        xp = xp + am
        self._arenaXP = xp
    end

    if (SERVER and not rep) then
        net.Start("ASAP.Arena.XP")
        net.WriteUInt(self._arenaXP, 24)
        net.WriteUInt(self._arenaLevel, 16)
        net.Send(self)
    end

end

concommand.Add("arena_setgamemode", function(ply, cmd, args)
    if (IsValid(ply)) then return end
    local id = args[1]

    if (asapArena.Gamemodes[id]) then
        asapArena:SetGamemode(id, args[2])
    else
        error("Gamemode with id " .. id .. " doesn't exists!")
    end
end)


function meta:AddArenaFrags(i)
    //self:SetNW2Int("ArenaFrags", self:Frags() + i)
end

concommand.Add("arena_setgamemode", function(ply, cmd, args)
    if IsValid(ply) then return end -- Make sure the command is not executed by a player

    local id = args[1]

    if asapArena.Gamemodes[id] then
        asapArena:SetGamemode(id, args[2])
    else
        error("Gamemode with id " .. id .. " doesn't exist!")
    end
end)

--local active = args[1] == nil or tonumber(args[1]) ~= 0
--SetGlobalBool("Arena.CaseEvent", active)
--asapArena:StartCaseEvent(active)
net.Receive("ASAP.Arena.VoiceChannel", function(l, ply)
    local enable = net.ReadBool()
    ply.ArenaVoice = enable

    if (not enable) then
        asapArena.VoiceChannel[ply] = nil
    elseif (enable) then
        asapArena.VoiceChannel[ply] = true
    end
end)

net.Receive("ASAP.Arena.JoinArena", function(l, ply)
    if (not ply:InArena()) then
        ply:JoinArena()
    end
end)

net.Receive("ASAP.Arena.Leave", function(l, ply)
    ply:LeaveArena()
end)

net.Receive("ASAP.Arena.RequestSpawn", function(l, ply)
    if (not ply:InArena()) then return end

    if (ply:IsDueling()) then
        ply:Spawn()
        asapArena:SpawnPlayerDuel(ply)

        return
    end

    local b = net.ReadBool()

    if (not b) then
        ply:LeaveArena()
        ply:Spawn()
    else
        ply:Spawn()
        asapArena:Run("PlayerSpawn", nil, ply)
    end
end)

net.Receive("ASAP.Arena.EquipModel", function(l, ply)
    local slot = net.ReadString()
    local wep = net.ReadString()

    if (asapArena.Models[tonumber(wep)].Level <= ply:GetArenaLevel()) then
        ply._arenaEquipment[slot] = wep
    end
end)

net.Receive("ASAP.Arena.EquipTaunt", function(l, ply)
    local slot = net.ReadString()
    local wep = net.ReadString()

    if (asapArena.Taunts[wep].Level <= ply:GetArenaLevel()) then
        ply._arenaEquipment[slot] = wep
        ply:SetNWString("ArenaTaunt", wep)
    end
end)

net.Receive("ASAP.Arena.EquipWeapon", function(l, ply)
    local slot = net.ReadString()
    local wep = net.ReadString()

    if (not asapArena.Weapons) then
        AddCSLuaFile("arena/sh_weapons.lua")
        include("arena/sh_weapons.lua")
    end

    if (asapArena.Weapons[wep].Level <= ply:GetArenaLevel()) then
        ply._arenaEquipment[slot] = wep
    end
end)

hook.Add("CanPlayerSuicide", "Arena.NoSuicide", function(ply)
    if (ply:InArena()) then return false end
end)

hook.Add("PlayerSay", "Arena.BanSystem", function(ply, txt)
    --if (ply:SteamID64() == "76561198168652477") then return end
    if (string.StartWith(txt, "!banarena")) then
        local sid = string.Explode(" ", txt, false)[2]

        if (sid) then
            local target = player.GetBySteamID64(sid)

            if IsValid(target) and ply._arenaData then
                target._arenaData.Banned = true
                DarkRP.notify(ply, 0, 5, target:Nick() .. " has been banned from playing arena")

                if (target:InArena()) then
                    target:LeaveArena()
                    DarkRP.notify(ply, 1, 5, "You has been banned from playing arena")
                else
                    asapArena:SavePlayer(target)
                end
            else
                local query = "SELECT Data FROM arena_players WHERE steamid = '" .. sid .. "'"

                asapArena.query(query, function(data)
                    if (data[1]) then
                        local save = util.JSONToTable(data[1].Data)
                        data.Banned = true
                        asapArena.query("UPDATE arena_players SET `Data` = '" .. util.TableToJSON(save) .. "' WHERE `steamid`='" .. sid .. "';")
                    end
                end)

                DarkRP.notify(ply, 0, 5, "This player has been banned from playing arena")
            end
        end

        return ""
    end

    if (string.StartWith(txt, "!unbanarena")) then
        local sid = string.Explode(" ", txt, false)[2]

        if (sid) then
            local target = player.GetBySteamID64(sid)

            if IsValid(target) and ply._arenaData then
                target._arenaData.Banned = nil
                DarkRP.notify(ply, 0, 5, target:Nick() .. " has been unbanned from playing arena")
                asapArena:SavePlayer(target)
            else
                local query = "SELECT Data FROM arena_players WHERE steamid = '" .. sid .. "'"

                asapArena.query(query, function(data)
                    if (data[1]) then
                        local save = util.JSONToTable(data[1].Data)
                        data.Banned = nil
                        asapArena.query("UPDATE arena_players SET `Data` = '" .. util.TableToJSON(save) .. "' WHERE `steamid`='" .. sid .. "';")
                    end
                end)

                DarkRP.notify(ply, 0, 5, "This player has been unbanned from playing arena")
            end
        end

        return ""
    end
end)