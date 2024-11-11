--This file is used for functions related to items, for example, creating, saving, loading, giving, taking, etc
BU3.Items = BU3.Items or {}
BU3.ItemsIndex = 0 --This is the starting index of items, each new item increases this by 1
BU3.Items.Items = BU3.Items.Items or {} --A table of all the items
local ITEM = {}

ITEMMetaAccessor = {
    __index = ITEM
}

--[[-------------------------------------------------------------------------
Accessor functions, some are not listed such as getmoney, get points etc as 
you can direct access the tables for them
---------------------------------------------------------------------------]]
function ITEM:GetName()
    return self.name
end

function ITEM:GetDescription()
    return self.desc
end

function ITEM:GetID()
    return self.itemID
end

--Tries to find an item based on its ID, if it fails it returns false
function BU3.Items.GetItemByID(itemID)
    if BATM.Items.Items[itemID] ~= nil then
        return BATM.Items.Items[itemID]
    else
        return false
    end
end

--Registers/creates an item, this item will be networks to players when they join
--or when the function is called (during runtime, not startup)
function BU3.Items.CreateItem(item, dontNetwork)
    --Check if the item already have an ID
    if item.itemID == nil then
        item.itemID = BU3.ItemsIndex
        BU3.ItemsIndex = BU3.ItemsIndex + 1
        item = setmetatable(item, ITEMMetaAccessor)
        BU3.Items.Items[item.itemID] = item
        print("[UNBOXING 3] Registered item of type '" .. item.type .. "' with name '" .. item.name .. "' and ID of '" .. item.itemID .. "'")
    else
        --Update the item instead
        BU3.Items.Items[item.itemID] = item
    end

    --Network it if we should and save it?
    if dontNetwork ~= true then
        BU3.SQL.SaveItem(item.itemID)
        net.Start("BU3:NetworkItem")
        net.WriteTable(BU3.Items.Items[item.itemID])
        net.Broadcast()
    end
    --Return the ID

    return item.itemID
end

--This will network the itemTable to a player
function BU3.Items.NetworkItems(ply)
    --First make the table a string
    local json = util.TableToJSON(BU3.Items.Items)
    local compressedData = util.Compress(json)
    net.Start("BU3:NetworkItemTable")
    net.WriteDouble(string.len(compressedData))
    net.WriteData(compressedData, string.len(compressedData))
    net.Send(ply)
end

concommand.Add("bu3_writejson", function(ply)
    if IsValid(ply) then return end

    file.Write("itemdata.json", util.TableToJSON(BU3.Items.Items))
end)

--Tries to register a crate or crate, will return false if infomation is missing and a string.
function BU3.Items.RegisterKeyCrate(itemData, shouldNetwork)
    --Check the item infomation
    if itemData.name == nil or string.len(itemData.name) < 1 then return false, "Invalid name" end
    if itemData.iconID == nil or string.len(itemData.iconID) < 1 then return false, "Invalid icon" end
    if itemData.rankRestricted == nil then return false, "Missing property : rankRestricted" end
    if itemData.price == nil or tonumber(itemData.price) == nil then return false, "Invalid price" end
    if itemData.zoom == nil or tonumber(itemData.zoom) == nil then return false, "Invalid zoom" end
    if itemData.color == nil or IsColor(itemData.color) == false then return false, "Invalid color" end
    if itemData.ranks == nil then return false, "Missing property : ranks" end
    if itemData.items == nil then return false, "Missing property : item" end
    --Passed all the checks, create it and return true
    local itemID = BU3.Items.CreateItem(itemData)

    return true, itemID
end

--Tries to register a crate or crate, will return false if infomation is missing and a string.
function BU3.Items.RegisterWeapon(itemData, shouldNetwork)
    --Check the item infomation
    if itemData.name == nil or string.len(itemData.name) < 1 then return false, "Invalid name" end
    if itemData.iconID == nil or string.len(itemData.iconID) < 1 then return false, "Invalid icon" end
    if itemData.rankRestricted == nil then return false, "Missing property : rankRestricted" end
    if itemData.price == nil or tonumber(itemData.price) == nil then return false, "Invalid price" end
    if itemData.zoom == nil or tonumber(itemData.zoom) == nil then return false, "Invalid zoom" end
    if itemData.color == nil or IsColor(itemData.color) == false then return false, "Invalid color" end
    if itemData.ranks == nil then return false, "Missing property : ranks" end
    if itemData.itemColorCode == nil then return false, "Missing property : itemColorCode" end
    if itemData.className == nil then return false, "Missing property : className" end
    --Passed all the checks, create it and return true
    local itemID = BU3.Items.CreateItem(itemData)

    return true, itemID
