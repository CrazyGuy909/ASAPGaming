local PLY = FindMetaTable("Player")

function PLY:GetStoreCredits()
    return self.credits or 0
end

function PLY:SetStoreCredits(amt, ignoreSave, addedCredits)
    self.credits = amt

    if self.credits < 0 then
        self.credits = 0
    end

    if SERVER then
        net.Start("Store.SyncCredits")
        net.WriteEntity(self)
        net.WriteUInt(self.credits, 32)
        net.Broadcast()

        if not ignoreSave then
            Store.Database:SaveCredits(self, addedCredits or self.credits)
        end
    end

    hook.Run("Store.CreditsChanged", self, amt)
end

function PLY:AddStoreCredits(amt)
    if not self._tradingcredits and amt < 0 and (self._oldCredits or 0) > 0 then
        self._oldCredits = self._oldCredits + amt

        if SERVER then
            net.Start("Store.SyncOldCredits")
            net.WriteInt(self._oldCredits, 32)
            net.Send(self)
        end
    end

    self:SetStoreCredits(self:GetStoreCredits() + amt, nil, amt)
end

function PLY:CanAffordStoreCredits(amt)
    local count = self:GetStoreCredits() + (not self._tradingcredits and (self._oldCredits and self._oldCredits or 0) or 0)

    return count >= amt
end

function PLY:SetPermanentWeapons(tbl)
    self.permanentWeapons = tbl

    if SERVER then
        net.Start("Store.PermanentWeapons")
        net.WriteTable(tbl)
        net.Send(self)
    end
end

function PLY:GetPermanentWeapons()
    return self.permanentWeapons or {}
end

function PLY:RemovePermanentWeapon(ent)
    self.permanentWeapons[ent] = nil
end

function PLY:AddPermanentWeapon(ent, save, saved)
    self.permanentWeapons[ent] = true

    if SERVER then
        net.Start("Store.PermanentWeapon")
        net.WriteString(ent)
        net.Send(self)

        if save then
            if saved then
                if type(ent) == "string" then
                    local wep = self:Give(ent)

                    if wep and IsValid(wep) and type(ent) == "string" then
                        wep.isPerm = true
                    end
                end
            end

            Store.Database:SaveWeapon(self, ent, saved)
        end
    end
end

function PLY:SetActivePermanentWeapons(tbl)
    self.activePermanentWeapons = tbl

    if SERVER then
        net.Start("Store.ActivePermanentWeapons")
        net.WriteTable(tbl)
        net.Send(self)
    end
end

function PLY:GetActivePermanentWeapons()
    return self.activePermanentWeapons or {}
end

function PLY:AddActivePermanentWeapon(ent)
    if self.permanentWeapons[ent] then
        self.activePermanentWeapons[ent] = true
    end
end

function PLY:RemoveActivePermanentWeapon(ent)
    if self.permanentWeapons[ent] then
        self.activePermanentWeapons[ent] = nil
    end
end

function PLY:GetStoreDiscount(id)
    local inv = SERVER and (self.rankInventory or {}) or (donationInventory or {})
    local highestRank = -1

    for k, v in pairs(inv) do
        if v > highestRank and v ~= 999 then
            highestRank = v
        end
    end

    local fullPrice
    local lastPrice

    for k, v in pairs(Store.Packages) do
        if tonumber(v.rankId) == tonumber(id) then
            fullPrice = v.cost
            if v.noDiscount then return 0 end
        end

        if highestRank and v.rankId == highestRank and v.rankId ~= 999 then
            lastPrice = v.cost
        end
    end

    if highestRank > id then return fullPrice end
    if not fullPrice or not lastPrice then return 0 end
    if id <= highestRank then return 0 end

    return math.max(2000, fullPrice - lastPrice)
end

local defaults = {}

hook.Add("PlayerLoadout", "Store.Weapons", function(ply)
    if ply:InArena() or ply:IsDueling() then return end

    for i, v in pairs(ply:GetActivePermanentWeapons()) do
        local wep = ply:Give(i)

        if wep and IsValid(wep) and type(i) == "string" then
            wep.isPerm = true
        end
    end

    if not IsValid(ply) or not ply._permaWeapons then return end

    for k, v in pairs(ply._permaWeapons) do
        if not ply._ub3inv[k] then return end
        ply:BU3UseItem(k or -1)
    end

    if ply:isCP() then
        ply:Give("zgo2_sniffer")
    end

    ply:SetGravity(1)
    ply:SetNWFloat("GravitySH", 1)
end)

hook.Add("canDropWeapon", "Store.CanDrop", function(ply, wep)
    if asapArena.BlacklistWeapons[wep:GetClass()] then return false end
    if wep.isPerm or not wep.ItemID then return false end
end)

function Store:FindWeapon(ent)
    for i, v in pairs(Store.Weapons) do
        for k, item in pairs(v.items) do
            if item.ent == ent then return i, k end
        end
    end
end

net.Receive("Store.SyncOldCredits", function()
    LocalPlayer()._oldCredits = net.ReadInt(32)
end)

net.Receive("Store.SpawnEffect", function()
    local id = net.ReadUInt(4)
    local ent = net.ReadEntity()

	if id == 1 then
	timer.Simple(0.1, function()
		local effect = ents.Create("info_particle_system")
		effect:SetKeyValue("effect_name", "gui/effects/manhacksparks")
		effect:SetPos(ent:GetPos())
		effect:Spawn()
		effect:Activate()

		timer.Simple(3, function()
			if IsValid(effect) then
				effect:Remove()
			end
		end)
	end)
    elseif id == 2 then
        local eff = EffectData()
        eff:SetOrigin(ent:GetPos())
        util.Effect("pipis_explosion", eff, true, true)
    end
end)

if SERVER then return end
local EFFECT = {}
local bird, feather, leaf = "ui/asap/birds", "ui/asap/feather", "ui/asap/leaf"

function EFFECT:Init(effectdata)
    local pos = effectdata:GetOrigin()
    local particle
    local emitter = ParticleEmitter(pos)
    emitter:SetNearClip(24, 32)

    for i = 1, 10 do
        local size = math.random(8, 16)
        particle = emitter:Add(bird, pos + VectorRand() * 64)
        particle:SetDieTime(math.Rand(0.5, 2.5))
        particle:SetStartAlpha(255)
        particle:SetEndAlpha(0)
        particle:SetStartSize(size)
        particle:SetEndSize(size)
        particle:SetVelocity(VectorRand():GetNormal() * 220 * Vector(1, 1, 0) + Vector(0, 0, math.random(100, 300)))
    end

    for i = 1, 10 do
        local size = math.random(8, 16)
        particle = emitter:Add(feather, pos + VectorRand() * 64)
        particle:SetDieTime(math.Rand(0.5, 2.5))
        particle:SetStartAlpha(255)
        particle:SetEndAlpha(0)
        particle:SetStartSize(size)
        particle:SetEndSize(size)
        particle:SetVelocity(VectorRand():GetNormal() * 220 * Vector(1, 1, 0) + Vector(0, 0, math.random(100, 300)))
    end

    for i = 1, 10 do
        local size = math.random(8, 16)
        particle = emitter:Add(leaf, pos + VectorRand() * 64)
        particle:SetDieTime(math.Rand(0.5, 2.5))
        particle:SetStartAlpha(255)
        particle:SetEndAlpha(0)
        particle:SetStartSize(size)
        particle:SetEndSize(size)
        particle:SetVelocity(VectorRand():GetNormal() * 220 * Vector(1, 1, 0) + Vector(0, 0, math.random(100, 300)))
    end

    emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end

effects.Register(EFFECT, "pipis_explosion")