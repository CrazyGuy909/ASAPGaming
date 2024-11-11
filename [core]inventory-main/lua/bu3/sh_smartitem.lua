function BU3:FetchItem(id)
    local isArmor = string.StartWith(id, "armor_")
    local meta = {
        canBeBought = false,
        canBeSold = false,
        className = id,
        color = color_white,
        iconIsModel = true,
        itemID = -1,
        itemColorName = 3,
        isSpecial = true,
        perm = false,
        price = 0,
        rankRestricted = false,
        type = "weapon"
    }
    local found = false
    if (not isArmor and weapons.Get(id)) then
        local weaponData = weapons.Get(id)
        meta.iconID = weaponData.WorldModel
        meta.name = weaponData.PrintName
        meta.desc = weaponData.PrintName
        meta.zoom = 0.45
        found = true
    else
        for k, v in pairs(Armor.Data) do
            if (v.Entitie == id) then
                meta.name = v.Name
                meta.iconID = v.Model
                meta.type = "suit"
                meta.desc = v.Name
                meta.zoom = 0.3
                found = true
                break
            end
        end
    end
    if (found) then
        return meta
    end
end