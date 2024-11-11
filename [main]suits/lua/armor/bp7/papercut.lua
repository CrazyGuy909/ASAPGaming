local runPower = .7
local baseHealth = 2800
local baseArmor = 2000
local baseJump = 380
local Gluongun = true

if SERVER then
    util.AddNetworkString("Papercut.DoAnim")
end

net.Receive("Papercut.DoAnim", function()
    local target = net.ReadEntity()
    local state = net.ReadBool()

    if (state) then
        target:AnimRestartGesture(6, ACT_HL2MP_JUMP_KNIFE, true)
    else
        target:AnimResetGestureSlot(6)
    end
end)

Armor:Add({
    Name = "Hydra Suit",
    Description = "Dashes forward lifting up enemies",
    Model = "models/konnie/asapgaming/destiny2/crushingset.mdl",
    Entitie = "armor_papercut",
    Wallhack = true,
    Health = baseHealth,
    Armor = baseArmor,
    JumpPower = baseJump,
    Speed = 1 + runPower,
    OnGive = function(ply)
        ply.immuneToGluon = Gluongun
    end,
    Abilities = {
        [1] = {
            Description = "Dash forwards damaging enemies",
            Action = function(armor, ply)
                local hookName = "papercut_" .. ply:SteamID64()

                if CLIENT then
                    hook.Remove("CalcView", hookName)
                    local runtime = 0

                    hook.Add("CalcView", hookName, function(_, pos, ang)
                        if (runtime > 1.5) then
                            hook.Remove("CalcView", hookName)

                            return
                        end

                        runtime = runtime + FrameTime()
                        local headPos = ply:GetPos() + Vector(0, 0, 45) - ply:GetAimVector() * 96

                        local tr = util.TraceLine({
                            start = ply:GetShootPos(),
                            endpos = headPos,
                            filter = ply
                        })

                        local tbl = {}
                        tbl.origin = tr.HitPos
                        tbl.angles = Angle(0, ply:GetAimVector():Angle().y, 0)
                        tbl.drawviewer = true

                        return tbl
                    end)
                else
                    net.Start("Papercut.DoAnim")
                    net.WriteEntity(ply)
                    net.WriteBool(true)
                    net.SendPVS(ply:GetPos())
                    ply:Freeze(true)
                    ply:EmitSound("ambient/energy/whiteflash.wav")

                    if (ply._trails) then
                        for k, v in pairs(ply._trails) do
                            v[1]:Remove()
                            v[2]:Remove()
                        end
                    end

                    ply._trails = {}

                    for k = 1, 5 do
                        local info = ents.Create("info_target")
                        info:SetParent(ply)
                        info:SetLocalPos(Vector(math.random(-24, 24), math.random(-24, 24), k * 8))
                        info:Spawn()
                        local trail = util.SpriteTrail(info, 0, color_white, true, 32, 0, 1, 1, "trails/tube.vmt")

                        ply._trails[k] = {info, trail}
                    end

                    timer.Simple(.5, function()
                        if not ply:Alive() then return end
                        ply:SetFOV(30, 0)
                        ply:SetFOV(0, .5)
                        local target = ply:GetPos()

                        local hitData = {ply}

                        ply:SetPos(ply:GetPos() + Vector(0, 0, 8))
                        ply:SetVelocity(Vector(0, 0, 48) + Vector(ply:GetAimVector().x, ply:GetAimVector().y, 0) * 2080)

                        for k = 1, 5 do
                            timer.Simple(k / 8, function()
                                local didHit = false

                                for _, ent in pairs(ents.FindInSphere(ply:GetPos(), 64)) do
                                    if (hitData[ent]) then continue end
                                    if (not ent:IsPlayer() and not ent:IsNPC()) then continue end
                                    if (ent == ply) then continue end
                                    if (ply:GetGang() ~= "" and ent:IsPlayer() and ent:GetGang() ~= ply:GetGang()) then continue end
                                    local diff = (target - ent:GetPos()):GetNormalized()
                                    local dmg = DamageInfo()
                                    dmg:SetDamage(math.min(50, ent:Health() * .15))
                                    dmg:SetDamageType(DMG_DISSOLVE)
                                    dmg:SetAttacker(ply)
                                    ent:TakeDamageInfo(dmg)
                                    hitData[ent] = true
                                    didHit = true
                                end

                                if (didHit) then
                                    ply:EmitSound("ambient/machines/slicer" .. math.random(1, 4) .. ".wav")
                                end
                            end)
                        end

                        for k, v in pairs(ply._trails) do
                            v[1]:SetParent(nil)
                        end
                    end)

                    timer.Simple(1, function()
                        if not ply:Alive() then return end
                        ply:Freeze(false)

                        timer.Simple(3, function()
                            if not ply:Alive() then return end

                            if (ply._trails) then
                                for k, v in pairs(ply._trails) do
                                    v[1]:Remove()
                                    v[2]:Remove()
                                end

                                ply._trails = nil
                            end
                        end)
                    end)
                end
            end,
            Cooldown = 10
        },
        [2] = {
            Description = "Lifts people around you",
            Action = function(armor, ply)
                if SERVER then
                    for _, ent in pairs(ents.FindInSphere(ply:GetPos(), 128)) do
                        if (not ent:IsPlayer() and not ent:IsNPC()) then continue end
                        if (ent == ply) then continue end
                        if (ent:IsPlayer() and ply:GetGang() ~= "" and ply:GetGang() == ent:GetGang()) then continue end
                        ent:SetPos(ent:GetPos() + Vector(0, 0, 8))
                        ent:SetVelocity(Vector(0, 0, 350))
                        local target = ents.Create("info_target")
                        target:SetPos(ent:GetPos() + Vector(0, 0, 30))
                        target:SetParent(ent)
                        target:Spawn()
                        target.Trail = util.SpriteTrail(target, 0, color_white, true, 28, 0, 3, .005, "particle/smokesprites_000" .. math.random(1, 9) .. ".vmt")

                        timer.Simple(3.5, function()
                            target:SetParent(nil)

                            timer.Simple(3, function()
                                target:Remove()
                            end)
                        end)

                        ent:EmitSound("weapons/fx/nearmiss/bulletltor0" .. math.random(1, 8) .. ".wav")
                    end
                end

                return true
            end,
            Cooldown = 50
        },
        [3] = {
            Description = "Travel super fast in your spirit form",
            Action = function(armor, ply)
                local timerName = "Papercut_inb" .. ply:SteamID64()

                if SERVER then
                    ply:GodEnable()
                    ply:SetWalkSpeed(1000)
                    ply:SetMaterial("asap/hexa_blue")
                end

                timer.Create(timerName, 5, 1, function()
                    if SERVER then
                        ply:SetWalkSpeed(150)
                        ply:GodDisable()
                        ply:SetMaterial("")
                    end
                end)
            end,
            Cooldown = 20
        },
        [4] = {
            Description = "Creates a typhon that will shred people around you",
            Action = function(armor, ply)
                if CLIENT then
                    RunConsoleCommand("optmenu_thirdperson", 1)

                    return true
                end

                if IsValid(ply._typhon) then
                    ply._typhon:Remove()
                end

                ply._typhon = ents.Create("sent_papercut_shield")
                ply._typhon:SetParent(ply)
                ply._typhon:SetOwner(ply)
                ply._typhon:SetLocalPos(Vector(0, 0, 0))
                ply._typhon:Spawn()
            end,
            Cooldown = 120
        }
    },
    OnRemove = function(ply)
        timer.Remove("Papercut_inb" .. ply:SteamID64())

        if SERVER then
            ply:GodDisable()
            ply:SetMaterial("")
        end
    end
})