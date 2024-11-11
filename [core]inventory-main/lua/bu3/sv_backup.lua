concommand.Add("bu3_writebackup", function(pl)
    if IsValid(pl) then return end
    local totalBackup = {}

    for _, ply in pairs(player.GetAll()) do
        totalBackup[ply:SteamID64()] = {
            Items = {},
            Suit = ply.armorSuit,
            Money = 0,
            Credits = 0
        }

        for _, wep in pairs(ply:GetWeapons()) do
            if wep.ItemID then
                local canDrop = hook.Call("canDropWeapon", GAMEMODE, ply, wep)
                if not canDrop then continue end
                table.insert(totalBackup[ply:SteamID64()].Items, wep.ItemID)
            end
        end

        for k, v in pairs(ents.FindByClass("nebula_printer")) do
            if IsValid(v:Getowning_ent()) and v:Getowning_ent() == ply then
                totalBackup[ply:SteamID64()].Money = totalBackup[ply:SteamID64()].Money + v:GetMoney() + 400000
            end
        end

        for k, v in pairs(ents.FindByClass("asap_pointstree")) do
            if IsValid(v:Getowning_ent()) and v:Getowning_ent() == ply then
                totalBackup[ply:SteamID64()].Credits = totalBackup[ply:SteamID64()].Credits + 50
            end
        end
    end

    file.Write("bu3_backup.txt", util.TableToJSON(totalBackup))
    global_backdata = totalBackup
end)

concommand.Add("bu3_deletebackup", function(ply)
    if not IsValid(ply) then
        file.Delete("bu3_backup.txt")
        global_backdata = nil
    end
end)

local cache = {}

function ReloadPlayerInfo(ply)
    if not global_backdata then
        global_backdata = util.JSONToTable(file.Read("bu3_backup.txt", "DATA") or "[]")
        file.Delete("bu3_backup.txt")
    end

    local data = global_backdata[ply:SteamID64()]

    if data then
        ply:ChatPrint("<color=green>Loading backup...</color>")

        for _, item in pairs(data.Items) do
            ply:UB3AddItem(item, 1)
        end

        if data.Suit and data.Suit ~= "" then
            if cache[data.Suit] then
                ply:UB3AddItem(cache[data.Suit], 1)
            else
                local class = Armor:Get(data.Suit).Entitie

                for k, v in pairs(BU3.Items.Items) do
                    if class == v.className then
                        cache[data.Suit] = v.itemID
                        ply:UB3AddItem(cache[data.Suit], 1)
                        break
                    end
                end
            end
        end

        ply:addMoney(data.Money)
        ply:GiveCredits(data.Credits)
    end

    global_backdata[ply:SteamID64()] = nil
end

hook.Add("PlayerInitialSpawn", "ReloadBackup", function(ply)
    timer.Simple(10, function()
        ReloadPlayerInfo(ply)
    end)
end)

local bps, cases = {}, {}

for k, v in pairs(BU3.Items.Items) do
    if v.type ~= "case" then continue end

    for id, cha in pairs(v.items) do
        local it = BU3.Items.Items[id]

        if it.type == "blueprint" then
            cases[v.name] = (cases[v.name] or 0) + 1
            bps[k] = bps[k] or {}
            table.insert(bps[k], id)
        end
    end
end

PrintTable(cases)