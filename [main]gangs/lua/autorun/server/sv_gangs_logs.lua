util.AddNetworkString("Gangs.LogViewer")
util.AddNetworkString("Gangs.DeleteLog")
util.AddNetworkString("Gangs.RemoveLogs")

net.Receive("Gangs.LogViewer", function(l, ply)
    if (ply:GangsHasPermission("VIEW_ACTIVITY") and (ply.nextLog or 0) < CurTime()) then
        ply.nextLog = CurTime() + 15
        asapgangs.SendLogs(ply)
    end
end)

net.Receive("Gangs.RemoveLogs", function(l, ply)
    if (ply:GangsHasPermission("VIEW_ACTIVITY") and (ply.nextLog or 0) < CurTime()) then
        ASAPDriver:MySQLQuery("DELETE FROM `gangs_log` WHERE `tag`='" .. ply:GetGang() .. "';")
    end
end)

net.Receive("Gangs.DeleteLog", function(l, ply)
    if (ply:GangsHasPermission("VIEW_ACTIVITY")) then
        local id = net.ReadInt(16)
        ASAPDriver:MySQLQuery("DELETE FROM gangs_log WHERE id='" .. id .. "' AND tag = '" .. ply:GetGang() .. "'")
    end
end)

function asapgangs.SendLogs(ply)
    local q = ASAPDriver:MySQLQuery("SELECT * FROM gangs_log WHERE tag ='" .. ply:GetGang() .. "'", function(data)
        net.Start("Gangs.LogViewer")
        net.WriteTable(data)
        net.Send(ply)
    end)
end

function asapgangs.AddLog(ply, kind, action)
    if (isstring(ply)) then
        ply = player.GetBySteamID64(ply)
        if (not IsValid(ply)) then return end
    end
   -- asapgangs.query("INSERT INTO gangs_log (`tag`, `steamid`, `info`, `kind`) VALUES ('" .. ply:GetGang() .. "', '" .. ply:SteamID64() .. "', '" .. SQLStr(action, true) .. "', '" .. SQLStr(kind, true) .. "');")
end