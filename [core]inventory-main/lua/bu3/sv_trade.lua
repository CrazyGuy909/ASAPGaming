util.AddNetworkString("BU3.Trade:SendInvitation")
util.AddNetworkString("BU3.Trade:SendResponse")
util.AddNetworkString("BU3.Trade:InsertItem")
util.AddNetworkString("BU3.Trade:SetMoney")
util.AddNetworkString("BU3.Trade:SetCredits")
util.AddNetworkString("BU3.Trade:ChangeStatus")
util.AddNetworkString("BU3.Trade:Start")
util.AddNetworkString("BU3.Trade:Finish")
util.AddNetworkString("BU3.Trade:SendMessage")
util.AddNetworkString("BU3.Trade:SyncStuff")
util.AddNetworkString("BU3.Trade:UpdateInfo")
util.AddNetworkString("ASAP.Trade:ToggleVoiceChat")
util.AddNetworkString("BU3.Trade:Quit")
util.AddNetworkString("BU3.Trade:UpdateInfoCredits")

ASAPTrade = {
    Sessions = {}
}

local whitelist = {
    ["/"] = true,
    ["a"] = true,
    ["pm"] = true,
    ["advert"] = true,
}
hook.Add("canChatCommand", "DisableChatCommands", function(ply, cmd, args)
    if (ply._tradeID or ply.DoingCoinflip) then
        if (whitelist[cmd]) then return end
        return false
    end
end)

ASAPTrade.CreditsTraded = ASAPTrade.CreditsTraded or {}

function ASAPTrade:StartTrade(ply, target)
    --I normally just know how to make things works instantly, always with creative solutions
    --This time i was facing this awful issue, for trade ids, i use os.time(), that returns time
    --in epoch on seconds, that means it only changes every second, so if 2 trades happens at the
    --same second, shit gets real and even me have no idea how broken that would be
    --How did i solve it? I just add seconds until nobody has this id, it would fix the issue
    --and the only drawback it's that the date will be innacurate just by few seconds
    local id = os.time()

    while (self.Sessions[id]) do
        id = id + 1
    end

    ply._tradeID = id
    ply._tradeSlot = 1
    target._tradeID = id
    target._tradeSlot = 2
    ply:SetNWBool("Trade.Ready", false)
    target:SetNWBool("Trade.Ready", false)
    ply._tradeHasInvite = nil
    target._tradeHasInvite = nil

    self.Sessions[id] = {
        Items = {{}, {}},
        Money = {0, 0},
        Credits = {0, 0},
        Players = {ply, target},
        ChatLog = {}
    }

    local targets = {ply, target}
    net.Start("BU3.Trade:Start")
    net.WriteTable(targets)
    net.Send(targets)

    hook.Add("PlayerCanHearPlayersVoice", ply, function(_, list, talk)
        if (not ply:GetNWBool("Trade.Voice") or not target:GetNWBool("Trade.Voice")) then return end
        if ((list == ply or list == target) and (talk == ply or talk == target)) then return true end
    end)
end

function ASAPTrade:FinishTrade(ply)
    local session = self.Sessions[ply._tradeID]

    if not session then
        ply._tradeID = nil
        net.Start("BU3.Trade:Quit")
        net.Send(ply)

        return
    end

    if (session.Players[1]:GetNWBool("Trade.Ready", false) and session.Players[2]:GetNWBool("Trade.Ready", false)) then
        session.Players[1]:SetNWBool("Trade.Ready", false)
        session.Players[2]:SetNWBool("Trade.Ready", false)
        local target = session.Players[1] == ply and session.Players[2] or session.Players[1]

        local canContinue = true
        for id = 1, 2 do
            if not canContinue then break end
            local target = session.Players[id == 1 and 2 or 1]
            local moneyAmount = session.Money[id]
            if (session.Players[id]:canAfford(moneyAmount)) then
                session.Players[id]:addMoney(-moneyAmount)
                target:addMoney(moneyAmount)
            else
                canContinue = false
                continue
            end
            local creditsAmount = session.Credits[id]
            if (session.Players[id]:GetStoreCredits() < creditsAmount) then
                canContinue = false
                continue
            end
            for k, v in pairs(session.Items[id]) do
                local target = session.Players[id == 1 and 2 or 1]
                if (not session.Players[id]._ub3inv[k] or session.Players[id]._ub3inv[k] < v) then
                    target:ChatPrint("Your trade has been cancelled because the trader doesn't have such item\nTalk with an admin")
                    canContinue = false
                    continue
                end

                if not canContinue then break end
                session.Players[id]:UB3RemoveItem(k, v)
                target:UB3AddItem(k, v)
            end

            if not canContinue then break end

            local target = session.Players[id == 1 and 2 or 1]
            session.Players[id]:AddStoreCredits(-creditsAmount)
            ASAPTrade.CreditsTraded[session.Players[id]] = (ASAPTrade.CreditsTraded[session.Players[id]] or 0) + creditsAmount
            if (ASAPTrade.CreditsTraded[session.Players[id]] > 10000) then
                session.Players[id]:SetNWBool("Trade.NoCredits", true)
            end

            target:AddStoreCredits(creditsAmount)
        end

        local a, b = session.Players[1], session.Players[2]
        net.Start("BU3.Trade:Finish")
        net.WriteInt(1, 4)
        net.Send({a, b})
        local chatlog = {}

        for k, v in pairs(session.ChatLog) do
            table.insert(chatlog, {
                Owner = a == v.Owner and 1 or 2,
                Message = sql.SQLStr(v.Message, true)
            })
        end

        local data = {
            key = "gonzo_built_it",
            a = tostring(a:SteamID64()),
            b = tostring(b:SteamID64()),
            id = tostring(ply._tradeID),
            date = tostring(os.time()),
            tradeinfo = util.TableToJSON({
                Items = table.Copy(session.Items),
                Money = session.Money,
                Credits = session.Credits,
                ChatLog = chatlog,
                Failed = 1,
            })
        }
		
        net.Start("BU3.Trade:Quit")
        net.Send({a, b})
        http.Post(asapMarket.API .. "/trade/upload", data)
        self.Sessions[a._tradeID] = nil
        a._tradeID = nil
        b._tradeID = nil
        a._tradeHasInvite = nil
        b._tradeHasInvite = nil
        ply._tradeID = nil
    end
