local GUMBALL = {}

if SERVER then
    util.AddNetworkString("ASAP:TEMP_BLIND")
end

if CLIENT then
    local Visor = CreateMaterial("noglow_props3", "Refract", {
        ["$model"] = 1,
        ["$bluramount"] = 0,
        ["$refracttinttexture"] = "effects/fog_d1_trainstation_02",
        ["$normalmap"] = "null-bumpmap"
    })

    net.Receive("ASAP:TEMP_BLIND", function()
        local isApply = net.ReadBool()
        local ply = LocalPlayer()

        if (isApply) then
            ply:EmitSound("rm_c4/draw.wav")
            ply._globus = ClientsideModel("models/maxofs2d/gm_painting.mdl")
            ply._globus:SetPos(EyePos() + EyeAngles():Forward() * 16)
            ply._globus:SetAngles(EyeAngles())
            ply._globus:SetMaterial("!noglow_props3")

            ply._globus.RenderOverride = function(s)
                if (LocalPlayer():KeyDown(IN_WALK)) then
                    s:DrawModel()
                end
            end

            hook.Add("PostDrawViewModel", ply._globus, function(s, vm)
                if (not ply:Alive()) then
                    ply._globus:Remove()

                    return
                end

                ply._globus:SetPos(vm:GetPos() + vm:GetForward() * 12)
                local ang = EyeAngles()
                --ang:RotateAroundAxis(ang:Up(), 90)
                ply._globus:SetAngles(ang)
            end)

            hook.Add("PostPlayerDraw", ply._globus, function(s, ply)
                if (ply == LocalPlayer()) then
                    ply._globus:SetPos(EyePos() + ply:GetAimVector() * 12)
                    local ang = EyeAngles()
                    --ang:RotateAroundAxis(ang:Up(), 90)
                    ply._globus:SetAngles(ang)
                end
            end)
        elseif IsValid(ply._globus) then
            ply._globus:Remove()
        end
    end)
end

GUMBALL.id = 12
GUMBALL.name = "X-Rays Decryptor"
GUMBALL.description = [[While holding ALT you will see trhough some props]]
GUMBALL.price = 10
GUMBALL.icon = Material("asap_gumballs/balls/blinding_image.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Purple
GUMBALL.activeTime = 60 * 3

function GUMBALL.OnGumballEquip(ply)
end

function GUMBALL.OnGumballDequip(ply)
end

function GUMBALL.OnGumballExpire(ply)
    net.Start("ASAP:TEMP_BLIND")
	net.WriteBool(false)
	net.Send(ply)
end

function GUMBALL.OnGumballUse(ply)
    net.Start("ASAP:TEMP_BLIND")
	net.WriteBool(true)
	net.Send(ply)
end

--[[-------------------------------------------------------------------------
Register the gumball
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)