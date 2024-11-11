const { init } = require("@pm2/io");
var db = require("./db.js");
var app = require("./methods.js");

var duelMemory = {
    Players: {},
    Duels: {},
    Tops: {}
};

var topUpdater;
var updateCache = {};

function initDB() {

    db.query("CREATE TABLE IF NOT EXISTS `s5618_asap_players`.`duel_logs` (" +
        "`duel_id` INT NOT NULL AUTO_INCREMENT," +
        "`won` VARCHAR(22) NULL," +
        "`timestamp` BIGINT NULL," +
        "`player_a` VARCHAR(22) NULL," +
        "`player_b` VARCHAR(22) NULL," +
        "`info` TEXT NULL," +
        "PRIMARY KEY (`duel_id`))");

    db.query("CREATE TABLE IF NOT EXISTS 's5618_asap_players`.`duel_players` (" +
        "`player` VARCHAR(22)," +
        "`wins` INT DEFAULT 0," +
        "`lose` INT DEFAULT 0," +
        "`bounty` LONGTEXT NULL," +
        "`mmr` INT DEFAULT 0," +
        "`enemies` INT DEFAULT 0," +
        "PRIMARY KEY (`player`))");

    db.query("SELECT COUNT(*) AS gamesAlive FROM duel_logs;", function (err, res) {
        if (err) {
            throw (err);
        }
        console.log("[DUELS] " + res.gamesAlive + " games registered");
        console.log("[DUELS] Cleaning old matchups");
        db.query("DELETE FROM duel_logs WHERE timestamp <" + (Date.now() + 3600 * 24 * 14 * 1000), function (err, res) {
            if (err) {
                throw (err);
            }
            console.log("[DUELS] " + res.affectedRows + " game(s) removed");
            updateTopList();
            initLooper();
        });
    })
}

function updateTopList() {
    duelMemory.Tops = {};
    db.query("SELECT mmr FROM duel_players ORDER BY mmr LIMIT 25;", function (err, res) {
        if (err) {
            throw (err);
        }
        var i = 1;
        for (const key in res) {
            if (Object.hasOwnProperty.call(res, key)) {
                duelMemory.Tops[i] = res[key].mmr;
                i++;
            }
        }
        // Call any function that needs the updated duelMemory.Tops here
    });
}


function updatePlayerData(body, data, res) {
    if (body.winner == 1 && body.a == data.player) {
        data.wins++;
    } else {
        data.lose++;
    }
    data.mmr += body.mmr[data.player == body.a ? 0 : 1];
    if (topUpdater != null) {
        clearTimeout(topUpdater);
    }

    if (!data.bounty)
        data.bounty = "[]";

    if (typeof (data.bounty) == "string")
        data.bounty = JSON.parse(data.bounty);

    for (const key in body.bounty) {
        if (Object.hasOwnProperty.call(body.bounty, key)) {
            const bounty = body.bounty[key];
            data.bounty[key] = (data.bounty[key] || 0) + bounty;
        }
    }
    topUpdater = setTimeout(function () {
        updateTopList();
    }, 1000 * 60)

    updateCache[data.player] = true;
}

function fetchPlayerData(sid, ser, cb) {
    db.query("SELECT * FROM duel_players WHERE player = " + db.escape(sid) + ";", function (err, res) {
        if (err) {
            ser.status(200);
            throw (err);
        }
        if (res.length == 0) {
            db.query("INSERT INTO duel_players (player) VALUES(" + db.escape(sid) + ")", function (err) {
                if (err) {
                    ser.status(200);
                    throw (err);
                }
                const data = {
                    Player: sid,
                    wins: 0,
                    lose: 0,
                    mmr: 0,
                }
                duelMemory.Players[data.player] = data
                if (cb) {
                    cb(duelMemory.Players[data.player]);
                } else
                    ser.json(data).status(200);
            })
            return;
        }
        res.forEach(info => {
            if (info) {
                duelMemory.Players[info.player] = info;
                if (cb) {
                    cb(duelMemory.Players[info.player]);
                } else
                    ser.json(duelMemory.Players[info.player]).status(200);
            }
        });
    });
}

function initLooper() {
    
    if (Object.keys(updateCache).length > 0) {
        var initialString = "UPDATE duel_players s " +
            "JOIN (" +
            "SELECT '-1' as player, 0 as wins_val, 0 as lose_val, 0 as mmr_score UNION ALL "
        for (const key in updateCache) {
            if (Object.hasOwnProperty.call(updateCache, key)) {
                const info = duelMemory.Players[key];
                initialString = initialString + "SELECT '" + key + "', " + (info.wins || 0) + ", " + (info.lose || 0) + ", " + (info.mmr || 0) + " UNION ALL "
            }
        }
        initialString = initialString.substr(0, initialString.length - 11);
        initialString = initialString + ") vals ON s.player = vals.player SET wins = wins_val, lose= lose_val, mmr = mmr_score;"
        updateCache = {};
        db.query(initialString, function (err, res) {
            if (err) {
                throw (err);
            }
            console.log(res.affectedRows + " has been saved.");
        });
    }
    setTimeout(function () {
        initLooper();
    }, 1000 * 1)
}

app.express.get("/duels/top", function (req, res) {
    res.json(duelMemory.Tops).status(200);
});

app.express.get("/duels/download", function (req, res) {
    var sid = req.query.sid;
    if (!sid) {
        res.send("Missing player sid").status(400);
        return;
    }
    if (duelMemory.Players[sid]) {
        res.json(duelMemory.Players[sid]).status(200);
        return;
    } else {
        fetchPlayerData(sid, res);
    }
})

app.express.post("/duels/finish", function (req, res) {
    const key = req.body.key;
    if (key != "gonzo_made_it") return;
    const a = req.body.a;
    const b = req.body.b;

    var str = req.body.bounty;
    str = str.replace(/\\/g, "");
    str = str.replace(/""/g, '"');
    req.body.bounty = JSON.parse(str);
    req.body.mmr = [parseInt(req.body.mmr[0]), parseInt(req.body.mmr[1])];

    if (a) {
        fetchPlayerData(a, res, (data) => {
            updatePlayerData(req.body, data, res)
        });
    }
    if (b) {
        fetchPlayerData(b, res, (data) => {
            updatePlayerData(req.body, data, res)
        });
    }
});


initDB()