local tail = {
    [1] = "10 Suit",
    [2] = "20 Suit",
    [3] = "30 Suit",
    [4] = "40 Suit",
    [5] = "50 Ultimate Suit",
}

local mdls = {
    [1] = "_sunbreak",
    [2] = "_pacific",
    [3] = "_monarchy",
    [4] = "_luxe",
    [5] = "",
}

local rewindtime = {3, 3, 15, 20, 30}

local playTime = 0
local soundData = {}

for k = 1, 9 do
    if (k == 4) then
        soundData[k] = Sound("ambient/energy/zap" .. 2 .. ".wav")
    end

    soundData[k] = Sound("ambient/energy/zap" .. k .. ".wav")
end

if SERVER then
    util.AddNetworkString("Rescuer.Zap")
    util.AddNetworkString("Rescuer.SetVMMode")
end

if CLIENT then
    local mode = 0

    local types = {
        [1] = Material("sprites/trinity_stun_particles"),
        [2] = Material("sprites/m95ghost_eye"),
        [3] = Material("sprites/m95_white_tiger_eye"),
    }

    net.Receive("Rescuer.SetVMMode", function()
        local md = net.ReadInt(4)
        local ent = net.ReadEntity()
        local doReturn = net.ReadBool()

        if (doReturn) then
            timer.Simple(3, function()
                if IsValid(ent) then
                    ent._rescueType = nil
                end
            end)
        end

        if (ent ~= LocalPlayer()) then
            ent._rescueType = md

            return
        end

        mode = md
        hook.Remove("PostDrawViewModel", "Rescuer.Buff")
        if (mode <= 0) then return end

        hook.Add("PostDrawViewModel", "Rescuer.Buff", function(vm, player, weapon)
            local attachment = vm:GetAttachment(1)
            if not attachment then return end
            render.SetMaterial(types[mode])
            render.DrawSprite(attachment.Pos, 24, 24, color_white)
        end)
    end)

    hook.Add("PostPlayerDraw", "Rescuer.ShowAbilities", function(ply)
        if (ply._rescueType and ply._rescueType > 0) then
            local wep = ply:GetActiveWeapon()
            if (not IsValid(wep)) then return end
            local att = wep:GetAttachment(wep:LookupAttachment("muzzle"))

            if (att) then
                render.SetMaterial(types[ply._rescueType])
                render.DrawSprite(att.Pos, 32, 32, color_white)
            end
        end
    end)
end

local function CreateRollback(max)
    --if not LocalPlayer().playingAnim then return end
    local lerpPos = LocalPlayer():GetPos()
    local lerpAng = EyeAngles()
    local oriPos = LocalPlayer():GetPos()
    local oriAng = EyeAngles()
    local targetPos = LocalPlayer()._rescuerTags[1][1]
    local targetAng = LocalPlayer()._rescuerTags[1][2]
    local delta = 1 / 5
    local hookName = "Rescuer.ViewController"
    local timeSquat = 0
    local prg = 2
    hook.Remove("CalcView", hookName)
    hook.Remove("ShouldDisableLegs", hookName)
    hook.Add("ShouldDisableLegs", hookName, function() return true end)

    hook.Add("CalcView", hookName, function(ply, pos, ang)
        if (timeSquat > delta) then
            if (timeSquat >= .5 or not ply._rescuerTags[prg]) then
                hook.Remove("CalcView", hookName)
                hook.Remove("ShouldDisableLegs", hookName)

                return
            end

            timeSquat = 0
            targetPos = ply._rescuerTags[prg][1]
            targetAng = ply._rescuerTags[prg][2]
            oriPos = lerpPos
            oriAng = lerpAng
            prg = prg + 1
        end

        timeSquat = timeSquat + FrameTime() * 2
        local left = math.Clamp(timeSquat / delta, 0, 1)
        lerpPos = LerpVector(left, oriPos, targetPos)
        lerpAng = LerpAngle(left, oriAng, targetAng)

        local tbl = {
            origin = lerpPos + Vector(0, 0, 60),
            drawviewer = true,
            angles = lerpAng,
            fov = 60 + 60 * Lerp(timeSquat, 1, 0)
        }

        return tbl
    end)
end

