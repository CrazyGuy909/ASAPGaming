require('log-timestamp');
const io = require("@pm2/io")
const cors = require('cors');
var express = require("express");
var historyData = require("./history");
var inventory = { giveItem: function (a, b, c) { } }
var stats = require("./stats.js")
var Config = require('./config.js')

var app = express();
app.use(express.json()); // for parsing application/json
app.use(express.urlencoded({
	extended: true
}));
app.use(cors())

var db = require("./db.js");
var reputationCache = {};

function retireItem(steamid, item, res) {
	db.query("SELECT * FROM marketplace WHERE steamid64='" + steamid + "' AND item_id =" + item, function (err, data) {
		if (data == null || data[0] == null) {
			res.send("0")
		} else {
			if (data[0].status == 1) {
				res.send("0")
				return;
			}
			res.send("1")
			db.query(
				"DELETE FROM marketplace WHERE steamid64='" +
				steamid +
				"' AND item_id=" +
				item +
				";"
			);
			db.query(
				"INSERT INTO market_reputation (steamid64, reputation) VALUES(" +
				steamid +
				", 1) ON DUPLICATE KEY UPDATE reputation = reputation - 1"
			);
		}
	})
}

function fetchItem(last, res, sort) {
	console.log(last + " " + sort)
	if (last == null && sort != null)
		last = 0;
	if (last == null) {
		console.log("QUERY")
		db.query(
			"SELECT item_id FROM marketplace ORDER BY " + (sort ? sort : "item_id DESC") + " LIMIT 1",
			function (err, data) {
				if (err){
					throw(e);
				}
				if (data && data[0]) {
					fetchItem(data[0].item_id, res, sort);
				} else {
					res.send("[]");
					console.log("Items not found")
				}
			}
		);
	} else {
		var query = "SELECT * FROM marketplace WHERE " + (sort ? 1 : "item_id <= ") +
			last +
//			" AND date +" + 3600 * 72 + " > " + Date.now() / 1000 +
			" AND status != 1 " +
			" ORDER BY " + (sort ? (sort == "expensive" ? "price ASC" : sort + " DESC ") : "item_id DESC") + " LIMIT 20" + (sort ? " OFFSET " + last + ";" : ";")
		db.query(query
			,
			function (err, data) {
				var lastID = last;
				var waitingReply = 0;
				if (data == null) {
					res.send("[]")
					return;
				};
				data.forEach(item => {
					if (item.item_id < lastID) lastID = item.item_id;
				});
				data.forEach(item => {
					if (reputationCache[item.steamid64]) {
						item.reputation = reputationCache[item.steamid64];
					} else {
						waitingReply++;
						db.query(
							"SELECT reputation FROM market_reputation WHERE steamid64='" +
							item.steamid64 +
							"';",
							function (err, rep) {
								if (rep[0]) {
									reputationCache[item.steamid64] = rep[0].reputation;
									item.reputation = reputationCache[item.steamid64];
								}
								waitingReply--;
								if (waitingReply <= 0) {
									//Send wait time
									var response = {
										lastID: sort ? last : lastID,
										items: data
									};
									res.send(JSON.stringify(response));
								}
							}
						);
					}
				});
				//We don't need to wait for reputations
				if (waitingReply == 0) {
					var response = {
						lastID: lastID,
						items: data
					};
					res.send(JSON.stringify(response));
				}
			}
		);
	}
}

