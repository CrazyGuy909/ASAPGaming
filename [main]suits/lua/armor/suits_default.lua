Armor.Save = false -- if set to true, all armors will be permanent and save
Armor.LoseOnDeath = true -- if set to true, it removes when you die.  

local function doInvisible(ply, seconds)
    ply.isInvis = true
    ply:AddEffects(EF_NODRAW)
    ply.maxInvisTime = seconds
    ply.invisTime = CurTime() + seconds

    ply.cloakTimer = ply:Wait(seconds, function()
        ply.isInvis = false
        ply:RemoveEffects(EF_NODRAW)
    end)
end

Armor:Add({
    Name = "x60 Space Suit", -- name it appears in the sandbox menu and darkrp menu
    Description = "Jump Boosters Activated - Anti Gravity Activated", -- description shown when using the suit
    Model = "models/player/n7legion/cerberus_guardian.mdl", -- what your model changes to
    Entitie = "armor_godlike", -- the entitie name for the armor
    Armor = 1500,
    Health = 1750,
    JumpPower = 500,
    Gravity = 0.6,
    Speed = 1.65,
    OnGive = function(ply)
        hook.Add("KeyPress", ply:SteamID64() .. "_megajump", function(p, key)
            if (p ~= ply) then return end
            if (key ~= IN_JUMP or not ply:IsOnGround()) then return end
            ply:SetNWVector("LastJump", ply:GetPos())
        end)
    end,
    Abilities = {
        [1] = {
            Cooldown = 10,
            Action = function(armor, ply)
                if (not ply:GetNWVector("LastJump", nil)) then return false, "You need to make a jump first!" end

                if SERVER then
                    local info = ents.Create("info_target")
                    info:SetPos(ply:GetPos() + Vector(0, 0, 30))
                    info:SetParent(ply)
                    info.Trail = util.SpriteTrail(info, 0, color_white, true, 64, 64, 1, 1 / 64, "tracer/hardlight_void_tracer")
                    ply:ScreenFade(SCREENFADE.IN, Color(200, 50, 255), 1, 0)
                    ply:EmitSound("player/portal_enter_02.wav")

                    timer.Simple(.1, function()
                        ply:SetPos(ply:GetNWVector("LastJump"))
                        ply:SetNWVector("LastJump", nil)
                    end)

                    timer.Simple(1, function()
                        if IsValid(info) then
                            info:Remove()
                        end
                    end)
                end

                return true
            end,
            Description = "Returns you to the last position you've jumped from"
        }
    },
    OnRemove = function(ply)
        ply:SetNWVector("LastJump", nil)
        hook.Remove("KeyPress", ply:SteamID64() .. "_megajump")
    end
})

-- what happens when the suit is removed
Armor:Add({
    Name = "x99 Space Suit", -- name it appears in the sandbox menu and darkrp menu
    Description = "Jump Boosters - Anti Gravity", -- description shown when using the suit
    Model = "models/suno/player/ghost/ply_ghost.mdl", -- what your model changes to
    Entitie = "armor_x99", -- the entitie name for the armor
    Health = 1500,
    Armor = 1200,
    JumpPower = 350,
    Speed = 1.85,
    Abilities = {
        [1] = {
            Cooldown = 20,
            Action = function(armor, ply)
                if (ply:IsOnGround()) then return false, "You must be on the air" end

                if (ply:GetNWBool("IsAntiGravity", false)) then
                    timer.Remove(ply:SteamID64() .. "nogravity")
                    ply:SetNWBool("IsAntiGravity", false)
                    ply:SetNWFloat("GravitySH", 1)
                    ply:SetMoveType(MOVETYPE_WALK)
                    ply:EmitSound("player/portal_enter_02.wav")

                    if IsValid(ply.Trail) then
                        ply.Trail:Remove()
                    end

                    return true
                end

                ply:SetNWBool("IsAntiGravity", true)
                ply:SetMoveType(MOVETYPE_FLY)
                ply:SetNWFloat("GravitySH", .1)
                ply:EmitSound("player/portal_enter_01.wav")

                if SERVER then
                    ply.Trail = util.SpriteTrail(ply, 0, color_white, true, 32, 0, 1, 1 / 32, "effects/wgun_trail")
                end

                timer.Create(ply:SteamID64() .. "nogravity", 5, 1, function()
                    if (ply:GetNWBool("IsAntiGravity", false)) then
                        ply:SetNWBool("IsAntiGravity", false)
                        ply:SetNWFloat("GravitySH", 1)
                        ply:SetMoveType(MOVETYPE_WALK)
                        ply:EmitSound("player/portal_enter_02.wav")

                        if IsValid(ply.Trail) then
                            ply.Trail:Remove()
                        end
                    end
                end)

                return 1
            end,
            Description = "Temporally disables gravity"
        }
    },
    OnRemove = function(ply)
        ply:SetNWBool("IsAntiGravity", false)
    end
})

