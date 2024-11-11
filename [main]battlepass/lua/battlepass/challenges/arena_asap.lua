local CHALLENGE1 = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE1:SetName("GIB ME ROYAL CRATE!")
CHALLENGE1:SetIcon("battlepass/tiers.png") -- <- ??
CHALLENGE1:SetDesc("")
CHALLENGE1:SetProgressDesc("Get :goal kills in royal crate event")
CHALLENGE1:SetFinishedDesc("You got :goal kills in royal crate event")
CHALLENGE1:SetID("royal_crate")

CHALLENGE1:AddHook("PlayerDeath", function(self, owner, ply, _, att)
    if (owner ~= att) then return end

    if (ply:InArena() and att:InArena() and ply ~= att and asapArena.ActiveGamemode.id == "gungame") then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE1)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("John Wick")
CHALLENGE:SetIcon("battlepass/tiers.png") -- <- ??
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Get :goal kills in arena")
CHALLENGE:SetFinishedDesc("You got :goal kills in arena")
CHALLENGE:SetID("john_wick")

CHALLENGE:AddHook("PlayerDeath", function(self, owner, ply, _, att)
    if (owner ~= att) then return end

    if (ply:InArena() and att:InArena() and ply ~= att) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)
local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Stabby Stabby")
CHALLENGE:SetIcon("battlepass/tiers.png") -- <- ??
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Get :goal melee kills in arena")
CHALLENGE:SetFinishedDesc("You got :goal melee kills in arena")
CHALLENGE:SetID("stabby_stabby")

CHALLENGE:AddHook("PlayerDeath", function(self, owner, ply, _, att)
    if (owner ~= att) then return end

    if (not melee_initialized) then
        melee_initialized = true
        melee_weapons = {
            ["csgo_default_t_golden"] = true
        }

        for k, v in pairs(asapArena.weaponList.melee) do
            local class = string.Explode(" ", v, false)[1]
            melee_weapons[class] = true
        end

        for k, v in pairs(asapArena.Gamemodes.melee.Weapons) do
            melee_weapons[v] = true
        end
    end

    if (ply:InArena() and att:InArena() and ply ~= att and IsValid(att:GetActiveWeapon()) and melee_weapons[att:GetActiveWeapon():GetClass()]) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)
local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("XP Farmer")
CHALLENGE:SetIcon("battlepass/tiers.png") -- <- ??
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Level up :goal times in arena")
CHALLENGE:SetFinishedDesc("You level up :goal times in arena!")
CHALLENGE:SetID("xp_farmer")

CHALLENGE:AddHook("OnArenaLevelUp", function(self, ply, lvl)
    self:AddProgress(1)
    self:NetworkProgress()
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)
local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("That’s a lot of damage")
CHALLENGE:SetIcon("battlepass/tiers.png") -- <- ??
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Deal :goal damage in arena")
CHALLENGE:SetFinishedDesc("You got :goal killstreaks in arena")
CHALLENGE:SetID("damage_dealer")

CHALLENGE:AddHook("EntityTakeDamage", function(self, owner, ply, dmg)
    if not (IsValid(dmg:GetAttacker()) and dmg:GetAttacker():IsPlayer() and dmg:GetAttacker():InArena()) then return end
    if (owner ~= dmg:GetAttacker()) then return end
    if (not ply:IsPlayer()) then return end
    local att = dmg:GetAttacker()

    if (ply:InArena() and att:InArena() and ply ~= att) then
        self:AddProgress(math.Round(dmg:GetDamage()))
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)
local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Not your crate!!!")
CHALLENGE:SetIcon("battlepass/tiers.png") -- <- ??
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Kill a player during the arena royal crate event that wears a golden knife")
CHALLENGE:SetFinishedDesc("You've ruined someone days!")
CHALLENGE:SetID("not_your_crate")

CHALLENGE:AddHook("EntityTakeDamage", function(self, owner, ply, dmg)
    if (owner ~= dmg:GetAttacker()) then return end
    if (dmg:GetDamage() < ply:Health()) then return end
    if (not ply:IsPlayer()) then return end
    local att = dmg:GetAttacker()
    if (ply:InArena() and att:InArena() and ply ~= att and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "csgo_default_t_golden") then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)


local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Time to CHOP CHOP")
CHALLENGE:SetIcon("battlepass/tiers.png") -- <- ??
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Get :goal kills in viking crate event")
CHALLENGE:SetFinishedDesc("You got :goal kills in viking crate event")
CHALLENGE:SetID("arena_viking")

CHALLENGE:AddHook("PlayerDeath", function(self, owner, ply, _, att)
    if (owner ~= att) then return end

    if (ply:InArena() and att:InArena() and ply ~= att and asapArena.ActiveGamemode.id == "melee") then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Suit Ripper")
CHALLENGE:SetIcon("battlepass/tiers.png") -- <- ??
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Get :goal kills in suit crate event")
CHALLENGE:SetFinishedDesc("You got :goal kills in suit crate event")
CHALLENGE:SetID("arena_suit")

CHALLENGE:AddHook("PlayerDeath", function(self, owner, ply, _, att)
    if (owner ~= att) then return end

    if (ply:InArena() and att:InArena() and ply ~= att and asapArena.ActiveGamemode.id == "suits") then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)