function doSearch(items, last, res, sort) {
	if (last == null) {
		db.query(
			"SELECT item_id FROM marketplace ORDER BY " + (sort ? sort : "item_id DESC") + " LIMIT 1",
			function (err, data) {
				if (data[0]) doSearch(items, data[0].item_id, res, sort);
				else {
					var response = {
						lastID: 0,
						items: []
					};
					res.send(JSON.stringify(response));
				}
			}
		);
	} else {
		var searchTerm = "WHERE (item=";
		items.forEach(id => {
			searchTerm = searchTerm + id + " OR item=";
		});
		db.query(
			"SELECT * from marketplace " +
			searchTerm +
			"-1) AND item_id <= " +
			last +
			" ORDER BY " + (sort ? sort : "item_id DESC") + " LIMIT 5;",
			function (err, data) {
				var lastID = last;
				var waitingReply = 0;
				if (data == null) {
					var response = {
						items: []
					};
					res.send(JSON.stringify(response));
					return;
				}
				data.forEach(item => {
					lastID = item.item_id;
					if (reputationCache[item.steamid64]) {
						item.reputation = reputationCache[item.steamid64];
					} else {
						waitingReply++;
						db.query(
							"SELECT reputation FROM market_reputation WHERE steamid64='" +
							item.steamid64 +
							"';",
							function (err, repp) {
								waitingReply--;
								if (repp == null || repp[0] == null)
									repp = [{ reputation: 0 }]
								if (repp[0].reputation == null)
									repp[0].reputation = 0;
								item.reputation = repp[0].reputation;
								reputationCache[item.steamid64] = repp[0].reputation;
								if (waitingReply <= 0) {
									//Send wait time
									var response = {
										lastID: lastID,
										items: data
									};
									res.send(JSON.stringify(response));
									return;
								}
							}
						);
					}
				});

				if (waitingReply == 0) {
					//Send wait time
					var final = {
						lastID: lastID,
						items: data
					};
					res.send(JSON.stringify(final));
				}
			}
		);
	}
}

app.get("/count", function (req, res) {
	var itemList = {};
	db.query("SELECT * FROM bu3_inventories;", function (error, results, fields) {
		if (error) throw error;
		results.forEach(inventory => {
			JSON.parse(inventory.inventoryData, function (k, v) {
				if (typeof v != "object") {
					if (itemList[k]) {
						itemList[k] = itemList[k] + v;
					} else {
						itemList[k] = v;
					}
				}
			});
		});
		console.log("Finished seeking inventory");
		db.query("SELECT * FROM marketplace", function (err, results, fields) {
			console.log("Starting to count marketplace");
			results.forEach(it => {
				itemList[it.item] = (itemList[it.item] ? itemList[it.item] : 0) + 1;
			});
			var superQuery = "";
			for (const [item, am] of Object.entries(itemList)) {
				superQuery =
					superQuery +
					"INSERT INTO market_reg (item, mid, gap, existence, history) VALUES(" +
					item +
					", 0, 0, " +
					am +
					", '[]') ON DUPLICATE KEY UPDATE existence = " +
					am +
					";\n";
			}
			res.send("Finished counting items");
		});
	});
	//
});

const listCounter = io.counter({
	name: 'Total Listing',
})

app.post("/create", function (req, res, next) {
	var key = req.body.key;
	if (key != "gonzo_built_it") return;
	listCounter.inc();
	db.query(
		"INSERT INTO marketplace(item, steamid64, date, price, category, rarity, status) VALUES(" +
		req.body.item +
		", '" +
		req.body.steamid +
		"', " +
		Math.round(Date.now() / 1000) +
		", " +
		req.body.price +
		", '" +
		req.body.category +
		"', " +
		req.body.rarity +
		", 0);",
		function (err, data) {
			if (err) {
				res.send("0");
				throw err
			};
			res.send(data.insertId.toString());
			console.log("Item #" + req.body.item + " has been published with id #" + data.insertId);
		}
	);
});

app.post("/retire", function (req, res) {
	var key = req.body.key;
	var steamid = req.body.steamid;
	var item = req.body.item;
	if (key != "gonzo_built_it") return;
	retireItem(steamid, item, res);
})

app.get("/search", function (req, res) {
	try {
		var items = JSON.parse(req.query.term);
		if (items.length == 0) {
			res.send(JSON.stringify({ items: [] }));
			return;
		}
		doSearch(items, req.query.last, res, req.query.sort);
	} catch (error) {
		//res.send("{items=[]}")
	}
});