-- what happens when the suit is removed
Armor:Add({
    Name = "Morpheus Suit", -- name it appears in the sandbox menu and darkrp menu
    Description = "Jump Boosters - Anti Gravity", -- description shown when using the suit
    Model = "models/konnie/asapgaming/destiny2/dreambane.mdl", -- what your model changes to
    Entitie = "armor_morpheus", -- the entitie name for the armor
    Health = 1400,
    Armor = 1400,
    JumpPower = 400,
    Gravity = 0.5,
    Speed = 1.2,
})

Armor:Add({
    Name = "Speed Suit", -- name it appears in the sandbox menu and darkrp menu
    Description = "Anti Gravity", -- description shown when using the suit
    Model = "models/player/n7legion/geth_infiltrator.mdl", -- what your model changes to
    Entitie = "armor_speedsuit", -- the entitie name for the armor
    Armor = 400,
    Health = 600,
    JumpPower = 350,
    Gravity = .9,
    Speed = 2,
})

Armor:Add({
    Name = "Broken Speed Suit", -- name it appears in the sandbox menu and darkrp menu
    Description = "Anti Gravity", -- description shown when using the suit
    Model = "models/player/lordvipes/me2_legion/legion_cvp.mdl", -- what your model changes to
    Entitie = "armor_borkspeedsuit", -- the entitie name for the armor
    Armor = 1250,
    Health = 1500,
    JumpPower = 350,
    Gravity = .9
})

Armor:Add({
    Name = "Scrap Suit", -- name it appears in the sandbox menu and darkrp menu
    Description = "Anti Gravity", -- description shown when using the suit
    Model = "models/konnie/asapgaming/destiny2/scatterhorn.mdl", -- what your model changes to
    Entitie = "armor_scrap", -- the entitie name for the armor
    Armor = 500,
    Health = 500,
    JumpPower = 250,
    Gravity = .5
})

Armor:Add({
    Name = "A-01 Suit", -- name it appears in the sandbox menu and darkrp menu
    Description = "Anti Gravity", -- description shown when using the suit
    Model = "models/konnie/asapgaming/destiny2/sunbreak.mdl", -- what your model changes to
    Entitie = "armor_a01su", -- the entitie name for the armor
    Armor = 500,
    Health = 500,
    JumpPower = 300,
    Gravity = 0.5,
    Speed = 1.25
})

Armor:Add({
    Name = "Nano Suit", -- name it appears in the sandbox menu and darkrp menu
    Description = "Jump Boosters", -- description shown when using the suit
    Model = "models/player/nanosuit/slow_nanosuit.mdl", -- what your model changes to
    Entitie = "armor_nano", -- the entitie name for the armor
    Armor = 500,
    Health = 500,
    JumpPower = 500,
    Speed = 1.5
})

local delay_of_boost = 5

