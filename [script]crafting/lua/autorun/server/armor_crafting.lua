util.AddNetworkString("Crafting.Start")

net.Receive("Crafting.Start", function(l, ply)
    local itemID = net.ReadInt(16)
    local kind = net.ReadString()
    local recipe = Armor.Crafting[kind][itemID]
    if not recipe then return end
    if (ply:getDarkRPVar("money", 0) < recipe["$"]) then return end

    for k, v in pairs(recipe) do
        if (k == "$") then continue end
        local item = ply._ub3inv[k]

        if not item then
            return
        elseif (item < v) then
            return
        end

        ply:UB3RemoveItem(k, v)
    end

    ply:addMoney(-recipe["$"])
    ply:UB3AddItem(itemID, 1)
end)