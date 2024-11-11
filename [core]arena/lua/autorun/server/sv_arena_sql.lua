util.AddNetworkString("ASAP.Arena.SaveInfo")
require("mysqloo")
local isLan = GetConVar("sv_lan")

asapArena.sqlInfo = {
    ["host"] = "172.0.0.2",
    ["username"] = "u5720_W3dOI1dTLP",
    ["password"] = "h.eeKkOWOuBBcvhebwu=25FP",
    ["dbname"] = "s5720_players",
    ["port"] = 3306
}

local conn = mysqloo.connect(asapArena.sqlInfo.host, asapArena.sqlInfo.username, asapArena.sqlInfo.password, asapArena.sqlInfo.dbname, asapArena.sqlInfo.port)

function conn:onConnected()
    print("[ASAP Arena] Database connection acquired")
end

function conn:onConnectionFailed(err)
    print("[ASAP Arena] Database connection failed!:")
    print(err)
end

conn:connect()

function asapArena.query(qry, callback)
    local q = conn:query(qry)

    function q:onError(err, cause)
        print("[ASAP Arena] Query error:")
        print(cause)
        print(err)
    end

    if callback then
        function q:onSuccess(data)
            callback(data)
        end
    end

    q:start()

    return q
end

function asapArena:CreatePlayer(ply, ignoreJoin)
    if (not ply._arenaData) then
        ply._arenaData = {}
    end

    ply._arenaEquipment = {
        Primary = "tfa_cso_ak47",
        Secondary = "tfa_cso_glock",
        Taunt = "laugh"
    }

    self.query("INSERT INTO arena_players(`steamid`,`Level`,`Experience`,`Score`,`Data`,`Equipment`) VALUES('" .. ply:SteamID64() .. "', '1', '0', '0', '" .. (ply._arenaData.Challenges and util.TableToJSON(ply._arenaData) or "[]") .. "', '" .. util.TableToJSON(ply._arenaEquipment) .. "');", function()
        if (ignoreJoin) then return end
        net.Start("ASAP.Arena.SendData")
        net.WriteTable(ply._arenaEquipment)
        net.WriteBool(false)
        net.Send(ply)
        ply.WaitingLoadout = true
        --ply:SetNoDraw(true)
        ply:GodEnable()
        self:SetPlayerModel(ply)
        self:Run("PlayerJoin", nil, ply)

        if (table.Count(self.Players) == 1) then
            self:Run("Init")
        else
            self:Run("PlayerSpawn", nil, ply)
        end
    end)
end

function asapArena:SavePlayer(ply)
    if (not ply.CanSave) then return end
    local query = "UPDATE arena_players SET `Level`='" .. ply:GetArenaLevel() .. "', `Experience`='" .. ply:GetArenaXP() .. "', `Score`='" .. ply:GetArenaScore() .. "', `Data` = '" .. util.TableToJSON(ply._arenaData or {}) .. "', `Equipment`='" .. util.TableToJSON(ply._arenaEquipment or {}) .. "' WHERE `steamid`='" .. ply:SteamID64() .. "';"

    self.query(query, function()
        DarkRP.notify(ply, 2, 5, "[Arena] Your progress has been saved.")
    end)
end

function asapArena:InitPlayer(ply)
    if not ply._arenaData then
        self:CreatePlayer(ply)
    end

    self:SetPlayerModel(ply)
    self:Run("PlayerJoin", nil, ply)
    self:GetChallenges(ply)

    if (table.Count(self.Players) == 1) then
        self:Run("Init")
    else
        self:Run("PlayerSpawn", nil, ply)
    end

    if (ply:IsDueling()) then return end
    net.Start("ASAP.Arena.SendData")
    net.WriteBool(false)
    net.Send(ply)
end

net.Receive("ASAP.Arena.SaveInfo", function(l, ply)
    local shouldSave = net.ReadBool()

    if (ply.WaitingLoadout) then
        ply:SetNoDraw(false)
        ply:GodDisable()
        ply:Spawn()
        ply.WaitingLoadout = nil
    end

    if (not shouldSave) then return end
    local query = "UPDATE arena_players SET `Equipment`='" .. util.TableToJSON(ply._arenaEquipment or {}) .. "' WHERE `steamid`='" .. ply:SteamID64() .. "';"

    asapArena.query(query, function()
        DarkRP.notify(ply, 2, 5, "[Arena] Your equipment has been saved.")
    end)
end)

net.Receive("ASAP.Arena.RequestStats", function(l, ply)
    if (not ply._requestedStats) then
        ply._requestedStats = true
        local query = "SELECT * FROM arena_players WHERE steamid = '" .. ply:SteamID64() .. "'"

        asapArena.query(query, function(data)
            if (data[1]) then
                ply._arenaXP = data[1].Experience
                ply._arenaLevel = data[1].Level
                ply._arenaScore = data[1].ArenaScore
                ply._arenaData = util.JSONToTable(data[1].Data)
                ply._arenaEquipment = util.JSONToTable(data[1].Equipment)
                ply:SetNWString("ArenaTaunt", ply._arenaEquipment.Taunt or "laugh")
                net.Start("ASAP.Arena.SendData")
                net.WriteTable(ply._arenaEquipment)
                net.WriteBool(true)
                net.Send(ply)
            end
        end)
    end
end)

asapArena.query("CREATE TABLE IF NOT EXISTS arena_players(steamid VARCHAR(22) PRIMARY KEY, Level INT DEFAULT 0, Experience INT DEFAULT 0, Score INT DEFAULT 0, Data LONGTEXT, Equipment LONGTEXT)")