Armor:Add({
    Name = "TAU Armor",
    Description = "Thrusters Activated",
    Model = "models/halo4/spartans/masterchief_player.mdl",
    Armor = 350,
    Health = 1500,
    Speed = 1.5,
    JumpPower = 200,
    Entitie = "armor_tau",
    Abilities = {
        [1] = {
            Cooldown = 15,
            Action = function(s, ply)
                if ((ply.armorLiftOff or 0) > CurTime()) then return end
                ply:SetVelocity((ply:GetAngles():Forward() * 800) + Vector(0, 0, 400))
                sound.Play("ambient/explosions/exp1.wav", ply:GetPos())
                ply.armorLiftOff = CurTime() + delay_of_boost
            end,
            Description = "Lift off"
        }
    }
})

Armor:Add({
    Name = "N7 Space Armor",
    Description = "Anti Gravity",
    Model = "models/player/combine_soldier_prisonguard.mdl",
    Armor = 400,
    Health = 800,
    Speed = 1.75,
    Gravity = 0.7,
    Entitie = "armor_n7"
})

Armor:Add({
    Name = "X-01 Prototype Suit", -- Wallhack
    Model = "models/player/suno/damwab/damwab.mdl",
    Description = "Anti Gravity - Shield Bubble",
    Entitie = "armor_wallhack",
    Wallhack = true,
    Armor = 1200,
    Health = 1500,
    Gravity = .65,
    JumpPower = 300,
    RunSpeed = 2,
    ScreenColor = Color(41, 128, 185, 35),
    OnGive = function(ply)
        if (IsValid(ply._shield)) then
            ply._shield:Remove()

            return
        end

        ply._shield = ents.Create("sent_waterbubble")
        ply._shield:Setup(ply)
        ply._shield:Spawn()
        ply:SetNW2Entity("ShieldEntity", ply._shield)
    end,
    Abilities = {
        [1] = {
            Cooldown = 20,
            Action = function(armor, ply)
                local bubble = ply:GetNW2Entity("ShieldEntity")
                if not IsValid(bubble) then return false, "You lost your ball" end
                bubble:SetStatus(true)
                bubble:SetModelScale(8, 0)

                bubble:Wait(7, function()
                    bubble:SetStatus(false)
                    bubble:SetModelScale(4, 0)
                end)
            end,
            Description = "Makes your bubble bigger and it also drows players inside it"
        }
    },
    OnRemove = function(ply)
        if IsValid(ply._shield) then
            ply._shield:Remove()
        end
    end
})

Armor:Add({
    Name = "Assassin Suit", -- Wallhack
    Description = "(Wallhack within 20 meters), (400 HP, 400 AP, +40% movement speed)",
    Model = "models/konnie/asapgaming/destiny2/phenotype.mdl",
    Entitie = "armor_assnor",
    Wallhack = true,
    Armor = 400,
    Health = 400,
    Gravity = .65,
    JumpPower = 300,
    Speed = 1.4,
    ScreenColor = Color(255, 0, 0, 15)
})

local hellOverlay = Material("skin/hellflame_overlay")
local noloop = false

Armor:Add({
    Name = "gX303 Suit", -- Dmg immune
    Description = "Anti Gravity - Immune to dmg for 5 seconds upon a 90 seconds cooldown",
    WallHack = true,
    Model = "models/me3/blagod/pm/n7soldier.mdl",
    Entitie = "armor_dmgimmune",
    Armor = 800,
    Health = 1200,
    JumpPower = 300,
    Speed = 1.9,
    HUDPaint = function(ply)
        if (ply.resist and ply.resist > 0) then
            ply.resist = ply.resist - FrameTime()
            Armor:DrawHUDBar("Overload:", ply.resist / 5, 5)

            if (ply.resist <= 0) then
                ply.resist = nil
            end
        end
    end,
    OnGive = function(ply)
        hook.Add("EntityTakeDamage", ply:SteamID64() .. "_nodmg", function(p, dmg)
            if (ply == p and p:GetNWBool("DMGResistor") and dmg:GetAttacker() ~= ply) then
                dmg:ScaleDamage(.25)
                dmg:GetAttacker():TakeDamageInfo(dmg)
                dmg:SetDamage(0)

                return true
            end
        end)
    end,
    Abilities = {
        [1] = {
            Cooldown = 30,
            Action = function(s, ply)
                ply.resist = 5
                ply:SetNWBool("DMGResistor", true)

                if SERVER then
                    ply:EmitSound("ambient/fire/ignite.wav")
                end

                timer.Create(ply:SteamID64() .. "_invuln", 5, 1, function()
                    if IsValid(ply) then
                        ply:SetNWBool("DMGResistor", false)
                    end
                end)
            end,
            Description = "You become invulnerable for 5 seconds (You reflect 25% damage dealt while invulnerable)"
        }
    },
    PostPlayerDraw = function(ply)
        if not noloop and ply:GetNWBool("DMGResistor") then
            noloop = true
            render.MaterialOverride(hellOverlay)
            render.SuppressEngineLighting(true)
            ply:DrawModel()
            render.SuppressEngineLighting(false)
            render.MaterialOverride(nil)
            noloop = false
        end
    end,
    OnRemove = function(ply)
        timer.Remove(ply:SteamID64() .. "_invuln")
        hook.Remove("EntityTakeDamage", ply:SteamID64() .. "_nodmg")
        ply:SetNWBool("DMGResistor", false)
        ply.dmgImmuneSuit = nil
    end
})

