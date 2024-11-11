local function loadDoors(id, min, max, retry)
    if (retry) then
        MsgN("Failed to read entities, trying again!")
    else
        MsgN("Zone " .. id .. " #installed#")
        MsgN("Reading doors! ")
    end

    local doors = 0

    for _, door in pairs(ents.FindInBox(min, max)) do
        if (door:isDoor()) then
            if not asapgangs.Doors[id] then
                asapgangs.Doors[id] = {}
            end

            asapgangs.Doors[id][door] = true
            doors = doors + 1
        end
    end

    if (doors == 0) then
        timer.Simple(5, function()
            loadDoors(id, min, max, true)
        end)
    else
        Msg(doors, " loaded!\n")
    end
end

net.Receive("GangZones.Broadcast", function(l, ply)
    asapgangs.Zones = {}
    asapgangs.Doors = {}
    local num = net.ReadInt(8)
    MsgN("Receiving zones header. Size=" .. num)

    for k = 1, num do
        local id = net.ReadString()
        local min = net.ReadVector()
        local max = net.ReadVector()
        local gang = net.ReadString()

        asapgangs.Zones[id] = {
            Start = min,
            EndPos = max,
            Gang = gang
        }

        MsgN("Reading ", id)
        if not id then continue end
        loadDoors(id, min, max)
    end
end)

local ranks = {
    trialmoderator = true,
    moderator = true,
    admin = true,
    senioradmin = true,
    superadmin = true,
    owner = true
}

net.Receive("GangZones.Own", function()
    local zone = net.ReadString()
    asapgangs.Zones[zone].Gang = net.ReadString()
    for k, v in pairs(ents.FindByClass("sent_gang_computer")) do
        if (v:GetGang() == LocalPlayer():GetGang()) then
            LocalPlayer().GangComputer = v
            break
        end
    end
end)

net.Receive("GangZones.Notify", function()
    local id = net.ReadInt(4)

    if (id == 1) then
        chat.AddText(Color(150, 50, 200), "[GANGS] ", color_white, "Your gang got a cool place to stay!")
    end

    timer.Simple(3, function()
        for k, v in pairs(ents.FindByClass("sent_gang_computer")) do
            if (v:GetGang() == LocalPlayer():GetGang()) then
                v:LoadBaseData(v:GetZone())
            end
        end
    end)
end)

net.Receive("GangZones.AcquireUpgrade", function()
    local zone = net.ReadString()
    local upg = net.ReadString()
    local level = net.ReadInt(4)

    if not asapgangs.Zones[zone] then
        asapgangs.Zones[zone] = {}
    end

    asapgangs.Zones[zone][upg] = level
end)

net.Receive("Gangs.StartRaid", function()
    local attackers = net.ReadString()
    local defenders = net.ReadString()

    LocalPlayer().RaidActive = {attackers, defenders}

    if IsValid(INFO) then
        INFO:Remove()
    end

    local notif = vgui.Create("Gangs.WarsPanel")
    notif:SetupInfo(attackers, defenders)
end)

net.Receive("Gangs.ExitRaid", function()
    local status = net.ReadInt(4)
    hook.Remove("HUDPaint", "GangWars.HUD")

    if IsValid(INFO) then
        INFO:Remove()
    end

    if (status == 0) then
        notification.AddLegacy("You went too far away from the base you were raiding", NOTIFY_ERROR, 5)
    elseif (status == 1) then
        notification.AddLegacy("You died and you cannot return to raid the base", NOTIFY_ERROR, 5)
    end
end)

net.Receive("Gangs.StopRaid", function()
    LocalPlayer().RaidActive = nil
    timer.Simple(5, function()
        if IsValid(INFO) then
            INFO:Remove()
        end
    end)
end)

net.Receive("ASAP.Gangs:RequestName", function(l)
    local gang = net.ReadString()
    local name = net.ReadString()

    if not asapgangs.gangList then
        asapgangs.gangList = {}
    end

    asapgangs.gangList[gang] = {
        Name = name
    }
end)

net.Receive("GangsMachine.UpdateResource", function()
    local isFull = net.ReadBool()
    local machine = net.ReadEntity()
    if not IsValid(machine) then return end
    if (isFull) then
        LocalPlayer().GangComputer = machine
        machine.Resources = {}
        local limit =  net.ReadUInt(4)
        if limit == 0 then return end
        for k = 1, limit do
            machine.Resources[net.ReadUInt(4)] = net.ReadUInt(32)
        end
    else
        if not machine.Resources then
            machine.Resources = {}
        end
        LocalPlayer().GangComputer = machine
        machine.Resources[net.ReadUInt(4)] = net.ReadUInt(32)
    end
end)

local circle = surface.GetTextureID("sprites/mat_jack_shockwave_white")
net.Receive("Gangs.SendShaftPos", function()
    local pos = net.ReadVector()
    local cache = net.ReadUInt(4)
    LocalPlayer():SetNWInt("Delivery.Packages", cache)
    hook.Add("HUDPaint", "Marked.Zone", function()
        if (LocalPlayer():GetNWInt("Delivery.Packages", 0) <= 0) then
            hook.Remove("HUDPaint", "Marked.Zone")
            return
        end
        surface.SetTexture(circle)
        local screen = (pos + Vector(0, 0, 4)):ToScreen()
        local siz = (RealTime() % 2) * 200
        local force = siz / 400
        surface.SetDrawColor(125, 255, 255, 255 * (1 - force))
        surface.DrawTexturedRectRotated(screen.x, screen.y, siz, siz, 0)
    end)
end)

concommand.Add("gang_listzones", function(ply, cmd, args)
    if (IsValid(ply) and not ranks[ply:GetUserGroup()]) then return end
    MsgN("Active zones:")
    MsgN("-------------")

    for k, v in pairs(asapgangs.Zones) do
        MsgN(k, " owned by ", v.Gang ~= "" and v.Gang or "No one")
    end
end)