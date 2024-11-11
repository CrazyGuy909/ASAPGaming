--[[-------------------------------------------------------------------------
This file will contain all the console commands for the addon
---------------------------------------------------------------------------]]
--Prints out all the items names and there id's
-- We use _ only for unused variables
local colors = {
    [1] = Color(169, 169, 169, 255), --Gray
    [2] = Color(0, 191, 255, 255), --Light blue
    [3] = Color(200, 0, 128, 255), --Purple
    [4] = Color(255, 0, 255, 255), --Pink
    [5] = Color(255, 0, 0, 255), --Red
    [6] = Color(255, 215, 0, 255), --Gold!
    [7] = Color(223, 223, 223), --Diamond!
    [8] = Color(255, 102, 0), --Fire!
    [9] = Color(0, 255, 221), --Rainbow!
    [10] = Color(5, 141, 0), --Glitched!
    [11] = Color(5, 255, 0), --Glitched!
}

concommand.Add("bu3_items", function(ply, _, args)
    print("----------------UNBOXING ITEM LIST-----------------")

    for k, v in pairs(BU3.Items.Items) do
        print(k, BU3.Items.Items[k].name)
    end

    print("---------------------------------------------------")
end)

-- We use _ only for unused variables
concommand.Add("bu3_find", function(_, __, args)
    local find = string.lower(args[1] or "")
    if find == "" then return end

    for k, v in pairs(BU3.Items.Items) do
        if string.find(string.lower(v.name), find) then
            MsgC(Color(27, 221, 89), k, " - ", colors[v.itemColorCode or 1], v.name, "\n")
        end
    end
end)

-- We use _ only for unused variables
concommand.Add("bu3_id", function(_, __, args)
    if not tonumber(args[1]) then return end
    local it = BU3.Items.Items[tonumber(args[1])]
    MsgC(colors[it.itemColorCode or 1], it.name,
        color_white, "\n\tType: ", Color(0, 187, 255), it.type,
        color_white, "\n\tClass: ", Color(0, 187, 255), it.className or "-NONE-", "\n")
end)

if SERVER then
    -- We use _ only for unused variables
    concommand.Add("bu3_online", function(ply, _, args, c)
        if ply:IsValid() then return end
        local target = player.GetBySteamID(c) or player.GetBySteamID64(c)
        MsgN("Player ", c, " it's ", target and "Online" or "Offline")
    end)

    -- We use _ only for unused variables
    concommand.Add("bu3_give", function(ply, _, args, c)
        if ply:IsValid() then return end

        --Check its a valid item
        args = string.Explode(" ", c)

        for k, v in pairs(args) do
            args[k] = v:Replace('"', "")
        end

        local sid = args[1]
        local itemIDToGive = tonumber(args[2])
        local amount = tonumber(args[3]) or 1
        local item = BU3.Items.Items[itemIDToGive]

        if item == nil then
            print("[UNBOXING 3] Invalid item ID. Do bu3_items in console to get a list of items and their id's")

            return
        end

        if sid == nil or sid == "" then
            print("Invalid SteamID64")
            print("The command works like this : bu3_give <STEAMID/64> <ID> <AMOUNT>")

            return
        end

        local target = sid:StartWith("STEAM_") and player.GetBySteamID(sid) or player.GetBySteamID64(sid)
        if target == nil or not IsValid(target) then
            local realSid = sid:StartWith("STEAM_0") and util.SteamIDTo64(sid) or sid
            
            ASAPDriver:MySQLSelect("bu3_inventories", "steamid=" .. realSid, function(data)
                if data == nil then
                    print("[UNBOXING 3] Failed to find player in database")
                    
                    return
                end
                
                local inv = data[1].inventoryData
                local invTable = util.JSONToTable(inv)

                if invTable == nil then
                    invTable = {}
                end

                if invTable[itemIDToGive] == nil then
                    invTable[itemIDToGive] = 0
                end

                invTable[itemIDToGive] = invTable[itemIDToGive] + amount
                inv = util.TableToJSON(invTable)

                ASAPDriver:MySQLQuery("UPDATE bu3_inventories SET inventoryData='" .. inv .. "' WHERE steamid='" .. realSid .. "';", function()
                    print("[UNBOXING 3] Gave player '" .. sid .. "' item '" .. item.name .. "'")
                end)
            end)

            return
        end

        --Okay all checks passed, lets give them there item
        target:UB3AddItem(itemIDToGive, amount)
        print("[UNBOXING 3] Give '" .. target:Name() .. "' item '" .. itemIDToGive .. "'")
    end)

    --Gives an item to every player on the server
    -- We use _ only for unused variables
    concommand.Add("bu3_give_all", function(ply, _, args)
        if ply:IsValid() then return end
        --Check its a valid item
        local itemIDToGive = tonumber(args[1])
        local amount = tonumber(args[2]) or 1
        local item = BU3.Items.Items[itemIDToGive]
        if item == nil then
            print("[UNBOXING 3] Invalid item ID. Do bu3_items in console to get a list of items and their id's")

            return
        end

        for k, v in pairs(player.GetAll()) do
            --Okay all checks passed, lets give them there item
            v:UB3AddItem(itemIDToGive, amount)
            print("[UNBOXING 3] Give '" .. v:Name() .. "' item '" .. itemIDToGive .. "'")
        end
    end)

    --Deletes someone inventory
    -- We use _ only for unused variables
    concommand.Add("bu3_wipe", function(ply, __, args)
        if ply:IsValid() then return end
        --Check its a valid item
        local sid = args[1]

        if sid == nil or sid == "" then
            print("Invalid SteamID64")
            print("This command will wipe a players inventory: bu3_wipe <STEAMID64>")

            return
        end

        local target = player.GetBySteamID64(sid)

        --Now wipe the inventory
        if target ~= nil then
            target._ub3inv = {}
            target:UB3SaveInventory()
            target:UB3UpdateClient()
            print("[UNBOXING 3] Wiped players inventory!")
        else
            print("[UNBOXING 3] Failed to wipe players inventory!")
        end
    end)
end
