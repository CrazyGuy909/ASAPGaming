if SERVER then
    util.AddNetworkString("ASAP.Suits:UpdateField")
end

local flow = Material("models/weapons/tfa_cso/pianogunex/$20@004_21-3_psychic_harmonium_glass")


Armor:Add({
    Name = "Neon Suit",
    Description = "Recharges armor when you deal damage",
    Model = "models/konnie/asapgaming/destiny2/whisperofthevictor.mdl",
    Entitie = "armor_neon",
    PostPlayerDraw = function(ply)
        if (ply.armorPower) then
            render.SuppressEngineLighting(true)
            render.MaterialOverride(flow)
            render.SetBlend(ply.armorPower / 255)
            ply:DrawModel()
            render.SetBlend(1)
            render.MaterialOverride(nil)
            render.SuppressEngineLighting(false)
            ply.armorPower = ply.armorPower - FrameTime() * (255 / .6)
            if (ply.armorPower <= 0)  then
                ply.armorPower = nil
            end
        end
    end,
    HUDPaint = function(ply)
        Armor:DrawHUDBar("Armor Charge", (ply.armorCharge or 0) / 10, 1, 10)
    end,
    Abilities = {
        [1] = {
            Description = "Reloads your armor 100AP for every 150DMG you deal",
            Cooldown = 20,
            Action = function(armor, ply)
                if (not ply.armorCharge) then
                    return false, "No charge"
                end

                local can = math.ceil((1500 - ply:Armor()) / 100)
                if (can > 0) then
                    if SERVER then
                        ply:EmitSound("weapons/tfa_cso/plasmagunexd/charge.wav")
                        local tag = ply:SteamID64() .. "armor_charge"
                        timer.Create(tag, 0.33, can, function()
                            if not IsValid(ply) or not ply.armorSuit or ply:Armor() > 1500 or ply.armorCharge <= 0 then
                                timer.Remove(tag)
                                return
                            end

                            net.Start("ASAP.Suits:UpdateField")
                            net.WriteUInt(3, 4)
                            net.WriteEntity(ply)
                            net.SendPVS(ply:GetShootPos())
                            ply:SetArmor(ply:Armor() + 100)
                            ply.armorCharge = ply.armorCharge - 1
                        end)
                    else
                        ply.armorCharge = math.max(ply.armorCharge - can, 0)
                    end
                end

                return true
            end
        }
    },
    Armor = 1500,
    Health = 2000,
    JumpPower = 500,
    Speed = 1.5,
    OnGive = function(ply)
        ply.armorCharge = 0
        ply.armorDamage = 0

        local tag = ply:SteamID64() .. "_armorSuit"
        hook.Add("EntityTakeDamage", ply:SteamID64() .. "_armorSuit", function(ent, dmg)
            if not IsValid(ply) then
                hook.Remove("EntityTakeDamage", tag)
                return
            end

            if (ent != ply and ent:IsPlayer() and (ent:GetGang() == "" or ent:GetGang() != ply:GetGang())) then
                ply.armorDamage = (ply.armorDamage or 0) + dmg:GetDamage()
                if (ply.armorDamage > 150) then
                    ply.armorDamage = 0
                    ply.armorCharge = math.min((ply.armorCharge or 0) + 1, 10)
                    net.Start("ASAP.Suits:UpdateField")
                    net.WriteUInt(0, 3)
                    net.WriteUInt(ply.armorCharge, 4)
                    net.Send(ply)
                end
            end
        end)
    end,
    OnRemove = function(ply)
        hook.Remove("EntityTakeDamage", ply:SteamID64() .. "_armorSuit")
    end
})

