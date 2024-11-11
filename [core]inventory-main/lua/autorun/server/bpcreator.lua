local basicRewards = {
    [1] = {717, 1164, 1238, 346, 653, 595, 388, 636, 588, 538, 579, 214, 303, 584, 650, 325, 211, 1097, 543, 408, 272, 241, 590, 1253, 405, 1248, 299, 210, 1234, 593},
    [2] = {618, 488, 344, 269, 690, 307, 519, 268, 379, 219, 273, 301, 169, 275, 1063, 503, 585, 657, 1100, 1079, 208, 583, 1260, 324, 620, 1078, 1102, 1259, 608, 378},
}
local bestFive = {
    [1] = {185, 311, 550, 1071, 1070, 1133, 1220, 1127, 162, 450, 153, 1131, 274, 339, 554, 625, 37, 385},
    [2] = {189, 1096, 263, 630, 1239, 264, 199, 882, 262, 705, 323, 222, 1251, 1268, 166, 182, 296, 267, 243, 320, 707, 191, 615, 599, 192},
}
local bestTens = {
    [1] = {375, 1263, 342, 415, 377, 436, 661, 947, 617, 706, 412, 448, 1093, 444, 1274, 702, 504, 613, 371, 424},
    [2] = {400, 248, 1232, 1241, 259, 1182, 290, 1261, 433, 704, 213, 316, 867, 445, 425, 437, 600, 602, 629, 292},
}
local bestTwentyFives = {
    [1] = {1198, 239, 220, 505, 338, 926, 1233, 393},
    [2] = {1092, 1080, 318, 1123, 704, 235, 433, 441},
}
local bestFifties = {
    [1] = {1227, 1212, 1213, 1194},
    [2] = {1228, 1230, 1231, 1232},
}

local finals = {
    [1] = {
        1188, 1054, 642, 293, 1183, 524, 1173, 1224, 1068, 1247, 856
    },
    [2] = {
        1218, 452, 1182, 660, 1217, 260, 1191, 1225, 1068, 1250, 855
    },
}

local suits = {
    [1] = {
        1227, 1230, 1063, 1112, 559
    },
    [2] = {
        1228, 1232, 566, 356, 1212
    },
    [3] = {
        1229, 1231, 1154, 1113, 1142
    },
    [4] = {
        1145, 1106, 1144, 1195, 1154
    }
}

local accessories = {
    414, 418, 436, 447, 426, 444, 435,
    439, 438, 429, 445, 446, 420, 605,
    431, 440, 608, 606, 433, 428, 448,
    422, 423, 416, 603, 424, 475, 434,
    432, 427, 449
}

local cases = {
    [1] = {1130, 162, 143, 1220},
    [2] = {185, 294, 1072, 274},
    [3] = {311, 554, 1127, 1132}
} 


