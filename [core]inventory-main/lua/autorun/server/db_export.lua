require("mysqloo")
itemDictionary = itemDictionary or {}
noExists = noExists or {
    zmlab_collectcrate = true,
    ztm_trashbag = true,
}

local db_export = mysqloo.connect("172.0.0.2", 
    "u5720_W3dOI1dTLP", 
    "h.eeKkOWOuBBcvhebwu=25FP", 
    "s5720_players", 
    3306
)

function db_export:onConnected()
    MsgN("DATABASE ON")
end

function db_export.quer(line, cb)
    local query = db_export:query(line)
    query.onSuccess = function(s, data)
        if cb then
            cb(data)
        end
    end
    query.onError = function(s, err)
        MsgN("Failed ", err)
    end
    query:start();
end
db_export:connect()
db_export:wait()

local i = 0
local itemCount = 0
local itemValid = 0
local max = 0
local progress = 0
playerInventory = playerInventory or {}
CANCEL_ITEM_CREATION = false
function db_fetchItems(players)
    if (CANCEL_ITEM_CREATION) then
        MsgN("WE VE STOPPED THIS SHIT!")
        return
    end
    local current = players[1]
    if (current) then
        db_export.quer("SELECT * FROM INV_Items WHERE Owner_ID='" .. current.Owner_ID .. "';", function(data)
            progress = progress + 1
            if (progress % 25 == 0) then
                MsgN("%" .. math.Round((progress / max) * 50, 1))
            end
            table.remove(players, 1)
            --MsgN("#" .. i .. " with " .. table.Count(data) .. " items")
            for k, v in pairs(data) do
                local class = v.Class
                local amount = 1
                itemCount = itemCount + 1
                if (noExists[class]) then continue end
                itemValid = itemValid + 1
                if class == "spawned_shipment" then
                    local json = util.JSONToTable(v.Data)
                    class = json.EntityClass
                    amount = json.Count or 1
                end
                if class == "spawned_weapon" then
                    local json = util.JSONToTable(v.Data)
                    class = json.WeaponClass
                    amount = json.Amount or 1
                end

                if (not playerInventory[current.Owner_ID]) then
                    playerInventory[current.Owner_ID] = {}
                end

                if (itemDictionary[class]) then
                    playerInventory[current.Owner_ID][itemDictionary[class]] = (playerInventory[current.Owner_ID][itemDictionary[class]] or 0) + amount
                else
                    for k, v in pairs(BU3.Items.Items) do
                        if (class == v.className) then
                            itemDictionary[class] = k
                            break
                        end
                    end
                    if (not itemDictionary[class]) then
                        noExists[class] = true
                    else
                        playerInventory[current.Owner_ID][itemDictionary[class]] = (playerInventory[current.Owner_ID][itemDictionary[class]] or 0) + amount
                    end        
                end
            end
            db_fetchItems(players)
        end)
    end
end

function db_processPlayers()
    progress = 0
    max = table.Count(playerInventory)
    MsgN("Items Count: ", itemCount," (valid: ", itemValid , ")")
    for k, inv in pairs(playerInventory) do
        db_export.quer("SELECT * FROM bu3_inventories WHERE steamid='" .. k .. "'", function(data)
            if (data[1]) then
                local inventory = util.JSONToTable(data[1].inventoryData or "[]")
                for id, am in pairs(inv) do
                    inventory[id] = (inventory[id] or 0) + am or 1
                end
                db_export.quer("UPDATE bu3_inventories SET inventoryData='" .. util.TableToJSON(inventory) .. "' WHERE steamid='" .. k .. "';")
            else
                db_export.quer("INSERT INTO bu3_inventories (steamid, inventoryData) VALUES('" .. k .. "', '" .. util.TableToJSON(inv) .. "')")
            end
            playerInventory[k] = nil
            progress = progress + 1
            if (progress % 25 == 0) then
                MsgN("%" .. math.Round(50 + (progress / max) * 50, 1))
            end
            if (progress == max) then
                MsgN("FINISHED EVERYTHING!")
            end
        end)
    end
