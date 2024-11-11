--[[-------------------------------------------------------------------------
Handles networking and unpacking of the server stuff
---------------------------------------------------------------------------]]
BU3.Inventory = BU3.Inventory or {}
BU3.Inventory.Inventory = BU3.Inventory.Inventory or {} --The acctual inventory

function BU3.Inventory.UpdateInventory(data)
    for k, v in pairs(data) do
        BU3.Inventory.Inventory[v[1]] = v[2]
    end
    MsgN("Updating this shouldn't occur")
end

local PLAYER = FindMetaTable("Player")
function PLAYER:UB3HasItem(itemID)
    if BU3.Inventory.Inventory[itemID] == nil then return false end
    if BU3.Inventory.Inventory[itemID] > 0 then return true, BU3.Inventory.Inventory[itemID] end
end

function BU3.Inventory.ItemCount()
    local amount = 0

    for k, v in pairs(BU3.Inventory.Inventory or {}) do
        amount = amount + v
    end

    return amount
end

net.Receive("BU3:UpdateInventory", function()
    local dataIncoming = net.ReadTable()
    BU3.Inventory.UpdateInventory(dataIncoming)
end)

net.Receive("BU3:FinishInventory", function()
    --Check if the menu is open?
    if BU3.UI._MENU_OPEN then
        --Check if the page is inventory
        if BU3.UI.ContentFrame.loadedPageName == "inventory" then
            BU3.UI.ContentFrame:LoadPage("inventory") --Reload it
        end
    end
end)

local function loadItems(useApi)
    BU3.Inventory.Inventory = {}

    if (useApi) then
        local api = asapMarket.API .. "/inventory?sid=" .. LocalPlayer():SteamID64()

        http.Fetch(api, function(body)
            if (string.StartWith(body, '{')) then
                BU3.Inventory.Inventory = util.JSONToTable(body)
            else
                local compiled = string.Replace(body, '\\', '')
                compiled = string.sub(compiled, 2, #compiled - 1)
                BU3.Inventory.Inventory = util.JSONToTable(compiled)
            end

            if BU3.UI._MENU_OPEN then
                --Check if the page is inventory
                if BU3.UI.ContentFrame.loadedPageName == "inventory" and IsValid(GINV) then
                    GINV:UpdateInventory()
                end
            end
        end)
    end
end

net.Receive("BU3:PrepareInventory", function()
    local useApi = net.ReadBool()
    loadItems(useApi)
end)

concommand.Add("bu3_loaditems", function()
    loadItems(true)
end)

net.Receive("BU3.AnounceGolden", function()
    local itemName = net.ReadString()
    local rarity = net.ReadUInt(4)
    local ply = net.ReadEntity()
    if not IsValid(ply) or not ply.Nick then return end
    if (rarity == 9) then
        chat.AddText(Color(255, 210, 0), "[Unbox] ", color_white, ply:Nick(), " has unboxed " .. string.format("'<rainbow=2>%s</rainbow>'", itemName))
    else
        local clr = BU3.Items.RarityToColor[rarity]
        chat.AddText(Color(255, 210, 0), "[Unbox] ", color_white, ply:Nick(), " has unboxed " .. string.format("'<flash=" .. clr.r .. "," .. clr.g .. "," .. clr.b .. "," .. ",2>%s</flash>'", itemName))
    end
end)

net.Receive("UB3.Sync", function()
    local itemID = net.ReadInt(16)
    local amount = net.ReadInt(16)

    MsgN("Receiving update ", itemID," ", amount)
    if not BU3.Inventory then
        BU3.Inventory = {
            Inventory = {}
        }
    elseif (not BU3.Inventory.Inventory) then
        BU3.Inventory.Inventory = {}
    end

    if (amount > 0) then
        local shouldPopulate = BU3.Inventory.Inventory[itemID] == nil
        BU3.Inventory.Inventory[itemID] = amount

        if shouldPopulate and IsValid(GINV) then
            GINV:PopulateItems()
        end
    else
        BU3.Inventory.Inventory[itemID] = nil

        if IsValid(GINV) and IsValid(GINV.InstalledItems[itemID]) then
            MsgN("Removing base element")
            GINV.InstalledItems[itemID]:Remove()
            GINV.InstalledItems[itemID] = nil
        end
    end

    if (amount > 0) then
        local item = BU3.Items.Items[itemID]
        if not item then return end
        chat.AddText(Color(168, 255, 0), "[INV] ", color_white, "Added '", BU3.Items.RarityToColor[item.itemColorCode], item.name, color_white, "'")
    end
end)

net.Receive("BU3.PushCategory", function()
    local id = net.ReadInt(16)
    local type = net.ReadString()
    BU3.Items.Items[id].type = type
end)

net.Receive("BU3.SetPerma", function()
    local name = net.ReadString()
    local wepMeta = weapons.GetStored(name)

    if not wepMeta or wepMeta.permad then return end

    wepMeta.permad = true
    wepMeta.PrintName = "★" .. wepMeta.PrintName
end)