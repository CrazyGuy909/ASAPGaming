--[[-------------------------------------------------------------------------
This file is used to calculate chances and generate a list of random items
---------------------------------------------------------------------------]]

BU3.Chances = BU3.Chances or {}

--Flush random seed
math.randomseed(os.time())
math.random()
math.random()

function generateItem(itemID)

	local totalChance = 0

	for k , v in pairs(BUC2.ITEMS[itemID].items) do
		
			v = BUC2.ITEMS[v]

			totalChance = totalChance + v.chance

	end

	local itemList = {}
		

	return item
 
end

local statfetcher = {}
--Generates a random case
function BU3.Chances.GenerateSingle(caseID, chan)
	--Get list of items from case
	if BU3.Items.Items[caseID] ~= nil and BU3.Items.Items[caseID].type == "case" then
		local case = BU3.Items.Items[caseID]
		local totalChance = 0
		for k ,v in pairs(case.items) do

			totalChance = totalChance + (isnumber(v) and v or v.chance)
		end

		if totalChance == 0 then
			return nil
		end
		local num = math.Rand(1 , totalChance)
		local prevCheck = 0

		for k ,v in pairs(case.items) do
			local chance = isnumber(v) and v or v.chance
			if num >= prevCheck and num <= prevCheck + chance then
				item = k
			end
			prevCheck = prevCheck + chance
		end

		local itemdata = BU3.Items.Items[item]
		if (itemdata.perm) then
			if ((chan or 6) > 0 and statfetcher[item]) then
				if (itemdata.name:StartWith("Tier")) then
					return item, isnumber(case.items[item]) and 1 or case.items[item].quantity or 0
				end
				local a, b = BU3.Chances.GenerateSingle(caseID, (chan or 6) - 1)
				return a, b
			end
			statfetcher[item] = true
		end
		--return the result
		return item, isnumber(case.items[item]) and 1 or case.items[item].quantity or 0
	end 
end

--Generates a random list of item ID's and returns them
--as a table
function BU3.Chances.GenerateList(caseID, amount)
	local items = {}

	for i = 1 , amount do
		items[i] = BU3.Chances.GenerateSingle(caseID)
	end

	return items
end