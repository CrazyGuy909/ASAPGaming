SAM.SQLConfig = SAM.SQLConfig or {}

SAM.SQLConfig.usesql = true -- Do you want to use a SQL database? If not then data will be stored in the local database.
-- Ignore below if above is false

-- Note: BANS ARE UNIVERSAL, MEANING IF YOU BAN SOMEONE ON ONE SERVER AND YOU HAVE ANOTHER SERVER USING THE SAME DATABASE THEY WILL BE BANNED THERE ALSO!

SAM.SQLConfig.serveridentifier = "ASAPONE" -- If you have multiple servers, MAKE SURE this variable is unique on each and every one of them.
--                                            If the serveridentifier is the same on two servers, then data like player ranks will be shared across between them.
--                                            Note: if you change this, any data saved will be lost e.g player ranks
--                                            ONLY use alphanumeric values (1-9 and a-z) no dashes or underscores or any type of punctuation.
SAM.SQLConfig.host = "172.0.0.2"
SAM.SQLConfig.port = 3306
SAM.SQLConfig.name = "s5720_players"
SAM.SQLConfig.user = "u5720_W3dOI1dTLP"
SAM.SQLConfig.pass = "h.eeKkOWOuBBcvhebwu=25FP"
