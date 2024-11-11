var db = require("./db.js");
var app = require("./methods.js");

function getItems(sid, callback){
    db.query("SELECT inventoryData FROM bu3_inventories WHERE steamid='" + sid + "';", function(err, data){
        if (data == null || data[0] == null){
            callback({});
        }else{
            var json = data[0].inventoryData
            var text = json.startsWith('""') ? json.substring(3, json.length - 3) : json
            callback(JSON.parse(text));

        }
    })
}

function giveItem(sid, item, amount, res){
    getItems(sid, function(data){
        if (data[item])
            data[item] = data[item] + amount
        else
            data[item] = amount

        db.query("UPDATE bu3_inventories SET inventoryData = '" + JSON.stringify(data) + "' WHERE steamid='" + sid + "';")
        if (res != null){
            res.send("1")
        }
    })
}

app.express.post("/additem", function(req, res){
    var sid = req.body.sid;
    var item = req.body.item;
    var amount = req.body.amount || 1;
    var key = req.body.key;
    
    if (key !== "gonzo_built_it"){
        res.status(403).send("Invalid key");
        return;
    }
    
    giveItem(sid, item, amount, res);
});

app.express.get("/inventory", function(req, res){
    var sid = req.query.sid
    if (sid == null){
        res.send("[]")
    }else{
        getItems(sid, function(data){
            var inventory = JSON.stringify(data);
            inventory.replace('\\"', "");
            res.send(inventory);
        })
    }
})

app.express.get("/arena", function(req, res){
    var sid = req.query.sid
    if (sid == null){
        res.send("[]")
    }else{
        db.query("SELECT * FROM arena_players WHERE steamid=" + db.escape(sid) + ";", function(err, data){
            if (data == null || data[0] == null){
                res.send("[]");
            }else{
                res.json(data[0]);
            }
        })
    }
})

app.express.get("/ping", function(req, res){
    res.send("1");
})

module.exports = {
    giveItem : giveItem,
    getItems : getItems
}