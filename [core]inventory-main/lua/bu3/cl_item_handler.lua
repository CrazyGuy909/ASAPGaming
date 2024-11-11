BU3.Items = BU3.Items or {}
SKIN = {}
SKIN.PrintName = "Unbox sim"
SKIN.Author = "Gonzo"
SKIN.DermaVersion = 1
SKIN.GwenTexture = Material("asap/borders")
SKIN.Red = GWEN.CreateTextureBorder(0, 1, 150, 165, 16, 16, 16, 16)
SKIN.Yellow = GWEN.CreateTextureBorder(150, 1, 150, 165, 16, 16, 16, 16)
SKIN.Purple = GWEN.CreateTextureBorder(300, 1, 150, 165, 16, 16, 16, 16)
SKIN.Pink = GWEN.CreateTextureBorder(450, 1, 150, 165, 16, 16, 16, 16)
SKIN.Blue = GWEN.CreateTextureBorder(600, 1, 150, 165, 16, 16, 16, 16)
SKIN.Gray = GWEN.CreateTextureBorder(750, 1, 150, 165, 16, 16, 16, 16)
local gray = GWEN.CreateTextureBorder(750, 1, 150, 165, 16, 16, 16, 16)
local glow = Material("sprites/mat_jack_basicglow")
local move = Material("effects/sleepersimeffects")
local clr = Color(178, 224, 230)
local clrfire = Color(207, 59, 40)
local clrfire2 = Color(207, 154, 40)
SKIN.Diamond = function(x, y, w, h)
    gray(x, y, w, h, ColorAlpha(clr, 120 + math.sin(CurTime() * 8) * 10))
    surface.SetDrawColor(clr)
    local offset = RealTime() % 1
    surface.SetMaterial(glow)
    surface.DrawTexturedRectUV(x - w, y, w * 3, h * 8, 0, offset, 1, offset + 1)
    surface.SetMaterial(move)
    surface.SetDrawColor(clr)
    surface.DrawTexturedRect(x, y, w, h)
end

local green = Color(0, 255, 0)
SKIN.Green = function(x, y, w, h)
    gray(x, y, w, h, green)
end

SKIN.Diamond = function(x, y, w, h)
    gray(x, y, w, h, ColorAlpha(clr, 120 + math.sin(CurTime() * 8) * 10))
    surface.SetDrawColor(clr)
    local offset = RealTime() % 1
    surface.SetMaterial(glow)
    surface.DrawTexturedRectUV(x - w, y, w * 3, h * 8, 0, offset, 1, offset + 1)
    surface.SetMaterial(move)
    surface.SetDrawColor(clr)
    surface.DrawTexturedRect(x, y, w, h)
end

local fireMat = Material("sprites/fragnade_exp")
SKIN.Fire = function(x, y, w, h)
    gray(x, y, w, h, ColorAlpha(clrfire, 120 + math.sin(CurTime() * 8) * 10))
    surface.SetDrawColor(clrfire2)
    local offset = RealTime() % 1
    surface.SetMaterial(glow)
    surface.DrawTexturedRectUV(x - w, y, w * 3, h * 8, 0, offset, 1, offset + 1)
    surface.SetMaterial(fireMat)
    surface.SetDrawColor(ColorAlpha(clrfire, 10))
    surface.DrawTexturedRect(x, y, w, h)
end

local rainbowMat = Material("sprites/cartfrag_exp")
SKIN.Rainbow = function(x, y, w, h)
    local rain = HSVToColor(CurTime() % 6 * 175, 1, 1)
    gray(x, y, w, h, ColorAlpha(rain, 120 + math.sin(CurTime() * 8) * 10))
    surface.SetDrawColor(rain)
    local offset = RealTime() % 1
    surface.SetMaterial(glow)
    surface.DrawTexturedRectUV(x - w, y, w * 3, h * 8, 0, offset, 1, offset + 1)
    surface.SetMaterial(rainbowMat)
    surface.SetDrawColor(ColorAlpha(rain, 10))
    surface.DrawTexturedRect(x, y, w, h)
