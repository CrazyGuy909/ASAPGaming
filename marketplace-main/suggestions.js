const app = require("./methods.js");
const db = require("./db.js")

let cachedData = {};
let emptyData = true;

function loadCache(cb){
    cachedData = {};
    db.query("SELECT * FROM feedback ORDER BY id DESC;", function (err, values, field) {
        if (!err) {
            for (const key in values) {
                if (Object.hasOwnProperty.call(values, key)) {
                    cachedData[values[key].id] = values[key];
                }
            }
        }else {
            cachedData = {};
        }

        emptyData = false;

        if (cb) {
            cb();
        }
    })
}

app.express.get("/suggestions/fetch", function(req, res){
    if (emptyData) {
        loadCache(() => {
            res.json(cachedData).status(200);
        })
    } else {
        res.json(cachedData).status(200);
    }
})

app.express.get("/suggestions/read", function(req, res){
    const id = req.query.id;
    if (id == null) {
        res.status(400).send("[]");
        return;
    }

    var response = {
        comments : [],
        score : 0,
        title : "Missing",
        description : "Missing",
    }

    if (!cachedData[id]) {
        res.status(400).json(response);
        return
    }

    response.title = cachedData[id].title;
    response.description = cachedData[id].description;

})

app.express.post("/suggestions/refresh", function(req, res) {
    loadCache()
})

loadCache()

