local IsDonator = function(ply) return ply:IsDonator(1) end
local IsUltra = function(ply) return ply:IsDonator(2) end
local IsMeme = function(ply) return ply:IsDonator(3) end
local IsMemeGod = function(ply) return ply:IsDonator(4) end
local IsMemeLegend = function(ply) return ply:IsDonator(5) end
local IsGrinch = function(ply) return ply:IsDonator(6) end
local IsChungus = function(ply) return ply:IsDonator(7) end
local IsVeryHot = function(ply) return ply:IsDonator(8) end
local IsSpooky = function(ply) return ply:IsDonator(9) end
local IsSnowy = function(ply) return ply:IsDonator(10) end
local IsEGG = function(ply) return ply:IsDonator(11) end
local IsUser = function(ply) return (ply:GetDonator() or 0) == 0 end

DarkRP.createEntity("Camera", {
    ent = "rprotect_camera",
    model = "models/tools/camera/camera.mdl",
    price = 3500,
    removable = true,
    max = 1,
    getPrice = function(ply, price) if ply.fire_sale then return price * (1 - 0.35) else return price end end,
    category = "Security",
    cmd = "camerabuy"  
})

DarkRP.createEntity("Terminal", {
    ent = "rprotect_terminal",
    model = "models/props_phx/rt_screen.mdl",
    price = 5000,
    removable = true,
    max = 1,
    getPrice = function(ply, price) if ply.fire_sale then return price * (1 - 0.35) else return price end end,
    category = "Security",
    cmd = "terminalbuy"  
})

DarkRP.createEntity("Scanner", {
    ent = "rprotect_scanner",
    model = "models/Items/battery.mdl",
    price = 10000,
    removable = true,
    max = 1,
    getPrice = function(ply, price) if ply.fire_sale then return price * (1 - 0.35) else return price end end,
    category = "Security",
    cmd = "buyscanner"  
})

DarkRP.createEntity("Health Recharger", {
    ent = "hp_charger",
    model = "models/props_c17/consolebox03a.mdl",
    price = 3000,
    max = 1,
    getPrice = function(ply, price) if ply.fire_sale then return price * (1 - 0.35) else return price end end,
    category = "Chargers",
    cmd = "buyacharggersfdhealthsr",
    customCheck = function(ply) return IsUser(ply) end,
    customCheckFailMsg = "You can buy V.I.P Health charger!",
})

DarkRP.createEntity("Armor Recharger", {
    ent = "armor_charger",
    model = "models/props_c17/consolebox03a.mdl",
    price = 5000,
    max = 1,
    category = "Chargers",
    cmd = "buyaarmorrecharger",
    customCheck = function(ply) return IsUser(ply) end,
    customCheckFailMsg = "You can buy V.I.P Health charger!",
})

DarkRP.createEntity("Health Recharger (VIP)", {
    ent = "vip_hp_charger",
    model = "models/props_lab/reciever01a.mdl",
    price = 5000,
    max = 1,
    getPrice = function(ply, price) if ply.fire_sale then return price * (1 - 0.35) else return price end end,
    category = "Chargers",
    cmd = "buyhealtgghvipdprhealth",
    customCheck = function(ply) return IsDonator(ply) end,
    customCheckFailMsg = "This entity is restricted to donator and higher!",
})

DarkRP.createEntity("Armor Recharger (VIP)", {
    ent = "vip_armor_charger",
    model = "models/props_lab/reciever01a.mdl",
    price = 8000,
    max = 1,
    category = "Chargers",
    cmd = "buyhealtgghvipdpr",
    customCheck = function(ply) return IsDonator(ply) end,
    customCheckFailMsg = "This entity is restricted to donator and higher!",
})

DarkRP.createEntity("Piano", {
    ent = "gmt_instrument_piano",
    model = "models/fishy/furniture/piano.mdl",
    price = 100000,
    removable = true,
    max = 1,
    getPrice = function(ply, price) if ply.fire_sale then return price * (1 - 0.35) else return price end end,
    category = "Piano",
    allowed = {TEAM_PIANIST},
    cmd = "buypiano"
})

DarkRP.createEntity("Radio", {
    ent = "whk_radio",
    model = "models/props_lab/citizenradio.mdl",
    price = 5000,
    removable = true,
    max = 1,
    getPrice = function(ply, price) if ply.fire_sale then return price * (1 - 0.35) else return price end end,
    category = "DJ",
    allowed = {TEAM_RADIODJ},
    cmd = "buywhkradio"
})