app.get("/fetch", function (req, res) {
	var last = req.query.last;
	console.log(db.state)
	fetchItem(last, res, req.query.sort);
});

var workingOn = {}
const salesCounter = io.counter({
	name: 'Total Sales',
})

const reqsec = io.meter({
	name: 'sales/min',
	unit: 'req/min',
	id: 'app/requests/sales'
})
app.post("/buy", function (req, res) {
	let item_id = req.body.id;
	let shouldAdd = req.body.shouldAdd == "1";
	if (req.body.key != "gonzo_built_it") return;
	if (workingOn[item_id]) return;
	workingOn[item_id] = true;
	db.query("SELECT * FROM marketplace WHERE item_id=" + item_id + ";", function (
		err,
		data
	) {
		if (data == null || data[0] == null) {
			res.send("3");
			console.log("Item id #" + item_id + " requested but doesn't exists!");
			workingOn[item_id] = null;
			return;
		}
		var item = data[0];
		var dateLimit = Math.round(parseInt(item.date + 3600 * 72))
		//dateLimit < Math.round(Date.now() / 1000)
		if (item.status == 1) {
			//db.query("DELETE FROM marketplace WHERE item_id=" + item_id + ";");
			//inventory.giveItem(item.steamid64, item.item, 1);
			console.log("Date limit " + dateLimit + " Remaining: " + (Math.round(Date.now() / 1000) - dateLimit))
			res.send("2");
			workingOn[item_id] = null;
			return;
		}
		salesCounter.inc();
		reqsec.mark();
		db.query(
			"UPDATE market_reputation SET reputation = reputation + 1 WHERE steamid64='" +
			item.steamid64 +
			"';",
			function (err) {
				db.query(
					"SELECT reputation FROM market_reputation WHERE steamid64='" +
					item.steamid64 +
					"';",
					function (err, rep) {
						workingOn[item_id] = null;
						if (rep[0] == null && !res.headerSent) {
							res.send("1");
							return;
						}
						reputationCache[item.steamid64] = rep[0].reputation;
						if (!res.headerSent)
							res.send("1");
					}
				);
			}
		);

		db.query(
			"SELECT history FROM market_reg WHERE item=" + item.item + ";",
			function (err, data) {
				historyData.updateHistory(item.item, item.price);
			}
		);
		stats.addSale(item.price);
		if (shouldAdd) {
			db.query(
				"UPDATE marketplace SET status = 1" +
				" WHERE item_id=" + item_id + " AND steamid64=" +
				item.steamid64 +
				";"
			);
		} else {
			db.query("DELETE FROM marketplace WHERE item_id=" + item_id + ";");
		}
	});
});

app.get("/prices", function (req, res) {
	if (historyData.cacheHistory[req.query.id]) {
		res.send(JSON.stringify(historyData.cacheHistory[req.query.id]));
		return
	}
	db.query(
		"SELECT * FROM market_reg WHERE item=" + req.query.id,
		function (err, query) {
			console.log("Loading settings")
			if (query == null || query[0] == null) {
				historyData.generateData(null);
				res.send("[]")
			} else {
				historyData.cacheHistory[req.query.id] = JSON.parse(query[0].history);
				historyData.cacheHistory[req.query.id].mainPrice = query[0].mid
				res.send(query[0].history);
			}
		}
	);
});

app.get("/fetchPrice", function (req, res) {
	var id = req.query.item
	db.query(
		"SELECT mid FROM market_reg WHERE item=" + id, function (err, data) {
			if (data == null || data[0] == null) {
				res.send("-1")
			} else {
				res.send(data[0].mid.toString())
			}
		})
})

app.get("/stats", function (req, res) {
	db.query("SELECT * FROM market_stats;", function (err, data) {
		var output = {
			money: data[0].value,
			sales: data[1].value,
		}
		res.send(JSON.stringify(output));
	})
})

app.listen(Config.expressPort, () => {
	console.log("Listening on :" + Config.expressPort);
});

module.exports = {
	express: app
};

inventory = require("./inventory")