end

local nextGlitch = 0
local glitchColor = Color(255, 255, 255)
local dir = 0
local speed = 33
local glitchMat = Material("sprites/trinity_stun_particles")
local glitch = Material("sprites/muzzle_star")

SKIN.Glitched = function(x, y, w, h)
    if (nextGlitch < CurTime()) then
        nextGlitch = CurTime() + math.Rand(.3, 1.2)
        glitchColor = HSVToColor(math.random(0, 360), math.Rand(.3, 1), math.Rand(.3, 1))
        dir = math.Rand(0, math.pi * 2)
        speed = math.Rand(-2, 8)
    end
    local extra = dir / math.pi
    local ox = ((RealTime() * speed) % 1) * math.cos(dir)
    local oy = ((RealTime() * speed) % 1) * math.sin(dir)
    local offset = RealTime() % 1
    gray(x, y + extra, w * extra, h - extra, ColorAlpha(glitchColor, 200 + math.sin(CurTime() * 8) * 10))
    surface.SetDrawColor(glitchColor)
    surface.SetMaterial(glow)
    surface.DrawTexturedRectUV(x - w, y, w * 3 * extra, h * 8 * extra, ox, ox, oy + 1, oy + 1)
    surface.SetMaterial(glitchMat)
    surface.SetDrawColor(ColorAlpha(glitchColor, 10))
    surface.DrawTexturedRectRotated(x + w / 2, y + h / 2, w, h, 0)

    surface.SetMaterial(glitch)
    surface.SetDrawColor(color_white)
    surface.DrawTexturedRectUV(x - w, y, w * 3, h * 8, 0, -offset, 1, 1 + offset)
end
derma.DefineSkin("Unbox System", "Unbox System skin", SKIN)
--A table of all the items, indexed via ID
BU3.Items.Items = {}


BU3.Items.RarityToFrame = {
    [1] = SKIN.Gray,
    [2] = SKIN.Blue,
    [3] = SKIN.Purple,
    [4] = SKIN.Pink,
    [5] = SKIN.Red,
    [6] = SKIN.Yellow,
    [7] = SKIN.Diamond,
    [8] = SKIN.Fire,
    [9] = SKIN.Rainbow,
    [10] = SKIN.Glitched,
    [11] = SKIN.Green,
}

BU3.Items.RarityToColor = {
    [1] = Color(169, 169, 169, 255), --Gray
    [2] = Color(0, 191, 255, 255), --Light blue
    [3] = Color(128, 0, 128, 255), --Purple
    [4] = Color(255, 0, 255, 255), --Pink
    [5] = Color(255, 0, 0, 255), --Red
    [6] = Color(255, 215, 0, 255), --Gold!
    [7] = Color(223, 223, 223), --Diamond!
    [8] = Color(255, 102, 0), --Fire!
    [9] = Color(0, 255, 221), --Rainbow!
    [10] = Color(5, 141, 0), --Glitched!
    [11] = Color(5, 255, 0), --Glitched!
    
}

BU3.Items.StringToRarity = {
    Gray = 1,
    Blue = 2,
    Purple = 3,
    Pink = 4,
    Red = 5,
    Gold = 6,
    Diamond = 7,
    Fire = 8,
    Rainbow = 9,
    Glitched = 10,
    Green = 11,
}

BU3.Items.RarityToString = {
    [1] = "Gray",
    [2] = "Blue",
    [3] = "Purple",
    [4] = "Pink",
    [5] = "Red",
    [6] = "Gold",
    [7] = "Diamond",
    [8] = "Fire",
    [9] = "Rainbow",
    [10] = "Glitched",
    [11] = "Green",
}

