hook.Add('playerBoughtShipment', "asap_EntityLimits", function(pPlayer, tbl, ent, price)

    if (pPlayer.shipmentCount and pPlayer.shipmentCount >= 5) then
        DarkRP.notify(pPlayer, 1, 5, "You have hit the shipment limit (5)")
        return
    end
    
    if (pPlayer.shipmentCount) then
        pPlayer.shipmentCount = pPlayer.shipmentCount + 1
        print(pPlayer.shipmentCount)
    else
        pPlayer.shipmentCount = 1
        print(pPlayer.shipmentCount)
    end


end)

hook.Add("EntityRemoved", "asap_EntityLimits", function(ent)
    if (ent and ent:GetClass() == "spawned_shipment") then
        local pPlayer = ent:Getowning_ent()

        if (pPlayer and IsValid(pPlayer)) then
            
            if (pPlayer.shipmentCount) then

                pPlayer.shipmentCount = pPlayer.shipmentCount - 1

                print(pPlayer.shipmentCount)
            end

        end

    end

end)

hook.Add("canBuyShipment", "asap_EntityLimitsCanBuy", function(pPlayer, tbl)
    if (pPlayer.shipmentCount and pPlayer.shipmentCount >= 5) then
        return false, false, "You have hit the shipment limit. You cannot buy another."
    end
end)