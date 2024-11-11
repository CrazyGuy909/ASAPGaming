
concommand.Add("asap_savecp", function(ply)
    if IsValid(ply) then return end

    local data = {}
    for k, v in pairs(ents.FindByClass("asap_controlpoint")) do
        table.insert(data, {
            pos = v:GetPos(),
            name = v:GetZoneName(),
            size = v:GetBounds(),
            faction = v:GetFaction(),
            CacheID = v.CacheID
        })
    end

    file.Write("capture_points.txt", util.TableToJSON(data))
    MsgN("[CPs] " .. #data .. " capture points saved.")
end)

concommand.Add("asap_resetcp", function(ply)
    if IsValid(ply) then return end

    for k, v in pairs(ents.FindByClass("asap_controlpoint")) do
        v:SetFaction("0")
    end
end)

concommand.Add("asap_loadcp", function(ply)
    if IsValid(ply) then return end

    for k, v in pairs(ents.FindByClass("asap_controlpoint")) do
        v:Remove()
    end

    local textFile = file.Read("capture_points.txt", "DATA") or "[]"
    local data = util.JSONToTable(textFile)
    for k, v in pairs(data) do
        local cp = ents.Create("asap_controlpoint")
        cp:SetPos(v.pos)
        cp:Spawn()
        timer.Simple(0, function()
            cp:SetZoneName(v.name)
            cp:SetX(v.size.x / 16)
            cp:SetY(v.size.y / 16)
            cp:SetZ(v.size.z / 16)
            cp:SetFaction(v.faction)
            cp.CacheID = v.CacheID
        end)
    end

    MsgN("[CPs] " .. #data .. " capture points loaded.")
end)

hook.Add("InitPostEntity", "asap.SpawnCPs", function()
    RunConsoleCommand("asap_loadcp")
end)