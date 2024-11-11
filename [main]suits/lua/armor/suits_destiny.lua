hook.Add("SetupMove", "ASAP.SuitFixes", function(ply, mv)
    if (not ply.armorSuit) then return end
    ply:SetGravity(ply:GetNWFloat("GravitySH", 1))
end)

Armor:Add({
    Name = "Aesculapius Suit",
    Description = "Powerful shield.",
    Model = "models/konnie/asapgaming/destiny2/reveriedawn.mdl",
    Entitie = "armor_aesculapius",
    Cooldown = 10,
    Wallhack = true,
    HUDPaint = function(ply)
        local shield = ply:GetNW2Entity("ShieldEntity")

        if IsValid(shield) then
            draw.SimpleText("Shield Life:", "XeninUI.TextEntry", ScrW() / 2 + 1, 121, Color(0, 0, 0), 1, TEXT_ALIGN_BOTTOM)
            draw.SimpleText("Shield Life:", "XeninUI.TextEntry", ScrW() / 2, 120, color_white, 1, TEXT_ALIGN_BOTTOM)
            surface.SetDrawColor(0, 0, 0)
            surface.DrawRect(ScrW() / 2 - 128, 128, 256, 24)
            surface.SetDrawColor(255, 255, 255)
            surface.DrawRect(ScrW() / 2 - 128 + 2, 130, 252 * (shield:Health() / shield.MaxHealth), 20)

            return false
        end
    end,
    Armor = 1150,
    Health = 1150,
    JumpPower = 300,
    Speed = 1.6,
    OnGive = function(ply)
        ply.immuneToGluon = true
    end,
    -- what happens when they get the suit equipped
    Abilities = {
        [1] = {
            Action = function(s, ply)
                if IsValid(ply:GetNW2Entity("ShieldEntity")) then return end

                if SERVER then
                    if (IsValid(ply._shield)) then return end
                    ply._shield = ents.Create("sent_armor_shield")
                    ply._shield:SetOwner(ply)
                    ply._shield:Spawn()
                    ply:SetNW2Entity("ShieldEntity", ply._shield)
                end

                return false
            end,
            Cooldown = 60
        }
    },
    OnRemove = function(ply)
        if IsValid(ply._shield) then
            ply._shield:Remove()
        end

        ply:SetNWFloat("GravitySH", 0)
        ply.immuneToGluon = nil
    end
})

Armor:Add({
    Name = "Osiris Armor",
    Description = "Lockpicks doors in 1 second",
    Model = "models/konnie/asapgaming/destiny2/titanretrograde.mdl",
    Entitie = "armor_osiris",
    Cooldown = 1,
    Wallhack = true,
    HUDPaint = function(ply)
        local shield = ply:GetNW2Entity("ShieldEntity")

        if IsValid(shield) then
            draw.SimpleText("Shield Life:", "XeninUI.TextEntry", ScrW() / 2 + 1, 121, Color(0, 0, 0), 1, TEXT_ALIGN_BOTTOM)
            draw.SimpleText("Shield Life:", "XeninUI.TextEntry", ScrW() / 2, 120, color_white, 1, TEXT_ALIGN_BOTTOM)
            surface.SetDrawColor(0, 0, 0)
            surface.DrawRect(ScrW() / 2 - 128, 128, 256, 24)
            surface.SetDrawColor(255, 255, 255)
            surface.DrawRect(ScrW() / 2 - 128 + 2, 130, 252 * (shield:Health() / shield.MaxHealth), 20)

            return false
        end
    end,
    Armor = 1500,
    Health = 1700,
    JumpPower = 300,
    Speed = 1.25,
    OnGive = function(ply)
        ply.immuneToGluon = true

        hook.Add("lockpickTime", ply, function(self, pl)
            if (pl == self and self.armorSuit) then
                return 1
            elseif not self.armorSuit then
                hook.Remove("lockpickTime", ply)

                return
            end
        end)
    end,
    Abilities = {
        [1] = {
            Cooldown = 60,
            Action = function(s, ply)
                if IsValid(ply:GetNW2Entity("ShieldEntity")) then return end

                if SERVER then
                    if (IsValid(ply._shield)) then return end
                    ply._shield = ents.Create("sent_armor_shield")
                    ply._shield:SetOwner(ply)
                    ply._shield:Spawn()
                    ply:SetNW2Entity("ShieldEntity", ply._shield)
                end

                return false
            end
        }
    },
    OnRemove = function(ply)
        if IsValid(ply._shield) then
            ply._shield:Remove()
        end

        hook.Remove("lockpickTime", ply)
        ply.immuneToGluon = nil
        ply.wallhackActive = nil
        ply.noFallDmg = nil

        if (ply._oldRunSpeed) then
            ply:SetRunSpeed(ply._oldRunSpeed)
            ply._oldRunSpeed = nil
        end
    end
})

