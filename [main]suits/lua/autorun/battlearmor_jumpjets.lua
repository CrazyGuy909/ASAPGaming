sound.Add({
    name = "jetpack_ignition",
    channel = CHAN_STATIC,
    volume = 0.6,
    level = 50,
    pitch = {95, 105},
    sound = "jumpjets/jumpjets_start.wav"
})

sound.Add({
    name = "jetpack_flame",
    channel = CHAN_STATIC,
    volume = 1,
    level = 50,
    pitch = {95, 105},
    sound = "jumpjets/jumpjets_loop.wav"
})
sound.Add({
    name = "jetpack_extinct",
    channel = CHAN_STATIC,
    volume = 0.1,
    level = 50,
    pitch = {95, 105},
    sound = "jumpjets/jumpjets_stop.wav"
})

local function battlearmor_checkmodel(ply)
    if ply:GetModel() ~= "models/mechsassault2_lonewolf/battle_armor.mdl" then return false end
    if ply:GetBodygroup(0) ~= 0 then return false end

    return true
end

if CLIENT then
    hook.Add("KeyPress", "battlearmor_starteffect", function(ply, key)
        if battlearmor_checkmodel(ply) == false or not ply:Alive() then return end

        if key == IN_JUMP then
            net.Start("battlearmor_fly")
            net.WriteBit(1)
            net.SendToServer()

            hook.Add("Think", "battlearmor_checkstop", function()
                if not LocalPlayer():KeyDown(IN_JUMP) then
                    net.Start("battlearmor_fly")
                    net.WriteBit(0)
                    net.SendToServer()
                    hook.Remove("Think", "battlearmor_checkstop")
                end
            end)
        end
    end)

    net.Receive("battlearmor_stop", function()
        hook.Remove("Think", "battlearmor_checkstop")
    end)
else
    util.AddNetworkString("battlearmor_fly")
    util.AddNetworkString("battlearmor_stop")
    local flameactive = {}

    local function battlearmor_checkground(ply)
        if ply:IsOnGround() == true or ply:WaterLevel() == 2 or ply:WaterLevel() == 3 then return false end

        return true
    end

    local function battlearmor_addeffect(ply)
        ply:StopSound("jetpack_ignition")
        ply:StopSound("jetpack_flame")
        ply:StopSound("jetpack_extinct")
        ply:EmitSound("jetpack_ignition")
        ply:EmitSound("jetpack_flame")
        ply:SetNWFloat("GravitySH", 0.1)
    end

    local function battlearmor_removeeffect(ply)
        ply:StopSound("jetpack_ignition")
        ply:StopSound("jetpack_flame")
        ply:StopSound("jetpack_extinct")
        ply:EmitSound("jetpack_extinct")
        ply:SetNWFloat("GravitySH", 1)
    end

    net.Receive("battlearmor_fly", function(len, ply)
        local id = ply:SteamID64() or ""

        if net.ReadBit() == 0 then
            if flameactive[id] == nil then return end
            flameactive[id] = nil
            battlearmor_removeeffect(ply)
            hook.Remove("Think", "battlearmor_" .. id)
        else
            if flameactive[id] == true then return end
            flameactive[id] = true

            timer.Simple(0.01, function()
                battlearmor_addeffect(ply)

                hook.Add("Think", "battlearmor_" .. id, function()
                    if battlearmor_checkground(ply) == true and battlearmor_checkmodel(ply) == true and ply:Alive() then
                        local effectdata = EffectData()
                        effectdata:SetEntity(ply)
                        util.Effect("battlearmor_flame", effectdata)
                    else
                        local id = ply:SteamID64() or ""
                        flameactive[id] = nil
                        battlearmor_removeeffect(ply)
                        hook.Remove("Think", "battlearmor_" .. id)
                        net.Start("battlearmor_stop")
                        net.Send(ply)
                    end
                end)
            end)
        end
    end)
end