Armor:Add({
    Name = "Janus Suit", -- Dmg immune
    Description = "Anti Gravity",
    Model = "models/konnie/asapgaming/destiny2/malenorthlight.mdl",
    Entitie = "armor_janusr",
    ScreenColor = Color(0, 0, 0, 0),
    Health = 2000,
    Armor = 2000,
    Gravity = .50,
    JumpPower = 300,
    Speed = 1.15,
    Wallhack = true,
    OnRemove = function(ply)
        ply.immuneToDmg = nil
    end,
    Abilities = {
        [1] = {
            Cooldown = 90,
            Action = function(s, ply)
                ply.immuneToDmg = true

                if (SERVER) then
                    timer.Create("ArmorSuit_ParticleEffects" .. ply:SteamID64(), 0.33, 15, function()
                        local effectData = EffectData()
                        local vPoint = ply:LocalToWorld(ply:OBBCenter())
                        effectData:SetStart(vPoint)
                        effectData:SetOrigin(vPoint)
                        effectData:SetScale(8)
                        effectData:SetFlags(3)
                        effectData:SetColor(0)
                        util.Effect("bloodspray", effectData)
                    end)
                end

                ply:Wait(5, function()
                    ply.immuneToDmg = nil
                end)
            end
        }
    }
})

Armor:Add({
    Name = "Battle Pass 1 suit", -- Reinhardt
    Description = "Anti Gravity - Gluon Immune - No Explosive Damage - Stompy",
    Model = "models/player/ow_reinhardt_classic_pm.mdl",
    Entitie = "armor_bp1",
    Wallhack = true,
    Health = 4000,
    Armor = 4000,
    JumpPower = 300,
    Gravity = 0.75,
    Speed = 1.75,
    OnGive = function(ply)
        hook.Add("EntityTakeDamage", ply:SteamID64() .. "_nobombs", function(ent, dmg)
            if (ent == ply and dmg:IsExplosionDamage()) then
                dmg:SetDamage(0)

                return true
            end
        end)

        hook.Add("OnPlayerHitGround", ply, function(s, ply, water, floater, speed)
            if (ply ~= s) then return end
            if (speed < 300) then return end
            local power = speed / 300
            util.ScreenShake(s:GetPos(), 30 * power, 60, 1, 256 * power)
            s:EmitSound("gbombs/fab/fab_initial.wav")

            for k, v in pairs(ents.FindInSphere(s:GetPos(), 256 * power)) do
                if (not v:IsPlayer() or v == s) then continue end
                if (not v.armorSuit) then continue end
                if (v:GetGang() ~= "" and v:GetGang() == s:GetGang()) then continue end
                local dmg = DamageInfo()
                local dist = 1 - v:GetPos():Distance(s:GetPos()) / 256
                dmg:SetAttacker(s)
                dmg:SetInflictor(s)
                dmg:SetDamageType(DMG_ALWAYSGIB)
                dmg:SetDamage(math.Clamp(v:Health() * .2, 10, 50) * dist)
                v:TakeDamageInfo(dmg)

                if (v:Health() < s:Health() and v:IsOnGround()) then
                    v:SetPos(v:GetPos() + Vector(0, 0, 2))
                    v:SetVelocity(Vector(0, 0, 100 * power * dist))
                end
            end
        end)

        ply.immuneToGluon = true
    end,
    Abilities = {
        [1] = {
            Cooldown = 30,
            Action = function(armor, ply)
                if SERVER then
                    local eff = EffectData()
                    eff:SetOrigin(ply:GetPos())
                    eff:SetEntity(ply)
                    util.Effect("eff_bp1", eff, true, true)
                    util.ScreenShake(ply:GetPos(), 40, 60, 1, 400)

                    for k, v in pairs(ents.FindInSphere(ply:GetPos(), 400)) do
                        if (not v:IsPlayer() or v == ply) then continue end
                        if (v:GetGang() ~= "" and v:GetGang() == ply:GetGang()) then continue end
                        local dmg = DamageInfo()
                        local dist = 1 - v:GetPos():Distance(ply:GetPos()) / 400
                        dmg:SetAttacker(ply)
                        dmg:SetInflictor(ply)
                        dmg:SetDamageType(DMG_ALWAYSGIB)
                        dmg:SetDamage(math.Clamp(v:Health() * .25, 10, 200))
                        v:TakeDamageInfo(dmg)
                        v:SetPos(v:GetPos() + Vector(0, 0, 2))
                        v:SetVelocity(Vector(0, 0, 300) + (v:GetPos() - ply:GetPos()):GetNormalized() * 300)
                        v:SelectWeapon(v:HasWeapon("weapon_fists") and "weapon_fists" or "weapon_physgun")
                    end
                end

                return true
            end,
            Description = "Throw away your enemies in a small radius, players will be unarmed"
        }
    },
    OnRemove = function(ply)
        hook.Remove("EntityTakeDamage", ply:SteamID64() .. "_nobombs")
        hook.Remove("OnPlayerHitGround", ply)
        ply.immuneToGluon = nil
    end
})

