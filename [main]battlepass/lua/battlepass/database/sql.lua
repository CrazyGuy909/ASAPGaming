function BATTLEPASS.Database:Setup()
    local conn = MySQLite
    conn.query([[
		CREATE TABLE IF NOT EXISTS battlepass_players (
			aid BIGINT(21),
			pid VARCHAR(32),
			owned SMALLINT(1) NOT NULL DEFAULT 0,
			tier INT UNSIGNED NOT NULL DEFAULT 1,
			progress INT UNSIGNED NOT NULL DEFAULT 0,
            reward VARCHAR(16) NOT NULL,
			PRIMARY KEY (aid, pid)
		)
	]])
    conn.query([[
		CREATE TABLE IF NOT EXISTS battlepass_challenges (
			aid BIGINT(21) NOT NULL,
			pid VARCHAR(32) NOT NULL,
			cat_name VARCHAR(32) NOT NULL,
			challenge_index varchar(48) NOT NULL,
			progress FLOAT NOT NULL,
			PRIMARY KEY (aid, pid, cat_name, challenge_index),
			CONSTRAINT pid_frgn
				FOREIGN KEY (aid, pid) REFERENCES battlepass_players (aid, pid)
				ON DELETE CASCADE
		)
	]])
    conn.query([[
		CREATE TABLE IF NOT EXISTS battlepass_claimed (
			aid BIGINT(21) NOT NULL,
			pid VARCHAR(32) NOT NULL,
			premium SMALLINT(1) NOT NULL,
			tier INT UNSIGNED NOT NULL,
			item_index INT UNSIGNED NOT NULL,
			PRIMARY KEY (aid, pid, premium, tier, item_index),
			CONSTRAINT pid_frgn_claimed
				FOREIGN KEY (aid, pid) REFERENCES battlepass_players (aid, pid)
				ON DELETE CASCADE
		)
	]])
end

function BATTLEPASS.Database:SavePlayer(ply)
    if not ply.BattlePass then return end
    local conn = MySQLite
    local aid = ply:SteamID64()
    local tbl = ply.BattlePass.Owned
    local query = [[
		INSERT INTO battlepass_players (aid, pid, owned, tier, progress)
		VALUES (:aid, ':pid', :owned, :tier, :progress)
		ON DUPLICATE KEY UPDATE
			owned = :owned,
			tier = :tier,
			progress = :progress,
			tokens = :tokens,
			claimed = ':claimed',
			stage = :stage,
            reward_id = ':reward_id'
	]]

    query = BATTLEPASS:Replace(query, {
        aid = aid,
        pid = BATTLEPASS.Pass.id,
        owned = tbl.owned and 1 or 0,
        tier = tbl.tier,
        progress = tbl.progress,
        tokens = ply.bpTokens or 0,
        claimed = ply.bpClaimed and util.TableToJSON(ply.bpClaimed) or "[]",
        stage = ply.bpStage or 1,
        reward_id = BATTLEPASS.Pass.id
    })

    conn.query(query)
end

function BATTLEPASS.Database:GetPlayer(ply, id, callback)
    local conn = MySQLite
    local aid = ply:SteamID64()
    local query = [[
		SELECT owned, tier, progress, tokens, claimed, stage, reward_id FROM battlepass_players
		WHERE aid = :aid
			AND pid = ':pid'
	]]

    query = BATTLEPASS:Replace(query, {
        aid = aid,
        pid = id
    })

    conn.query(query, function(result)
        callback(result and result[1] or {
            tier = 0,
            progress = 0,
            owned = false,
            tokens = 0,
            claimed = {},
            stage = 1
        })
    end)
end

function BATTLEPASS.Database:SaveChallenge(ply, cat, challengeIndex, extraProgress, stage)
    local conn = MySQLite
    local aid = type(ply) == "string" and ply or ply:SteamID64()
    local id = BATTLEPASS.Pass.id
    local progress = 0

    if type(ply) ~= "string" then
        local tbl = ply.ActiveChallenges
        if not tbl then return end
        tbl = tbl[cat]
        if not tbl then return end
        tbl = tbl[challengeIndex]
        if not tbl then return end
        progress = math.Round(tbl.progress, 2)
    else
        progress = extraProgress
    end

    local query = [[
		INSERT INTO battlepass_challenges (aid, pid, cat_name, challenge_index, progress, stage)
		VALUES (:aid, ':pid', ':cat_name', ':challenge_index', :progress, :stage)
		ON DUPLICATE KEY UPDATE
			progress = :progress,
			stage = :stage
	]]

    query = BATTLEPASS:Replace(query, {
        aid = aid,
        pid = id,
        cat_name = cat,
        challenge_index = challengeIndex,
        progress = progress,
        stage = stage or 1
    })

    conn.query(query)
end

function BATTLEPASS.Database:GetChallenges(ply, callback)
    local conn = MySQLite
    local aid = ply:SteamID64()
    local id = BATTLEPASS.Pass.id
    local query = [[
		SELECT cat_name, challenge_index, progress, stage FROM battlepass_challenges
		WHERE aid = :aid
			AND pid = ':id'
	]]

    query = BATTLEPASS:Replace(query, {
        aid = aid,
        id = id
    })

    conn.query(query, function(result)
        callback(result)
    end)
end

function BATTLEPASS.Database:GetClaims(ply, callback)
    local conn = MySQLite
    local aid = ply:SteamID64()
    local id = BATTLEPASS.Pass.id
    local query = [[
		SELECT premium, tier, item_index FROM battlepass_claimed
		WHERE pid = ':pid'
			AND aid = :aid
	]]

    query = BATTLEPASS:Replace(query, {
        pid = id,
        aid = aid
    })

    conn.query(query, function(result)
        callback(result or {})
    end)
end

BATTLEPASS.QueuedChallengeRequests = BATTLEPASS.QueuedChallengeRequests or {}

function BATTLEPASS:ProcessChallengeQueue()
    for i, v in pairs(self.QueuedChallengeRequests) do
        local tbl = string.Explode("$_$", i)
        local aid = tbl[1]
        local cat = tbl[2]
        local index = tbl[3]
        local stage = tbl[4]
        local progress = v
        self.Database:SaveChallenge(aid, cat, index, progress, stage)
        self.QueuedChallengeRequests[i] = nil
    end
end

hook.Add("InitPostEntity", "BATTLEPASS.ProcessQueue", function()
    timer.Create("BATTLEPASS.ProcessQueue", 5, 0, function()
        BATTLEPASS:ProcessChallengeQueue()
    end)
end)

hook.Add("DarkRPDBInitialized", "BATTLEPASS", function()
    BATTLEPASS.Database:Setup()
end)