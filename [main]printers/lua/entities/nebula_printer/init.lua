AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr, cs)
    if not tr.Hit then return end
    local ent = ents.Create(cs)
    ent:SetPos(tr.HitPos + tr.HitNormal * 16)
    ent:Spawn()
    ent:Activate()
    ent:Setowning_ent(ply)
	ent:SetOwner(ply)
	hook.Run("OnPrinterCreated", ent)
    return ent
end

function ENT:OnRemove()
    if self.LoopingMachine and self.LoopingMachine.Stop then
        self:StopLoopingSound(self.LoopingMachine)
    end
end

function ENT:StartSyphoning(ply)
    self:SetSyphon(ply)

    if self:GetRaidUpgrade() > 0 then
        DarkRP.notify(self:Getowning_ent(), 1, 4, "Your printer has been tampered")
    end

    self:EmitSound("npc/strider/striderx_alert5.wav")
end

function ENT:Initialize()
    self:SetModel("models/ogl/ogl_oneprint_nebula.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_NONE) -- Change this if necessary

    self:SetUseType(SIMPLE_USE)
    self:Activate()
    self:SetHealth(NebulaPrinters.Config.Health)

    -- Ensure owner is set before calling the hook
    if not IsValid(self:GetOwner()) then
        self:SetOwner(self:Getowning_ent())  -- or however the owner should be set
    end

    for k = 1, 6 do
        self:SetBodygroup(k + 1, 1)
        self:SetBodygroup(k + 7, 1)
        self:SetBodygroup(k + 7 + 6, 1)
        self:SetBodygroup(k + 7 + 12, 1)
    end

    self:GetPhysicsObject():Wake()
    self:AddPrinter()
    
    -- Call the hook after all initialization is done
    hook.Run("OnPrinterCreated", self)
end

function ENT:Use()
end

function ENT:AddPrinter()
    if self:GetPrinters() > 5 then return end

    self:SetPrinters(self:GetPrinters() + 1)
    local offset = (self:GetPrinters() - 1) * 6

    for k = 1, 4 do
        self:SetBodygroup(self:GetPrinters() + 1, 0)
        self:SetBodygroup(self:GetPrinters() + 1 + k * 6, 0)
    end

    self:EmitSound("doors/door_latch1.wav")
end

function ENT:ToggleFans()
    self:SetFansOn(not self:GetFansOn())

    if self.LoopingMachine and self.LoopingMachine.Stop then
        self.LoopingMachine:Stop()
    end

    if self:GetFansOn() and self:GetIsOn() then
        self.LoopingMachine = CreateSound(self, "ambient/machines/lab_loop1.wav")
        self.LoopingMachine:SetSoundLevel(60)
        self.LoopingMachine:Play()
        timer.Create(self:EntIndex() .. "_sound", SoundDuration( "ambient/machines/lab_loop1.wav" ), 0, function()
            if (IsValid(self) and self.LoopingMachine) then
                self.LoopingMachine:Play()
            end
        end)
    end
end

ENT.HealingIn = 0

function ENT:Think()
    if not IsValid(self:Getowning_ent()) then
        self:TakeDamage(5, self, self)

        return
    end

    if IsValid(self:GetSyphon()) then
        local dist = self:GetPos():Distance(self:GetSyphon():GetPos())

        if not self:GetSyphon():Alive() or dist > 512 then
            self:EmitSound("npc/strider/strider_step2.wav")
            self:SetSyphon(nil)
            self:NextThink(CurTime())

            return true
        end

        self:EmitSound("npc/strider/strider_minigun.wav", 90, 175, .6)
        local eff = EffectData()
        eff:SetOrigin(self:GetPos() + self:GetForward() * 28 + self:GetUp() * 56)
        eff:SetMagnitude(2)
        eff:SetScale(2)
        eff:SetRadius(16)
        eff:SetNormal(self:GetForward())
        util.Effect("Sparks", eff, true, true)
        local ten = self:GetRaidUpgrade() / 10
        local percent = self:GetMaxMoney() * .05 - ten * self:GetMaxMoney() * .025
        self:GetSyphon():addMoney(percent)
        self:SetMoney(self:GetMoney() - percent)

        hook.Run("ASAPPrinters.WithdrawMoney", self:GetSyphon(), self, percent, 10)

        if self:GetMoney() <= 0 then
            self:UpdateState(false, self:GetSyphon())
            self:SetMoney(0)
            self:SetSyphon(nil)
            self:NextThink(CurTime())

            return true
        end

        self:NextThink(CurTime() + NebulaPrinters.Config.TickDelay + ten * 2)

        return true
    end

    if self:GetIsOn() then
        self:SetMoney(self:GetMoney() + self:GetMoneyPerSecond())
        /*
        if self:GetMoney() > self:GetMaxMoney() then
            self:SetSkin(1)
            self:SetMoney(math.Round(self:GetMaxMoney()))
            self:SetIsOn(false)
        end
        */
    end

    if self:Health() ~= NebulaPrinters.Config.Health and self.HealingIn < CurTime() then
        self:SetHealth(self:Health() + 15)
        self:SetSkin(2)

        if self:Health() >= NebulaPrinters.Config.Health then
            self:SetSkin(0)
            self:SetHealth(NebulaPrinters.Config.Health)
        end
    end

    self:NextThink(CurTime() + NebulaPrinters.Config.TickDelay)

    return true
end

ENT.Cooldown = 0

function ENT:UpdateState(b, triggered)
    if self.Cooldown > CurTime() then return end
    self.Cooldown = CurTime() + 1

    if self:GetPrinters() == 0 then
        DarkRP.notify(triggered, 1, 4, "You need to have at least one printer to use this.")
        self:EmitSound("buttons/button10.wav")

        return
    end

    self:SetIsOn(b)
    local animName = b and (self:GetFansOn() and "printer on" or "moneyfall") or "idle"
    self:SetSequence(animName)
    self:ResetSequence(animName)
    self:EmitSound(b and "buttons/button1.wav" or "buttons/button16.wav")

    if self.LoopingMachine then
        self.LoopingMachine:Stop()
    end

    if self:GetFansOn() and b then
        self.LoopingMachine = CreateSound(self, "ambient/machines/lab_loop1.wav")
        self.LoopingMachine:SetSoundLevel(60)
        self.LoopingMachine:Play()
        timer.Create(self:EntIndex() .. "_sound", SoundDuration( "ambient/machines/lab_loop1.wav" ), 0, function()
            if (IsValid(self) and self.LoopingMachine) then
                self.LoopingMachine:Play()
            end
        end)
    end

    self:NextThink(CurTime())
end

function ENT:OnRemove()
    if self.LoopingMachine then
        self.LoopingMachine:Stop()
    end
end

function ENT:OnTakeDamage(dmg)
    if self:Health() <= 0 then return end
    if (self:GetFansOn()) then
        dmg:SetDamage(dmg:GetDamage() * 1.5)
    end
    self:SetHealth(self:Health() - dmg:GetDamage())
    self.HealingIn = CurTime() + 5
    self:SetSkin(3)

    if self:Health() <= 0 then
        hook.Run("ASAPPrinters.DestroyPrinter", self, dmg:GetAttacker())

        if IsValid(self:Getowning_ent()) then
            local explode = ents.Create("env_explosion") -- creates the explosion
            explode:SetPos(self:GetPos())
            explode:SetOwner(dmg:GetAttacker())
            explode:Spawn()
            explode:SetKeyValue("iMagnitude", "90")
            explode:Fire("Explode", 0, 0)
        end

        self:Remove()
    else
        self:callOnClient(RPC_PVS, "Hurt")
    end
end