local tierAmount = 200
local code = [[
BATTLEPASS:AddPass("battlepass_10", {
        name = "Battle Pass 2 Remastered",
        ends = "Wup wup wup",
        rewards = {
            free = {
                ]]

local function selectItem(i, premium)
    local isFive = i % 5 == 0
    local isTen = i % 10 == 0
    local isTwentyFive = i % 25 == 0
    local isFifty = i % 50 == 0
    local isFinal = i > tierAmount - 10

    if isFinal then
        return finals[premium and 2 or 1][i - (tierAmount - 10)]
    end

    if isFifty then
        return bestFifties[premium and 2 or 1][math.random(1, #bestFifties[premium and 2 or 1])]
    end 

    if isTwentyFive then
        return bestTwentyFives[premium and 2 or 1][math.random(1, #bestTwentyFives[premium and 2 or 1])]
    end

    if isTen then
        return bestTens[premium and 2 or 1][math.random(1, #bestTens[premium and 2 or 1])]
    end

    if isFive then
        return bestFive[premium and 2 or 1][math.random(1, #bestFive[premium and 2 or 1])]
    end

    return basicRewards[premium and 2 or 1][math.random(1, #basicRewards[premium and 2 or 1])], true
end

local milestones = {
    [false] = {
        [20] = 1128,
        [25] = 1188, --250 credits
        [35] = 1227,
        [50] = 1188,
        [75] = 1188,
        [90] = 1232, --Sunset suit
        [100] = 1188,
        [115] = 1227,
        [125] = 1188,
        [140] = 1109, --Magnum
        [150] = 1188,
        [175] = 1188,
    },
    [true] = {
        [20] = 1227,
        [30] = 1109, --Magnum
        [40] = 1230, --Neon suit
        [75] = 1270, --Ancient crate
        [95] = 1228,
        [115] = 1128,
        [130] = 1231, --Redsun suit
        [150] = 1270,
        [165] = 1228,
    }
}

function generateBattlepass()

    local food = {
        suits = table.Copy(suits),
        accessories = table.Copy(accessories),
        cases = table.Copy(cases)
    }

    local temp = {
        [false] = {},
        [true] = {}
    }

    local level = 1000
    for type, items in pairs(food) do
        level = 1000

        if (type == "suits") then
            local played = 0
            for i = 1, table.Count(items) do
                local y = 0
                for k, v in RandomPairs(items[i]) do
                    y = y + 1
                    local index = (i - 1) * 50 + y * 8
                    temp[true][index + 1] = v
                    played = played + 1
                    if (i == 4) then continue end
                    temp[false][index + 6] = v
                end
            end
        end

        if (level <= 0) then
            print("Failed to fill suits")
        end
        level = 1000
        
        if (type == "cases") then
            local played = 0
            for i = 1, table.Count(items) do
                local y = 0
                for k, v in RandomPairs(items[i]) do
                    y = y + 1
                    local index = (i - 1) * 55 + y * 20
                    temp[true][index - 18] = v
                    played = played + 1
                    if (i == 4) then continue end
                    temp[false][index - 9] = v
                end
            end
        end
        
        if (level <= 0) then
            print("Failed to fill suits")
        end
        level = 1000

        if (type == "accessories") then
            local i = 1
            local played = 0
            for k, v in RandomPairs(items) do
                local index = (i - 1) * 6 + 2
                local target = math.random(1, 2) == 1
                if temp[target][index] then continue end
                temp[target][index] = v
                played = played + 1
                i = i + 1
            end
        end
    end

    local procesed = {}
    
    for _, target in pairs({true, false}) do
        level = 1000
        local magnums = 0
        local utility = 0
        for k = 1, tierAmount do
            if (milestones[target][k]) then
                temp[target][k] = milestones[target][k]
                continue
            end
            if (temp[target][k]) then continue end
            local new, random = selectItem(k, target)
            while (procesed[new] and not random and level > 0) do
                level = level - 1
                if (level <= 0) then
                    MsgN(k)
                end
                new = selectItem(k, target)
            end
            if random then
                procesed[new] = target
                if ((k + (target and 6 or 12)) % 24 == 0) then
                    new = ({293, 292, 293, 292})[(magnums % 4) + 1]
                    //MsgN("added magnum into ", target, " at ", k)
                    magnums = magnums + 1
                end

                if ((k + (target and 6 or 12) - 12) % 24 == 0) then
                    new = ({615, 1191, 1173, 1092})[(utility % 4) + 1]
                    //MsgN("added utility into ", target, " at ", k)
                    utility = utility + 1
                end
            end
            temp[target][k] = new
        end

        if (level <= 0) then
            print("Failed to fill extra")
        end
    end

    for k = 1, tierAmount do
        if not temp[false][k] then
            return
        end
        code = code .. "[" .. k .. "] = {BATTLEPASS:CreateItem(" .. temp[false][k] .. ")},\n\t\t\t"
    end
    code = code .. "\r\t\t}, premium = {\n\t\t\t"
    for k = 1, tierAmount do
        code = code .. "[" .. k .. "] = {BATTLEPASS:CreateItem(" .. temp[true][k] .. ")},\n\t\t\t"
    end
    code = code .. "\r\t\t}\n},\n\t\ttiers = " .. tierAmount .. ",\n\t\tchallenges = BATTLEPASS.ChallengesTable\n\t}\n)"
    file.Write("battlepass_10.txt", code)

end

concommand.Add("bp_update", function()
    hook.Run("BU3.ItemsLoaded")
    BroadcastLua("hook.Run('BU3.ItemsLoaded')")
end)

concommand.Add("bp_showitems", function(ply, cmd, args)
    if IsValid(ply) then return end
    local category = args[1]
    local rarity = tonumber(args[2]) or nil
    local amount = tonumber(args[3]) or 1
    MsgN("Category: " .. category, "\nRarity: " .. (rarity or "NONE"), "\nAmount: " .. amount)
    local result = {}
    local selected = {}
    for k, v in RandomPairs(BU3.Items.Items) do
        if amount <= 0 then break end
        if category and v.type == category then
            if (v.name:find("|", 1, true)) then
                continue
            end
            if rarity and v.itemColorCode != rarity then
                MsgN("No rarity")
                continue
            end
            if table.HasValue(result, v.itemID) then
                continue
            end
            selected[v.name] = v.itemID
            table.insert(result, v.itemID)
            amount = amount - 1
            continue
        end

        if rarity and v.itemColorCode == rarity then
            if table.HasValue(result, v.itemID) then
                continue
            end
            selected[v.name] = v.itemID
            table.insert(result, v.itemID)
            amount = amount - 1
            continue
        end
    end
    
    PrintTable(selected)
    local text = table.concat(result, ", ")
    MsgN(text)
end)

concommand.Add("bp_helper", function(ply)
    if IsValid(ply) then return end
    generateBattlepass()
end)