DarkRP.createEntity("Beer", {
    ent = "durgz_alcohol",
    model = "models/drug_mod/alcohol_can.mdl",
    price = 500,
    max = 2,
    getPrice = function(ply, price) if ply.fire_sale then return price * (1 - 0.35) else return price end end,
    category = "Bartender",
    allowed = {TEAM_BARTENDER},
    cmd = "buybeerbar"
})

DarkRP.createEntity("Vodka", {
    ent = "durgz_vodka",
    model = "models/half-dead/gopniks/vodka.mdl",
    price = 650,
    max = 2,
    getPrice = function(ply, price) if ply.fire_sale then return price * (1 - 0.35) else return price end end,
    category = "Bartender",
    allowed = {TEAM_BARTENDER},
    cmd = "buyvodkabar"
})

DarkRP.createEntity("Water", {
    ent = "durgz_water",
    model = "models/drug_mod/the_bottle_of_water.mdl",
    price = 100,
    max = 2,
    getPrice = function(ply, price) if ply.fire_sale then return price * (1 - 0.35) else return price end end,
    category = "Bartender",
    allowed = {TEAM_BARTENDER},
    cmd = "buywaterbar"
})

DarkRP.createEntity("Cigarette", {
    ent = "durgz_cigarette",
    model = "models/boxopencigshib.mdl",
    price = 400,
    max = 1,
    getPrice = function(ply, price) if ply.fire_sale then return price * (1 - 0.35) else return price end end,
    category = "Bartender",
    allowed = {TEAM_BARTENDER},
    cmd = "buywcigarettebar"
})

DarkRP.createEntity("Cigar", {
    ent = "durgz_cigar",
    model = "models/jellik/cigar.mdl",
    price = 600,
    max = 1,
    getPrice = function(ply, price) if ply.fire_sale then return price * (1 - 0.35) else return price end end,
    category = "Bartender",
    allowed = {TEAM_BARTENDER},
    cmd = "buywcigarbar"
})
DarkRP.createEntity("Apple", {
    ent = "durgz_apple",
    model = "models/apple.mdl",
    price = 900,
    max = 1,
    getPrice = function(ply, price) 
        if ply.fire_sale then 
            return price * 0.65 
        else 
            return price 
        end 
    end,
    category = "Bartender",
    allowed = {TEAM_BARTENDER},
    cmd = "buyapplebar"
})

DarkRP.createEntity("Lean", {
    ent = "durgz_lean",
    model = "models/jellik/lean.mdl",
    price = 600,
    max = 1,
    getPrice = function(ply, price) 
        if ply.fire_sale then 
            return price * 0.65 
        else 
            return price 
        end 
    end,
    category = "Drugs",
    allowed = {TEAM_DRUG},
    cmd = "buyleandrug"
})

DarkRP.createEntity("Cocaine", {
    ent = "durgz_cocaine",
    model = "models/cocn.mdl",
    price = 800,
    max = 1,
    getPrice = function(ply, price) 
        if ply.fire_sale then 
            return price * 0.65 
        else 
            return price 
        end 
    end,
    category = "Drugs",
    allowed = {TEAM_DRUG},
    cmd = "buycocodrug"
})

DarkRP.createEntity("PCP", {
    ent = "durgz_pcp",
    model = "models/marioragdoll/Super Mario Galaxy/star/star.mdl",
    price = 750,
    max = 1,
    getPrice = function(ply, price) 
        if ply.fire_sale then 
            return price * 0.65 
        else 
            return price 
        end 
    end,
    category = "Drugs",
    allowed = {TEAM_DRUG},
    cmd = "buypcpdrug"
})

DarkRP.createEntity("Mushroom", {
    ent = "durgz_mushroom",
    model = "models/ipha/mushroom_small.mdl",
    price = 1500,
    max = 1,
    getPrice = function(ply, price) 
        if ply.fire_sale then 
            return price * 0.65 
        else 
            return price 
        end 
    end,
    category = "Drugs",
    allowed = {TEAM_DRUG},
    cmd = "buymushdrug"
})

