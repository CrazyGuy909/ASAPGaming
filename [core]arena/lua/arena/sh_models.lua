asapArena.Models = {
    {
        Name = "Default Soldiers",
        Level = 1,
        Models = {"models/player/urban.mdl", "models/player/gasmask.mdl", "models/player/swat.mdl", "models/player/riot.mdl"}
    },
    {
        Name = "Terrorist Package",
        Level = 10,
        Models = {"models/cod players/opfor4.mdl", "models/cod players/opfor5.mdl", "models/cod players/opfor6.mdl", "models/cod players/opfor3.mdl", "models/cod players/opfor2.mdl", "models/cod players/opfor1.mdl"}
    },
    {
        Name = "Combine Soldiers",
        Level = 15,
        Models = {"models/player/combine_soldier.mdl", "models/player/combine_super_soldier.mdl", "models/player/combine_soldier_prisonguard.mdl", "models/player/police.mdl"}
    },
    {
        Name = "Spec Ops",
        Level = 25,
        Models = {"models/mw2guy/bz/bzsoap.mdl", "models/mw2guy/bz/tfbz01.mdl", "models/mw2guy/bz/tfbz03.mdl", "models/mw2guy/bz/tfbzw01.mdl"}
    },
    {
        Name = "Russian Riot Police",
        Level = 35,
        Models = {"models/cod players/fsb_takeemout3.mdl", "models/cod players/fsb_takeemout5.mdl", "models/cod players/fsb_takeemout6.mdl", "models/cod players/fsb_takeemout7.mdl"}
    },
    {
        Name = "Russian Soldiers",
        Level = 50,
        Models = {"models/mw2guy/rus/gassoldier.mdl", "models/mw2guy/rus/soldier_f.mdl", "models/mw2guy/rus/soldier_e.mdl", "models/mw2guy/rus/soldier_c.mdl"}
    },
    {
        Name = "Stealth Squad",
        Level = 75,
        Models = {"models/mw2guy/diver/diver_01.mdl", "models/mw2guy/diver/diver_02.mdl", "models/mw2guy/diver/diver_03.mdl"}
    }
}

table.sort(asapArena.Models, function(a,b)
    return a.Level < b.Level
end)

function asapArena:SetPlayerModel(ply)
    local customModels = asapArena:Run("SetPlayerModel", nil, ply)
    if (customModels == true) then return end
    local mdl, _ = table.Random(self.Models[tonumber((ply._arenaEquipment or {}).PlayerModel) or 1].Models)
    ply:SetModel(mdl)
    ply:GetHands():SetModel("models/weapons/c_arms_cstrike.mdl")
    timer.Simple(0, function()
        net.Start("ASAP.HUD.ModelUpdate")
        net.Send(ply)
    end)
end