end

net.Receive("BU3.Trade:InsertItem", function(l, ply)
    local item = net.ReadUInt(16)
    local amount = net.ReadUInt(16)

    if (ply._ub3inv[item] and ply._ub3inv[item] >= amount) then
        local tradeSession = ASAPTrade.Sessions[ply._tradeID]

        if not tradeSession then
            ply._tradeID = nil
            net.Start("BU3.Trade:Quit")
            net.Send(ply)

            return
        end

        tradeSession.Items[ply._tradeSlot][item] = amount > 0 and amount or nil
        net.Start("BU3.Trade:SyncStuff")
        net.WriteTable(tradeSession)
        net.Send(tradeSession.Players)
        tradeSession.Players[1]:SetNWBool("Trade.Ready", false)
        tradeSession.Players[2]:SetNWBool("Trade.Ready", false)
        net.Start("BU3.Trade:UpdateInfo")
        net.WriteBool(true)
        net.WriteEntity(ply)
        net.WriteInt(item, 32)
        net.WriteBool(tradeSession.Items[ply._tradeSlot][item] ~= nil)
        net.Send(tradeSession.Players)
    end
end)

net.Receive("BU3.Trade:ChangeStatus", function(l, ply)
    local state = net.ReadBool()
    ply:SetNWBool("Trade.Ready", state)
end)

net.Receive("BU3.Trade:Finish", function(l, ply)
    ASAPTrade:FinishTrade(ply)
end)

net.Receive("BU3.Trade:SetMoney", function(l, ply)
    local amount = net.ReadUInt(32)
    if (amount < 0) then return end

    if (ply:canAfford(amount)) then
        local tradeSession = ASAPTrade.Sessions[ply._tradeID]
        tradeSession.Money[ply._tradeSlot] = amount
        net.Start("BU3.Trade:SyncStuff")
        net.WriteTable(tradeSession)
        net.Send(tradeSession.Players)
        tradeSession.Players[1]:SetNWBool("Trade.Ready", false)
        tradeSession.Players[2]:SetNWBool("Trade.Ready", false)
        net.Start("BU3.Trade:UpdateInfo")
        net.WriteBool(false)
        net.WriteEntity(ply)
        net.WriteUInt(amount, 32)
        net.WriteBool(true)
        net.Send(tradeSession.Players)
    end
end)

net.Receive("BU3.Trade:SetCredits", function(l, ply)
    local amount = net.ReadUInt(32)
    if (amount < 0) then return end

    if (ply:GetNWBool("Trade.NoCredits")) then
        ply:SendLua([[
Derma_Message("You've exceeded max credits sent, talk with the staff to uplift the limit.", "Error", "OK")
        ]])
        return
    end

    if (ply:GetStoreCredits() >= amount) then
        local tradeSession = ASAPTrade.Sessions[ply._tradeID]
        tradeSession.Credits[ply._tradeSlot] = amount
        net.Start("BU3.Trade:SyncStuff")
        net.WriteTable(tradeSession)
        net.Send(tradeSession.Players)
        tradeSession.Players[1]:SetNWBool("Trade.Ready", false)
        tradeSession.Players[2]:SetNWBool("Trade.Ready", false)
        net.Start("BU3.Trade:UpdateInfoCredits")
        net.WriteEntity(ply)
        net.WriteUInt(amount, 32)
        net.Send(tradeSession.Players)
    end
end)

