local meta = FindMetaTable("Player")

function meta:InitGangRank()
    local tag = self:GetGang()
    local found = false

    for rank, info in pairs(asapgangs.gangList[tag].Ranks) do
        for k, sid in pairs(info.Members) do
            if (self:SteamID64() == sid) then
                self:SetNWString("Gang.Rank", rank)
                found = true
                break
            end

            if (found) then break end
        end
    end

    if not asapgangs.Players then
        asapgangs.Players = {}
    end

    if not asapgangs.Players[tag] then
        asapgangs.Players[tag] = {}
    end

    table.insert(asapgangs.Players[tag], self)
end

function meta:UpdateGang(tag)
    local ogang = self:GetNWString("Gang", "")

    if (ogang ~= "" and asapgangs.Players[ogang]) then
        table.RemoveByValue(asapgangs.Players[ogang], self)
    end

    if (tag) then
        if (not asapgangs.Players[tag]) then
            asapgangs.Players[tag] = {}
        end

        table.insert(asapgangs.Players[tag], self)

        if (asapgangs.gangList[tag]) then
            self:SetNWString("Gang", tag)
            self:InitGangRank()
            net.Start("Gangs_ToPlayer")
            net.WriteString(tag)
            net.WriteTable(asapgangs.gangList[tag])
            net.Send(self)
        else
            asapgangs.FetchGangs(tag, function(v)
                self:SetNWString("Gang", tag)
                self:InitGangRank()
                net.Start("Gangs_ToPlayer")
                net.WriteString(tag)
                net.WriteTable(asapgangs.gangList[tag])
                net.Send(self)
            end)
        end
    else
        ASAPDriver:MySQLQuery("SELECT * FROM gangs_cache WHERE steamid = '" .. self:SteamID64() .. "';", function()
            if (data and data[1] and data[1].gang) then
                if (not asapgangs.gangList[data[1].gang]) then
                    asapgangs.FetchGangs(data[1].gang, function()
                        self:UpdateGang(data[1].gang)
                    end)
                else
                    self:UpdateGang(data[1].gang)
                end
            end
        end)
    end
end

hook.Add("onXPEarned", "Gangs.XPBoost", function(ply, amount, reason)
    if (ply:GetGang() ~= "") then
        local gang = asapgangs.gangList[ply:GetGang()]
        if (not gang) then return end
        local multiplier = 1 + (UPGRADE_TEST["XP"].Data[gang.Shop.Upgrades.XP] or 0) / 100

        return math.ceil(multiplier * amount)
    end
end)

hook.Add("playerGetSalary", "Gangs.SalaryBoost", function(ply, amount)
    if (ply:GetGang() ~= "") then
        local gang = asapgangs.gangList[ply:GetGang()]
        if (not gang) then return end
        local multiplier = 1 + (UPGRADE_TEST["Salary"].Data[gang.Shop.Upgrades.Salary] or 0) / 100

        return false, nil, multiplier * amount
    end
end)

local rewards = {
    [1] = "tfa_cso_spas12exb",
    [2] = "tfa_cso_guardian",
    [3] = "tfa_cso_crossbowex_v6",
    [4] = "tfa_cso_magnumdrill"
}
hook.Add("PlayerSpawn", "Gangs.AssignSpawnStats", function(ply)
    if (ply:InArena()) then return end

    timer.Simple(.5, function()
        if (ply:GetGang() == "") then return end
        local extraArmor = asapgangs.GetUpgrade(ply:GetGang(), "Armor") * 25
        ply:SetArmor(extraArmor)

        if (asapgangs.GetUpgrade(ply:GetGang(), "Thompson") > 0) then
            ply:Give("m9k_thompson")
        end

        local points = ents.FindByClass("asap_controlpoint")
        local controlled = 0
        for k, v in pairs(points) do
            if (v:GetFaction() == ply:GetGang()) then
                controlled = controlled + 1
            end
        end

        if (controlled == 0) then return end
        local armor = 50 * controlled
        ply:SetArmor(ply:Armor() + armor)
        local wep = ply:Give(rewards[math.Clamp(controlled, 1, 4)])
        if not IsValid(wep) then return end
        ply:ChatPrint("You have been rewarded for controlling " .. controlled .. " control points with <rainbow=3>" .. wep:GetPrintName() .. "</rainbow> and <color=150,100,255>" .. armor .. "AP</color>!")
    end)
end)

hook.Add("EntityTakeDamage", "Gangs.BulletUpgrade", function(ent, dmginfo)
    if (not ent:IsPlayer()) then return end
    if (ent:InArena()) then return end
    if (ent:IsDueling()) then return end

    if (dmginfo:IsBulletDamage() and dmginfo:GetAttacker():IsPlayer()) then
        if (dmginfo:GetAttacker():InArena()) then return end
        local att = dmginfo:GetAttacker()

        if (dmginfo:GetAttacker() and dmginfo:GetAttacker():IsPlayer() and ent:GetGang() == dmginfo:GetAttacker():GetGang()) then
            local upg = asapgangs.GetUpgrade(ent:GetGang(), "NoTDM")
            if (ChrismasEvents and ChrismasEvents.PlayersIn[ent]) then return end
            if (upg > 0 and not ent.asapZonesCanGangDamage) then
                hook.Run("GangTakeDamage", ent, dmginfo)
                return true
            end
        end

        if (att:GetGang() ~= "" and att:IsGangBuffed()) then
            dmginfo:ScaleDamage(1 + 2 * asapgangs.GetUpgrade(att:GetGang(), "Damage") / 100)
        end

        if (ent:IsGangBuffed()) then
            dmginfo:ScaleDamage(1 - (2 * asapgangs.GetUpgrade(att:GetGang(), "Damage") / 100))
        end
    end
end)

