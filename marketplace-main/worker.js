var db = require("./db.js")
var wk = {}
wk.fetch = function (page, callback) {
    var mem = this.Mem
    db.query("SELECT * FROM logs_data LIMIT " + (page * 50) + ", " + ((page + 1) * 50) + ";", function (err, res) {
        res.forEach(item => {
            if (!mem.pageMem[page]) {
                mem.pageMem[page] = [item]
            } else {
                wk.addlog(item)
            }
        })
        callback();
    })
}

wk.addlog = function (item) {
    var mem = this.Mem
    var loopPage = 0
    if (!mem.pageMem[loopPage]) {
        mem.pageMem[loopPage] = []
    }
    mem.pageMem[loopPage].unshift(item);
    while (mem.pageMem[loopPage].length > 20) {
        if (!mem.pageMem[loopPage + 1]) {
            mem.pageMem[loopPage + 1] = []
        }
        mem.pageMem[loopPage + 1].unshift(mem.pageMem[loopPage][mem.pageMem[loopPage].length - 1]);
        mem.pageMem[loopPage].pop();
        loopPage++;
        if (!mem.pageMem[loopPage]) {
            mem.pageMem[loopPage] = []
        }
    }
}

wk.addFilter = function (item, cat, page = null) {
    if (!this.Mem.filters[cat]) {
        this.Mem.filters[cat] = [];
    }
    var mem = this.Mem.filters[cat];
    var loopPage = page || 0;
    if (!mem[loopPage]) {
        mem[loopPage] = [];
    }
    mem[loopPage].unshift(item);
    while (mem[loopPage].length > 50) {
        if (!mem[loopPage + 1]) {
            mem[loopPage + 1] = [];
        }
        mem[loopPage + 1].unshift({ ...mem[loopPage][mem[loopPage].length - 1] });
        mem[loopPage].pop();
        loopPage++;
        if (!mem[loopPage]) {
            mem[loopPage] = []
        }
    }
}

wk.insert = function (params, response) {
    db.query("INSERT INTO logs_data (category, timestamp, player_a, player_b, a, b) VALUES ('" + params.category +
        "', " + Math.round(new Date().getTime() / 1000) +
        ", " + params.player_a +
        ", " + (params.player_b || "0") +
        ", '" + (params.a || "") +
        "', '" + (params.b || "") + "');", function (err, res) {
            if (err) {
                console.log(err)
                return
            }
            var log = {
                category: params.category,
                timestamp: Math.round(new Date().getTime() / 1000),
                player_a: params.player_a,
                player_a: params.player_b,
                a: params.a || "",
                b: params.b || "",
                id: res.insertId
            }
            wk.addlog(log);
            wk.addFilter(log, params.category, 0);
            response.send("1")
        })

}

wk.doFilter = function (arg, page, cb) {
    if (this.Mem.filters[arg] && this.Mem.filters[arg][page]){
        cb(this.Mem.filters[arg][page]);
        return
    }
    db.query("SELECT * FROM logs_data WHERE category='" + arg + "' LIMIT " + (page * 50) + ", " + ((page + 1) * 50) + ";", function (err, res) {
        if (err) {
            return;
        }
        res.forEach(el => {
            wk.addFilter(el, arg, page)
        })
        cb(res)
    });
}

wk.findPlayer = function (query, res) {
    const sid = query.sid
    const page = query.page || 0

    db.query("SELECT * FROM logs_data WHERE player_a='" + sid + "' or player_b = '" + sid + "' LIMIT  " + (page * 50) + ", " + ((page + 1) * 50) + ";", function (err, data) {
        res.json(data)
    })
}

module.exports = wk