end

function db_startProcess()
    db_export.quer("SELECT DISTINCT Owner_ID FROM INV_Items;", function(data)
        max = table.Count(data)
        MsgN("We found " .. table.Count(data) .. " users")
        local activePlayers = data
        db_fetchItems(activePlayers)
    end)
end

function db_generateMissing()
    for k, v in pairs(noExists) do
        if (not weapons.Get(k) and not string.StartWith(k, "armor_")) then
            continue
        end
        local item = {
            price = 0,
            className = k,
            color = color_white,
            perm = false,
            rankRestricted = false,
            ranks = {},
            zoom = .25,
            itemColorCode = 1,
            iconIsModel = true
        }
        if (weapons.Get(k)) then
            local wep = weapons.Get(k)
            item.name = wep.PrintName
            item.desc = wep.PrintName
            item.iconID = wep.WorldModel
            item.type = "weapon"
        else
            for _, v in pairs(Armor.Data) do
                if (v.Entitie == k) then
                    item.name = v.Name
                    item.iconID = v.Model
                    item.type = "suit"
                    item.desc = v.Name
                    item.zoom = 0.3
                    found = true
                    break
                end
            end
        end
        if (not item.name) then MsgN("Skipping ", k) continue end
        BU3.Items.CreateItem(item, false)
        noExists[k] = nil
    end
    MsgN("You can start looking for inventories with unbox_stage3, it will take around 5 minutes")
end

local items = {
    "m9k_winchester73",
    "m9k_acr",
    "robotnik_bo1_74g",
    "m9k_amd65",
    "m9k_an94",
    "m9k_auga3",
    "robotnik_bo1_com",
    "robotnik_bo1_en",
    "m9k_f2000",
    "mac_bo2_falosw",
    "m9k_fal",
    "robotnik_bo1_gal",
    "robotnik_bo1_hk",
    "m9k_m416",
    "mac_codww2_m1g",
    "m9k_m16a4_acog",
    "mac_bo2_m8a1",
    "mac_bo2_mtar",
    "mac_bo2_pdw",
    "mac_bo2_smr",
    "m9k_vikhr",
    "mac_codww2_stg",
    "robotnik_bo1_stn",
    "mac_bo2_swat",
    "m9k_tar21",
    "robotnik_mw2_tar",
    "mac_bo2_type25",
    "deployable_shield",
    "heavy_shield",
    "m9k_famas",
    "m9k_glock",
    "m9k_ak47",
    "tfa_ak74",
    "m9k_m4a1",
    "cw_fiveseven",
    "m9k_g3a3",
    "m9k_mp5",
    "m9k_deagle",
    "m9k_colt1911",
    "cw_mr96",
    "cw_p99",
    "robotnik_bo1_mak",
    "m9k_mossberg590",
    "cw_vss",
    "weapon_gluongun",
    "infinitygunx99",
    "m9k_emp_grenade",
    "fo3_fatman_mininuke",
    "mac_codww2_bren",
    "m9k_fg42",
    "robotnik_mw2_lsw",
    "m9k_m1918bar",
    "m9k_m60",
    "robotnik_mw2_mg4",
    "mac_bo2_mk48",
    "m9k_pkm",
    "robotnik_bo1_rpk",
    "robotnik_mw2_44",
    "robotnik_bo1_cz",
    "mac_bo2_exec",
    "m9k_hk45",
    "m9k_m29satan",
    "m9k_sig_p229r",
    "m9k_luger",
    "m9k_coltpython",
    "m9k_ragingbull",
    "m9k_scoped_taurus",
    "m9k_remington1858",
    "m9k_model3russian",
    "m9k_model500",
    "m9k_model627",
    "mac_bo2_tac45",
    "robotnik_mw2_usp",
    "m9k_honeybadger",
    "m9k_bizonp19",
    "m9k_usc",
    "m9k_kac_pdw",
    "robotnik_bo1_ki",
    "m9k_magpulpdr",
    "m9k_mp40",
    "robotnik_mw2_mp5",
    "m9k_mp5sd",
    "m9k_mp7",
    "m9k_mp9",
    "robotnik_bo1_mpl",
    "mac_bo2_msmc",
    "m9k_smgp90",
    "robotnik_bo1_pm",
    "robotnik_mw2_pp",
    "mac_codww2_ppsh",
    "mac_bo2_scorp",
    "robotnik_bo1_spc",
    "m9k_sten",
    "m9k_tec9",
    "robotnik_mw2_tmp",
    "m9k_thompson",
    "m9k_uzi",
    "m9k_dbarrel",
    "robotnik_bo1_h10",
    "m9k_ithacam37",
    "m9k_jackhammer",
    "robotnik_mw2_rngr",
    "m9k_remington870",
    "mac_bo2_870",
    "mac_codww2_sawed",
    "m9k_spas12",
    "m9k_striker12",
    "m9k_browningauto5",
    "m9k_1897winchester",
    "m9k_1887winchester",
    "m9k_barret_m82",
    "m9k_m98b",
    "m9k_dragunov",
    "m9k_svu",
    "mac_bo2_dsr50",
    "mac_codww2_no2",
    "m9k_intervention",
    "mac_codww2_karb",
    "m9k_aw50",
    "mac_codww2_smle",
    "m9k_m24",
    "m9k_sl8",
    "m9k_svt40",
    "mac_bo2_svu",
    "m9k_contender",
    "tfa_dax_big_glock",
    "m9k_m202",
    "tfa_ins2_volk",
    "weapon_teslagun",
    "tfa_csgo_smoke",
    "tfa_csgo_molly",
    "tfa_qc_supernailgun",
    "deika_scavenger",
    "armor_bp1",
    "armor_bp2",
    "armor_bp3",
    "armor_z07_tp",
    "armor_simulator",
}

