sound.Add({
    name = "jetpack_ignition_ars",
    channel = CHAN_STATIC,
    volume = 0.6,
    level = 50,
    pitch = {95, 105},
    sound = "vanquish/thruster_start.wav"
})

sound.Add({
    name = "jetpack_flame_ars",
    channel = CHAN_STATIC,
    volume = 1,
    level = 50,
    pitch = {95, 105},
    sound = "vanquish/thruster_loop.wav"
})

sound.Add({
    name = "jetpack_extinct_ars",
    channel = CHAN_STATIC,
    volume = 0.1,
    level = 50,
    pitch = {95, 105},
    sound = "vanquish/thruster_extinct.wav"
})

local function ars_checkmodel(ply)
    if ply:GetModel() ~= "models/vanquish/player/augmented_reaction_suit.mdl" then return false end
    if ply:GetBodygroup(0) ~= 0 then return false end

    return true
end

if CLIENT then
    hook.Add("KeyPress", "ars_starteffect", function(ply, key)
        if ars_checkmodel(ply) == false or not ply:Alive() then return end

        if key == IN_JUMP then
            net.Start("ars_fly")
            net.WriteBit(1)
            net.SendToServer()

            hook.Add("Think", "ars_checkstop", function()
                if not LocalPlayer():KeyDown(IN_JUMP) then
                    net.Start("ars_fly")
                    net.WriteBit(0)
                    net.SendToServer()
                    hook.Remove("Think", "ars_checkstop")
                end
            end)
        end
    end)

    net.Receive("ars_stop", function()
        hook.Remove("Think", "ars_checkstop")
    end)
else
    util.AddNetworkString("ars_fly")
    util.AddNetworkString("ars_stop")
    local flameactive = {}

    local function ars_checkground(ply)
        if ply:IsOnGround() == true or ply:WaterLevel() == 2 or ply:WaterLevel() == 3 then return false end

        return true
    end

    local function ars_addeffect(ply)
        ply:StopSound("jetpack_ignition_ars")
        ply:StopSound("jetpack_flame_ars")
        ply:StopSound("jetpack_extinct_ars")
        ply:EmitSound("jetpack_ignition_ars")
        ply:EmitSound("jetpack_flame_ars")
        ply:SetNWFloat("GravitySH", 0.1)
    end

    local function ars_removeeffect(ply)
        ply:StopSound("jetpack_ignition_ars")
        ply:StopSound("jetpack_flame_ars")
        ply:StopSound("jetpack_extinct_ars")
        ply:EmitSound("jetpack_extinct_ars")
        ply:SetNWFloat("GravitySH", 1)
    end

    net.Receive("ars_fly", function(len, ply)
        local id = ply:SteamID64() or ""

        if net.ReadBit() == 0 then
            if flameactive[id] == nil then return end
            flameactive[id] = nil
            ars_removeeffect(ply)
            hook.Remove("Think", "ars_" .. id)
        else
            if flameactive[id] == true then return end
            flameactive[id] = true

            timer.Simple(0.01, function()
                ars_addeffect(ply)

                hook.Add("Think", "ars_" .. id, function()
                    if ars_checkground(ply) == true and ars_checkmodel(ply) == true and ply:Alive() then
                        local effectdata = EffectData()
                        effectdata:SetEntity(ply)
                        util.Effect("ars_flame", effectdata)
                    else
                        local id = ply:SteamID64() or ""
                        flameactive[id] = nil
                        ars_removeeffect(ply)
                        hook.Remove("Think", "ars_" .. id)
                        net.Start("ars_stop")
                        net.Send(ply)
                    end
                end)
            end)
        end
    end)
end