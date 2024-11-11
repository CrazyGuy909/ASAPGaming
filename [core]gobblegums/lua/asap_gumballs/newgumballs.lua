hook.Add("EntityTakeDamage", "ASAP.Gumballs:New", function(ent, dmg)
    local att = dmg:GetAttacker()

    if IsValid(att) and dmg:IsBulletDamage() then
        if (att.heal_bullets and att:Health() < (att:GetMaxHealth() / 2)) then
            att:SetHealth(att:Health() + dmg:GetDamage() * .25)
        end

        if (att.fire_bullets or att.venom_bullets) then
            local dice = math.random(0, 100) < 5

            if dice then
                local sec = math.Clamp(dmg:GetDamage() / 100, 0, 2)

                if (att.fire_bullets) then
                    ent:Ignite(sec, 1)
                end

                if (att.venom_bullets and ent.CreatePoison) then
                    ent:CreatePoison(sec, att, att:GetActiveWeapon(), .025)
                end
            end
        end
    end

    if (ent.revive_bullets and dmg:GetDamage() > ent:Health()) then
        ent:SetHealth(1)
        ent:GodEnable()
        ent:Freeze(true)
        ent:EmitSound("doubleornothing/cashout.mp3")
        ent:SetNoDraw(false)
        ent:ConCommand("optmenu_thirdperson 1")

        timer.Create(ent:EntIndex() .. "_revive", .5, 5, function()
            ent:SetNoDraw(not ent:GetNoDraw())
        end)

        timer.Simple(3, function()
            if not IsValid(ent) then return end
            ent:ConCommand("optmenu_thirdperson 0")
            ent:SetNoDraw(false)
            ent.revive_bullets = false
            ent:SetHealth(math.floor(ent:GetMaxHealth() / 2))
            ent:GodDisable()
            ent:Freeze(false)
        end)

        dmg:SetDamage(0)

        return true
    end

end)

local GUMBALL = {}
GUMBALL.id = 19
GUMBALL.name = "Poison Contigency"
GUMBALL.description = [[You have 5% chances at poisoning someone when shoot.]]
GUMBALL.price = 100
GUMBALL.icon = Material("asap_gumballs/balls/poison.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Purple
GUMBALL.Cooldown = 900
GUMBALL.activeTime = 360

function GUMBALL.OnGumballEquip(ply)
end

function GUMBALL.OnGumballDequip(ply)
end

function GUMBALL.OnGumballExpire(ply)
    ply.venom_bullets = false
end

function GUMBALL.OnGumballUse(ply)
    ply.venom_bullets = true
end

ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)
GUMBALL = {}
GUMBALL.id = 20
GUMBALL.name = "Fire Contigence"
GUMBALL.description = [[You have 5% chances at burning someone when shoot.]]
GUMBALL.price = 100
GUMBALL.Cooldown = 900
GUMBALL.icon = Material("asap_gumballs/balls/fire.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Purple
GUMBALL.activeTime = 360

function GUMBALL.OnGumballEquip(ply)
end

function GUMBALL.OnGumballDequip(ply)
end

function GUMBALL.OnGumballExpire(ply)
    ply.fire_bullets = false
end

function GUMBALL.OnGumballUse(ply)
    ply.fire_bullets = true
end

ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)
GUMBALL = {}
GUMBALL.id = 21
GUMBALL.name = "Blood Berserker"
GUMBALL.description = [[You heal 25% of damage dealt if your health is below 50%]]
GUMBALL.price = 100
GUMBALL.Cooldown = 300
GUMBALL.icon = Material("asap_gumballs/balls/heal.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Purple
GUMBALL.activeTime = 600

function GUMBALL.OnGumballEquip(ply)
end

function GUMBALL.OnGumballDequip(ply)
end

function GUMBALL.OnGumballExpire(ply)
    ply.heal_bullets = false
end

function GUMBALL.OnGumballUse(ply)
    ply.heal_bullets = true
end

ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)
GUMBALL = {}
GUMBALL.id = 22
GUMBALL.name = "Plan B"
GUMBALL.description = [[Resurrect if in the last 5 seconds you got shoot to death]]
GUMBALL.price = 100
GUMBALL.Cooldown = 1800
GUMBALL.icon = Material("asap_gumballs/balls/resurrect.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Orange
GUMBALL.activeTime = 300

function GUMBALL.OnGumballEquip(ply)
end

function GUMBALL.OnGumballDequip(ply)
end

function GUMBALL.OnGumballExpire(ply)
    ply.revive_bullets = false
    DarkRP.notify(ply, 0, 5, "Plan B Gumball has expired! TAKE COVER")
end

function GUMBALL.OnGumballUse(ply)
    ply.revive_bullets = true
end

ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)

GUMBALL = {}
GUMBALL.id = 23
GUMBALL.name = "Silk Touch"
GUMBALL.description = [[On killing someone with a suit, 100% drop chance]]
GUMBALL.price = 100
GUMBALL.Cooldown = 1800
GUMBALL.icon = Material("asap_gumballs/balls/silktouch.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Orange
GUMBALL.activeTime = 60

function GUMBALL.OnGumballEquip(ply)
end

function GUMBALL.OnGumballDequip(ply)
end

function GUMBALL.OnGumballExpire(ply)
    ply.armor_dropper = false
end

function GUMBALL.OnGumballUse(ply)
    ply.armor_dropper = true
end

ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)