hook.Add("PlayerTick", "Gangs.VerifyBuffs", function(ply)
    if (ply:InArena()) then return end
    if (ply:GetGang() == "") then return end

    --Let's make it check for buffs every 5 seconds
    if ((ply.nextBuff or 0) < CurTime()) then
        ply.nextBuff = CurTime() + 5
    else
        return
    end

    --Did we have a buff source before? Let's verify if we are near them again
    if (IsValid(ply._buffSource) and ply._buffSource:GetPos():DistToSqr(ply:GetPos()) < 180000) then return end
    local found = false

    for k, v in pairs(player.GetAll()) do
        --We don't verify ourselves or someone outside our gang
        if (v == ply) then continue end
        if (v:GetGang() ~= ply:GetGang()) then continue end

        --If we are THIS closer then we should do our shit
        if (v:GetPos():DistToSqr(ply:GetPos()) < 180000) then
            ply._buffSource = v
            ply:SetNWBool("GangBuffed", true)
            found = true

            --If the other player doesn't have a buff source, we buff them with ourselves
            if (not IsValid(v._buffSource)) then
                v._buffSource = ply
                v:SetNWBool("GangBuffed", true)
            end

            break
        end
    end

    --Not found and we are buffed? Let's take that off
    if (not found and ply:IsGangBuffed()) then
        ply._buffSource = nil
        ply:SetNWBool("GangBuffed", false)
    end
end)

hook.Add("Initialize", "SAM.LimitInitGang", function()
    timer.Simple(1, function()
        if (SAM) then
            hook.Remove("PlayerSpawnProp", "SAM.Limiter-Prop")

            hook.Add("PlayerSpawnProp", "SAM.Limiter-Prop", function(ply, model, ent)
                local limit = (SAM.Default_Config.DonatorLimits[ply:GetDonatorByRoleName()] or SAM.Default_Config.DefaultPropLimit) + (asapgangs.GetUpgrade(ply:GetGang(), "Prop") > 0 and 5 or 0)

                if (ply:GetCount("props") >= limit) then
                    SAM.ShootError(ply, "You have reached your PROP limit of: " .. limit)

                    return false
                end
            end)
        end
    end)
end)

hook.Add("PlayerDeath", "Gangs.GiveKills", function(ply, inf, att)
    if (not IsValid(att) or not att:IsPlayer()) then return end
    if (ply:GetGang() != "") then return end

    ASAPDriver:MySQLQuery("UPDATE gangs_list SET deaths=deaths + 1 WHERE Tag = '" .. ply:GetGang() .. "';")
    if (att:GetGang() != "") then
        ASAPDriver:MySQLQuery("UPDATE gangs_list SET kills=kills + 1 WHERE Tag = '" .. att:GetGang() .. "';")
    end

end)

if (SAM) then
    hook.Remove("PlayerSpawnProp", "SAM.Limiter-Prop")

    hook.Add("PlayerSpawnProp", "SAM.Limiter-Prop", function(ply, model, ent)
        local limit = (SAM.Default_Config.DonatorLimits[ply:GetDonatorByRoleName()] or SAM.Default_Config.DefaultPropLimit) + (asapgangs.GetUpgrade(ply:GetGang(), "Prop") > 0 and 5 or 0)

        if (ply:GetCount("props") >= limit) then
            SAM.ShootError(ply, "You have reached your PROP limit of: " .. limit)

            return false
        end
    end)
end

local cmd = "!ggg"
hook.Add("PlayerSay", "GangsAdmin", function(ply, txt)
    if not ply:IsAdmin() then return end
    if (not txt:StartWith(cmd)) then return end

    local args = string.Explode(" ", txt)
    if (#args < 3) then return "Invalid arguments" end

    local target = player.GetBySteamID(args[2])
    if not IsValid(target) then
        return "Invalid target"
    end

    asapgangs.AddMember(ply, args[3])
    return ""
end)

local function GangMsg(ply, args)
    local DoSay = function(text)
        if text == "" then
            DarkRP.notify(ply, 1, 4, DarkRP.getPhrase("invalid_x", "argument", ""))

            return
        end

        for k, target in pairs(player.GetAll()) do
            if (target:GetGang() ~= "" and target:GetGang() == ply:GetGang()) then
                DarkRP.talkToPerson(target, Color(255, 175, 0, 255), "(Gang) " .. ply:Nick(), Color(255, 255, 255, 255), text, ply)
            end
        end
    end

    return args, DoSay
end

local function createGangTag()
    if (DarkRP and DarkRP.getChatCommands and DarkRP.getChatCommands()["g"]) then
        DarkRP.getChatCommands()["g"] = nil
    end

    DarkRP.defineChatCommand("g", GangMsg, 0)
end

hook.Add("DarkRPFinishedLoading", "RemoveOldG", function()
    createGangTag()
end)