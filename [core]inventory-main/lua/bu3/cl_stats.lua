BU3.Stats = {}

net.Receive("BU3:NetworkStats", function()
	BU3.Stats = util.JSONToTable(net.ReadString())
end)