Armor:Add({
    Name = "Heavy Guardian Armor",
    Description = "Lockpicks doors in 2 second (Shield with 20 second cooldown)",
    Model = "models/delta/destiny2/titanexilemale.mdl",
    Entitie = "armor_hgahga",
    Cooldown = 20,
    Wallhack = true,
    HUDPaint = function(ply)
        local shield = ply:GetNW2Entity("ShieldEntity")

        if IsValid(shield) then
            draw.SimpleText("Shield Life:", "XeninUI.TextEntry", ScrW() / 2 + 1, 121, Color(0, 0, 0), 1, TEXT_ALIGN_BOTTOM)
            draw.SimpleText("Shield Life:", "XeninUI.TextEntry", ScrW() / 2, 120, color_white, 1, TEXT_ALIGN_BOTTOM)
            surface.SetDrawColor(0, 0, 0)
            surface.DrawRect(ScrW() / 2 - 128, 128, 256, 24)
            surface.SetDrawColor(255, 255, 255)
            surface.DrawRect(ScrW() / 2 - 128 + 2, 130, 252 * (shield:Health() / shield.MaxHealth), 20)

            return false
        end
    end,
    Armor = 2000,
    Health = 2150,
    JumpPower = 500,
    Speed = 2.1,
    Gravity = 0.85,
    OnGive = function(ply)
        ply.immuneToGluon = true

        hook.Add("lockpickTime", ply, function(self, pl)
            if (pl == self and self.armorSuit == "Heavy Guardian Armor") then
                return 2
            elseif self.armorSuit ~= "Heavy Guardian Armor" then
                hook.Remove("lockpickTime", ply)

                return
            end
        end)
    end,
    Abilities = {
        [1] = {
            Cooldown = 45,
            Action = function(s, ply)
                if IsValid(ply:GetNW2Entity("ShieldEntity")) then
                    if SERVER then
                        SafeRemoveEntity(ply:GetNW2Entity("ShieldEntity"))
                    end
                    return
                end

                if SERVER then
                    if (IsValid(ply._shield)) then return end
                    ply._shield = ents.Create("sent_armor_shield")
                    ply._shield:SetOwner(ply)
                    ply._shield:Spawn()
                    ply:SetNW2Entity("ShieldEntity", ply._shield)
                end

                return true
            end
        }
    },
    OnRemove = function(ply)
        if IsValid(ply._shield) then
            ply._shield:Remove()
        end

        hook.Remove("lockpickTime", ply)
        ply.immuneToGluon = nil
    end
})

Armor:Add({
    Name = "Stealth Guardian Armor",
    Description = "Lockpicks doors in 2 second - Goes invisible temporarily 5 minute cooldown",
    Model = "models/delta/destiny2/hunterexilemale.mdl",
    Entitie = "armor_sgasga",
    Wallhack = true,
    Health = 1800,
    Armor = 1250,
    JumpPower = 400,
    Speed = 1.50,
    Gravity = 0.85,
    OnGive = function(ply)
        ply.immuneToGluon = true

        hook.Add("lockpickTime", ply, function(self, pl)
            if (pl == self and self.armorSuit) then
                return 2
            elseif (not self.armorSuit) then
                hook.Remove("lockpickTime", ply)

                return
            end
        end)
    end,
    OnRemove = function(ply)
        if IsValid(ply._shield) then
            ply._shield:Remove()
        end

        hook.Remove("lockpickTime", ply)
        ply.immuneToGluon = nil
    end
})

