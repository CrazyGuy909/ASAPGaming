var db = require("./db.js");

db.query(`CREATE TABLE IF NOT EXISTS market_stats (
    field varchar(32) NOT NULL,
    value varchar(128) NOT NULL,
    UNIQUE KEY field (field)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;`)

function addSale(price){
    db.query("INSERT INTO market_stats (field, value) VALUES('money', " + price + ") ON DUPLICATE KEY UPDATE " +
    "value = value + " + price + ";")
    db.query("INSERT INTO market_stats (field, value) VALUES('sales', 1) ON DUPLICATE KEY UPDATE " +
    "value = value + 1;")
}

module.exports = {
    addSale : addSale
}