Armor:Add({
    Name = "Prototype z07 Teleportation Suit", -- Apex legends portal shiz
    Model = "models/blagod/mass_effect/pm/mercenaries/cat6/sniper_pm.mdl",
    Entitie = "armor_z07_tp",
    Health = 1000,
    Armor = 750,
    Speed = 1.3,
    Abilities = {
        [1] = {
            Cooldown = 60,
            Action = function(s, ply)
                if SERVER then
                    local targetZone = ents.Create("gmod_button")
                    targetZone:SetModel("models/mcmodelpack/items/pearl.mdl")
                    targetZone:SetPos(ply:GetPos() + ply:OBBCenter())
                    targetZone:SetOwner(ply)
                    targetZone:Spawn()
                    targetZone:EmitSound("garrysmod/balloon_pop_cute.wav")
                    targetZone.owner = ply
                    SafeRemoveEntityDelayed(targetZone, 30)
                    targetZone.Think = function(s)
                        s:SetAngles(Angle(0, (SERVER and CurTime() or RealTime()) * 96 % 360), 0)
                    end
                    targetZone.Use = function(s, act)
                        if not IsValid(ply) then
                            targetZone:Remove()
                            return
                        end
                        act:SetPos(ply:GetPos())
                        act:SetVelocity(Vector(0, 0, 0))
                        act:EmitSound("ambient/levels/citadel/portal_beam_shoot5.wav")
                        act:ScreenFade(SCREENFADE.IN, color_white, .65, .15)
                        act:SetFOV(30, 0)
                        act:SetFOV(0, .5)
                        SafeRemoveEntity(targetZone)
                    end

                    table.insert(ply.activePortals, targetZone)
                end
            end,
            Description = "Places a pearl to teleport a player into your location"
        }
    },
    OnGive = function(ply)
        for k, v in pairs(ply.activePortals or {}) do
            SafeRemoveEntity(v)
        end
        ply.activePortals = {}
    end,
    OnRemove = function(ply)
        for k, v in pairs(ply.activePortals or {}) do
            SafeRemoveEntity(v)
        end
        ply.activePortals = {}
    end
})

