local GM = {}
GM.Name = "Base Gamemode"
GM.BaseStruct = "This is baseGamemode"
GM.CanRespawn = true
GM.NoVote = true
function GM:PlayerSpawn(ply)
    timer.Simple(0, function()
        self:SelectSpawn(ply)
        self:Loadout(ply)
    end)
end

CreateConVar("arena_fav_spawn", "A", {FCVAR_ARCHIVE, FCVAR_USERINFO}, "Favorite spawn (A to F)")

function GM:SelectSpawn(ply)
    if (not ply:InArena()) then return end
    if (ply.armorSuit) then
        ply:SetNWBool("InArena", false)
        asapArena:Run("PlayerLeave", nil, ply)
        ply:LeaveArena()
        asapArena:SavePlayer(ply)
        ply:SetTeam(TEAM_CITIZEN)
        local spawn = hook.Run("PlayerSelectSpawn", ply)
        ply:SetPos(spawn:GetPos())
		if ply and IsValid(ply) then
			ply:SetHealth(100)
			ply:SetArmor(0)
		end
        return
    end

    if (self.AutoSpawn) then
        local ranSpawn = table.Random(asapArena.SpawnPoints[self.AutoSpawn].spawns)
		if ply and IsValid(ply) then
			ply:SetHealth(100)
			ply:SetArmor(0)
		end
        ply:SetPos(ranSpawn - Vector(0, 0, 48))
        return
    end

    local favSpawn = string.byte(string.upper(ply:GetInfo("arena_fav_spawn")))
    if (not favSpawn or favSpawn < 65 or favSpawn > 70) then
        favSpawn = math.random(65, 70)
    end

    local ranSpawn = table.Random(asapArena.SpawnPoints[string.char(favSpawn)].spawns)
	if ply and IsValid(ply) then
			ply:SetHealth(100)
			ply:SetArmor(0)
	end
    ply:SetPos(ranSpawn - Vector(0, 0, 48))
end

local function equipArenaWeapon(wep, ply)
    if not ply._arenaData then return end
    for k, v in pairs(((ply._arenaData.Attachments or {})[wep] or {}).equipped or {}) do
        local sWep = ply:GetWeapon(wep)
        timer.Simple(.1, function()
            if IsValid(sWep) then
                if (sWep.InitAttachments and (not sWep.AttachmentCache or not sWep.AttachmentCache[v])) then
                    sWep:InitAttachments()
                end

                sWep:Attach(v)
            end
        end)
    end
end

function GM:Loadout(ply)
    if (not ply._arenaEquipment) then return end

    timer.Simple(1, function()
        asapArena:SetPlayerModel(ply)
    end)

    ply:StripWeapons()

    if (ply._arenaEquipment["Primary"]) then
        local wep = ply:Give(ply._arenaEquipment["Primary"])
        if (wep) then
            ply:SetAmmo(1000, wep:GetPrimaryAmmoType())
            equipArenaWeapon(ply._arenaEquipment["Primary"], ply)
        end
    end

    if (ply._arenaEquipment["Secondary"]) then
        local wep = ply:Give(ply._arenaEquipment["Secondary"])
        if (not wep) then return end
        if (wep.GetMaxClip1) then
            ply:SetAmmo(1000, wep:GetPrimaryAmmoType())
        end
        equipArenaWeapon(ply._arenaEquipment["Secondary"], ply)
    end

    if (ply._arenaEquipment["Melee"]) then
        ply:Give(ply._arenaEquipment["Melee"])
    end

    if (ply._arenaEquipment["Misc"]) then
        ply:Give(ply._arenaEquipment["Misc"])
    end
end

function GM:HUDPaint()
end

function GM:Init()
end

function GM:CanPlayerRespawn(ply)
    return true
end

function GM:PlayerJoin(ply)
end

function GM:PlayerLeave(ply)
end

function GM:PlayerDeath(ply, att)
end

function GM:Think()
end

function GM:EntityTakeDamage()
end

asapArena:AddGamemode("base", GM)