DarkRP.createEntity("Heroin", {
    ent = "durgz_heroine",
    model = "models/jellik/heroin.mdl",
    price = 710,
    max = 1,
    getPrice = function(ply, price) 
        if ply.fire_sale then 
            return price * 0.65 
        else 
            return price 
        end 
    end,
    category = "Drugs",
    allowed = {TEAM_DRUG},
    cmd = "buyheroindrug"
})

DarkRP.createEntity("Weed", {
    ent = "durgz_weed",
    model = "models/katharsmodels/contraband/zak_wiet/zak_wiet.mdl",
    price = 950,
    max = 1,
    getPrice = function(ply, price) 
        if ply.fire_sale then 
            return price * 0.65 
        else 
            return price 
        end 
    end,
    category = "Drugs",
    allowed = {TEAM_DRUG},
    cmd = "buyweeddrug"
})

DarkRP.createEntity("Printer Rack", {
    ent = "nebula_printer",
    model = "models/asapgaming/moneyprinter/money_printer.mdl",
    price = 50000,
    max = 1,
    getPrice = function(ply, price) 
        if ply.fire_sale then 
            return price * 0.65 
        else 
            return price 
        end 
    end,
    cmd = "printermachine",
    category = "Printers"
})

DarkRP.createEntity("Printer Rack", {
    ent = "nebula_printer",
    model = "models/asapgaming/moneyprinter/money_printer.mdl",
    price = 100000,
    max = 1,
    getPrice = function(ply, price) 
        if ply.fire_sale then 
            return price * 0.65 
        else 
            return price 
        end 
    end,
    cmd = "printermachine2",
    category = "Printers",
    customCheck = function(ply) return IsMemeGod(ply) end,
    customCheckFailMsg = "This entity is restricted to Executive and higher!"
})

DarkRP.createEntity("Printer Rack", {
    ent = "nebula_printer",
    model = "models/asapgaming/moneyprinter/money_printer.mdl",
    price = 100000,
    max = 1,
    getPrice = function(ply, price) 
        if ply.fire_sale then 
            return price * 0.65 
        else 
            return price 
        end 
    end,
    cmd = "printermachine3",
    category = "Printers",
    customCheck = function(ply) return IsMemeLegend(ply) end,
    customCheckFailMsg = "This entity is restricted to Limited Ranks and higher!"
})

DarkRP.createEntity("Gang Computer", {
    ent = "sent_gang_computer",
    model = "models/zerochain/props_factory/zpf_lab.mdl",
    price = 100000,
    max = 1,
    allowed = {TEAM_GANGLEADER},
    cmd = "buygangcomputer",
    category = "Gang",
    onBought = function(ply, ent)
        ent:Setowning_ent(ply)
    end
})

--- TURRETS

DarkRP.createEntity("Turret", {
    ent = "ent_turret",
    model = "models/asap/basic_turret.mdl",
    price = 25000,
    removable = true,
    max = 2,
    allowed = {TEAM_BASEBIGBRAIN, TEAM_BASEBIGBRAINVIP, TEAM_BASEBIGBRAINMEME},
    getPrice = function(ply, price) 
        if ply.fire_sale then 
            return price * 0.65 
        else 
            return price 
        end 
    end,
    category = "Base Defense",
    cmd = "buyturret",
    spawn = function(ply, tr, tblEnt)
        local tr = ply:GetEyeTrace()
        local ent = ents.Create("ent_turret")
        timer.Simple(0, function()
            ent:SetTurretOwner(ply)
        end)
        ent:SetPos(tr.HitPos)
        ent:Spawn()
        ent:Setowning_ent(ply)
        return ent
    end
})

DarkRP.createEntity("Generator", {
    ent = "power_generator",
    model = "models/tnt/lightning_lv3.mdl",
    price = 40000,
    removable = true,
    max = 1,
    allowed = {TEAM_BASEBIGBRAIN, TEAM_BASEBIGBRAINVIP, TEAM_BASEBIGBRAINMEME},
    getPrice = function(ply, price) 
        if ply.fire_sale then 
            return price * 0.65 
        else 
            return price 
        end 
    end,
    category = "Base Defense",
    cmd = "buygenerator",
    spawn = function(ply, tr, tblEnt)
        local tr = ply:GetEyeTrace()
        local ent = ents.Create("power_generator")
        timer.Simple(0, function()
            ent:Setowning_ent(ply)
        end)
        ent:SetPos(tr.HitPos)
        ent:Spawn()
        return ent
    end
})