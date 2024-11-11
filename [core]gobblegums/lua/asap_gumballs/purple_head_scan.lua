local GUMBALL = {}
GUMBALL.id = 14
GUMBALL.name = "Head Scale"
GUMBALL.description = [[Head shots have a chance to do 3x more damage.]]
GUMBALL.price = 10
GUMBALL.icon = Material("asap_gumballs/balls/head_scan.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Purple
GUMBALL.activeTime = 60 * 8

function GUMBALL.OnGumballEquip(ply)
end

function GUMBALL.OnGumballDequip(ply)
end

function GUMBALL.OnGumballExpire(ply)
    ply.headscan = false
end

function GUMBALL.OnGumballUse(ply)
    ply.headscan = true
end

GobblegumAdd("ScalePlayerDamage", "ASAP:HeadScan:", function(ply, hitgroup, dmginfo)
    local att = dmginfo:GetAttacker()
    if (ply:InArena()) then return end

    if att.headscan then
        if not att:IsPlayer() then return end

        if hitgroup == HITGROUP_HEAD and math.random(1, 3) == 2 then
            local bonePos = ply:GetBonePosition(ply:LookupBone("ValveBiped.Bip01_Head1") or 1)
            dmginfo:SetDamagePosition(bonePos)
            dmginfo:ScaleDamage(2)
			ply:EmitSound("nmrihimpact/sharp_heavy1.wav")
			local eff = EffectData()
			eff:SetOrigin(bonePos)
			eff:SetMagnitude(100)
			eff:SetScale(100)
			util.Effect("BloodImpact", eff, true, true)
        end
    end
end)

--[[-------------------------------------------------------------------------
Register the gumball
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)