var db = require("./db.js");
var app = require("./methods.js");
var fs = require("fs")

function fetchTable(data, table, sid, name, id, next, array) {
    db.query("SELECT * FROM " + table + " WHERE " + sid + "='" + id + "';", function (err, qr) {
         if (err) {
			// Handle the error, such as logging it or returning an error response
			console.error("Database query error:", err);
			// Call the 'next' callback to continue with the next step
			next(err);
			return;
		}
		if (array) {
            data[name] = [];
            qr.forEach((el) => {
                data[name].push(el)
            })
        } else {
            if (qr[0]) {
                data[name] = qr[0];
            } else {
                data[name] = null;
            }
        }
        next();
    })
}

function downloadUserData(id, res) {
    var totalData = {};
    fetchTable(totalData, "darkrp_player", "uid", "darkrp", id, () => {
        fetchTable(totalData, "arena_players", "steamid", "arena", id, () => {
            fetchTable(totalData, "asap_gobblegums", "steamid", "gobblegums", id, () => {
                fetchTable(totalData, "bu3_inventories", "steamid", "unbox", id, () => {
					res.json(totalData).status(200);
					})
				}, true)
			})
		})
}

let itemsData;
let itemNames = [];
let itemSlot = [];
const color = [
    "#A9A9A9",
    "#00BFFF",
    "#800080",
    "#FF00FF",
    "#FF0000",
    "#FFD700",
];

function redownloadItems(res){
    console.log("Cooking up items;")
    itemsData = {};

    db.query("SELECT * FROM bu3_items;", function(err, result){
        if (err){
            throw err;
        }
        result.forEach(element => {
            var data = JSON.parse(element.itemData);
            var builder = {
                name : data.name,
                iconID : data.iconID,
                color : data.color,
                type : data.type,
                rarity : data.itemColorCode,
                itemID : element.itemID,
				canBeSold: data.canBeSold,
				canBeBought: data.canBeBought,
				className: data.className,
				ranks: data.ranks,
				desc: data.desc,
				iconIsModel: data.iconIsModel,
				zoom: data.zoom,
				rankRestricted: data.rankRestricted,
				price: data.price,
				gift: data.gift,
				lua: data.lua,
				isNew: data.isNew,
				items: data.items,
				perm: data.perm,
				gift: data.gift,
				itemColorCode: data.itemColorCode,
				isFeatured: data.isFeatured
            };
            itemSlot.push(element.itemID);
            itemNames.push(data.name.toLowerCase());
            itemsData[element.itemID] = builder;
        });
        if (res) {
            res.json(itemsData);
        }
    })
}

app.express.post("/updateitems", function(req, res){
    if (req.body.key == "gonzo_made_it") {
        redownloadItems(res);
    }
});

app.express.get("/items", function (req, res) {
    const id = req.query.id;
    if (!itemsData) {
        redownloadItems(res);
        return;
    }
    res.json(itemsData);
})

app.express.get("/user", function (req, res) {
    const id = req.query.id;
    //res.send("[]");
    downloadUserData(id, res);
})

var rankList;
var lastUpdate = 0;
app.express.get("/easter", function (req, res) {
    /*
    if (rankList != null && lastUpdate < Date.now() / 1000){
        res.json(rankList).status(200);
        return
    }
    lastUpdate = Date.now() / 1000 + 3 * 60;
    */
    db.query("SELECT * FROM asap_easter ORDER BY eggs DESC LIMIT 50", (err, data) => {
        rankList = data
        if (data == null){
            data = [];
        }
        rankList = data;
        res.json(data).status(200);
    })
})

var equipments = {};

app.express.post("/eq/push", function (req, res) {
    const id = req.body.id;
    const cls = req.body.cls;
    const armor = req.body.armor;
    const key = req.body.key;

    /*
    if (key != "gonzo_made_it") {
        res.send("0");
        return;
    };
    if (!equipments[id]) {
        equipments[id] = {
            weapons : []
        }
    }
    if (cls && equipments[id].weapons.indexOf(cls) == -1) {
        equipments[id].weapons.push(cls);
    }
    if (armor) {
        equipments[id].armor = armor;
    }
    */
    res.send("1").status(200);
})

app.express.post("/eq/take", function (req, res) {
    /*
    const id = req.body.id;
    const cls = req.body.take;
    if (!equipments[id]) {
        res.send("0").status(400);
        return;
    }
    if (cls == "1") {
        equipments[id].armor = null;
        delete (equipments[id].armor);
    } else {
        equipments[id].weapons.splice(equipments[id].weapons.indexOf(cls), 1);
    }

    if (equipments[id].weapons.length == 0 && !equipments[id].armor){
        equipments[id] = undefined;
    }
    */
    res.send("1").status(200);
})

app.express.post("/eq/clear", function (req, res) {
    const id = req.body.id;
    const key = req.body.key;

    if (key != "gonzo_made_it") {
        res.send("0").status(500);
        return;
    };
    if (id) {
        delete (equipments[id])
    } else {

        equipments = {};
    }
    res.send("1").status(200);
})

app.express.get("/eq/get", function (req, res) {
    const id = req.query.id;
    res.send("0").status(404);
    /*
    if (equipments[id]) {
        res.json(equipments[id]).status(200);
    }else{
        res.send("0").status(404);
    }
    */
})

app.express.get("/eq/debug", function (req, res) {
    res.json(equipments).status(200);
})

app.express.get("/eq/save", function (req, res) {
    if (!fs.existsSync("./save")){
        fs.mkdirSync("./save")
    }
    fs.writeFileSync("./save/dump.json", JSON.stringify(equipments));
    res.send("Saved persistence file").status(200);
})

app.express.get("/eq/load", function (req, res) {
    if (!fs.existsSync("./save/dump.json")){
        res.send("The save file doesn't exists...").status(400);
        return;
    }
    equipments = JSON.parse(fs.readFileSync("./save/dump.json"));
    res.send("Persistence file has been loaded").status(200);
})

let customJobs;
function cookCustomJobs(res, skip) {
    console.log("[CJ] Cooking jobs");
    db.query("SELECT * FROM customjobs", (err, data) => {
        customJobs = data || {};
        if (res) {
            res.json(skip ? "1" : data).status(200);
        }
    })
}

app.express.get("/customjobs", async (req, res) => {
    if (customJobs == null) {
        cookCustomJobs(res);
        return
    }

    res.json(customJobs).status(200);
})

app.express.post("/customjobsreload", async (req, res) =>{
    if (key != "gonzo_made_it") {
        res.send("0").status(500);
        return;
    };

    cookCustomJobs(res, true);
})