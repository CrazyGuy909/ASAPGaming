util.AddNetworkString("armorSend")
util.AddNetworkString("armorSync")
util.AddNetworkString("ASAP.Suits:ShowDropSuit")
--This is the time in seconds it takes to drop a suit after they type a command.
local SuitDropCooldown = 5

hook.Add("PlayerSpawn", "giveArmorBack", function(ply)
    if Armor.LoseOnDeath and ply.armorSuit then
        ply:removeArmorSuit()

        return
    end

    timer.Simple(.05, function()
        if ply.armorSuit then
            ply:applyArmorSuit()
        end
    end)
end)

hook.Add("PlayerSay", "RemoveAmorCommand", function(ply, text)
    if ply:InArena() then return end
    if ply:IsDueling() then return end

    if string.lower(text) == "!dropsuit" or string.lower(text) == "/dropsuit" then
        SafeRemoveEntity(ply.lastDroppedSuit)
        if not ply.armorSuit then
            DarkRP.notify(ply, 1, 5, "You are not wearing a suit!")

            return ""
        end
		
        if ply.armorEquipped ~= ply.armorSuit then
            DarkRP.notify(ply, 1, 5, "You can not drop this suit!")

            return ""
        end

        if ply:GetMoveType() == MOVETYPE_NONE or ply:HasGodMode() then
            DarkRP.notify(ply, 1, 5, "You cannot drop your suit right now")

            return
        end

        ply._suitToDrop = true
        ply:SetNWBool("AllowAbilities", false)
        net.Start("ASAP.Suits:ShowDropSuit")
        net.WriteUInt(SuitDropCooldown, 4)
        net.Send(ply)
        ply:SendLua("")

        timer.Simple(SuitDropCooldown, function()
            if not IsValid(ply) or not ply.armorSuit then return end

            if ply.battleTag and ply.battleTag > CurTime() then
                ply._suitResets = (ply._suitResets or 0) + 1

                timer.Simple(20, function()
                    if not IsValid(ply) then return end
                    ply._suitResets = math.Clamp(ply._suitResets - 1, 0, 5)
                end)
            end

            ply:SetNWBool("AllowAbilities", true)

            if ply:GetMoveType() == MOVETYPE_NONE or ply:HasGodMode() then
                DarkRP.notify(ply, 1, 5, "You cannot drop your suit right now")

                return
            end

            local data = Armor:Get(ply.armorSuit)

            if data then
                ply.armorEquipped = nil
                MsgC(Color(255, 100, 0),"[Suits] ", color_white, ply:Nick() .. ":" .. ply:SteamID64(), " dropped suit ", Color(255, 100, 0), data.Name, "\n")
                ply:removeArmorSuit()
                --Recreate the suit
                local suit = ents.Create(data.Entitie)
                local tracePos = ply:GetEyeTrace().HitPos

                if tracePos:Distance(ply:EyePos()) > 200 then
                    tracePos = tracePos - ply:EyePos()
                    tracePos:Normalize()
                    tracePos = tracePos * 200
                    tracePos = ply:EyePos() + tracePos
                end

                if not ply:Alive() then return end
                if ply:InArena() then return end
                suit:SetPos(tracePos)
                suit:SetAngles(ply:GetAngles())
                suit.armorEquipped = true
                suit:Spawn()
                ply.lastDroppedSuit = suit
            end
        end)

        return ""
    end
end)

local PMeta = FindMetaTable("Player")

function PMeta:applyArmorSuit()
	print("IM APPLYING")
    local data = Armor:Get(self.armorSuit)
    if not data then return end
	print(data)
	print("IFNOTDATA")
    self:SetModel(data.Model)
    net.Start("armorSync")
    net.WriteEntity(self)
    net.WriteString(self.armorSuit)
    net.Broadcast()
    hook.Run("PlayerEquipSuit", self, self.armorSuit)

    if IsValid(self) and IsValid(self:GetHands()) then
        hook.Run("PlayerSetHandsModel", self, self:GetHands())
    end

    self:SetHealth(data.Health or self:Health())
    self:SetArmor(data.Armor or self:Armor())

    if data.Speed then
        self._oldRunSpeed = self:GetRunSpeed()
        self:SetRunSpeed(self:GetRunSpeed() * data.Speed)
    end

    if data.Gravity then
        self:SetGravity(data.Gravity)
        self:SetNWFloat("GravitySH", data.Gravity)
    end

    self:SetJumpPower(data.JumpPower or self:GetJumpPower())
    self:SetMaxHealth(self:Health())
    self:SetMaxArmor(self:Armor())
    local ply = self

    if (ply._suitResets or 0) > 0 then
        ply:SetHealth(ply:GetMaxHealth() - (ply:GetMaxHealth() * math.min(ply._suitResets, 4) * .15))
    end

    if data.OnGive then
        data.OnGive(self)
    end

    self._requireUnload = true
end