net.Receive("Rescuer.Zap", function()
    local pos = net.ReadVector()
    local eff = EffectData()
    eff:SetOrigin(pos)
    eff:SetScale(500)
    eff:SetMagnitude(500)
    util.Effect("TeslaHitboxes", eff, true, true)
    EmitSound(soundData[math.random(1, 9)], pos, LocalPlayer():EntIndex())
end)

local function SuitRemove(ply, k)
    if CLIENT then
        local hookName = "Rescuer.ViewController"
        hook.Remove("CalcView", hookName)
        hook.Remove("ShouldDisableLegs", hookName)
        timer.Remove("Rescuer.ShadowCountdown")
    else
        local shadowTimerID = ply:SteamID64() .. "_rescuerShadow"
        local deathHookName = "Rescuer.Return_" .. ply:SteamID64()

        if IsValid(ply._rescuerShadow) then
            ply._rescuerShadow:Remove()
        end

        ply:GodDisable()
        ply:SetNoDraw(false)
        timer.Remove(shadowTimerID)
        hook.Remove("PlayerDeath", deathHookName)
        ply._oldRunSpeed = nil
        ply:SetRunSpeed(500)
    end
end

local function CreateTimescaleBullet(ent, x)
    local hookName = "Rescuer_Slowdown" .. (ent:SteamID64() or "ASDF")

    if SERVER then
        ent:SetLaggedMovementValue(math.Clamp(1 / x, .1, 5))
        timer.Remove(hookName)

        timer.Create(hookName, 5, 1, function()
            hook.Remove("EntityFireBullets", hookName)
            if not IsValid(ent) then return end
            ent:SetLaggedMovementValue(1)
            ent:SetMaterial("")
            net.Start("Rescuer.SetVMMode")
            net.WriteInt(0, 4)
            net.WriteEntity(ent)
            net.Broadcast()
        end)
    else
        timer.Create(hookName, 5, 1, function()
            hook.Remove("EntityFireBullets", hookName)
        end)
    end

    hook.Remove("EntityFireBullets", hookName)

    hook.Add("EntityFireBullets", hookName, function(fire)
        if not IsValid(ent) then
            hook.Remove("EntityFireBullets", hookName)
        end

        if (ent == fire) then
            local wep = ent:GetActiveWeapon()
            local time = wep:GetNextPrimaryFire() - CurTime()
            wep:SetNextPrimaryFire(CurTime() + math.max(1 / 11, time * x))
        end
    end)
end

local runPower = .4
local baseHealth = 1500
local baseArmor = 1600
local healthIncrease = 150
local armorIncrease = 150
local baseJump = 380
local jumpIncrease = 20
local wallhack = true
local Gluongun = false
local class = "armor_rescuer"
local mdl = "models/konnie/asapgaming/destiny2/moonfang_hunter"

