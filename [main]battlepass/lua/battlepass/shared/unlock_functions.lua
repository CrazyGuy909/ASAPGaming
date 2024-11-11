BATTLEPASS.Unlock = {}

function BATTLEPASS.Unlock.Unbox(ply, tbl)
    if (SERVER) then
        ply:UB3AddItem(tbl.extra.id, 1)
    end
end


function BATTLEPASS.Unlock.Money(ply, tbl)
    if (SERVER) then
        ply:addMoney(tbl.extra.amount)
    end
end

function BATTLEPASS.Unlock.InvWeapon(ply, tbl)
    if (SERVER) then
        local amt = tbl.extra.amount or 1
        local pos = ply:GetPos()
        local ent = ents.Create("spawned_weapon")
        ent:SetPos(pos)
        ent:Spawn()

        if (tbl.display) then
            ent:SetModel(tbl.display)
        end

        ent:SetWeaponClass(tbl.extra.ent)
        ent:Setamount(amt)
        ply:inv_pickup(ent)
    end
end

function BATTLEPASS.Unlock.Weapon(ply, tbl)
    if (SERVER) then
        ply:AddPermanentWeapon(tbl.extra.ent, true)
    end
end

function BATTLEPASS.Unlock.ASAPXP(ply, tbl)
    if (SERVER) then
        ply:AddXP(tbl.extra.amount, "Battle Pass")
    end
end

function BATTLEPASS.Unlock.ASAPPoints(ply, tbl)
    if (SERVER) then
        ply:GiveCredits(tbl.extra.amount)
        ply:ASAPSaveAllData()
    end
end

function BATTLEPASS.Unlock.Credits(ply, tbl)
    ply:AddStoreCredits(tbl.extra.amount)
end

local suitEnts = {
    ["speed"] = "armor_speedsuit",
    ["nano"] = "armor_nano",
    ["tau"] = "armor_tau",
    ["x60"] = "armor_godlike",
    ["x99"] = "armor_x99",
    ["hazmat"] = "armor_hazmat",
    ["wallhack"] = "armor_wallhack",
    ["bp1"] = "armor_bp1",
    ["gx303"] = "armor_dmgimmune",
    ["n7space"] = "armor_n7",
    ["z00"] = "armor_z00_cloak",
    ["z02"] = "armor_z02_speed",
    ["z07"] = "armor_z07_tp",
    ["z10"] = "armor_z10_chemist",
    ["bp2"] = "armor_bp2",
    ["bp3"] = "armor_bp3",
    ["assassin"] = "royal_assassin_armor",
    ["knight"] = "royal_knight_armor",
    ["warrior"] = "royal_warrior_armor",
    ["x35"] = "x35_power_suit"
}

function BATTLEPASS.Unlock.Suit(ply, tbl)
    if (SERVER) then
        local pos = ply:GetPos()
        local ent = ents.Create(suitEnts[tbl.extra.suit])
        ent:SetPos(pos)
        ent:Spawn()
        ply:inv_pickup(ent)
    end
end

local randMoney = {250000, 500000, 1000000, 12500000, 1500000, 2000000, 3000000}
local randWeps = {"tfa_doom_gauss", "tfa_wintershowl", "mac_bo2_deathmach", "weapon_fluence", "weapon_teslagun", "weapon_hoff_thundergun", "weapon_bms_gluon", "tfa_raygun_mark2", "deika_scavenger", "weapon_gargan ", "weapon_sh_detector_player", "weapon_sh_detector", "weapon_752_m2_flamethrower", "tfa_ins2_volk", "m27__mystifier", "tfa_raygun", "tfa_ins2_codol_free", "weapon_grimreaper", "tfa_csgo_sonarbomb", "m9k_emp_grenade", "robotnik_mw2_at4", "robotnik_mw2_m79", "tfa_ins2_volk", "deika_blundergat", "tfa_csgo_molly", "mac_bo2_warmach", "m9k_orangecore_grenade"}
local randXP = {1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 1000}
local randPoints = {500, 1000, 1500, 2000, 2500, 3000}
local randCredits = {10, 15, 20, 25, 30, 35, 40, 45, 50}
local randSuits = {"armor_speedsuit", "armor_nano", "armor_tau", "armor_godlike", "armor_x99", "armor_hazmat", "armor_wallhack", "armor_dmgimmune", "armor_n7"}

function BATTLEPASS.Unlock.Mystery(ply)
    if (SERVER) then
        local r = math.random(1, 6)

        if r == 1 then
            ply:addMoney(randMoney[math.random(#randMoney)])
        end

        if r == 2 then
            local amt = 1
            local pos = ply:GetPos()
            local ent = ents.Create("spawned_weapon")
            ent:SetPos(pos)
            ent:Spawn()
            ent:SetWeaponClass(randWeps[math.random(#randWeps)])
            ent:Setamount(amt)
            ply:inv_pickup(ent)
        end

        if r == 3 then
            ply:AddXP(randXP[math.random(#randXP)])
        end

        if r == 4 then
            ply:GiveCredits(randPoints[math.random(#randPoints)])
            ply:ASAPSaveAllData()
        end

        if r == 5 then
            ply:AddStoreCredits(randCredits[math.random(#randCredits)])
        end

        if r == 6 then
            local pos = ply:GetPos()
            local ent = ents.Create(suitEnts[math.random(#suitEnts)])
            ent:SetPos(pos)
            ent:Spawn()
            ply:inv_pickup(ent)
        end
    end

    if (CLIENT) then
        XeninUI:Notify("You got a Mystery Item from the Battle Pass, spooky!", LocalPlayer(), 4, XeninUI.Theme.Green)
    end
end

function BATTLEPASS.Unlock.RandomSuit(ply, tbl)
    if (SERVER) then
        local pos = ply:GetPos()
        local ent = ents.Create(randSuits[math.random(#randSuits)])
        ent:SetPos(pos)
        ent:Spawn()
        ply:inv_pickup(ent)
    end
end