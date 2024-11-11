hook.Add("PlayerInitialSpawn", "Donation", function(ply)
    timer.Simple(5, function()
        DonationRoles.Database:GetPlayer(ply, function(rank, visual, existed)
            timer.Simple(3, function()
                ply:SetDonator(rank or 0, visual or 0, true)
            end)
        end)
    end)
end)

function DonationRoles.WebhookUser(aid)
    http.Post("https://asapgaming.co/webhook/createuser", {
        steam_account_id = aid
    })
end