local function addSuit(k)
    Armor:Add({
        Name = "S-80" .. (k > 1 and tail[k] or ""),
        Description = "(+" .. (100 * runPower * k) .. "% Run Speed +" .. (baseArmor + k * healthIncrease) .. " Armor +" .. (baseHealth + k * armorIncrease) .. " Health)" .. (wallhack and "(Wallhack)" or "") .. (Gluongun and "(Gluon Inmunity)" or ""),
        Model = mdl .. mdls[k] .. ".mdl",
        Entitie = class .. "_" .. k,
        Wallhack = true,
        HUDPaint = function(ply)
            local percent = (#(ply._rescuerTags or {}) / (2 + k))
            Armor:DrawHUDBar("Charges:", percent, -0, 2 + k)
        end,
        Health = baseHealth + k * healthIncrease,
        Armor = baseArmor + k * armorIncrease,
        JumpPower = baseJump + k * jumpIncrease,
        Speed = 1 + runPower * k,
        OnGive = function(ply)
            ply.immuneToGluon = Gluongun
            local hookName = "Rescuer_" .. ply:SteamID64()
            ply._rescuerTags = {}

            timer.Create(hookName, 7.5, 0, function()
                if not IsValid(ply) or not ply:Alive() then
                    timer.Remove(hookName)

                    return
                end

                table.insert(ply._rescuerTags, 1, {ply:GetPos(), ply:GetAngles()})

                table.remove(ply._rescuerTags, 3 + k)
            end)
        end,
        OnGiveClient = function()
            local ply = LocalPlayer()
            local hookName = "Rescuer_" .. ply:SteamID64()
            ply.playingAnim = false
            ply._rescuerTags = {}

            timer.Create(hookName, 7.5, 0, function()
                if not IsValid(ply) or not ply:Alive() then
                    timer.Remove(hookName)

                    return
                end

                if (ply._isTraveling) then return end

                table.insert(ply._rescuerTags, 1, {ply:GetPos(), ply:GetAngles()})

                table.remove(ply._rescuerTags, 3 + k)
            end)
        end,
        Abilities = {
            [1] = {
                Cooldown = 12 - (k - 1),
                Description = "Rewinds you back up to " .. (3 + k - 1) .. " seconds",
                Action = function(armor, ply)
                    if (#ply._rescuerTags < 3) then return false, "Not enough charge" end

                    if SERVER then
                        ply:GodEnable()
                        ply:SetNoDraw(true)
                    else
                        CreateRollback()
                    end

                    ply:ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 100), .5, 0)
                    ply._isTraveling = true

                    timer.Simple(#ply._rescuerTags / 15, function()
                        ply._isTraveling = false

                        if SERVER then
                            ply:SetNoDraw(false)
                            ply:GodDisable()
                        end
                    end)

                    local goals = #ply._rescuerTags

                    for k = 1, #ply._rescuerTags do
                        timer.Simple(k / 15, function()
                            goals = goals - 1
                            ply:SetPos(ply._rescuerTags[k][1])
                            ply:SetEyeAngles(ply._rescuerTags[k][2])

                            if (goals <= 0) then
                                ply._rescuerTags = {}
                            end
                        end)
                    end
                end
            },
            [2] = {
                Cooldown = 15 - (k - 1),
                Description = "Slows down a target a " .. (30 + (k - 1) * 2) .. "% or speed up if ally",
                Action = function(armor, ply)
                    local tr = ply:GetEyeTrace().Entity
                    if (not IsValid(tr) or not tr:IsPlayer()) then 
                        tr = ply
                    end
                    local ally = tr:GetGang() == ply:GetGang()
                    CreateTimescaleBullet(tr, ally and .7 - k * .06 or 2 + (k - 1) / 2)
                    tr:EmitSound("ambient/machines/spinup.wav")

                    if SERVER then
                        net.Start("Rescuer.SetVMMode")
                        net.WriteInt(ally and 3 or 2, 4)
                        net.WriteEntity(tr)
                        net.WriteBool(false)
                        net.Broadcast()
                    end
                end
            },
            [3] = {
                Cooldown = 40 - (k - 1) * 4,
                Description = "Steals the bullets from your enemy's weapons",
                Action = function(armor, ply)
                    if CLIENT then return true end
                    ply:EmitSound("ambient/machines/teleport1.wav")

                    for k, v in pairs(ents.FindInSphere(ply:GetPos(), 1024 + k * 200)) do
                        if not v:IsPlayer() then continue end
                        if (v == ply) then continue end
                        if (ply:GetGang() ~= "" and ply:GetGang() == v:GetGang()) then continue end
                        v:EmitSound("ambient/materials/footsteps_glass1.wav")
                        net.Start("Rescuer.SetVMMode")
                        net.WriteInt(1, 4)
                        net.WriteEntity(v)
                        net.WriteBool(true)
                        net.Broadcast()

                        if (IsValid(v:GetActiveWeapon())) then
                            v:GetActiveWeapon():SetClip1(0)
                        end
                    end
                end
            }
        },
        OnRemove = function(ply)
            local hookName = "Rescuer_Slowdown" .. ply:SteamID64()
            timer.Remove(hookName .. "0.5")
            timer.Remove(hookName .. "2")
            hook.Remove("EntityFireBullets", hookName .. "0.5")
            hook.Remove("EntityFireBullets", hookName .. "2")
            hook.Remove("EntityFireBullets", hookName)
        end,
        OnRemoveClient = function(ply)
            SuitRemove(ply, k)
        end
    })
end

for k = 1, 5 do
    addSuit(k)
end