Armor:Add({
    Name = "Prototype z10 Chemist Suit", -- caustic
    Description = "Place a trap down that will trigger once an enemy is nearby",
    Model = "models/blagod/mass_effect/pm/mercenaries/cat6/heavy_pm.mdl",
    Entitie = "armor_z10_chemist",
    HUDPaint = function(ply)
        Armor:DrawHUDBar("Traps available:", (2 - ply:GetNWInt("PlacedTraps")) / 2, 2, 2)
    end,
    Health = 1500,
    Armor = 1000,
    Speed = 1.1,
    JumpPower = 300,
    OnGive = function(ply)
        ply.causticTrap = true
    end,
    Abilities = {
        [1] = {
            Cooldown = 30,
            Action = function(s, ply)
                if (ply:GetNWInt("PlacedTraps", 0) >= 2) then return false, "You have too many active traps" end

                if SERVER then
                    local trap = ents.Create("sent_gastrap")
                    trap:SetPos(ply:GetPos())
                    trap:SetOwner(ply)
                    trap:Spawn()

                    if not ply.causticTraps then
                        ply.causticTraps = {}
                    end

                    ply:SetNWInt("PlacedTraps", ply:GetNWInt("PlacedTraps", 0) + 1)
                    table.insert(ply.causticTraps, trap)
                end
            end,
            Description = "Places a venom tramp"
        }
    },
    OnRemove = function(ply)
        ply.causticTrap = false

        if ply.causticTraps then
            for k, v in pairs(ply.causticTraps) do
                if IsValid(v) then
                    v:Remove()
                end
            end

            table.Empty(ply.causticTraps)
        end
    end
})

Armor:Add({
    Name = "Prototype z02 Speed Suit", -- octane
    Description = "Place down a jump pad that will propell players",
    Model = "models/blagod/mass_effect/pm/mercenaries/cat6/specialist_pm.mdl",
    Entitie = "armor_z02_speed",
    Health = 1500,
    Armor = 1200,
    Speed = 2,
    JumpPower = 500,
    OnGive = function(ply)
        SafeRemoveEntity(ply.octaneJumper)
    end,
    Abilities = {
        [1] = {
            Cooldown = 10,
            Action = function(s, ply)
                if SERVER then
                    SafeRemoveEntity(ply.octaneJumper)
                    local pad = ents.Create("octanepad")
                    pad:SetPos(ply:GetPos() + (ply:GetForward() * 75) + Vector(0, 0, 50))
                    pad:Spawn()
                    pad:DropToFloor()
                    ply:SetNWInt("PlacedTraps", ply:GetNWInt("PlacedTraps", 0) + 1)
                    ply.octaneJumper = pad
                end
            end
        }
    },
    OnRemove = function(ply)
        SafeRemoveEntity(ply.octaneJumper)
    end
})

