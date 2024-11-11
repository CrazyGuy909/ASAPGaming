var db = require("./db.js");
var app = require("./methods.js");
const { stringify } = require("querystring");
var tradeHistory = {};
db.query(
  "CREATE TABLE IF NOT EXISTS `s5618_asap_players`.`market_trade` (" +
    "`id` INT NOT NULL," +
    "`player_a` varchar(32) ," +
    "`player_b` varchar(32) ," +
    "`date` INT(32) NOT NULL ," +
    "`tradeinfo` TEXT NOT NULL ," +
    "PRIMARY KEY (`id`)," +
    "UNIQUE INDEX `id_UNIQUE` (`id` ASC))"
);

function loadPlayerHistory(sid, callback=null) {
  db.query(
    "SELECT * FROM market_trade WHERE player_a = " +
      sid +
      " OR player_b = " +
      sid,
    function (err, data) {
      tradeHistory[sid] = {};
      for (let index = 0; index < data.length; index++) {
        const element = data[index];
        var str = element.tradeinfo
        str = str.replace(/\\/g, "");
        str = str.replace(/""/g, '"');
        let js = {};
        try{
          js = JSON.parse(str);
        }catch(e){
          //console.log(e)
          //console.log(str)
        }
        tradeHistory[sid][element.id] = {
          player_a: element.player_a,
          player_b: element.player_b,
          date: element.date,
          tradeinfo: js,
        };
      }
      if (callback) {
        callback(tradeHistory[sid]);
      }
    }
  );
}

function setupPlayerHistory(sid, id=null, history=null) {
  if (tradeHistory[sid]) tradeHistory[sid][id] = history;
  else {
    loadPlayerHistory(sid);
  }
}

function prepareListing(res, sid, id=null){
  if (id && tradeHistory[sid][id]){
      res.json(tradeHistory[sid][id]);
  }else if (!id){
    if (tradeHistory[sid]){
      var finalSend = {};
      for (let key of Object.keys(tradeHistory[sid])){
        const element = tradeHistory[sid][key]
        finalSend[key] = {
          player_a : element.player_a,
          player_b : element.player_b,
          date : element.date
        }
      }
      res.json(finalSend);
    }else{
      loadPlayerHistory(sid, function(data){
        //res.json(data);
        prepareListing(res, sid)
      })
    }
  }
}

app.express.post("/trade/upload", function (req, res) {
  //console.log(req.body)
  var key = req.body.key;
  if (key != "gonzo_built_it") {
    res.send("500");
    return;
  }
  var playera = req.body.a;
  var playerb = req.body.b;
  var id = req.body.id;
  var date = req.body.date;
  var tradeinfo = req.body.tradeinfo;
  var insert = "INSERT INTO market_trade (id, player_a, player_b, date, tradeinfo) VALUES(" +
  id +
  ", " +
  playera +
  ", " +
  playerb +
  ", " +
  date +
  ", '" +
  tradeinfo +
  "');"
  db.query(insert,
    function () {
      console.log("Trade #" + id + " has been logged")
      res.sendStatus(200);
    }
  );

  var history = {
    player_a: playera,
    player_b: playerb,
    date : date,
    tradeinfo: JSON.parse(tradeinfo),
  };

  setupPlayerHistory(playera, id, history);
  setupPlayerHistory(playerb, id, history);
});

app.express.get("/trade/get", function (req, res) {
  const sid = req.query.steamid;
  const id = req.query.id;
  if (!sid) {
    res.sendStatus(500);
    return;
  }

  if (tradeHistory[sid]) {
    prepareListing(res, sid, id);
  } else {
    loadPlayerHistory(sid, function (data) {
      prepareListing(res, sid, id);
    });
  }
});