end

--Tries to register a crate or entity, will return false if infomation is missing and a string.
function BU3.Items.RegisterEntity(itemData, shouldNetwork)
    --Check the item infomation
    if itemData.name == nil or string.len(itemData.name) < 1 then return false, "Invalid name" end
    if itemData.iconID == nil or string.len(itemData.iconID) < 1 then return false, "Invalid icon" end
    if itemData.rankRestricted == nil then return false, "Missing property : rankRestricted" end
    if itemData.price == nil or tonumber(itemData.price) == nil then return false, "Invalid price" end
    if itemData.zoom == nil or tonumber(itemData.zoom) == nil then return false, "Invalid zoom" end
    if itemData.color == nil or IsColor(itemData.color) == false then return false, "Invalid color" end
    if itemData.ranks == nil then return false, "Missing property : ranks" end
    if itemData.itemColorCode == nil then return false, "Missing property : itemColorCode" end
    if itemData.className == nil then return false, "Missing property : className" end
    --Passed all the checks, create it and return true
    local itemID = BU3.Items.CreateItem(itemData)

    return true, itemID
end

--Tries to register a crate or entity, will return false if infomation is missing and a string.
function BU3.Items.RegisterAccesory(itemData, shouldNetwork)
    --Check the item infomation
    if itemData.name == nil or string.len(itemData.name) < 1 then return false, "Invalid name" end
    if itemData.iconID == nil or string.len(itemData.iconID) < 1 then return false, "Invalid icon" end
    if itemData.rankRestricted == nil then return false, "Missing property : rankRestricted" end
    if itemData.price == nil or tonumber(itemData.price) == nil then return false, "Invalid price" end
    if itemData.zoom == nil or tonumber(itemData.zoom) == nil then return false, "Invalid zoom" end
    if itemData.ranks == nil then return false, "Missing property : ranks" end
    if itemData.itemColorCode == nil then return false, "Missing property : itemColorCode" end
    if itemData.accessoryID == nil then return false, "Missing property : accessoryID" end
    --Passed all the checks, create it and return true
    local itemID = BU3.Items.CreateItem(itemData)

    return true, itemID
end

--Used to register a money item
function BU3.Items.RegisterMoney(itemData, shouldNetwork)
    --Check the item infomation
    if itemData.name == nil or string.len(itemData.name) < 1 then return false, "Invalid name" end
    if itemData.iconID == nil or string.len(itemData.iconID) < 1 then return false, "Invalid icon" end
    if itemData.zoom == nil or tonumber(itemData.zoom) == nil then return false, "Invalid zoom" end
    if itemData.color == nil or IsColor(itemData.color) == false then return false, "Invalid color" end
    if itemData.itemColorCode == nil then return false, "Missing property : itemColorCode" end
    if itemData.moneyAmount == nil then return false, "Missing property : moneyAmount" end
    --Passed all the checks, create it and return true
    local itemID = BU3.Items.CreateItem(itemData)

    return true, itemID
end

--Registers either pointshop 1 or two points
function BU3.Items.RegisterPoints(itemData, shouldNetwork)
    --Check the item infomation
    if itemData.name == nil or string.len(itemData.name) < 1 then return false, "Invalid name" end
    if itemData.iconID == nil or string.len(itemData.iconID) < 1 then return false, "Invalid icon" end
    if itemData.zoom == nil or tonumber(itemData.zoom) == nil then return false, "Invalid zoom" end
    if itemData.color == nil or IsColor(itemData.color) == false then return false, "Invalid color" end
    if itemData.itemColorCode == nil then return false, "Missing property : itemColorCode" end
    if itemData.pointsAmount == nil then return false, "Missing property : pointsAmount" end

    if itemData.premium == nil then
        itemData.premium = false
    end

    --Passed all the checks, create it and return true
    local itemID = BU3.Items.CreateItem(itemData)

    return true, itemID
end

--Registers either pointshop 1 or two points
function BU3.Items.RegisterCredits(itemData, shouldNetwork)
    --Check the item infomation
    if itemData.name == nil or string.len(itemData.name) < 1 then return false, "Invalid name" end
    if itemData.iconID == nil or string.len(itemData.iconID) < 1 then return false, "Invalid icon" end
    if itemData.zoom == nil or tonumber(itemData.zoom) == nil then return false, "Invalid zoom" end
    if itemData.color == nil or IsColor(itemData.color) == false then return false, "Invalid color" end
    if itemData.itemColorCode == nil then return false, "Missing property : itemColorCode" end
    if itemData.creditsAmount == nil then return false, "Missing property : pointsAmount" end

    if itemData.premium == nil then
        itemData.premium = false
    end

    --Passed all the checks, create it and return true
    local itemID = BU3.Items.CreateItem(itemData)

    return true, itemID
