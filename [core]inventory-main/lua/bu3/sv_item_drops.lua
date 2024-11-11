timer.Create("bu3_item_drops", BU3.Config.DropTime * 60, 0, function()
    local rewards = math.ceil(player.GetCount() / 10)

    for k, v in RandomPairs(player.GetAll()) do
        if rewards <= 0 then return end
		

		if v:IsDonator(1) == true then
			local r = math.random(0, 100)
			if r <= 10 then
				local item = table.Random(BU3.Config.DropItems)
				if BU3.Items.Items[item] == nil then return end
				v:UB3AddItem(item, 1)
				rewards = rewards - 1
				v:ChatPrint("<rainbow=3>[UNBOXING]</rainbow> You received a random drop <color=green>'" .. BU3.Items.Items[item].name .. "'</color>!")
			end
		end
	end
end)

timer.Create("bu3_item_rare_drops", BU3.Config.RareDropTime * 60, 0, function()
    local rewards = math.ceil(player.GetCount() / 10)

    for k, v in RandomPairs(player.GetAll()) do
        if rewards <= 0 then return end
		

		if v:IsDonator(3) == true then
			local r = math.random(0, 100)
			if r <= 10 then
				local item = table.Random(BU3.Config.RareDropItems)
				if BU3.Items.Items[item] == nil then return end
				v:UB3AddItem(item, 1)
				rewards = rewards - 1
				v:ChatPrint("<rainbow=3>[UNBOXING]</rainbow> You received a rare random drop <color=green>'" .. BU3.Items.Items[item].name .. "'</color>!")
			end
		end
	end
end)