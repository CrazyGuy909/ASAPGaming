var forever = require('forever-monitor');
const nodemailer = require("nodemailer");
const safetyChecks = {
    windows: /(?:"(.*[^\/])"|(\w+))(?:\s(.*))?/,
    linux: /(.*?[^\\])(?: (.*)|$)/,
  };

  
var child = new (forever.Monitor)("init.js", {
    max: 25,
    args: [],
    silent : true,
    logFile: 'info.log', // Path to log output from forever process (when daemonized)
    outFile: 'out.log', // Path to log output from child stdout
    errFile: 'err.log',
    parser : function(command, args) {
        const match = command.match(
          process.platform === 'win32' ? safetyChecks.windows : safetyChecks.linux
        );
      
        //
        // No match means it's a bad command. This is configurable
        // by passing a custom `parser` function into the `Monitor`
        // constructor function.
        //
        if (!match) {
          return false;
        }
      
        if (process.platform == 'win32') {
          command = match[1] || match[2];
          if (match[3]) {
            args = match[3].split(' ').concat(args);
          }
         command = '"' + command + '"';
        } else {
          command = match[1];
          if (match[2]) {
            args = match[2].split(' ').concat(this.args);
          }
        }
      
        return {
          command: command,
          args: args,
        };
      }
});

child.on('watch:restart', function(info) {
  console.error('Restarting script because ' + info.file + ' changed');
});


child.on('restart', function() {
  console.error('Something went wrong! Restarting for ' + child.times + ' time');
});

child.on('exit', function () {
    let transporter = nodemailer.createTransport({
        host: "smtp.ipage.com",
        port: 465,
        secure: true, // true for 465, false for other ports
        auth: {
            user: "marketplace@rgbmill.net", // generated ethereal user
            pass: "8UJjINHN9K3HA7pc" // generated ethereal password
        }
    });

    // send mail with defined transport object
    transporter.sendMail({
        from: 'Marketplace! <marketplace@rgbmill.net>', // sender address
        to: "gregoranderson08@gmail.com", // list of receivers
        subject: "Marketplace Server is Down", // Subject line
        text: "", // plain text body
        html: "<h2>Logs:</h2>", // html body
        attachments: [
            {
                path: 'err.log',
            },{
                path: 'out.log',
            }
        ]
    });
});

child.start();