AddCSLuaFile()
local runPower = 1.5
local baseHealth = 2500
local baseArmor = 1500
local healthIncrease = 0
local armorIncrease = 100
local baseJump = 300
local jumpIncrease = 40
local wallhack = false
local Gluongun = false

local function doTrace(ply)
    local tr = util.TraceHull({
        start = ply:GetShootPos(),
        endpos = ply:GetShootPos() + ply:GetAimVector() * 1024,
        ignoreworld = true,
        mins = -Vector(32, 32, 32),
        maxs = Vector(32, 32, 32),
        filter = function(v) return v:IsPlayer() and v ~= ply end
    })

    return tr
end

Armor:Add({
    Name = "Karma Suit",
    Description = "Make them pay",
    Model = "models/konnie/asapgaming/destiny2/competitiveset_hunter.mdl",
    Entitie = "armor_karma",
    Wallhack = false,
    HUDPaint = function(ply)
        netrunner_VisionUI(ply)
    end,
    OnGiveClient = function(ply) end,
    Armor = baseArmor + armorIncrease,
    Health = baseHealth + healthIncrease,
    JumpPower = baseJump + jumpIncrease,
    Speed = 1 + runPower,
    OnGive = function(ply)
        ply.immuneToGluon = Gluongun
        if IsValid(ply.BallController) then
            ply.BallController:Remove()
        end

        ply.BallController = ents.Create("sent_karma_sphere")
        ply.BallController:SetOwner(ply)
        ply.BallController:SetGoodTarget(ply)
        ply.BallController:SetBadTarget(ply)
        ply.BallController:Spawn()
        ply:SetNWEntity("BallController", ply.BallController)
    end,
    Abilities = {
        [1] = {
            Cooldown = 3,
            Action = function(armor, ply)
                if SERVER then
                    if not IsValid(ply.BallController) then return end
                    local target = ply.BallController:GetGoodTarget()

                    if (target == ply) then
                        local tr = doTrace(ply)
                        if not IsValid(tr.Entity) then return end
                        ply:EmitSound("staff/ult_melee_swing.mp3")
                        ply.BallController:SetGoodTarget(tr.Entity)
                        tr.Entity.goodBall = true
                        tr.Entity.ballEnemy = tr.Entity:IsGangEnemy(ply:GetGang())
                    else
                        ply.BallController:GetBadTarget().goodBall = false
                        ply:EmitSound("player/portal_enter_01.wav")
                        ply.BallController:SetGoodTarget(ply)
                    end
                else
                    local ball = ply:GetNWEntity("BallController")

                    if (ball:GetGoodTarget() == ply) then
                        local tr = doTrace(ply)
                        if not IsValid(tr.Entity) then return false, "Target must be a player" end
                    end
                end

                return true
            end,
            Description = "Allies: Recharges armor, protects 25% damage received. Enemies: Drains armor"
        },
        [2] = {
            Cooldown = 3,
            Description = "Allies: Heals when health it's below 50%. Enemies: Receive extra 25% damage",
            Action = function(armor, ply)
                if SERVER then
                    if not IsValid(ply.BallController) then return end
                    local target = ply.BallController:GetBadTarget()

                    if (target == ply) then
                        local tr = doTrace(ply)
                        if not IsValid(tr.Entity) then return end
                        ply:EmitSound("staff/ult_melee_swing.mp3")
                        ply.BallController:SetBadTarget(tr.Entity)
                        tr.Entity.badBall = true
                        tr.Entity.ballEnemy = tr.Entity:IsGangEnemy(ply:GetGang())
                    else
                        ply.BallController:GetBadTarget().badBall = false
                        ply.BallController:SetBadTarget(ply)
                        ply:EmitSound("player/portal_enter_01.wav")
                    end
                else
                    local ball = ply:GetNWEntity("BallController")

                    if (ball:GetBadTarget() == ply) then
                        local tr = doTrace(ply)
                        if not IsValid(tr.Entity) then return false, "Target must be a player" end
                    end
                end

                return true
            end
        },
        [3] = {
            Cooldown = 30,
            Action = function(armor, ply)
                if SERVER then
                    ply.BallController:Explode()
                end

                return true
            end,
            Description = "Red ball ignites, Blue ball freezes. Both balls, does nothing"
        },
        [4] = {
            Cooldown = 120,
            Action = function(armor, ply)
                if SERVER then
                    ply:EmitSound("tfa_cso2/weapons/lollipop/lollipop_draw.wav")

                    local totalHealth = 0
                    local amount = 0
                    local sphere = ents.FindInSphere(ply:GetShootPos(), 1024)
                    local players = {}
                    for k, v in pairs(sphere) do
                        if (not v:IsPlayer()) then continue end
                        totalHealth = totalHealth + v:Health()
                        amount = amount + 1
                        table.insert(players, v)
                    end

                    for k, v in pairs(players) do
                        v:SetHealth(totalHealth / amount)
                    end
                end

                return true
            end,
            Description = "Karma happens, everyone around you gets to same HP"
        }
    },
    OnRemove = function(ply)
        ply:SetNWEntity("BallController", nil)

        if SERVER and IsValid(ply.BallController) then
            ply.BallController:Remove()
            ply.BallController = nil
        end
    end
})