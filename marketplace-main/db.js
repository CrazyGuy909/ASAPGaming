var Config = require('./config.js');
const ps = require('ps-node');
var mysql = require('mysql');
const util = require("util");
var connection;
const { exec } = require('child_process');

function doConnect() {
  connection = mysql.createConnection({
    host: Config.db.ip,
    user: Config.db.user,
    password: Config.db.password,
    database: Config.db.default
  });
}

doConnect();

connection.connect(function (err) {
  if (err) {
    console.error('error connecting: ' + err.stack);
    return;
  }

  console.log('connected as id ' + connection.threadId);
});

connection.on("error", function (err) {
  console.log("Seems like we lost connection, let's start it again");
  ps.lookup({
    command: 'mysqld',
  }, function (err, resultList) {
    if (err) {
      throw new Error(err);
    }
    var found = false;
    resultList.forEach(function (process) {
      if (process) {
        found = true;
        doConnect();
        console.log('PID: %s, COMMAND: %s, ARGUMENTS: %s', process.pid, process.command, process.arguments);
      }
    });

    if (!found) {
      exec("/usr/sbin/mysqld --defaults-file=/etc/mysql/mysql.cnf --standalone", function (err) {
        if (err) {
          console.log(err);
          return;
        }

        doConnect();
      });
    }
  });

});

connection.pquery = util.promisify(connection.query);

module.exports = connection;