end

function BU3.Items.RegisterAttachment(itemData, shouldNetwork)
    --Check the item infomation
    if itemData.name == nil or string.len(itemData.name) < 1 then return false, "Invalid name" end
    if itemData.iconID == nil or string.len(itemData.iconID) < 1 then return false, "Invalid icon" end
    if itemData.price == nil or tonumber(itemData.price) == nil then return false, "Invalid price" end
    if itemData.zoom == nil or tonumber(itemData.zoom) == nil then return false, "Invalid zoom" end
    if itemData.ranks == nil then return false, "Missing property : ranks" end
    if itemData.itemColorCode == nil then return false, "Missing property : itemColorCode" end
    if itemData.className == nil then return false, "Missing property : className" end
    local itemID = BU3.Items.CreateItem(itemData)

    return true, itemID
end

--Registers either pointshop 1 or two points
function BU3.Items.RegisterPSItem(itemData, shouldNetwork)
    --Check the item infomation
    if itemData.name == nil or string.len(itemData.name) < 1 then return false, "Invalid name" end
    if itemData.iconID == nil or string.len(itemData.iconID) < 1 then return false, "Invalid icon" end
    if itemData.price == nil or tonumber(itemData.price) == nil then return false, "Invalid price" end
    if itemData.zoom == nil or tonumber(itemData.zoom) == nil then return false, "Invalid zoom" end
    if itemData.ranks == nil then return false, "Missing property : ranks" end
    if itemData.itemColorCode == nil then return false, "Missing property : itemColorCode" end
    if itemData.className == nil then return false, "Missing property : className" end
    --Passed all the checks, create it and return true
    local itemID = BU3.Items.CreateItem(itemData)

    return true, itemID
end

--Registers either pointshop 1 or two points
function BU3.Items.RegisterLuaItem(itemData, shouldNetwork)
    --Check the item infomation
    if itemData.name == nil or string.len(itemData.name) < 1 then return false, "Invalid name" end
    if itemData.iconID == nil or string.len(itemData.iconID) < 1 then return false, "Invalid icon" end
    if itemData.zoom == nil or tonumber(itemData.zoom) == nil then return false, "Invalid zoom" end
    if itemData.color == nil or IsColor(itemData.color) == false then return false, "Invalid color" end
    if itemData.itemColorCode == nil then return false, "Missing property : itemColorCode" end
    if itemData.className == nil then return false, "Missing property : className" end
    if itemData.lua == nil then return false, "Missing property : Lua" end
    --Passed all the checks, create it and return true
    local itemID = BU3.Items.CreateItem(itemData)

    return true, itemID
end

--[[-------------------------------------------------------------------------
Networking stuff
---------------------------------------------------------------------------]]
util.AddNetworkString("BU3:CreateItem")
util.AddNetworkString("BU3:NetworkItem")
util.AddNetworkString("BU3:NetworkItemTable")
util.AddNetworkString("BU3:PromptUser")
util.AddNetworkString("BU3:DeleteRegisteredItem")
util.AddNetworkString("BU3:CLDeleteItem")

net.Receive("BU3:DeleteRegisteredItem", function(len, ply)
    --Athenticate the users
    if not table.HasValue(BU3.Config.AdminRanks, ply:GetUserGroup()) then return end
    local itemID = net.ReadInt(32)
    ply:ChatPrint("[UNBOXING WARNING!] PLEASE RESTART THE SERVER AFTER DELETING ITEMS OTHERWISE THIS COULD CAUSE SOME CONFLICTS!")
    BU3.Items.Items[itemID] = nil
    BU3.SQL.DeleteItem(itemID)
    net.Start("BU3:CLDeleteItem")
    net.WriteInt(itemID, 32)
    net.Broadcast()

    --Now loop over every case that has this item and remove it to prevent errors
    for k, v in pairs(BU3.Items.Items) do
        if v.items ~= nil then
            print("Found case!!!")

            if BU3.Items.Items[k].items[itemID] ~= nil then
                BU3.Items.Items[k].items[itemID] = nil
                net.Start("BU3:NetworkItem")
                net.WriteTable(BU3.Items.Items[k])
                net.Broadcast()
                BU3.SQL.SaveItem(v.itemID)
            end
        end
    end
end)

