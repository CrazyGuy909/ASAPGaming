local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Ripped Off")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Kill :goal players with suits equipped")
CHALLENGE:SetFinishedDesc("No even the machine could stop you")
CHALLENGE:SetID("suit_ripper")

CHALLENGE:AddHook("SuitDeath", function(self, owner, ply, att, armor)
    if not att:IsPlayer() or ply == att or owner ~= att then return end
    local suit = Armor:Get(armor)
    if IsValid(att) and not suit.IsCosmetic then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Souvenir Gift")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Grab :goal suits from players that died")
CHALLENGE:SetFinishedDesc("Maybe it wasn't about the kills, but the gifts we got!")
CHALLENGE:SetID("suit_gift")

CHALLENGE:AddHook("OnSuitStole", function(self, owner, ply)
    if owner ~= ply then return end

    self:AddProgress(1)
    self:NetworkProgress()
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Conqueror")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Capture :goal points in the map")
CHALLENGE:SetFinishedDesc("Grove street, home")
CHALLENGE:SetID("capture_cp")

CHALLENGE:AddHook("OnControlPointCaptured", function(self, owner, point, tag, ply)
    if owner ~= ply then return end

    self:AddProgress(1)
    self:NetworkProgress()
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Bee Swarm")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Kill :goal players contesting your point")
CHALLENGE:SetFinishedDesc("They will think twice before contesting your point again")
CHALLENGE:SetID("capture_killer")

CHALLENGE:AddHook("PlayerDeath", function(self, owner, ply, inf, att)
    if (att != owner) then return end
    if (not ply.contesting) then return end
    if (not IsValid(att) or not att:IsPlayer() or ply.contesting:GetFaction() != att:GetGang() or owner != att) then return end

    self:AddProgress(1)
    self:NetworkProgress()
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Absolution")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Kill :goal targets as hitman")
CHALLENGE:SetFinishedDesc("The funny bald guy did it again, huray!")
CHALLENGE:SetID("hitman_sucess")

CHALLENGE:AddHook("Hitman.HitSuccess", function(self, owner, offered, victim, killer)
    if (not IsValid(killer) or not killer:IsPlayer() or owner != killer) then return end

    self:AddProgress(1)
    self:NetworkProgress()
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Counter-Strike")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Kill :goal hitmen which you're his target")
CHALLENGE:SetFinishedDesc("Hitman? More like deathman amirite?")
CHALLENGE:SetID("hitman_fail")

CHALLENGE:AddHook("Hitman.Failure", function(self, owner, offered, victim)
    if (not IsValid(victim) or not victim:IsPlayer() or owner != victim) then return end

    self:AddProgress(1)
    self:NetworkProgress()
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Metal Expert")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Craft :goal Ultimate Suit Parts in manufacture table")
CHALLENGE:SetID("ultimate_metal")

CHALLENGE:AddHook("OnMinigameSuccess", function(self, owner, ply, id, amount, ent)
    if (owner != victim or id != 9) then return end

    self:AddProgress(amount)
    self:NetworkProgress()
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Weapons Expert")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Craft :goal Ultimate Weapons Parts in manufacture table")
CHALLENGE:SetID("ultimate_weapons")

CHALLENGE:AddHook("OnMinigameSuccess", function(self, owner, ply, id, amount, ent)
    if (owner != victim or id != 8) then return end

    self:AddProgress(amount)
    self:NetworkProgress()
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Counter-Fit Expert")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Sell over :goal money in Counter-Fit resources")
CHALLENGE:SetID("counterfit_money")

CHALLENGE:AddHook("OnGangPackageDelivered", function(self, owner, ply, gang, amount)
    if (owner != victim) then return end

    self:AddProgress(amount)
    self:NetworkProgress()
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Trouble Makers")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Start :goal raids (Lockpick entrances)")
CHALLENGE:SetID("trouble_makers")

CHALLENGE:AddHook("OnGangRaidStart", function(self, owner, def, att)
    if (owner:GetGang() and owner:GetGang() != att) then return end

    self:AddProgress(1)
    self:NetworkProgress()
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Nerd Stompers")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Win :goal raids (Destroy main computer or defend it)")
CHALLENGE:SetID("nerd_stompers")

CHALLENGE:AddHook("OnGangRaidEnd", function(self, owner, def, att, success)
    local myGang = owner:GetGang()
    if (not myGang or myGang == "") then return end
    if (success and myGang == att) then
        self:AddProgress(1)
        self:NetworkProgress()
        return
    end

    if (not success and myGang == def) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)