local cmd = "!clearlimit"
hook.Add("PlayerSay", "ClearLimit", function(ply, text)
    if (ply:IsAdmin() and text:StartWith(cmd)) then
        local sid = text:sub(#cmd + 2)
        if sid and IsValid(player.GetBySteamID(sid)) then
            local target = player.GetBySteamID(sid)
            target:SetNWBool("Trade.NoCredits", false)
            ASAPTrade.CreditsTraded[target] = 0
            ply:ChatPrint("Limit cleared for " .. target:Nick())
            DarkRP.notify(target, 0, 4, "Your limit has been cleared by an admin.")
        else
            ply:ChatPrint("Invalid player.")
        end

        return ""
    end
end)

net.Receive("BU3.Trade:SendInvitation", function(l, ply)
    local target = net.ReadEntity()

    if (GetGlobalBool("Purge.Active", false)) then
        ply:SendLua("Derma_Message('You cannot trade during a purge', 'Error', 'ok')")
        return
    end

    if (not target.loadedInventory or not ply.loadedInventory) then
        ply:SendLua("Derma_Message('Player data not initialized!', 'Error', 'ok')")

        return
    end

    if (ply.DoingCoinflip or target.DoingCoinflip) then
        ply:SendLua("Derma_Message('You cannot trade while doing a coinflip', 'Error', 'ok')")

        return
    end

    if (timer.Exists(ply:SteamID64() .. "_tradeRequest")) then
        ply:SendLua("Derma_Message('Wait for the other player to accept/decline your invitation first', 'Error', 'ok')")

        return
    end

    if (target._tradeID or target._tradeHasInvite) then
        ply:SendLua("Derma_Message('This player is busy', 'Error', 'ok')")

        return
    end

    target._tradeHasInvite = ply
    ply._tradeHasInvite = target
    net.Start("BU3.Trade:SendInvitation")
    net.WriteEntity(ply)
    net.Send(target)

    timer.Create(ply:SteamID64() .. "_tradeRequest", 20, 1, function()
        if IsValid(ply) then
            ply._tradeHasInvite = nil
            ply:SendLua("Derma_Message('Your trade offer timed out', 'Oh noes')")

            if IsValid(target) then
                target._tradeHasInvite = nil
            end
        end
    end)
end)

net.Receive("BU3.Trade:SendResponse", function(l, ply)
    local res = net.ReadBool()
    local target = ply._tradeHasInvite

    if (GetGlobalBool("Purge.Active", false)) then
        ply:SendLua("Derma_Message('You cannot trade during a purge', 'Error', 'ok')")
        ply._tradeHasInvite = nil
        target._tradeHasInvite = nil
        return
    end

    if (IsValid(target)) then
        if (target._tradeID) then return end

        if (res) then
            if not ASAPTrade then
                ASAPTrade = {
                    Sessions = {}
                }
            end

            ASAPTrade:StartTrade(ply, target)
        else
            ply._tradeHasInvite = nil
            target._tradeHasInvite = nil
            target:SendLua("Derma_Message('Your trade offer has been declined', 'Oh noes')")
        end

        timer.Remove(target:SteamID64() .. "_tradeRequest")
    end
end)

net.Receive("BU3.Trade:SendMessage", function(l, ply)
    local msg = net.ReadString()
    msg = string.Replace(msg, '"', "")

    if (ply._tradeID) then
        local session = ASAPTrade.Sessions[ply._tradeID]

        if not session then
            ply._tradeID = nil
            net.Start("BU3.Trade:Quit")
            net.Send(ply)

            return
        end

        table.insert(session.ChatLog, {
            Owner = ply,
            Message = msg
        })

        net.Start("BU3.Trade:SendMessage")
        net.WriteString(msg)
        net.Send(session.Players[1] == ply and session.Players[2] or session.Players[1])
    end
end)

net.Receive("ASAP.Trade:ToggleVoiceChat", function(l, ply)
    ply:SetNWBool("Trade.Voice", not ply:GetNWBool("Trade.Voice", false))
end)

net.Receive("BU3.Trade:Quit", function(l, ply)
    if (ply._tradeID) then
        local session = ASAPTrade.Sessions[ply._tradeID]
        local otherply = session.Players[1] == ply and session.Players[2] or session.Players[1]

        if IsValid(otherply) then
            net.Start("BU3.Trade:Quit")
            net.Send(otherply)
            DarkRP.notify(otherply, 0, 5, ply:Nick() .. " has cancelled the trade.")
            otherply._tradeID = nil
        end

        ASAPTrade.Sessions[ply._tradeID] = nil
        ply._tradeID = nil
    end
end)

hook.Add("PlayerDisconnected", "BU3.TradeQuit", function(ply)
    if (ply._tradeID) then
        local session = ASAPTrade.Sessions[ply._tradeID]
        local target = session.Players[1] == ply and session.Players[2] or session.Players[1]
        net.Start("BU3.Trade:Quit")
        net.Send(target)
        ASAPTrade.Sessions[ply._tradeID] = nil
        target._tradeID = nil
    end
end)