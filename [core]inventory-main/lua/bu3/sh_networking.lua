--This file is used for more easier networking of compressed binary data
if SERVER then util.AddNetworkString("_bu3_") end

BU3.Net = {} 

--List of all recievers.
BU3.Net.Receivers = {} 

--Tell BU3 we are about to send a message
BU3.Net.Start = function(msgName)
	net.Start("_bu3_")
	net.WriteString(msgName)
end

--Converts, compresses and writes a table 
BU3.Net.WriteCompressedTable = function(data)
	local data = table.util.JSONToTable(data)
	data = util.Compress(data)
	net.WriteData(data)
end

--Convert, decompressed and reads a table
BU3.Net.ReadCompressedData = function()
	local data = net.ReadData()
	data = util.Decompress(data)
	data = util.JSONToTable(data)
	return data
end

BU3.Net.Receive = function(msgName, func)
	BU3.Net.Receivers[msgName] = func
end

--The receiver
net.Receive("_bu3_", function(len, ply)
	if BU3.Net.Receivers[net.ReadString()] then
		BU3.Net.Receivers[net.ReadString()](len, ply)
	end
end)