function db_findItems()
    itemDictionary = {}
    MsgN("Find items command has been run")
    db_export.quer("SELECT * FROM INV_Items;", function(data)
        MsgN("We found ", table.Count(data), " items")
        for _, item in pairs(data) do
            local class = item.Class
            if class == "spawned_weapon" then
                local json = util.JSONToTable(item.Data)
                class = json.WeaponClass
            end
            if class == "spawned_shipment" then
                local json = util.JSONToTable(item.Data)
                class = json.EntityClass
            end
            if (string.StartWith(class, "zm") or string.StartWith(class, "ztm")) then continue end
            if (itemDictionary[class]) then continue end
            for k, v in pairs(BU3.Items.Items) do
                if (class == v.className) then
                    itemDictionary[class] = k
                    break
                end
            end
            if (not itemDictionary[class]) then
                noExists[class] = true
            end
        end
        MsgN("You can run now unbox_stage2 for ", table.Count(noExists), " items!")
        for _, id in pairs(items) do
            if not itemDictionary[id] then
                noExists[id] = true
            end
        end
    end)
end


concommand.Add("unbox_stage1", function()
    MsgN("Running stage 1")
    db_findItems()
    MsgN("Reloading stage 1")
end)

concommand.Add("unbox_stage2", function()
    db_generateMissing()
end)

concommand.Add("unbox_stage3", function()
    db_startProcess()
end)

concommand.Add("unbox_stage4", function()
    db_processPlayers()
end)

concommand.Add("unbox_finish", function(ply, args)
    if (not args[1]) then
        MsgN("THIS COMMAND WILL DROP OLD INVENTORY DATABASE, WRITE WITH THIS COMMAND 'yes' TO COMFIRM OPERATION!!!")
        MsgN("Please verify you got your items from your old inventory in your unbox inventory")
    elseif(args[1] == "yes") then
        db_export.quer("DROP TABLE INV_Items")
    end 
end)