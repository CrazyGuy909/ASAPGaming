asapArena.Gamemodes = asapArena.Gamemodes or {}
asapArena.BaseGamemode = asapArena.BaseGamemode or {}
asapArena.ActiveGamemode = asapArena.ActiveGamemode or nil

function asapArena:AddGamemode(id, data)
    data.id = id
    self.Gamemodes[id] = data
end

local bannedModes = {
    gungame = true,
    raregungame = true,
    suits = true
}

hook.Add("CanPlayerJoinArena", "Arena.Time", function(ply)
    local id = asapArena.ActiveGamemode.id
    local isSpecial = (id == "deathmatch" and 6 or 15)

	return true
end)

function asapArena:SetGamemode(id, arg)
    --id = 'deathmatch'
    if SERVER then
        SetGlobalString("ActiveGamemode", id)
        net.Start("ASAP.Arena.SetGamemode")
        net.WriteString(id)
        net.Broadcast()
        if (self.DispatchDuels) then
            --self:DispatchDuels()
        end
    end

    if (self.ActiveGamemode and self.ActiveGamemode.OnRemove) then
        self.ActiveGamemode:OnRemove()
    end

    local gamemode = self.Gamemodes[id]
    self.ActiveGamemode = gamemode

    --if (self._gameID == id) then return end
    for k, v in pairs(self.Players or {}) do
        if (not IsValid(k)) then
            self.Players[k] = nil
            continue
        end

        if (not k:InArena()) then continue end

        local canJoin = hook.Run("CanPlayerJoinArena", k)

        if (canJoin == false) then
            k:LeaveArena()
            continue
        end

        if (bannedModes[id] and self.BanList[k:SteamID()] and self.BanList[k:SteamID()][id] and self.BanList[k:SteamID()][id] > 0) then
            k:LeaveArena()
        end
    end

    timer.Remove("Arena.DeathMatch")
    self:Run("Init", id, arg)
    self._gameID = id
end

function asapArena:_initModes(id)
    if (id) then
        local v = self.Gamemodes[id]

        if (not v) then
            MsgN("Invalid gamemode base ", id)

            return
        end

        if (v.Base and not v.Rebased) then
            local base = self:_initModes(v.Base)
            table.Inherit(v, base)
            v.Rebased = true

            return v
        else
            return v
        end
    end

    for k, v in pairs(self.Gamemodes) do
        if (v.Base) then
            local base = self:_initModes(v.Base)

            if (base) then
                table.Inherit(v, base)
            end
        end
    end
end

local _, folders = file.Find("arena/*", "LUA")

for k, v in pairs(folders) do
    AddCSLuaFile("arena/" .. v .. "/" .. v .. ".lua")
    include("arena/" .. v .. "/" .. v .. ".lua")
end

asapArena:_initModes()

if SERVER then
    asapArena:SetGamemode(GetGlobalString("ActiveGamemode", "deathmatch"))
end