AddCSLuaFile()
local baseJump = 300
local jumpIncrease = 40
local Gluongun = false

local function skolas_movement(ply, mv)
    if (ply:KeyDown(IN_JUMP)) then
        local vel = mv:GetVelocity()
        mv:SetVelocity(Vector(vel.x * 1.01, vel.y * 1.01, math.Clamp(vel.z + 10 * (1 / FrameTime()), -50, 400)))

        if (CLIENT and not ply.airSound) then
            ply.airSound = ply:StartLoopingSound("ambient/gas/cannister_loop.wav")
        end
    elseif (ply.airSound) then
        ply:StopLoopingSound(ply.airSound)
        ply.airSound = nil
    end
end

local rock = Material("models/props_canal/rock_riverbed01a")
local hellOverlay = Material("skin/hellflame_overlay")
local heal = Material("sprites/plasmagun_exp")
local trail = Material("effects/qc_trail")
local push = Material("effects/muzzleflashx_nemole_w")
local noloop = false

Armor:Add({
    Name = "Skolas Suit",
    Description = "May the never released suit win",
    Model = "models/konnie/asapgaming/destiny2/skolas.mdl",
    Entitie = "armor_skolas",
    HUDPaint = function(ply) end,
    OnGiveClient = function(ply)
        hook.Add("Move", ply:SteamID64() .. "_skmove", function(p, mv)
            if (p == ply and ply:GetNWBool("Skolas.AllowFly", false)) then
                skolas_movement(p, mv)
            end
        end)
    end,
    PrePlayerDraw = function(ply)
        if (ply:GetNWBool("Skolas.IsBoulder")) then
            render.SetMaterial(rock)
            render.SuppressEngineLighting(true)
            render.DrawSphere(ply:GetPos() + Vector(0, 0, 32), 42, 8, 8, color_white)
            render.SuppressEngineLighting(false)

            return true
        end
    end,
    PostPlayerDraw = function(ply)
        if (ply:GetNWBool("Skolas.IsHealing")) then
            render.SetMaterial(heal)
            render.DrawSprite(ply:EyePos() - Vector(0, 0, 30), 172, 172, Color(0, 255, 255))
        end

        if (ply:GetNWBool("Skolas.AllowFly") and not ply:IsOnGround()) then
            render.SetMaterial(trail)
            local tr = util.QuickTrace(ply:GetPos(), Vector(0, 0, -900), ply)
            render.DrawBeam(ply:GetPos(), tr.HitPos, 16, (RealTime() * 2) % 1, (RealTime() * 2) % 1 - 1, color_white)
            render.SetMaterial(push)
            render.DrawSprite(ply:GetPos(), 48, 48, color_white)
            render.DrawSprite(tr.HitPos, 48, 48, color_white)
        end

        if not noloop and ply:GetNWBool("Skolas.OnFire") then
            noloop = true
            render.MaterialOverride(hellOverlay)
            render.SuppressEngineLighting(true)
            ply:DrawModel()
            render.SuppressEngineLighting(false)
            render.MaterialOverride(nil)
            noloop = false
        end
    end,
    Armor = 3000,
    Health = 4500,
    JumpPower = baseJump + jumpIncrease,
    Speed = 1.45,
    OnGive = function(ply)
        ply.immuneToGluon = Gluongun

        hook.Add("Move", ply:SteamID64() .. "_skmove", function(p, mv)
            if (p == ply and ply:GetNWBool("Skolas.AllowFly", false)) then
                skolas_movement(p, mv)
            end
        end)

        hook.Add("EntityTakeDamage", ply:SteamID64() .. "_skfire", function(p, dmg)
            if (ply == dmg:GetAttacker() and dmg:GetAttacker():GetNWBool("Skolas.OnFire")) then
                dmg:ScaleDamage(1.2)
                if not IsValid(dmg:GetVictim()) then return end

                if ((dmg:GetVictim().nextIgnite or 0) < CurTime() and math.random(1, 10) <= 3) then
                    dmg:GetVictim():Ignite(3, p)
                    dmg:GetVictim().nextIgnite = CurTime() + 3
                end
            end

            if (ply == p and ply:GetNWBool("Skolas.IsBoulder")) then
                dmg:SetScale(.25)
            end
        end)
    end,
    Abilities = {
        [1] = {
            Cooldown = 25,
            Action = function(armor, ply)
                ply:SetNWBool("Skolas.AllowFly", true)

                timer.Create(ply:SteamID64() .. "_skolas_fly", 5, 1, function()
                    if IsValid(ply) then
                        ply:SetNWBool("Skolas.AllowFly", false)
                    end
                end)

                return true
            end,
            Description = "Allows you to fly for 5 seconds"
        },
        [2] = {
            Cooldown = 30,
            Description = "Turns you into a boulder and protects you from 75% incoming damage",
            Action = function(armor, ply)
                if (ply:GetNWBool("Skolas.IsBoulder")) then
                    ply:Freeze(false)
                    ply:SetNWBool("Skolas.IsBoulder", false)
                    timer.Remove(ply:SteamID64() .. "_skolas_boulder")

                    return true
                end

                ply:SetNWBool("Skolas.IsBoulder", true)
                ply:Freeze(true)

                timer.Create(ply:SteamID64() .. "_skolas_boulder", 5, 1, function()
                    if IsValid(ply) then
                        ply:Freeze(false)
                        ply:SetNWBool("Skolas.IsBoulder", false)
                    end
                end)

                return 3
            end
        },
        [3] = {
            Cooldown = 30,
            Action = function(armor, ply)
                ply:SetNWBool("Skolas.IsHealing", true)

                timer.Create(ply:SteamID64() .. "_skolas_heal", 1, 5, function()
                    for k, v in pairs(ents.FindInSphere(ply:GetPos(), 400)) do
                        if (not v:IsPlayer()) then continue end

                        if ((ply:GetGang() == "" and v == ply) or (ply:GetGang() ~= "" and v:GetGang() == ply:GetGang())) then
                            local heal_amount = (v:GetMaxHealth() - v:Health()) * .2
                            v:SetHealth(v:Health() + math.floor(heal_amount))
                        end
                    end
                end)

                timer.Simple(6, function()
                    if IsValid(ply) then
                        ply:SetNWBool("Skolas.IsHealing", false)
                    end
                end)

                return true
            end,
            Description = "Heals yourself and your gang members around you across 5 seconds"
        },
        [4] = {
            Cooldown = 25,
            Action = function(armor, ply)
                ply:SetNWBool("Skolas.OnFire", true)

                timer.Create(ply:SteamID64() .. "_skolas_fire", 5, 1, function()
                    if IsValid(ply) then
                        ply:SetNWBool("Skolas.OnFire", false)
                    end
                end)

                return true
            end,
            Description = "Deal 20% extra damage and there's a 30% chance of igniting your target"
        },
    },
    OnRemove = function(ply)
        timer.Remove(ply:SteamID64() .. "_skolas_fire")
        timer.Remove(ply:SteamID64() .. "_skolas_heal")
        timer.Remove(ply:SteamID64() .. "_skolas_boulder")
        timer.Remove(ply:SteamID64() .. "_skolas_fly")
        ply:SetNWBool("Skolas.AllowFly", false)
        ply:SetNWBool("Skolas.OnFire", false)
        ply:SetNWBool("Skolas.IsBoulder", false)
        hook.Remove("Move", ply:SteamID64() .. "_skmove")
    end,
    OnRemoveClient = function(ply)
        timer.Remove(ply:SteamID64() .. "_skolas_fire")
        timer.Remove(ply:SteamID64() .. "_skolas_heal")
        timer.Remove(ply:SteamID64() .. "_skolas_boulder")
        timer.Remove(ply:SteamID64() .. "_skolas_fly")
        hook.Remove("Move", ply:SteamID64() .. "_skmove")

        if (ply.airSound) then
            ply:StopLoopingSound(ply.airSound)
            ply.airSound = nil
        end
    end
})