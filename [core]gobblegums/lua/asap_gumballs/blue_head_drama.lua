local GUMBALL = {}
GUMBALL.id = 7
GUMBALL.name = "Head Drama"
GUMBALL.description = [[Every bullet that hits the player counts as a headshot.
]]
GUMBALL.price = 10
GUMBALL.icon = Material("asap_gumballs/balls/head_drama.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Blue
GUMBALL.activeTime = 60 * 3

function GUMBALL.OnGumballEquip(ply)
end

function GUMBALL.OnGumballDequip(ply)
end

function GUMBALL.OnGumballExpire(ply)
    ply.headdrama = false
end

function GUMBALL.OnGumballUse(ply)
    ply.headdrama = true
    ply.headdramatimer = CurTime() + GUMBALL.activeTime
end

GobblegumAdd("ScalePlayerDamage", "ASAP:HeadDrama:", function(ply, hitgroup, dmginfo)
    local att = dmginfo:GetAttacker()
    if not att:IsPlayer() then return end

    if att.headdrama and hitgroup ~= HITGROUP_HEAD then
        if (ply:InArena()) then return end
        local bonePos = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Head1") or 1)
        dmginfo:SetDamagePosition(bonePos or ply:GetShootPos())
        dmginfo:ScaleDamage(1.8 - (1 - ((att.headdramatimer or (CurTime() + 60)) - CurTime()) / 360) * .8)
    end
end)

--[[-------------------------------------------------------------------------
Register the gumball
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)