function PMeta:removeArmorSuit()
    local data = Armor:Get(self.armorSuit)
    if not data then return end
    local percent = self:Health() / self:GetMaxHealth()

    if data.OnRemove then
        data.OnRemove(self)
    end

    if data.Gravity then
        self:SetNWFloat("GravitySH", 1)
    end

    net.Start("armorSync")
    net.WriteEntity(self)
    net.WriteString("")
    net.Broadcast()
    net.Start("armorSend")
    net.WriteString("nil")
    net.Send(self)
    self.armorSuit = nil
    hook.Call("PlayerSetModel", GAMEMODE, self)
    hook.Run("PlayerSetHandsModel", self, self:GetHands())
    hook.Run("PlayerRemoveSuit", self, self.armorSuit)

    if self._oldRunSpeed then
        self:SetRunSpeed(self._oldRunSpeed)
    end

    timer.Simple(0, function()
        self:SetGravity(1)
        self:SetHealth(math.ceil(100 * percent + 1))
        self:TakeDamage(1)
        self:SetArmor(0)
        self:SetJumpPower(200)
        self:SetMaxHealth(100)
        self:SetMaxArmor(100)
    end)
end

function PMeta:giveArmorSuit(name)
    local data = Armor:Get(name)
    if not data then return end
    if self.armorSuit then
        self:removeArmorSuit()
    end
    if not self._maxHealth then
        self._maxHealth = self:GetMaxHealth()
    end
    self.armorSuit = name
    self:applyArmorSuit()
    net.Start("armorSend")
    net.WriteString(name)
    net.Send(self)
end

local gluonGuns = {
    ["weapon_gluongun"] = true,
    ["weapon_bms_gluon"] = true
}

hook.Add("PlayerShouldTakeDamage", "ArmorSuits", function(ply, attacker)
    if (ply:InArena()) then return end
    if ply.immuneToGluon and attacker:IsPlayer() and attacker.GetActiveWeapon then
        local activeWeapon = attacker:GetActiveWeapon()
        if IsValid(activeWeapon) and gluonGuns[activeWeapon:GetClass()] and ply.immuneToGluon then return false end
    end

    if ply.immuneToDmg then return false end
end)

hook.Add("OnPlayerChangedTeam", "ArmorSuits", function(ply)
    if ply:InArena() then return end
    if ply:IsDueling() then return end

    if ply.armorSuit and ply:Alive() then
        local data = Armor:Get(ply.armorSuit)

        if data then
            DarkRP.notify(ply, NOTIFY_GENERIC, 4, "You changed your job, so your suit has been dropped")
            local oldsuit = ply.armorSuit
            ply:removeArmorSuit()
            if ply.armorEquipped ~= oldsuit then return end
            --Recreate the suit
            ply.armorEquipped = nil
            local suit = ents.Create(data.Entitie)
            local tracePos = ply:GetEyeTrace().HitPos

            if tracePos:Distance(ply:EyePos()) > 200 then
                tracePos = tracePos - ply:EyePos()
                tracePos:Normalize()
                tracePos = tracePos * 200
                tracePos = ply:EyePos() + tracePos
            end

            suit:SetPos(tracePos)
            suit:SetAngles(ply:GetAngles())
            suit:Spawn()
        end
    end
end)

-- For candy :^)
hook.Add("GetFallDamage", "suits_nofallDmg", function(ply, speed)
    if ply.armorSuit and ply.armorSuit ~= "" then return 0 end
end)

hook.Add("canArrest", "suits_noArrest", function(_, ply)
    if ply and ply.armorSuit then return false, "You can't arrest this player as their suit is too powerful" end
end)

hook.Add("ScalePlayerDamage", "Suit.Protect", function(ply, hit, dmg)
    if (not ply.armorSuit or ply.armorSuit == "") then return end
    if (dmg:IsBulletDamage()) then
        dmg:ScaleDamage(0.85)
    elseif (dmg:IsExplosionDamage()) then
        dmg:ScaleDamage(1.15)
    elseif (dmg:IsDamageType(DMG_SHOCK)) then
        dmg:ScaleDamage(1.30)
    end
end)

local suitFilter = CreateConVar("asap_discord_suitfilter", "", FCVAR_ARCHIVE, "Suits that shouldn't show")
hook.Add("PlayerDeath", "suits_dropChance", function(ply, inf, att)
    if ply:InArena() then return end

    if not ply.armorSuit or ply.armorSuit == "" then return end
    local suit = Armor:Get(ply.armorSuit)
    local chance = math.Rand(0, 100)
    local oldsuit = ply.armorSuit

    if not suit.IsCosmetic and suitFilter:GetString() ~= "" then
        local filter = string.Explode(",", suitFilter:GetString())
        local canShow = true

        for k, v in pairs(filter) do
            if v == ply.armorSuit then
                canShow = false
                break
            end
        end

        if canShow then
            BU3.NotifyRip(ply, att:IsPlayer() and att or inf)
        end
    elseif (not suit.IsCosmetic) then
        BU3.NotifyRip(ply, att:IsPlayer() and att or inf)
    end

    hook.Run("SuitDeath", ply, att, ply.armorSuit)
    ply:removeArmorSuit()
    if att.armor_dropper or chance <= 5 + ((ply._suitResets or 0) * 10) then
        if ply.armorEquipped ~= oldsuit then return end
        local deathPos = ply:GetPos()
        local ent = ents.Create(suit.Entitie)
        ent:SetPos(deathPos + Vector(0, 0, 50))
        ent.armorEquipped = true
        ent.IsTainted = true
        ent:Spawn()

        if att.armor_dropper then
            att.armor_dropper = nil
        end
    end
end)

concommand.Add("asap_givesuit", function(ply, cmd, args, argstr)
    if IsValid(ply) then return end
    gonzo():removeArmorSuit()
    gonzo():giveArmorSuit(argstr)
end)