Armor:Add({
    Name = "Venom Suit",
    Description = "Makes a clound of toxic gas around you",
    Model = "models/konnie/asapgaming/destiny2/wildwood.mdl",
    Entitie = "armor_venom",
    Wallhack = true,
    HUDPaint = function(ply)
        local shield = ply:GetNW2Entity("ShieldEntity")

        if IsValid(shield) then
            draw.SimpleText("Toxic Cloud:", "XeninUI.TextEntry", ScrW() / 2 + 1, 121, Color(0, 0, 0), 1, TEXT_ALIGN_BOTTOM)
            draw.SimpleText("Toxic Cloud:", "XeninUI.TextEntry", ScrW() / 2, 120, color_white, 1, TEXT_ALIGN_BOTTOM)
            surface.SetDrawColor(0, 0, 0)
            surface.DrawRect(ScrW() / 2 - 128, 128, 256, 24)
            surface.SetDrawColor(255, 255, 255)
            surface.DrawRect(ScrW() / 2 - 128 + 2, 130, 252 * (shield:Health() / 10), 20)
        end
    end,
    Health = 1400,
    Armor = 1250,
    JumpPower = 200,
    Speed = 1.45,
    OnGive = function(ply)
        ply.immuneToGluon = true
    end,
    -- what happens when they get the suit equipped
    Abilities = {
        [1] = {
            Cooldown = 30,
            Action = function(s, ply)
                if (not IsFirstTimePredicted()) then return false end
                if IsValid(ply:GetNW2Entity("ShieldEntity")) then return false end

                if SERVER then
                    if (IsValid(ply._shield)) then return end
                    ply._shield = ents.Create("sent_armor_poison")
                    ply._shield:SetOwner(ply)
                    ply._shield:Spawn()
                    ply:SetNW2Entity("ShieldEntity", ply._shield)
                end
            end
        }
    },
    OnRemove = function(ply)
        if IsValid(ply._shield) then
            ply._shield:Remove()
        end

        ply.immuneToGluon = nil
    end
})

Armor:Add({
    Name = "Simulator Suit",
    Description = "When you get shoot enemy gets blinded",
    Model = "models/konnie/asapgaming/destiny2/simulator.mdl",
    Entitie = "armor_simulator",
    Cooldown = 10,
    Wallhack = true,
    HUDPaint = function(ply)
        if ply._hasSimulator and (ply._simulationSuit or 0) > 0 then
            ply._simulationSuit = ply._simulationSuit - FrameTime()
            draw.SimpleText("Flashing shield:", "XeninUI.TextEntry", ScrW() / 2 + 1, 121, Color(0, 0, 0), 1, TEXT_ALIGN_BOTTOM)
            draw.SimpleText("Flashing Shield:", "XeninUI.TextEntry", ScrW() / 2, 120, color_white, 1, TEXT_ALIGN_BOTTOM)
            surface.SetDrawColor(0, 0, 0)
            surface.DrawRect(ScrW() / 2 - 128, 128, 256, 24)
            surface.SetDrawColor(255, 255, 255)
            surface.DrawRect(ScrW() / 2 - 128 + 2, 130, 252 * (ply._simulationSuit / 10), 20)
        end
    end,
    Armor = 1150,
    Health = 900,
    JumpPower = 200,
    Speed = 1.70,
    OnGive = function(ply)
        ply.immuneToGluon = true
    end,
    -- what happens when they get the suit equipped
    Abilities = {
        [1] = {
            Cooldown = 10,
            Action = function(s, ply)
                if (not IsFirstTimePredicted()) then return false end
                ply._simulationSuit = 10
                ply._hasSimulator = true

                if SERVER then
                    hook.Remove("EntityTakeDamage", ply)

                    hook.Add("EntityTakeDamage", ply, function(_, ent, dmg)
                        if (ent == ply and ent:IsPlayer()) then
                            net.Start("Simulator.Flashes")
                            net.Send(dmg:GetAttacker())
                        end
                    end)
                end

                ply:Wait(10, function()
                    if ply._hasSimulator then
                        ply:SetNW2Bool("ExtinctionSuit", false)
                        hook.Remove("EntityTakeDamage", ply)
                    end
                end)
            end
        }
    },
    OnRemove = function(ply)
        ply._hasSimulator = false
        ply:SetNW2Bool("ExtinctionSuit", false)
        hook.Remove("EntityTakeDamage", ply)
        ply.immuneToGluon = nil
    end
})

Armor:Add({
    Name = "Dragonfly Suit",
    Description = "Sets people around you on fire",
    Model = "models/konnie/asapgaming/destiny2/notorious.mdl",
    Entitie = "armor_dragon",
    Wallhack = true,
    Armor = 1500,
    Health = 1800,
    JumpPower = 360,
    Speed = 2.05,
    OnGive = function(ply)
        ply.immuneToGluon = true
    end,
    -- what happens when they get the suit equipped
    Abilities = {
        [1] = {
            Cooldown = 30,
            Action = function(s, ply)
                if (not IsFirstTimePredicted()) then return false end
                local effectdata = EffectData()
                effectdata:SetOrigin(ply:GetPos() + Vector(0, 0, 60))
                util.Effect("eff_firestorm", effectdata)
                ply:EmitSound("ambient/fire/ignite.wav")

                if SERVER then
                    for k, v in pairs(ents.FindInSphere(ply:GetPos(), 256)) do
                        if (v ~= ply and v:IsPlayer() or v:IsNPC()) then
                            local dist = v:GetPos():Distance(ply:GetPos()) / 256
                            v:Ignite(10 - dist * 10)
                        end
                    end
                end
            end
        }
    },
    OnRemove = function(ply)
        ply.immuneToGluon = nil
    end
})

