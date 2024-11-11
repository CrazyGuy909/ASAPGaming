util.AddNetworkString("ASAP.Arena:SendStats")
local maxPlayersThreshold = CreateConVar("arena_bulletlogger", 1, FCVAR_ARCHIVE)

hook.Add("PlayerInitialSpawn", "Arena.LoadLogs", function(ply)
    if (ply:IsBot()) then return end
    local data = util.JSONToTable(file.Read("bulletinfo/" .. ply:SteamID64() .. ".txt") or "[]")
    if (table.Count(data) >= 0) then
        ply.BulletInfo = data
    end
end)

hook.Add("PostEntityTakeDamage", "Arena.LogHits", function(ply, dmg, took)
    if (not ply:IsPlayer()) then return end
    if (not maxPlayersThreshold:GetBool()) then return end
    if (ply:IsPlayer() and not ply:InArena()) then return end
    local attacker = dmg:GetAttacker()
    if (not attacker:IsPlayer()) then return end
    local lastHitGroup = ply:LastHitGroup()
    if not IsValid(attacker) or not IsValid(attacker:GetActiveWeapon()) then return end
    local wepClass = attacker:GetActiveWeapon():GetClass()
    if (not attacker.BulletInfo) then
        attacker.BulletInfo = {}
    end
    if (not attacker.BulletInfo[wepClass]) then
        attacker.BulletInfo[wepClass] = {Hits = 0, HitGroups = {}}
    end
    attacker.BulletInfo[wepClass].Hits = attacker.BulletInfo[wepClass].Hits + 1
    attacker.BulletInfo[wepClass].HitGroups[lastHitGroup] = (attacker.BulletInfo[wepClass].HitGroups[lastHitGroup] or 0) + 1
    timer.Remove(attacker:EntIndex() .. "_bulletSave")
    timer.Create(attacker:EntIndex() .. "_bulletSave", 10, 1, function()
        file.Write("bulletinfo/" .. attacker:SteamID64() .. ".txt", util.TableToJSON(attacker.BulletInfo, true))
    end)
end)

hook.Add("EntityFireBullets", "Arena.LogMiss", function(ent, data)
    if (not maxPlayersThreshold:GetBool()) then return end
    if (not ent:IsPlayer()) then return end
    if (not ent:InArena()) then return end
    local wep = ent:GetActiveWeapon():GetClass()
    if (not ent.BulletInfo) then
        ent.BulletInfo = {
            [wep] = {
                Bullets = 0,
                Hits = 0,
                HitGroups = {}
            }
        }
    end
    if (not ent.BulletInfo[wep]) then
        ent.BulletInfo[wep] = {
            Bullets = 0,
            Hits = 0,
            HitGroups = {}
        }
    end

    ent.BulletInfo[wep].Bullets = (ent.BulletInfo[wep].Bullets or 0) + 1
    timer.Remove(ent:EntIndex() .. "_bulletSave")
    timer.Create(ent:EntIndex() .. "_bulletSave", 10, 1, function()
        file.Write("bulletinfo/" .. ent:SteamID64() .. ".txt", util.TableToJSON(ent.BulletInfo, true))
    end)
end)

hook.Add("PlayerSay", "Arena.SendLogs", function(ply, txt)
    if (ply:IsSuperAdmin() and string.StartWith(txt, "!arenastats")) then
        local target = string.sub(txt, #"!arenestats " + 1)
        local logFound = false
        if (tonumber(target)) then
            local victim = player.GetBySteamID64(target)
            if (IsValid(victim)) then
                net.Start("ASAP.Arena:SendStats")
                net.WriteTable(victim.BulletInfo or {})
                net.Send(ply)
                logFound = true
            else
                if (file.Exists("bulletinfo/" .. target .. ".txt", "DATA")) then
                    net.Start("ASAP.Arena:SendStats")
                    net.WriteTable(util.JSONToTable(file.Read("bulletinfo/" .. target .. ".txt")))
                    net.Send(ply)
                    logFound = true
                end
            end
        else
            for k, v in pairs(player.GetAll()) do
                if (string.find(string.lower(v:Nick()), target, 1, true)) then
                    net.Start("ASAP.Arena:SendStats")
                    net.WriteTable(v.BulletInfo or {})
                    net.Send(ply)
                    logFound = true
                    break
                end
            end
        end
        if (not logFound) then
            DarkRP.notify(ply, 1, 5, "Target not found!")
        end
        return ""
    end
end)

-- Define the table containing commands and their scheduled start times
local gamemodes = {
    {mode = "gungame", start_time = "01:15"},
    {mode = "zombie", start_time = "02:00"},
	{mode = "tdm", start_time = "03:00"},
	{mode = "melee", start_time = "04:00"},
	{mode = "zombie", start_time = "05:00"},
	{mode = "gungame", start_time = "06:00"},
	{mode = "tdm", start_time = "07:00"},
	{mode = "melee", start_time = "08:00"},
	{mode = "tdm", start_time = "09:00"},
	{mode = "zombie", start_time = "11:00"},
	{mode = "melee", start_time = "12:00"},
	{mode = "gungame", start_time = "13:15"},
    {mode = "zombie", start_time = "14:00"},
	{mode = "melee", start_time = "15:00"},
	{mode = "gungame", start_time = "16:00"},
	{mode = "tdm", start_time = "17:00"},
	{mode = "melee", start_time = "18:00"},
	{mode = "gungame", start_time = "19:00"},
	{mode = "tdm", start_time = "20:00"},
	{mode = "zombie", start_time = "21:00"},
	{mode = "gungame", start_time = "22:00"},
	{mode = "tdm", start_time = "23:00"},
	{mode = "zombie", start_time = "00:00"},
}

-- Function to parse time string to hours and minutes
local function parseTime(t)
    local hour, minute = t:match("(%d+):(%d+)")
    return tonumber(hour), tonumber(minute)
end

-- Function to check if it's the right time to execute a command
local function checkAndExecuteCommands()
    local currentHour = tonumber(os.date("%H"))
    local currentMinute = tonumber(os.date("%M"))
    for _, cmd in ipairs(gamemodes) do
        local hour, minute = parseTime(cmd.start_time)
        if currentHour == hour and currentMinute == minute then
            local commandString = "arena_setgamemode " .. cmd.mode
            RunConsoleCommand(unpack(string.Explode(" ", commandString)))
        end
    end
end

-- Create a timer that checks every minute
timer.Create("CommandExecutionTimer", 60, 0, checkAndExecuteCommands)

file.CreateDir("bulletinfo")
