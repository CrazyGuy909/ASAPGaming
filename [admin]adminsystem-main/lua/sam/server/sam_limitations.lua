hook.Add("Initialize", "SAM.LimitInit", function()
    -- Is the gamemode currently being used Sandbox derived?
    if (GAMEMODE.IsSandboxDerived) then
        -- Weapon Limiter
        hook.Add("PlayerSpawnSWEP", "SAM.Limiter-Weapon", function(ply, class, info)
        	if (SAM.GetRankTable(ply:GetUserGroup()).limitations.canSpawnWeps != true) then
        		return false
        	end
            return true
        end)
        -- Prop Limiter
        hook.Add("PlayerSpawnProp", "SAM.Limiter-Prop", function(ply, v)
            local limit = SAM.Default_Config.DonatorLimits[ply:GetDonatorByRoleName()] or SAM.Default_Config.DefaultPropLimit
            if (ply:GetCount("props") >= limit) then
                SAM.ShootError(ply, "You have reached your PROP limit of: "..limit)
                return false
            end
        end)
        -- Entity Limiter
        /*
        hook.Add("PlayerSpawnSENT", "SAM.Limiter-SENT", function(ply, v)
            local limit = SAM.GetRankTable(ply:GetUserGroup()).limitations.entities
            if (ply:GetCount("sents") >= limit) then
                SAM.ShootError(ply, "You have reached your SENT limit of: "..limit)
                return false
            end
            return true
        end)
        */
        -- NPC Limiter
        hook.Add("PlayerSpawnNPC", "SAM.Limiter-NPC", function(ply, v)
            local limit = SAM.GetRankTable(ply:GetUserGroup()).limitations.npcs
            if (ply:GetCount("npcs") >= limit) then
                SAM.ShootError(ply, "You have reached your NPC limit of: "..limit)
                return false
            end
            return true
        end)
        -- Vehicle Limiter
        hook.Add("PlayerSpawnVehicle", "SAM.Limiter-Vehicle", function(ply, v)
            local limit = SAM.GetRankTable(ply:GetUserGroup()).limitations.vehicles
            if (ply:GetCount("vehicles") >= limit) then
                SAM.ShootError(ply, "You have reached your VEHICLE limit of: "..limit)
                return false
            end
            return true
        end)
        -- Ragdoll Limiter
        hook.Add("PlayerSpawnRagdoll", "SAM.Limiter-Ragdoll", function(ply, v)
            local limit = SAM.GetRankTable(ply:GetUserGroup()).limitations.ragdolls
            if (ply:GetCount("ragdolls") >= limit) then
                SAM.ShootError(ply, "You have reached your RAGDOLL limit of: "..limit)
                return false
            end
            return true
        end)
    end

    print("SAM >> Sandbox Limitations Enabled")
end)