Armor:Add({
    Name = "Cronus Suit",
    Description = "Lockpicks doors in 1 second",
    Model = "models/konnie/asapgaming/destiny2/intrepidexploit.mdl",
    Entitie = "armor_cronus",
    Cooldown = 1,
    Wallhack = true,
    Armor = 1200,
    Health = 1600,
    Speed = 2.05,
    OnGive = function(ply)
        ply.immuneToGluon = true

        hook.Add("lockpickTime", ply, function(self, pl)
            if (pl == self and self.armorSuit) then
                return 1
            elseif not self.armorSuit then
                hook.Remove("lockpickTime", ply)

                return
            end
        end)
    end,
    OnRemove = function(ply)
        hook.Remove("lockpickTime", ply)
        ply.immuneToGluon = nil
    end
})

Armor:Add({
    Name = "Z-105 Suit",
    Description = "Lockpicks doors in 1 second",
    Model = "models/konnie/asapgaming/destiny2/virtuous.mdl",
    Entitie = "armor_z105s",
    Cooldown = 1,
    Wallhack = true,
    Health = 2000,
    Armor = 2000,
    Speed = 2.5,
    OnGive = function(ply)
        ply.immuneToGluon = true

        hook.Add("lockpickTime", ply, function(self, pl)
            if (pl == self and self.armorSuit) then
                return 1
            elseif (not self.armorSuit) then
                hook.Remove("lockpickTime", ply)

                return
            end
        end)
    end,
    OnRemove = function(ply)
        hook.Remove("lockpickTime", ply)
        ply.immuneToGluon = nil
    end
})

Armor:Add({
    Name = "Hera Suit",
    Description = "Goes invisible while lockpicking",
    Model = "models/konnie/asapgaming/destiny2/equitisshade.mdl",
    Entitie = "armor_hera",
    Cooldown = 1,
    Wallhack = true,
    Armor = 1250,
    Health = 1500,
    Speed = 2.55,
    OnGive = function(ply)
        ply.immuneToGluon = true

        hook.Add("lockpickStarted", ply, function(self, pl)
            if (pl == self and self.armorSuit) then
                ply:SetNoDraw(true)
            elseif not self.armorSuit then
                hook.Remove("lockpickStarted", ply)

                return
            end
        end)

        hook.Add("onLockpickCompleted", ply, function(self)
            self:SetNoDraw(false)
        end)
    end,
    Abilities = {
        [1] = {
            Cooldown = 30,
            Action = function(s, ply)
                if CLIENT then return true end

                local tr = util.TraceHull({
                    start = ply:GetShootPos(),
                    endpos = ply:GetShootPos() + ply:GetAimVector() * 1000,
                    mins = -Vector(16, 16, 16),
                    maxs = Vector(16, 16, 16),
                    filter = ply
                })

                TFA.ParticleTracer("weapon_gauss_rail_normal", ply:GetShootPos() + Vector(0, 0, -16), tr.HitPos, false)

                timer.Simple(.2, function()
                    local eff = EffectData()
                    eff:SetOrigin(tr.HitPos)
                    eff:SetMagnitude(3)
                    eff:SetEntity(ply)
                    util.Effect("eff_bp1", eff, true, true)

                    for k, v in pairs(ents.FindInSphere(tr.HitPos, 200)) do
                        if not v:IsPlayer() or v == ply then continue end
                        if v:GetGang() ~= "" and v:GetGang() == ply then continue end
                        local dmg = DamageInfo()
                        dmg:SetDamage(v.armorSuit and 75 or 250)
                        dmg:SetDamageType(DMG_SHOCK)
                        dmg:SetAttacker(ply)
                        dmg:SetInflictor(ply)
                        v:CreateWeed(5)
                        v:TakeDamageInfo(dmg)
                    end
                end)
            end,
            Description = "Causes an explosion that will apply electrify to a player (Will spaz for few seconds)"
        }
    },
    OnRemove = function(ply)
        hook.Remove("lockpickStarted", ply)
        hook.Remove("onLockpickCompleted", ply)
        ply:SetNoDraw(false)
        ply.immuneToGluon = nil
    end
})