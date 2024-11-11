AddCSLuaFile()

if SERVER then
    util.AddNetworkString("ArmorDLC.MarkPlayers")
    util.AddNetworkString("Simulator.Flashes")
end

Armor:Add({
    Name = "Honos Suit",
    Description = "Mark players around you",
    Model = "models/konnie/asapgaming/destiny2/devastationcomplex.mdl",
    Entitie = "armor_honos",
    Wallhack = true,
    Armor = 1300,
    Health = 1300,
    RunSpeed = 1.95,
    OnGive = function(ply)
        ply.immuneToGluon = true
    end,
    -- what happens when they get the suit equipped
    Abilities = {
        [1] = {
            Cooldown = 60,
            Action = function(s, ply)
                if SERVER then
                    local players = {}

                    for k, v in pairs(ents.FindInSphere(ply:GetPos(), 2048)) do
                        if (not v:IsPlayer()) then continue end
                        if (v == ply) then continue end
                        local am = ply:GetAimVector():Dot((v:EyePos() - ply:GetPos() + Vector(70)):GetNormalized())

                        if (am > .5) then
                            table.insert(players, v:EyePos())
                        end
                    end

                    local buddies = {ply}

                    for k, v in pairs(ents.FindInSphere(ply:GetPos(), 300)) do
                        if (not v:IsPlayer()) then continue end
                        if (v == ply) then continue end

                        local tr = util.TraceLine({
                            start = ply:EyePos(),
                            endpos = v:EyePos(),
                            filter = ply
                        })

                        if (tr.Entity == v) then
                            table.insert(buddies, v)
                        end
                    end

                    net.Start("ArmorDLC.MarkPlayers")
                    net.WriteTable(players)
                    net.Send(buddies)
                end
            end
        }
    },
    OnRemove = function(ply)
        ply.immuneToGluon = nil
    end
})

if SERVER then return end
local players = {}
local hitmark = surface.GetTextureID("asap/ui/mark")

net.Receive("ArmorDLC.MarkPlayers", function()
    local data = net.ReadTable()
    players = {}

    for k, v in pairs(data) do
        table.insert(players, {
            Pos = v,
            Alpha = 0,
            Life = 5,
            Dist = v:Distance(LocalPlayer():EyePos())
        })
    end

    hook.Remove("HUDPaint", "HonosPlayers")

    hook.Add("HUDPaint", "HonosPlayers", function()
        for k, v in pairs(players) do
            v.Alpha = Lerp(FrameTime() * 2, v.Alpha, v.Life > 0 and 255 or -1)

            if (v.Life <= 0 and v.Alpha <= 0) then
                hook.Remove("HUDPaint", "HonosPlayers")

                return
            elseif (v.Alpha > 250) then
                v.Life = v.Life - FrameTime()
            end

            local pos = v.Pos:ToScreen()
            surface.SetTexture(hitmark)
            surface.SetDrawColor(255, 255, 255, v.Alpha)
            surface.DrawTexturedRectRotated(pos.x, pos.y, (128 - (v.Dist / 2048) * 64) * (v.Alpha / 255), (128 - (v.Dist / 2048) * 64) * (v.Alpha / 255), 360 * (v.Alpha / 255))
        end
    end)
end)

net.Receive("Simulator.Flashes", function()
    LocalPlayer():ScreenFade(SCREENFADE.IN, color_white, .5, 0)
    LocalPlayer():EmitSound("weapons/stunstick/spark" .. math.random(1, 3) .. ".wav")
    hook.Remove("RenderScreenspaceEffects", "MotionBlured")
    local power = 5

    hook.Add("RenderScreenspaceEffects", "MotionBlured", function()
        DrawMotionBlur(.05, power / 2.5, 0.05)
        power = power - FrameTime()

        if (power <= 0) then
            hook.Remove("RenderScreenspaceEffects", "MotionBlured")
        end
    end)
end)