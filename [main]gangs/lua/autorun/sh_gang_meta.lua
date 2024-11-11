local meta = FindMetaTable("Player")

if (not asapgangs) then
    asapgangs = {
        gangList = {}
    }
end

function asapgangs.GetUpgrade(tag, id)
    if (not asapgangs.gangList or not asapgangs.gangList[tag]) then return 0 end

    return asapgangs.gangList[tag].Shop.Upgrades[id] or 0
end

function asapgangs.GetMembers(tag)
    local members = {}
    for k, v in pairs(player.GetAll()) do
        if (v:GetGang() == tag) then
            table.insert(members, v)
        end
    end
    return members
end

function meta:FindGang()
    if (not asapgangs.gangList) then return end

    return asapgangs.gangList[self:GetGang()]
end

function meta:IsGangBuffed()
    return self:GetNWBool("GangBuffed", false)
end

function meta:IsGangEnemy(name)
    local ourgang = self:GetGang()
    if (ourgang or "") == "" or (name or "") == "" then return true end

    return name != ourgang
end

function meta:GangsHasPermission(str)
    local rank = self:GetNWString("Gang.Rank", "User")
    if (rank == "Administrator") then return true end
    if (rank == "User" or rank == "") then return false end
    local gang = asapgangs.gangList[self:GetGang()]
    if not gang then return false end

    return (gang.Ranks[rank] or {
        Permissions = {}
    }).Permissions[str]
end

function meta:GetGang()
    return self:GetNWString("Gang", nil)
end

local nextCheck = 0
local zoneManager = {}

hook.Add("Think", "GangWars.Inner", function()
    if (nextCheck > CurTime()) then return end
    nextCheck = CurTime() + (CLIENT and .5 or 2)

    for zone, data in pairs(asapgangs.Zones or {}) do
        if (data.Gang == "") then
            if (CLIENT and LocalPlayer():GetPos():WithinAABox(data.Start, data.EndPos)) then
                LocalPlayer().gangZone = nil
            end
            continue
        end

        for _, ply in pairs(SERVER and player.GetAll() or {LocalPlayer()}) do
            if (ply:GetPos():WithinAABox(data.Start, data.EndPos)) then
                ply.gangZone = zone

                if (not zoneManager[ply]) then
                    zoneManager[ply] = zone
                    hook.Run("Gangs.EnterZone", ply, zone)
                end
            elseif (ply.gangZone == zone) then
                ply.gangZone = nil
                zoneManager[ply] = nil
                hook.Run("Gangs.ExitZone", ply, zone)
            end
        end
    end
end)

if CLIENT then
    local icon = surface.GetTextureID("ui/gangs/computer/gangswar")
    local zoneIndicator = 0
    local placeholder

    hook.Add("HUDPaint", "Gangs.WarTest", function()
        if (LocalPlayer().RaidActive) then
            return
        end

        local gangzone = LocalPlayer().gangZone

        if gangzone then
            placeholder = gangzone

            if (zoneIndicator < 100) then
                zoneIndicator = Lerp(FrameTime() * 2, zoneIndicator, 128)
            end
        elseif (zoneIndicator > 0) then
            zoneIndicator = Lerp(FrameTime() * 8, zoneIndicator, -8)

            if (zoneIndicator <= 0) then
                placeholder = nil
            end
        end

        if (placeholder) then
            local bx = 0

            if (asapgangs.Zones[gangzone]) then
                draw.SimpleText("Belongs to " .. asapgangs.Zones[gangzone].Gang, "Gangs.Small", ScrW() / 2, -8 + zoneIndicator, Color(120, 200, 255, 100), 1, 1)
            end

            surface.SetFont("Gangs.Medium")
            local tx, _ = surface.GetTextSize("You're in " .. placeholder)
            local tx2, _ = draw.SimpleText("You're in ", "Gangs.Medium", ScrW() / 2 - tx / 2, -32 + zoneIndicator, color_white, 0, 1)
            draw.SimpleText(placeholder, "Gangs.Medium", ScrW() / 2 - tx / 2 + tx2, -32 + zoneIndicator, Color(255, 200, 0), 0, 1)
        end
    end)
end