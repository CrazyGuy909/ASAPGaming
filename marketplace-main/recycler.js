var Mem = require('./mem.js')
var db = require("./db.js")
var app = require("./methods.js")

const categories = {
    ["Disconnects"]: 3600 * 72,
    ["Connections"]: 3600 * 72,
    ["Prop Spawn"]: 3600 * 24,
    ["Tool Use"]: 3600 * 72,
    ["Kills"]: 3600 * 24 * 14,
    ["Printer Withdraw"]: 3600 * 24 * 5,
    ["Printer Stole"]: 3600 * 24 * 7,
    ["Warranted"]: 3600 * 24 * 5,
    ["UnWarranted"]: 3600 * 24 * 5,
    ["Demotes"]: 3600 * 24 * 5,
    ["Name Changes"]: 3600 * 24 * 5,
    ["Doors Bought"]: 3600 * 24 * 3,
    ["Doors Sold"]: 3600 * 24 * 3,
    ["Wanted"]: 3600 * 24 * 5,
    ["UnWanted"]: 3600 * 24 * 5,
    ["Bought Entity"]: 3600 * 24 * 3,
    ["Law added"]: 3600 * 24 * 5,
    ["Law removed"]: 3600 * 24 * 5,
    ["Advert"]: 3600 * 24 * 14,
    ["Chat"]: 3600 * 24 * 30,
    ["Damage"]: 3600 * 24 * 7,
    ["Buy Gobblegum"]: 3600 * 24 * 5,
    ["Buy Ability"]: 3600 * 24 * 5,
    ["Used Gobblegum"]: 3600 * 24 * 5,
    ["Arena Join"]: 3600 * 24 * 5,
    ["Arena Leave"]: 3600 * 24 * 5,
    ["Arena Wins"]: 3600 * 24 * 14,
    ["Job Changes"]: 3600 * 24 * 7,
    ["Lockpick"]: 3600 * 24 * 14,
}

function processCategory(id, time) {
    const limit = (Date.now() / 1000) - time
    if (Mem.filters[id]) {
        const pages = Mem.filters[id].length;
        var finalArray = [];
        var hasEnded = false;
        var cleaned = 0;
        for (let page = 0; page < Mem.filters[id].length; page++) {
            const collection = Mem.filters[id][page];
            cleaned += collection.length;
            collection.forEach(log => {
                if (log.timestamp > limit) {
                    hasEnded = true;
                } else {
                    finalArray.push(log);
                    cleaned--;
                }
            });
            if (hasEnded) {
                break;
            }
        }
        Mem.filters[id] = {};
        var slot = 0;
        var pageIndex = 0;
        for (let index = 0; index < finalArray.length; index++) {
            const element = finalArray[index];
            if (slot > 20){
                pageIndex++;
                slot = 0;
                if (!Mem.filters[id][pageIndex]){
                    Mem.filters[id][pageIndex] = [];
                }
            }
            Mem.filters[id][pageIndex].push(element);
            slot++;
        }
        if (cleaned > 0)
            console.log("Cleaned up " + cleaned + " entries for category " + id)
        return;
    }
    db.query("DELETE FROM logs_data WHERE category='" + id + "' AND timestamp < " + limit + ";", function (err, res, field) {
        if (err) {
            console.error(err);
            return;
        }
        if (res.affectedRows > 0)
            console.log("Cleaned " + res.affectedRows + " entries for " + id);
    });
}

var timeOut;
function cleanStart(){
    console.log("Starting coroutine...")
    for (const category in categories) {
        if (categories.hasOwnProperty(category)) {
            const element = categories[category];
            processCategory(category, element)
        }
    }
    timeOut = setTimeout(() => {
        console.log("Starting a new clean")
        cleanStart();
    }, 1000 * 3600 * 24);
}
app.express.get("/maintance", function (req, res) {
    if (req.query.key != "gonzo_made_it") {
        res.send("ERROR:");
        return
    };
    clearTimeout(timeOut);
    cleanStart();
    res.send("FINISHED CLEANUP");
})

cleanStart();
console.log("Initialized recycler...")