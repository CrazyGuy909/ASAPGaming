local runPower = .3
local baseHealth = 2750
local baseArmor = 2500
local baseJump = 400
local Gluongun = true

if SERVER then
    util.AddNetworkString("Meltdown.DoAnim")
    util.AddNetworkString("Meltdown.Glow")
end

net.Receive("Meltdown.DoAnim", function()
    local target = net.ReadEntity()
    local state = net.ReadBool()

    if (state) then
        target:AnimRestartGesture(6, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)
    else
        target:AnimResetGestureSlot(6)
    end
end)

net.Receive("Meltdown.Glow", function()
    local ent = net.ReadEntity()
    local b = net.ReadBool()
    ent._doingMelt = b
end)

local function makeThirdPerson(ply)
    if (CLIENT) then
        local hookName = ply:SteamID64() .. "_meltdown_cv"
        hook.Remove("CalcView", hookName)
        local runtime = 0

        hook.Add("CalcView", hookName, function(_, pos, ang)
            if (runtime > 2) then
                hook.Remove("CalcView", hookName)

                return
            end

            runtime = runtime + FrameTime()
            local headPos = ply:GetPos() + Vector(0, 0, 80) - ply:GetAimVector() * 96

            local tr = util.TraceLine({
                start = ply:GetShootPos(),
                endpos = headPos,
                filter = ply
            })

            local tbl = {}
            tbl.origin = tr.HitPos
            tbl.angles = Angle(10, ply:GetAimVector():Angle().y, 0)
            tbl.drawviewer = true

            return tbl
        end)

        return true
    end
end