--All the types of items there can be
BU3.Items.Types = {
    customLua = 1, --The item runs custom lua
    weapon = 2, --The item is a weapon
    money = 3, --The item is money
    points1 = 4, --The item is points (pointshop1)
    points2 = 5, --The item is points (pointshop2)
    points2pre = 6, --The item is points (pointshop2 premium)
    points1item = 7, --The item is an item for pointshop1
    points2item = 8, --The item is a pointshop2 item
    entity = 9, --The item is a basic entity
    accesory = 10,
    credits = 11, --The item is money
	hitmarker = 12,
	vox = 13,
}

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
    return self.description
end

function ITEM:GetID()
    return self.id
end

function ITEM:GetSuggestedValue()
    return self.suggestedValue
end

function ITEM:GetMarketHistory()
    return self.marketHistory
end

function ITEM:GetItemType()
    return self.itemType
end

function ITEM:GetAveragePrice()
    return self.averagePrice
end

function ITEM:GetOnPress()
    return self.onPress
end

function ITEM:GetOnUnbox()
    return self.onUnbox
end

function ITEM:GetMarketListings()
    return self.market
end

function ITEM:GetPerma()
    return self.perma
end

--Registers an item in the item table
function BU3.Items.RegisterItem(itemID, itemData)
    local item = setmetatable(itemData, ITEMMetaAccessor)
    BU3.Items.Items[itemID] = item
end

--Tries to find an item based on its ID, if it fails it returns false
function BU3.Items.GetItemByID(itemID)
    if BU3.Items.Items[itemID] ~= nil then
        return BU3.Items.Items[itemID]
    else
        return false
    end
end

--Returns all items that can be bought
function BU3.Items.GetBuyableItems()
    local buyableItems = {}

    for k, v in pairs(BU3.Items.Items) do
        if v.canBeBought then
            table.insert(buyableItems, v)
        end
    end

    return buyableItems
end

--[[-------------------------------------------------------------------------
Networking stuff
---------------------------------------------------------------------------]]
net.Receive("BU3:NetworkItem", function()
    local item = net.ReadTable()
    BU3.Items.RegisterItem(item.itemID, item)
end)

net.Receive("BU3:CLDeleteItem", function()
    local itemID = net.ReadInt(32)
    BU3.Items.Items[itemID] = nil
end)

hook.Add("InitPostEntity", "BU3.NetworkItems", function()
    RunConsoleCommand("bu3_fetchitems")
end)

net.Receive("BU3:NetworkItemTable", function()
    local dataLen = net.ReadDouble()
    local rawData = net.ReadData(dataLen)
    local uncompressedData = util.Decompress(rawData)
    local rawTables = util.JSONToTable(uncompressedData)

    for k, v in pairs(rawTables) do
        v.color = Color(v.color.r, v.color.g, v.color.b, v.color.a)
        BU3.Items.RegisterItem(v.itemID, v)
    end
end)

concommand.Add("bu3_fetchitems", function()
    MsgC(Color(0, 255, 0), "[INV]", color_white, "Requesting items\n")
    http.Fetch(asapMarket.API .. "/items", function(data)
        MsgC(Color(0, 255, 0), "[INV]", color_white, "Items Downloaded!\n")
        local rawTables = util.JSONToTable(data)

        if not istable(rawTables) then
            rawTables = util.JSONToTable(file.Read("itemdata.json", "DATA") or "[]")
            if not istable(rawTables) then
                MsgN("[INV] Failed again to load items :/")
                return
            end
        end

        for k, v in pairs(rawTables or {}) do
            v.color = Color(v.color.r, v.color.g, v.color.b, v.color.a)
            BU3.Items.RegisterItem(v.itemID, v)
        end

        hook.Run("BU3.ItemsLoaded")

        if !BU3.UI._MENU_OPEN then return end
            --Check if the page is inventory
        if IsValid(BU3.UI.ContentFrame) and BU3.UI.ContentFrame.loadedPageName == "inventory" then
            BU3.UI.ContentFrame:LoadPage("inventory") --Reload it
        end
    end, function(err)
        MsgC(Color(255, 0, 0), "[INV]", color_white, "Failed to request items: ", err, "\n", asapMarket.API .. "/items\n")

        MsgN("Failed to fetch items: " .. err)
    end)
end)