Armor:Add({
    Name = "Battle Pass 2 suit",
    Description = "Thrusters Activated - Anti Gravity Activated - Health Regen",
    Model = "models/blagod/mass_effect/pm/w40k/alliance_tactical_n7.mdl",
    Entitie = "armor_bp2",
    Wallhack = true,
    Armor = 3000,
    Health = 3000,
    Speed = 1.5,
    Gravity = .8,
    HUDPaint = function(ply)
        if (not ply.suitIsGod or ply.suitGodTime < 0) then return end
        ply.suitGodTime = ply.suitGodTime - FrameTime()
        Armor:DrawHUDBar("God mode:", ply.suitGodTime / 10, 1)
    end,
    OnGive = function(ply)
        local tag = ply:SteamID() .. "_bp2_regen"
        timer.Create(tag, 2, 0, function()
            if not IsValid(ply) or not ply:Alive() or not ply.armorSuit then 
                timer.Remove(tag)
                return
            end
            ply:SetHealth(math.min(ply:Health() + 10, ply:GetMaxHealth()))
        end)
    end,
    OnRemove = function(ply)
        local tag = ply:SteamID() .. "_bp2_regen"
        ply.suitIsGod = nil
        ply.suitGodTime = nil
        if SERVER then
            ply:GodDisable()
        end
        timer.Remove(tag)
    end,
    Abilities = {
        [1] = {
            Cooldown = 5,
            Action = function(s, ply)
                if SERVER then
                    ply:SetVelocity((ply:GetAngles():Forward() * 800) + Vector(0, 0, 400))
                    sound.Play("ambient/explosions/exp1.wav", ply:GetPos())
                end

                return true
            end,
        },
        [2] = {
            Cooldown = 180,
            Action = function(s, ply)
                ply.suitIsGod = true
                ply.suitGodTime = 10

                if SERVER then
                    ply:GodEnable()
                end

                ply:Wait(ply.suitGodTime, function()
                    if IsValid(ply) and SERVER then
                        ply:GodDisable()
                    end
                end)
            end
        }
    }
})

Armor:Add({
    Name = "Royal Assassin Suit",
    Health = 1000,
    Armor = 1000,
    Speed = 2.5,
    Model = "models/epangelmatikes/nc/neo_crusader_g.mdl",
    Entitie = "armor_rass",
})

Armor:Add({
    Name = "Battle Pass 5 Anubis Armor",
    Model = "models/konnie/asapgaming/destiny2/gardenofsalvation.mdl",
    Entitie = "armor_anubis",
    Armor = 500,
    Health = 5000,
    Speed = 3
})

Armor:Add({
    Name = "Prototype z00 Cloaking Suit",
    Description = "Goes invisible temporarily (5 minute cooldown)",
    Model = "models/blagod/mass_effect/pm/cerberus/eng_cerb.mdl",
    Entitie = "armor_z00_cloak",
    Health = 1000,
    Armor = 1000,
    Speed = 1.3,
    Abilities = {
        [1] = {
            Cooldown = 300,
            Action = function(s, ply)
                doInvisible(ply, 30)
                return true
            end
        }
    },
    HUDPaint = function(ply)
        if (ply.isInvis) then
            Armor:DrawHUDBar("Invisibility Duration", math.Clamp((ply.invisTime - CurTime()) / ply.maxInvisTime, 0, 1), 0)
        end
    end,
    OnRemove = function(ply)
        if (ply.cloakTimer) then
            ply.cloakTimer:Remove()
        end

        ply.isInvis = false
        ply:SetNoDraw(false)
    end
})

Armor:Add({
    Name = "Mantis Suit",
    Description = "Wallhacks - Anti Gravity - Invisible temporarily (5 minute cooldown) - Gluon Immune",
    Model = "models/konnie/asapgaming/destiny2/futurefacing.mdl",
    Entitie = "armor_mantis",
    Wallhack = true,
    Health = 1000,
    Armor = 1000,
    Gravity = .5,
    Speed = 1.1,
    OnGive = function(ply)
        ply.immuneToGluon = true
    end,
    Abilities = {
        [1] = {
            Cooldown = 200,
            Action = function(s, ply)
                doInvisible(ply, 20)
                return true
            end
        }
    },
    HUDPaint = function(ply)
        if (ply.isInvis) then
            Armor:DrawHUDBar("Invisibility Duration", math.Clamp((ply.invisTime - CurTime()) / ply.maxInvisTime, 0, 1), 0)
        end
    end,
    OnRemove = function(ply)
        if (ply.cloakTimer) then
            ply.cloakTimer:Remove()
        end

        ply.immuneToGluon = nil
        ply.isInvis = false
        ply:SetNoDraw(false)
    end
})

Armor:Add({
    Name = "Royal Knight Suit", -- Wallhack
    Description = "Wallhack",
    Model = "models/nigt_sentinel_1.mdl",
    Entitie = "armor_rknight",
    Wallhack = true,
    Health = 1200,
    Armor = 1750,
    Speed = 2,
    Gravity = .95
})