Armor:Add({
    Name = "Meltdown Suit",
    Description = "Heals itself when dealing damage",
    Model = "models/konnie/asapgaming/destiny2/competitiveset_titan.mdl",
    Entitie = "armor_meltdown",
    Wallhack = true,
    Passive = "All damage you receive charges your rage",
    PostPlayerDraw = function(ply)
        if not IsValid(ply) and not IsValid(ply.orange) then
            ply.orange = ClientsideModel("models/konnie/asapgaming/destiny2/competitiveset_titan.mdl")
            if not IsValid(ply.orange) then return end
            ply.orange:SetPos(ply:GetPos())
            ply.orange:SetNoDraw(true)

            ply.orange.RenderOverride = function(ent)
                if not IsValid(ply) then
                    ent:Remove()

                    return
                end

                local power = math.Clamp(ply:GetNWInt("Meltdown") / 1000, 0, 1)
                render.SetBlend(ply._doingMelt and .7 or .2 * power)

                if ply._doingMelt then
                    ent:DrawModel()
                else
                    render.SetColorModulation(1, .1, 0)
                    ent:DrawModel()
                    render.SetColorModulation(1, 1, 1)
                end

                render.SetBlend(1)
            end

            local matrix = Matrix()
            matrix:Scale(Vector(1.01, 1.01, 1.01))
            ply.orange:EnableMatrix("RenderMultiply", matrix)
            ply.orange:SetMaterial("debug/debugdrawflat")
            ply:CallOnRemove("remove_orange", function()
                if IsValid(ply.orange) then
                    ply.orange:Remove()
                end
            end)
        else
            local power = math.Clamp(ply:GetNWInt("Meltdown") / 1000, 0, 1)
            if not IsValid(ply.orange) then return end
            if (power >= 0.01) then
                if (ply._doingMelt) then
                    ply.orange:SetMaterial("asap/hexa_yellow")
                    ply.orange:SetColor(Color(255, 25, 0))
                else
                    ply.orange:SetMaterial("debug/debugdrawflat")
                    ply.orange:SetColor(color_white)
                end

                ply.orange:DrawModel()
                ply.orange:SetPos(ply:GetPos() + VectorRand() * power * 5)
                ply.orange:SetAngles(Angle(0, ply:GetAngles().y, 0))
                ply.orange:SetSequence(ply:GetSequence())
                ply.orange:SetCycle(ply:GetCycle())
                ply.orange:SetPoseParameter("move_x", ply:GetPoseParameter("move_x"))
                ply.orange:SetPoseParameter("move_y", ply:GetPoseParameter("move_y"))
                ply.orange:InvalidateBoneCache()
            end
        end
    end,
    HUDPaint = function(ply)
        local percent = (ply:GetNWInt("Meltdown") / 1000)
        Armor:DrawHUDBar("Rage:", percent, 0, 2)

        if (ply._meltdownRemain and ply._meltdownRemain > 0) then
            Armor:DrawHUDBar("Constant Rage:", ply._meltdownRemain / 20, 1)
            ply._meltdownRemain = ply._meltdownRemain - FrameTime()
        end
    end,
    Abilities = {
        [1] = {
            Cooldown = 15,
            Description = "Turns rage into a shotgun projectile",
            Action = function(armor, ply)
                if (ply.waitingAttack) then return false, "You are still charging your attack" end

                ply:SetAngles(ply:GetAngles() + Angle(0, -90, 0))
                ply:AnimRestartGesture(6, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)

                if (ply:GetNWInt("Meltdown") > 25) then
                    ply.waitingAttack = true
                    ply:EmitSound("buttons/combine_button7.wav")
                    makeThirdPerson(ply)
                    local power = math.min(ply:GetNWInt("Meltdown"), 500)
                    ply:SetNWInt("Meltdown", ply:GetNWInt("Meltdown", 0) - power)

                    if SERVER then
                        ply:Freeze(true)
                        net.Start("Meltdown.DoAnim")
                        net.WriteEntity(ply)
                        net.WriteBool(true)
                        net.SendPVS(ply:GetPos())

                        timer.Simple(.75, function()
                            ply.waitingAttack = nil
                            ply:FireBullets({
                                Attacker = ply,
                                Damage = 200,
                                Force = 50,
                                TracerName = "AirboatGunHeavyTracer",
                                Num = math.ceil(power / 50),
                                Dir = ply:EyeAngles():Forward(),
                                Spread = Vector(.15, .15, 0),
                                Src = ply:EyePos(),
                                ignoreEntity = ply
                            })

                            ply:EmitSound("ambient/explosions/explode_4.wav")
                            ply:Freeze(false)
                            local ball = ents.Create("prop_combine_ball")
                            ball:SetPos(ply:GetPos() + Vector(0, 0, 30))
                            ball:Spawn()
                            ball:Fire("Explode", 0, 0)
                        end)
                    end

                    return true
                end

                return false, "Not enough rage."
            end
        },
        [2] = {
            Cooldown = 30,
            Description = "Heals part of your rage",
            Action = function(armor, ply)
                if (ply._doingMelt) then
                    return false, "You cannot cast this ability right now"
                end
                if (ply.waitingAttack) then return false, "You are still charging your attack" end

                if (ply:GetNWInt("Meltdown") > 25) then
                    ply:SetAngles(ply:GetAngles() + Angle(0, -90, 0))
                    ply:AnimRestartGesture(6, ACT_GMOD_GESTURE_TAUNT_ZOMBIE, true)
                    ply:EmitSound("buttons/combine_button7.wav")
                    ply.waitingAttack = true
                    makeThirdPerson(ply)

                    if SERVER then
                        ply:Freeze(true)

                        timer.Simple(.75, function()
                            ply.waitingAttack = false
                            ply:Freeze(false)
                            local power = math.min(ply:GetNWInt("Meltdown"), 500)
                            ply:SetHealth(ply:Health() + power / 5)
                            ply:TakeDamage(0)
                            ply:SetNWInt("Meltdown", ply:GetNWInt("Meltdown", 0) - power)
                        end)
                    end

                    return true
                end

                return false, "Not enough rage."
            end
        },
        [3] = {
            Cooldown = 25,
            Description = "Your rage becomes invencible",
            Action = function(armor, ply)
                local melt = ply:GetNWInt("Meltdown", 0)
                local timerName = "Melting_run_" .. ply:SteamID64()

                if (ply.waitingAttack) then return false, "You are still charging your attack" end

                if (ply._doingMelt) then
                    ply:EmitSound("buttons/combine_button3.wav")
                    timer.Remove(timerName)
                    ply._doingMelt = false

                    if SERVER then
                        ply:Freeze(false)
                        ply:GodDisable()
                        net.Start("Meltdown.Glow")
                        net.WriteEntity(ply)
                        net.WriteBool(false)
                        net.Broadcast()
                    end

                    return true
                elseif (melt > 50) then
                    ply:EmitSound("buttons/combine_button3.wav")
                    ply._doingMelt = true
                    ply.waitingAttack = true
                    if SERVER then
                        ply:Freeze(true)
                        ply:GodEnable()
                        net.Start("Meltdown.Glow")
                        net.WriteEntity(ply)
                        net.WriteBool(true)
                        net.Broadcast()
                    else
                        local lerpedPos = EyePos()
                        local lerpedVal = 0

                        hook.Add("CalcView", "Meltdown.View", function(_, pos, ang)
                            if (not ply:Alive() or not ply._doingMelt) then
                                hook.Remove("CalcView", "Meltdown.View")

                                return
                            end

                            if (lerpedVal < .5) then
                                lerpedVal = lerpedVal + FrameTime()
                            end

                            local origin = Lerp(1 - lerpedVal / .5, lerpedPos, ply:GetPos() + Vector(0, 0, 45))
                            local tr = util.QuickTrace(origin, ang:Forward() * -96, ply)
                            local tbl = {}
                            tbl.origin = tr.HitPos
                            tbl.angles = ang
                            tbl.drawviewer = true

                            return tbl
                        end)
                    end

                    timer.Create(timerName, 1, 0, function()
                        if (ply:GetNWInt("Meltdown", 0) >= 50) then
                            ply:SetNWInt("Meltdown", ply:GetNWInt("Meltdown", 0) - 50)

                            if (ply:GetNWInt("Meltdown", 0) <= 0) then
                                timer.Remove(timerName)
                                ply.waitingAttack = nil
                                armor.Abilities[3].Action(armor, ply)
                            end
                        end
                    end)

                    return 1
                end

                return false, "Not enough rage."
            end
        },
        [4] = {
            Cooldown = 105,
            Description = "FILLS YOUR RAGE!1!11!!!!!",
            Action = function(armor, ply)
                local timerName = "Meltdown_Ultimate" .. ply:SteamID64()
                ply._meltdownRemain = 20
                timer.Create(timerName, .5, 20, function()
                    if (not IsValid(ply) or ply.armorSuit ~= armor.Name) then
                        timer.Remove(Meltdown_Ultimate)

                        return
                    end

                    ply:SetNWInt("Meltdown", math.min(ply:GetNWInt("Meltdown", 0) + math.random(50, 100), 1000))
                end)
            end
        }
    },
    Armor = baseArmor,
    Health = baseHealth,
    JumpPower = baseJump,
    Speed = 1 + runPower,
    OnGive = function(ply)
        ply.immuneToGluon = Gluongun
        local hookName = ply:SteamID64() .. "_Meltdown"

        hook.Add("EntityTakeDamage", hookName, function(ent, dmg)
            if not IsValid(ply) then
                hook.Remove("EntityTakeDamage", hookName)

                return
            end

            if (ent == ply) then
                ply:SetNWInt("Meltdown", math.Clamp(ply:GetNWInt("Meltdown", 0) + dmg:GetDamage(), 0, 1000))
            end
        end)
    end,
    OnRemove = function(ply)
        hook.Remove("EntityTakeDamage", ply:SteamID64() .. "_Meltdown")
        hook.Remove("CalcView", "Meltdown.View")

        if ply._oldRunSpeed then
            ply:SetRunSpeed(ply._oldRunSpeed)
            ply._oldRunSpeed = nil
        end

        ply:GodDisable()
        ply:Freeze(false)
        net.Start("Orange.Remove")
        net.WriteEntity(ply)
        net.Broadcast()
        net.Start("Meltdown.Glow")
        net.WriteEntity(ply)
        net.WriteBool(false)
        net.Broadcast()
    end
})