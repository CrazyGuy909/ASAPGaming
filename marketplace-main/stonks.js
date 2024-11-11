var db = require("./db.js");
var app = require("./methods.js");

var firstCheck = false;

function stonksFetch(filter, res) {
  var searchTerm = "WHERE (item=";
  filter.forEach((id) => {
    searchTerm = searchTerm + id + " OR item=";
  });
  if (filter.length == 0){
    searchTerm = ""
  }else{
    searchTerm = searchTerm + "-1)"
  }
  db.query("SELECT * FROM market_stonks " + searchTerm, function (err, data) {
    if (data && data[0]) {
      res.send(JSON.stringify(data));
    } else {
      res.send("[]");
    }
  });
}

app.express.post("/stonks/remove", function (req, res) {
  let key = req.body.key == "gonzo_built_it";
  if (key) {
    db.query(
      "DELETE FROM market_stonks WHERE item =" + req.body.id + ";",
      function () {
        res.send("1");
      }
    );
  }
});

app.express.post("/stonks/add", function (req, res) {
  let key = req.body.key == "gonzo_built_it";
  if (key) {
    let item_id = req.body.id;
    let item_price = req.body.price;
    let item_amount = req.body.amount || 0;
    db.query(
      "INSERT INTO market_stonks (item, price, amount) VALUES(" +
        item_id +
        ", " +
        item_price +
        ", " +
        item_amount +
        " ) ON DUPLICATE KEY UPDATE price=" +
        item_price +
        ", amount=" +
        item_amount +
        ";",
      function () {
        res.send("1");
      }
    );
  }
});

app.express.post("/stonks/buy", function (req, res) {
  let key = req.body.key == "gonzo_built_it";
  if (key) {
    let item = req.body.id;
    db.query("SELECT * FROM market_stonks WHERE item=" + item, function (
      err,
      data
    ) {
      if (data && data[0] && data[0].amount > 0) {
        db.query("UPDATE market_stonks SET amount = amount - 1 WHERE item=" + item, function () {
          data[0].amount = data[0].amount - 1;
          res.json(data[0]);
        });
      } else {
        res.send("0");
      }
    });
  }
});

app.express.post("/stonks/sell", function (req, res) {
  let key = req.body.key == "gonzo_built_it";
  if (key) {
    let item = req.body.id;
    db.query("SELECT * FROM market_stonks WHERE item=" + item, function (
      err,
      data
    ) {
      if (data && data[0]) {
        db.query("UPDATE market_stonks SET amount = amount + 1 WHERE item=" + item, function () {
          data[0].amount = data[0].amount + 1;
          res.json(data[0]);
        });
      } else {
        res.send("0");
      }
    });
  }
});

app.express.get("/stonks/get", function (req, res) {
  var filter = JSON.parse(req.query.filter || "[]") || [];
  if (!firstCheck) {
    firstCheck = true;
    db.query(
      "CREATE TABLE `asap_players`.`market_stonks` (" +
        "`item` INT NOT NULL," +
        "`price` INT NULL DEFAULT 0," +
        "`amount` INT NULL DEFAULT 0," +
        "PRIMARY KEY (`item`)," +
        "UNIQUE INDEX `item_UNIQUE` (`item` ASC))",
      function () {
        stonksFetch(filter, res);
      }
    );
  } else {
    stonksFetch(filter, res);
  }
});