Armor:Add({
    Name = "Royal Warrior Suit", -- Reinhardt
    Description = "Wallhack - Gluon Immune",
    Model = "models/vasey105/bdo/armour/phm_00_0007_pm.mdl",
    Entitie = "armor_rwarrior",
    Wallhack = true,
    Health = 1200,
    Armor = 1750,
    Speed = 2,
    OnGive = function(ply)
        ply.immuneToGluon = true
    end,
    OnRemove = function(ply)
        ply.immuneToGluon = nil
    end
})

Armor:Add({
    Name = "Rioter Suit", -- Reinhardt
    Description = "Wallhack",
    Model = "models/konnie/asapgaming/destiny2/tangledweb.mdl",
    Entitie = "armor_rioters",
    Wallhack = true,
    Health = 2000,
    Armor = 2000,
    Speed = 1.5,
})

Armor:Add({
    Name = "x35 Power Suit", -- Reinhardt
    Description = "Wallhack",
    Model = "models/vanquish/player/augmented_reaction_suit.mdl",
    Entitie = "armor_x35",
    Wallhack = true,
    Health = 1000,
    Armor = 1000,
    Speed = 2
})

Armor:Add({
    Name = "Battle Pass 3 suit",
    Description = "Jetpack - Wallhacks - Gluon Gun Immune - Anti Gravity",
    Model = "models/mechsassault2_lonewolf/battle_armor.mdl",
    Entitie = "armor_bp3",
    Wallhack = true,
    Health = 3500,
    Armor = 3500,
    Speed = 1.35,
    Gravity = .45,
    OnGive = function(ply)
        ply.immuneToGluon = true
    end,
    HUDPaint = function(ply)

        if IsValid(ply:GetNW2Entity("ShieldEntity")) then
            local progress = math.Clamp((ply:GetNW2Entity("ShieldEntity"):GetDuration() - CurTime()) / 15, 0, 1)
            Armor:DrawHUDBar("Shield Duration", progress, 1) 
        end

        if IsValid(ply:GetNW2Entity("HeavenEntity")) then
           local progress = math.Clamp((ply:GetNW2Float("HeavenExpire") - CurTime()) / 10, 0, 1)
            Armor:DrawHUDBar("Heaven Duration", progress, 2)
        end
    end,
    Abilities = {
        [1] = {
            Cooldown = 40,
            Description = "Summons a shield which will cover your back",
            Action = function(armor, ply)
                if IsValid(ply:GetNW2Entity("ShieldEntity")) then return end

                if SERVER then
                    if (IsValid(ply._shield)) then return end
                    ply._shield = ents.Create("sent_dynamicshield")
                    ply._shield:SetOwner(ply)
                    ply._shield:Spawn()
                    ply:SetNW2Entity("ShieldEntity", ply._shield)
                end
            end
        },
        [2] = {
            Cooldown = 60,
            Description = "Heaven Scorcher for 8 seconds",
            Action = function(armor, ply)
                if IsValid(ply:GetNW2Entity("HeavenEntity")) then return end

                if SERVER then
                    if (IsValid(ply._heaven)) then return end
                    ply._heaven = ply:Give("tfa_cso_heavenscorcher")
                    ply:SelectWeapon("tfa_cso_heavenscorcher")
                    ply:Wait(8, function()
                        SafeRemoveEntity(ply._heaven)
                        ply._heaven = nil
                        if IsValid(ply.lastWeapon) then
                            ply:SelectWeapon(ply.lastWeapon:GetClass())
                        end
                    end)
                    ply:SetNW2Float("HeavenExpire", CurTime() + 8)
                    ply:SetNW2Entity("HeavenEntity", ply._heaven)
                end
            end
        },
    },
    OnRemove = function(ply)
        ply.immuneToGluon = nil
        ply:Wait(.1, function()
            ply:SetGravity(1)
            ply:SetNWFloat("GravitySH", 0)
        end)
    end
})