net.Receive("BU3:CreateItem", function(len, ply)
    if not table.HasValue(BU3.Config.AdminRanks, ply:GetUserGroup()) then return end
    local data = net.ReadTable()
    local itemID = data.itemID
    local worked, reasonOrID

    if data.type == "case" or data.type == "key" then
        worked, reasonOrID = BU3.Items.RegisterKeyCrate(data, true)

        if not worked then
            ply:ChatPrint("[UNBOXING 3] Failed to create case/key : '" .. reasonOrID .. "'")
        else
            print("Created the case! (" .. reasonOrID .. ")")
        end
    elseif data.type == "weapon" then
        worked, reasonOrID = BU3.Items.RegisterWeapon(data, true)

        if not worked then
            ply:ChatPrint("[UNBOXING 3] Failed to weapon : '" .. reasonOrID .. "'")
        else
            print("Created the weapon! (" .. reasonOrID .. ")")
        end
    elseif data.type == "entity" then
        worked, reasonOrID = BU3.Items.RegisterEntity(data, true)

        if not worked then
            ply:ChatPrint("[UNBOXING 3] Failed to entity : '" .. reasonOrID .. "'")
        else
            print("Created the entity! (" .. reasonOrID .. ")")
        end
    elseif data.type == "money" then
        worked, reasonOrID = BU3.Items.RegisterMoney(data, true)

        if not worked then
            ply:ChatPrint("[UNBOXING 3] Failed to money : '" .. reasonOrID .. "'")
        else
            print("Created the money! (" .. reasonOrID .. ")")
        end
    elseif data.type == "points1" or data.type == "points2" then
        worked, reasonOrID = BU3.Items.RegisterPoints(data, true)

        if not worked then
            ply:ChatPrint("[UNBOXING 3] Failed to points : '" .. reasonOrID .. "'")
        else
            print("Created the points! (" .. reasonOrID .. ")")
        end
    elseif data.type == "points1item" or data.type == "points2item" then
        worked, reasonOrID = BU3.Items.RegisterPSItem(data, true)

        if not worked then
            ply:ChatPrint("[UNBOXING 3] Failed to PS item : '" .. reasonOrID .. "'")
        else
            print("Created the PS item! (" .. reasonOrID .. ")")
        end
    elseif data.type == "lua" then
        worked, reasonOrID = BU3.Items.RegisterLuaItem(data, true)

        if not worked then
            ply:ChatPrint("[UNBOXING 3] Failed to register Lua item : '" .. reasonOrID .. "'")
        else
            print("Created the Lua item! (" .. reasonOrID .. ")")
        end
    elseif data.type == "accesory" then
        worked, reasonOrID = BU3.Items.RegisterAccesory(data, true)

        if not worked then
            ply:ChatPrint("[UNBOXING 3] Failed to Accesory item : '" .. reasonOrID .. "'")
        else
            print("Created the Accesory item! (" .. reasonOrID .. ")")
        end
    elseif data.type == "attachment" then
        worked, reasonOrID = BU3.Items.RegisterAttachment(data, true)

        if not worked then
            ply:ChatPrint("[UNBOXING 3] Failed to Accesory item : '" .. reasonOrID .. "'")
        else
            print("Created the Accesory item! (" .. reasonOrID .. ")")
        end
    elseif data.type == "credits" then
        worked, reasonOrID = BU3.Items.RegisterCredits(data, true)

        if not worked then
            ply:ChatPrint("[UNBOXING 3] Failed to Credits item : '" .. reasonOrID .. "'")
        else
            print("Created the Credits item! (" .. reasonOrID .. ")")
        end
    elseif data.type == "suit" then
        worked, reasonOrID = BU3.Items.RegisterEntity(data, true)

        if not worked then
            ply:ChatPrint("[UNBOXING 3] Failed to Suit item : '" .. reasonOrID .. "'")
        else
            print("Created the Suit item! (" .. reasonOrID .. ")")
        end
    end

    if worked ~= nil then
        if worked == true then
            if itemID ~= nil then
                net.Start("BU3:PromptUser")
                net.WriteString("Updated!")
                net.WriteString("The item has been updated (" .. itemID .. ")")
                net.WriteBool(false)
                net.Send(ply)
            else
                net.Start("BU3:PromptUser")
                net.WriteString("Item Created!")
                net.WriteString("The item has been created with ID " .. reasonOrID .. "!")
                net.WriteBool(true)
                net.Send(ply)
            end
        else
            net.Start("BU3:PromptUser")
            net.WriteString("Creation failed!")
            net.WriteString("Reason : " .. reasonOrID)
            net.WriteBool(false)
            net.Send(ply)
        end
    end
end)