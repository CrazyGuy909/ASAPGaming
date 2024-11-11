--[[-------------------------------------------------------------------------
Handles stats for the users, such as cases opened, trades made and items pruchases etc
---------------------------------------------------------------------------]]

local PLAYER = FindMetaTable("Player")

function PLAYER:BU3LoadStats()
	local stats = self:GetPData("bu3_stats", "")
	stats = util.JSONToTable(stats) or {}
	self:BU3UpdateClientStats()

	self.bu3stats = stats
end

function PLAYER:BU3SaveStats()
	local stats = util.TableToJSON(self.bu3stats)
	self:SetPData("bu3_stats", stats)
end

function PLAYER:BU3AddStat(name, amount)
	if not self.bu3stats then
		self.bu3stats = {}
	end
	if self.bu3stats[name] == nil then
		self.bu3stats[name] = amount
	else
		self.bu3stats[name] = self.bu3stats[name] + amount
	end

	self:BU3SaveStats()
	self:BU3UpdateClientStats()
end

--Returns a table of stats
function PLAYER:BU3GetStats()
	return self.bu3stats
end

function PLAYER:BU3UpdateClientStats()
	net.Start("BU3:NetworkStats")
	net.WriteString(util.TableToJSON(self.bu3stats) or "[]")
	net.Send(self)
end

util.AddNetworkString("BU3:NetworkStats")

