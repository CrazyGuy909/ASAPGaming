
local meta = FindMetaTable("Player")

function meta:InArena()
    return self:GetNWBool("InArena", false)
end

function meta:GetArenaXP()
    return self._arenaXP or 0
end

function meta:GetArenaFrags()
    return self:Frags()
end

function meta:GetArenaDeaths()
    return self:Deaths()
end

function meta:GetArenaScore()
    return self._arenaScore or 0
end

function meta:GetArenaLevel()
    return self._arenaLevel or 1
end

function meta:GetStats()
    if true then return end
    if CLIENT then
        if (!asapArena.Stats && !asapArena.statsRequested) then
            asapArena.statsRequested = true
            asapArena.Stats = {}
            net.Start("ASAP.Arena.RequestStats")
            net.SendToServer()
        end
        return asapArena.Stats
    else
        return self.arenaStats or {}
    end
end

function asapArena:GetState()
    return GetGlobalInt("Arena.State", 0)
end

function asapArena:SetState(x)
    SetGlobalInt("Arena.State", x)
end