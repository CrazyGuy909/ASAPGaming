

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Most Wanted")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Open the bank vault")
CHALLENGE:SetFinishedDesc("You could get away with it!")
CHALLENGE:SetID("vault_assault")

CHALLENGE:AddHook("pVaultMoneyCleaned", function(self, owner, ply)
    if (ply == owner) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Base Engineer")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Using turrets protect your base and kill :goal players.")
CHALLENGE:SetFinishedDesc("Raiding it's not more! Thanks to the science")
CHALLENGE:SetID("turret_killer")

CHALLENGE:AddHook("PlayerDeath", function(self, owner, ply, inf, att)
    if (inf.IsTurret and att == owner) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Be GONE Turret")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Destroy :goal Police Turrets")
CHALLENGE:SetFinishedDesc("I have the power of god!")
CHALLENGE:SetID("turret_anarch")

CHALLENGE:AddHook("EntityTakeDamage", function(self, owner, ent, dmg)
    if (ent.IsTurret and dmg:GetAttacker() == owner and ent.IsCoordless and ent:Health() <= dmg:GetDamage() and ent:GetReady()) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("ILLEGAL!")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Destroy :goal Printers as police member")
CHALLENGE:SetFinishedDesc("Exterminate...Exterminate not fiscalized income methods")
CHALLENGE:SetID("printer_killer")

CHALLENGE:AddHook("EntityTakeDamage", function(self, owner, ent, dmg)
    if not owner:isCP() then  return end
    if ent:GetClass() != "asap_money_printer" then  return end
    if dmg:GetAttacker() != owner then  return end
    if ent.destroyedPrinter then  return end
    if dmg:GetDamage() < ent:Health() then  return end

    ent.destroyedPrinter = true
    self:AddProgress(1)
    self:NetworkProgress()
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Breaking Bad")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Make :goal from selling meth")
CHALLENGE:SetFinishedDesc("We finally made enough meth, impossible")
CHALLENGE:SetID("breaking_meth")

CHALLENGE:AddHook("zmlab_OnMethSell_DropOff_Use", function(self, owner, ply, meth)
    if (owner == ply) then
        local Earning = meth * ( zmlab.config.MethBuyer.SellRanks[ply:GetNWString("usergroup", "")] or zmlab.config.MethBuyer.SellRanks["default"])
        self:AddProgress(Earning)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)

local CHALLENGE = BATTLEPASS:CreateTemplateChallenge()
CHALLENGE:SetName("Dancing in a battle field")
CHALLENGE:SetIcon("battlepass/tiers.png")
CHALLENGE:SetDesc("")
CHALLENGE:SetProgressDesc("Dance on top of the Royal crate in arena.")
CHALLENGE:SetFinishedDesc("BREAKING NEWS: Crazy man dances in the middle of a war zone!")
CHALLENGE:SetID("royal_dance")

CHALLENGE:AddHook("OnPlayerTaunt", function(self, owner, ply)
    if (ply == owner and ply:GetPos():Distance(Vector(-3398, -3047, -9474)) < 128) then
        self:AddProgress(1)
        self:NetworkProgress()
    end
end)

BATTLEPASS:RegisterChallenge(CHALLENGE)