local lavaRevive = Material("models/weapons/tfa_cso/vulcanus9/gasgauge04")
Armor:Add({
    Name = "Sunset Suit",
    Description = "Resurrects you when you die (Resets on death)",
    Model = "models/konnie/asapgaming/destiny2/cunningcontender.mdl",
    Entitie = "armor_sunset",
    PostPlayerDraw = function(ply)
        if (ply.armorPower) then
            render.SuppressEngineLighting(true)
            render.MaterialOverride(lavaRevive)
            render.SetBlend(ply.armorPower / 255)
            ply:DrawModel()
            render.SetBlend(1)
            render.MaterialOverride(nil)
            render.SuppressEngineLighting(false)
            ply.armorPower = ply.armorPower - FrameTime() * (255 / 3)
            if (ply.armorPower <= 0)  then
                ply.armorPower = nil
            end
        end
    end,
    HUDPaint = function(ply)
        Armor:DrawHUDBar("Revive", ply.hasRevived and 0 or 1, 0, 1)
    end,
    Armor = 2000,
    Health = 2300,
    JumpPower = 400,
    Speed = 1.4,
    OnGive = function(ply)
        local stats = {2300, 2000}

        ply:GodDisable()

        local tag = ply:SteamID64() .. "_armorSuit"

        hook.Add("PlayerDeath", tag, function(p)
            if (p == ply and p.hasRevived) then
                p.hasRevived = false
                net.Start("ASAP.Suits:UpdateField")
                net.WriteUInt(1, 3)
                net.WriteBool(false)
                net.Send(p)
                hook.Remove("PlayerDeath", tag)
            end
        end)

        hook.Add("EntityTakeDamage", tag, function(p, dmg)
            if (not p:IsPlayer()) then return end
            if (not p:Alive()) then return end
            if p != ply or p.hasRevived then
                return
            end

            if (dmg:GetDamage() >= p:Health()) then

                local eff = EffectData()
                eff:SetOrigin(p:GetPos() + p:OBBCenter())
                util.Effect("exp_moon", eff, true, true)

                p:EmitSound("weapons/tfa_cso/magicknife/magic_start.wav", 120)
                net.Start("ASAP.Suits:UpdateField")
                net.WriteUInt(1, 3)
                net.WriteBool(true)
                net.Send(p)

                net.Start("ASAP.Suits:UpdateField")
                net.WriteUInt(3, 3)
                net.WriteEntity(p)
                net.SendPVS(p:EyePos())

                p.hasRevived = true
                p:GodEnable()
                if (p:IsOnGround()) then
                    p:SetPos(p:GetPos() + Vector(0, 0, 16))
                end
                p:ConCommand("optmenu_thirdperson 1")
                p:SetMoveType(MOVETYPE_NONE)
                p:ChatPrint("<color=yellow>You're reviving in 3 seconds...</color>")
                p:Wait(3, function()
                    if not IsValid(p) then return end
                    p:EmitSound("weapons/tfa_cso/magicknife/magic_end.wav")
                    p:ConCommand("optmenu_thirdperson 0")
                    p:SetHealth(stats[1] * .5)
                    p:SetArmor(stats[2] * .5)
                    p:SetMoveType(MOVETYPE_WALK)
                    p:GodDisable()
                end)

                dmg:SetDamage(0)

                hook.Remove("EntityTakeDamage", tag)
                return true
            end
        end)
    end,
    OnRemove = function(ply)
        hook.Remove("EntityTakeDamage", ply:SteamID64() .. "_armorSuit")
        ply:SetMoveType(MOVETYPE_WALK)
        ply:GodDisable()
    end
})

Armor:Add({
    Name = "Red Sun Suit",
    Description = "Wallhack - Releases a sun that will suck and burn players around it",
    Model = "models/konnie/asapgaming/destiny2/survivalofthestrong.mdl",
    Entitie = "armor_redsun",
    WallHack = true,
    HUDPaint = function(ply)
        if (ply.sunDuration) then
            Armor:DrawHUDBar("Sun Duration", ply.sunDuration / 10, 0, 1)
            ply.sunDuration = ply.sunDuration - FrameTime()
            if ply.sunDuration <= 0 then
                ply.sunDuration = nil
            end
        end
    end,
    Abilities = {
        [1] = {
            Description = "Creates a sun that will suck and burn players around it",
            Cooldown = 20,
            Action = function(armor, ply)
                if SERVER then
                    SafeRemoveEntity(ply.sunEntity)
                else
                    return true
                end

                local ent = ents.Create("sent_redsun")
                ent:SetPos(ply:GetShootPos() + ply:GetAimVector() * 64)
                ent:SetAngles(ply:EyeAngles())
                ent:SetOwner(ply)
                ent:Spawn()
                ply.sunEntity = ent

                net.Start("ASAP.Suits:UpdateField")
                net.WriteUInt(2, 3)
                net.Send(ply)
                return true
            end
        }
    },
    Armor = 2000,
    Health = 2500,
    JumpPower = 400,
    Speed = 1.4
})

local models = {
    [1] = {
        Model = "models/player/masseffect3/characters/geth_trooper.mdl",
        Health = 500,
        Armor = 500,
        Speed = 2,
        Name = "I",
    },
    [2] = {
        Model = "models/player/masseffect3/characters/geth_rockettrooper.mdl",
        Health = 750,
        Armor = 500,
        Speed = 2.5,
        Name = "II",
    },
    [3] = {
        Model = "models/player/masseffect3/characters/geth_pyro.mdl",
        Health = 1000,
        Armor = 750,
        Speed = 3,
        Name = "III",
    },
    [4] = {
        Model = "models/player/masseffect3/characters/geth_prime_small.mdl",
        Health = 1250,
        Armor = 750,
        Speed = 3.5,
        Name = "IV",
    }
}

for k, v in pairs(models) do
    Armor:Add({
        Name = "OC Speed Suit " .. v.Name, -- name it appears in the sandbox menu and darkrp menu
        Description = "Anti Gravity Activated",
        Model = v.Model, -- what your model changes to
        Entitie = "armor_ocspeedsuit" .. k, -- the entitie name for the armor
        Armor = v.Armor, -- how much armor it gives
        Health = v.Health, -- how much health it gives
        JumpPower = 250, -- how much jump power it gives
        Speed = v.Speed, -- how much speed it gives
        Gravity = .8
    })
end

if CLIENT then
    net.Receive("ASAP.Suits:UpdateField", function(l, ply)
        local armor = net.ReadUInt(3)
        if (armor == 0) then
            LocalPlayer().armorCharge = net.ReadUInt(4)
        elseif (armor == 1) then
            LocalPlayer().hasRevived = net.ReadBool()
        elseif (armor == 2) then
            LocalPlayer().sunDuration = 10
        elseif (armor == 3) then
            local ent = net.ReadEntity()
            ent.armorPower = 255
        end
    end)
end