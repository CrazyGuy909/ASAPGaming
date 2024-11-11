local SLOT = {}

function SLOT:Init()
    self:SetText("")
    self.LastData = {
        VElements = {}
    }
    self.VElements = {}
end

local colors = {
    Primary = Color(229, 69, 69),
    Secondary = Color(69, 193, 229),
    Melee = Color(115, 209, 52),
    Misc = Color(230, 229, 105),
    PlayerModel = Color(220, 105, 230),
    Taunt = Color(0, 54, 255)
}

local ranks = {
    [20] = Color(0, 138, 255),
    [40] = Color(78, 202, 81),
    [60] = Color(208, 117, 29),
    [80] = Color(244, 71, 255),
    [100] = Color(255, 249, 71)
}

local deg = surface.GetTextureID("vgui/gradient-l")
SLOT.HoverProgress = 0
SLOT.IsLevel = false

function SLOT:Paint(w, h)
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(ColorAlpha(self.Color or color_white, self:IsHovered() and 150 or 50))
    surface.DrawOutlinedRect(0, 0, w, h)
    if (self.IsLevel) then
        surface.DrawRect(0, 0, w, 8)
        surface.DrawRect(0, h - 8, w, 8)
        surface.DrawRect(0, 8, 8, h - 16)
        surface.DrawRect(w - 8, 8, 8, h - 16)
    end
    surface.SetDrawColor(ColorAlpha(self.Color or color_white, self.HoverProgress))
    self.HoverProgress = Lerp(FrameTime() * 2, self.HoverProgress, self:IsHovered() and 25 or 0)

    local poly = {
        {
            x = 0,
            y = 0,
            u = 0,
            v = 0
        },
        {
            x = w,
            y = 0,
            u = .75 + math.cos(RealTime() * 4) * .25,
            v = 0
        },
        {
            x = w,
            y = h,
            u = .75 + math.sin(RealTime() * 4) * .25,
            v = 1
        },
        {
            x = 0,
            y = h,
            u = .5,
            v = 0
        }
    }

    surface.SetTexture(deg)
    surface.DrawPoly(poly)

    if (LocalPlayer()._arenaEquipment[self.Kind]) then
        if (self.Kind ~= "Taunt") then
            local data = asapArena.Weapons[LocalPlayer()._arenaEquipment[self.Kind]]
            if (not data) then return end
            draw.SimpleText(data.Name, self.IsLevel and "Arena.Medium" or "Arena.Small", self.IsLevel and 14 or 8, self.IsLevel and 12 or 4, Color(255, 255, 255, 200))
            local tx, _ = draw.SimpleText("Level: ", "Arena.Small", self.IsLevel and 16 or 10, self.IsLevel and 56 or 48, Color(255, 255, 255, 50))
            draw.SimpleText(self.IsLevel and self.Level or data.Level, "Arena.Small", (self.IsLevel and 16 or 10) + tx, self.IsLevel and 56 or 48, color_white)
            if (self.IsLevel) then
                surface.SetDrawColor(ColorAlpha(self.Color, 200))
                surface.DrawOutlinedRect(16, h - 32, w - 32, 16)
                local diff = asapArena:LevelFormula((self.Level or 1) + 1) - asapArena:LevelFormula(self.Level or 1)
                local xp = asapArena:GetWeaponXP(LocalPlayer(), self.ID)
                local am = 1 - (asapArena:LevelFormula(self.Level + 1) - xp) / diff
                surface.DrawRect(18, h - 30, (w - 36) * am, 12)
                surface.SetTexture(deg)
                surface.SetDrawColor(self.Color.r * .5, self.Color.g * .5, self.Color.b * .5, 255)
                surface.DrawTexturedRectUV(18, h - 30, (w - 32) * am, 12, 0, 0, am / 2 + math.cos(RealTime() * 3) * am / 2, 1)

                surface.DrawRect(16, h - 56, 32, 24)
                draw.SimpleText(self.Level, "Arena.Small", 32, h - 44, color_white, 1, 1)
                surface.DrawRect(w - 16 - 32, h - 56, 32, 24)
                draw.SimpleText(self.Level + 1, "Arena.Small", w - 32, h - 44, color_white, 1, 1)

                draw.SimpleText(xp .. "/" .. asapArena:LevelFormula(self.Level + 1), "Arena.Small", 56, h - 55, Color(255, 255, 255, 150))

                --draw.SimpleText(am, "Arena.Small", w / 2, 32, Color(255, 255, 255, 150))
            end
        elseif (self.Kind == "Taunt") then
            local data = asapArena.Taunts[LocalPlayer()._arenaEquipment[self.Kind]]
            draw.SimpleText(data.Name, "Arena.Medium", 8, 4, Color(255, 255, 255, 200))
            local tx, _ = draw.SimpleText("Level: ", "Arena.Small", 10, 48, Color(255, 255, 255, 50))
            draw.SimpleText(data.Level, "Arena.Small", 10 + tx, 48, color_white)
        end
    else
        draw.SimpleText("Empty", "Arena.Medium", w / 2 - 2, h / 2 - 2, Color(255, 255, 255, 5), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function SLOT:SetKind(kind)
    self.Color = colors[kind]
    self.Kind = kind
    self.IsLevel = self.Kind == "Primary" or self.Kind == "Secondary"

    if (not asapArena.Models) then
        include("arena/sh_models.lua")
    end

    if (not LocalPlayer()._arenaEquipment) then
        LocalPlayer()._arenaEquipment = {}
    end

    self.Model = vgui.Create("DModelPanel", self)
    self.Model:Dock(FILL)
    self.Model:DockMargin(2, 2, 2, 2)
    self.Model:SetMouseInputEnabled(false)

    if (kind == "PlayerModel") then
        local slot = tonumber(LocalPlayer()._arenaEquipment[self.Kind] or 1) or 1
        self.Model:SetModel((asapArena.Models[slot] or {}).Models[1] or LocalPlayer():GetModel())
    elseif (LocalPlayer()._arenaEquipment[self.Kind] and weapons.GetStored(LocalPlayer()._arenaEquipment[self.Kind])) then
        local wepModel = weapons.GetStored(LocalPlayer()._arenaEquipment[self.Kind]).ViewModel
        self.Model:SetModel(wepModel)
    end

    self.Model.LayoutEntity = function() end

    if IsValid(self.Model:GetEntity()) then
        self.Model:GetEntity():SetLocalAngles(Angle(0, 65, 0))
    end

    self.Model:SetCamPos(Vector(0, 60, 46))
    self.Model:SetLookAt(Vector(0, 0, 51))
    self.Model:SetFOV(40)

    if (self.IsLevel) then
        self:InvalidateParent(true)
        self:UpdateInfo()
    end

    if (kind == "PlayerModel") then
        self.Model:SetCamPos(Vector(0, 70, 35))
        self.Model:SetLookAt(Vector(0, 0, 40))
        self.Model:SetFOV(45)

        self.Model.PostDrawModel = function(s, ent)
            if (ent._disableWep) then return end

            if IsValid(ARENA_LOADOUT._weapon) then
                if (not ARENA_LOADOUT._weapon.IsBonemerged) then
                    if (ent.HandAtt) then
                        local wep = ARENA_LOADOUT._weapon
                        local pos, ang = ent:GetBonePosition(ent.HandAtt)

                        --ang:RotateAroundAxis(ang:Forward(), 180)
                        if (wep.Offset) then
                            pos = pos + ang:Up() * wep.Offset.Pos.Up + ang:Forward() * wep.Offset.Pos.Forward + ang:Right() * wep.Offset.Pos.Right
                            ang:RotateAroundAxis(ang:Up(), wep.Offset.Ang.Up)
                            ang:RotateAroundAxis(ang:Forward(), wep.Offset.Ang.Forward)
                            ang:RotateAroundAxis(ang:Right(), wep.Offset.Ang.Right)
                        end

                        wep:SetPos(pos)
                        wep:SetAngles(ang)
                    else
                        ent.HandAtt = ent:LookupBone("ValveBiped.Bip01_R_Hand")

                        if (not ent.HandAtt) then
                            ent._disableWep = true
                        end

                        return
                    end
                end

                ARENA_LOADOUT._weapon:DrawModel()
            end
        end
    end
end
local blacklist = {
    "hands","sleeve"
}

SLOT.BestPos = Vector(0, 0, 0)
SLOT.BestLook = Vector(0, 0, 0)
function SLOT:PrepareCamera()
    local ent = self.WeaponModel.Entity
    local minx, maxx = ent:GetRenderBounds()

    local size = maxx-minx
    local isTaller = (maxx - minx).z < (maxx - minx).x || (maxx - minx).z < (maxx - minx).y
    
    self.BestPos = Vector(size.x / 3,size.x * 1.5,-size.z / 4)
    self.BestLook = Vector(size.x / 3,0,-size.z / 4)
    --self.Model:SetCamPos(Vector(0,-40,20))
    self.WeaponModel:SetCamPos(self.BestPos)
    self.WeaponModel:SetLookAt(self.BestLook)
end

SLOT.Mods = {}
function SLOT:UpdateInfo(kind)
    self.ID = LocalPlayer()._arenaEquipment[self.Kind]
    if not self.ID then
        return
    end
    local wepData = weapons.GetStored(self.ID)
    self.Color = Color(200, 200, 200)
    self.Level = asapArena:GetWeaponLevel(LocalPlayer(), self.ID)

    if (not IsValid(self.WeaponModel) and wepData) then
        self.WeaponModel = vgui.Create("DModelPanel", self)
        self.WeaponModel:Dock(FILL)
        self.WeaponModel:SetMouseInputEnabled(false)
        self.WeaponModel:DockMargin(8, 8, 8, 8)
        self.WeaponModel:SetModel(wepData.ViewModel or "")
        self.WeaponModel:SetFOV(60)
        self.WeaponModel.LayoutEntity = function() end
        self.WeaponModel.PreDrawModel = function(s, ent)
            render.SuppressEngineLighting(true)
            ent:DrawModel()
            render.SuppressEngineLighting(false)
            if (self.LastData.VElements) then
                for k,v in pairs(self.LastData.VElements) do
                    if IsValid(v) then
                        v:DrawModel()
                    end
                end
            end
            return false
        end
    elseif (wepData) then
        self.WeaponModel:SetModel(wepData.ViewModel)
    end

    local ent = self.WeaponModel:GetEntity()
    for k,v in pairs(ent:GetMaterials() or {}) do
        for _,black in pairs(blacklist) do
            if (string.find(v, black, 1, true)) then
                ent:SetSubMaterial(k - 1, "null")
            end
        end
    end

    self.VElements = wepData.VElements
    self:PrepareCamera()
    self.Extra = Vector(0,0,0)
    self.WeaponModel:SetCamPos(self.BestPos + self.Extra)
    self.WeaponModel:SetLookAt(self.BestLook + self.Extra)

    if (!self.Mods.List) then
        self.Mods.List = {}
    end

    for k, v in pairs(self.Mods.List or {}) do
        v:Remove()
    end

    for k, v in pairs(self.LastData and self.LastData.VElements or {}) do
        if IsValid(v) then
            v:Remove()
        end
    end
    
    if (LocalPlayer()._arenaData.Attachments or {})[self.ID] then
        for k, v in SortedPairs(LocalPlayer()._arenaData.Attachments[self.ID].equipped, true) do
            local data = TFA.Attachments.Atts[v]
            timer.Simple(.1, function()
                --self:Setup(false)
                self:Setup(true, data)
            end)
        end
    end

    for k, v in SortedPairs(ranks) do
        if (self.Level >= k) then
            self.Color = v
        else
            break
        end
    end
end


SLOT.LastData = {}
function SLOT:Setup(equip, data)
    if (istable(data) && data.Preview) then
        if (equip) then
            data:Preview(self.WeaponModel.Entity)
        else
            data:OnExit(self.WeaponModel.Entity)
        end
    end

    --This is the nice and cool thing we all ask about, how does skins works
    if (data and string.StartWith(data.ID, "skin")) then
        --We get the goodamn weapon table for skins
        local skinTable = TFACW_SKINNED_WEAPONS[self.ID]
        if (!skinTable) then
            return
        end
        if (equip) then
            self.LastData.Coords = {}

            for k,v in pairs(skinTable.coordinates.viewmodel) do
                self.LastData.Coords[k] = self.WeaponModel.Entity:GetSubMaterial(k)
                --We substract 1 into submaterial and then we go into skin weapon folder, then we use the last 6 letters of the id to know the skin mat
                local change = true
                for _,black in pairs(blacklist) do
                    if (string.find(self.WeaponModel.Entity:GetMaterials()[k] or "", black, 1, true)) then
                        self.WeaponModel.Entity:SetSubMaterial(k - 1, "null")
                        change = false
                    end
                end
                if (change) then
                    self.WeaponModel.Entity:SetSubMaterial(k - 1, skinTable.skinDirectory .. v .. "/" .. string.sub(data.ID, 6))
                end
            end
        else
            for k,v in pairs(skinTable.coordinates.viewmodel) do
                --Revert it back faggot
                self.WeaponModel.Entity:SetSubMaterial(k - 1, self.LastData.Coords[k])
                for k,v in pairs(self.WeaponModel.Entity:GetMaterials()) do
                    for _,black in pairs(blacklist) do
                        if (string.find(v, black, 1, true)) then
                            self.WeaponModel.Entity:SetSubMaterial(k - 1, "null")
                        end
                    end
                end
            end
        end
        return
    end

    if (data and string.StartWith(data.ID, "trinket")) then
        if (!self.LastData.VElements) then
            self.LastData.VElements = {}
        end
        if (equip) then
            local wepInfo = weapons.GetStored(self.ID)
            local trinket = weapons.GetStored(self.ID).VElements["trinket"]
            local ent = ClientsideModel(data.WeaponTable.VElements.trinket.model)
            ent.Trinket = true
            table.insert(self.LastData.VElements, ent)
        
            local pos, ang = self:GetBoneOrientation(wepInfo.VElements, trinket, self.WeaponModel.Entity)

            ent:SetPos(pos + ang:Forward() * trinket.pos.x + ang:Right() * trinket.pos.y + ang:Up() * trinket.pos.z)
            ang:RotateAroundAxis(ang:Up(), trinket.angle.y)
            ang:RotateAroundAxis(ang:Right(), trinket.angle.p)
            ang:RotateAroundAxis(ang:Forward(), trinket.angle.r)
            ent:SetAngles(ang)
            local matrix = Matrix()
            matrix:Scale(trinket.size)
            ent:EnableMatrix("RenderMultiply", matrix)

        else
            self.WeaponModel:SetCamPos(self.BestPos + self.Extra)
            self.WeaponModel:SetLookAt(self.BestLook + self.Extra)

            for k,v in pairs(self.LastData.VElements) do
                if (v.Trinket) then
                    v:Remove()
                    table.remove(self.LastData.VElements, k)
                    break
                end
            end
        end
        
        return
    end

    if (equip) then
        if ((data.WeaponTable or {}).Bodygroups_V) then
            if (!self.LastData.Bodygroups) then
                self.LastData.Bodygroups = {}
            end
            for k,v in pairs(data.WeaponTable.Bodygroups_V) do
                self.LastData.Bodygroups[k] = self.Model.Entity:GetBodygroup(k)
                self.WeaponModel.Entity:SetBodygroup(k, v)
            end
        end

        if ((data.WeaponTable or {}).VElements) then
            local wepInfo = weapons.GetStored(self.ID)
            if (!self.LastData.VElements) then
                self.LastData.VElements = {}
            end
            for k,v in pairs(data.WeaponTable.VElements) do
                if (self.VElements[k] && self.VElements[k].type == "Model") then
                    local trinket = self.VElements[k]
                    local ent = ClientsideModel(trinket.model)

                    local pos, ang = self:GetBoneOrientation(wepInfo.VElements, trinket, self.WeaponModel.Entity)
                    ent:SetPos(pos + ang:Forward() * trinket.pos.x + ang:Right() * trinket.pos.y + ang:Up() * trinket.pos.z)
                    ang:RotateAroundAxis(ang:Up(), trinket.angle.y)
                    ang:RotateAroundAxis(ang:Right(), trinket.angle.p)
                    ang:RotateAroundAxis(ang:Forward(), trinket.angle.r)
                    ent:SetAngles(ang)
                    local matrix = Matrix()
                    matrix:Scale(trinket.size)
                    ent:EnableMatrix("RenderMultiply", matrix)

                    ent.ID = data.ID
                    table.insert(self.LastData.VElements, ent)
                end
            end
        end
    else
        if (self.LastData.Bodygroups) then
            for k,v in pairs(self.LastData.Bodygroups) do
                self.Model.Entity:SetBodygroup(k, v)
                table.RemoveByValue(self.LastData.Bodygroups, v)
            end
        end
        if (self.LastData.VElements) then
            for k,v in pairs(self.LastData.VElements) do
                if (v.ID == data.ID) then
                    v:Remove()
                    table.remove(self.LastData.VElements, k)
                end
            end
        end
    end
end

function SLOT:GetBoneOrientation(basetabl, tabl, ent, bone_override)
	local bone, pos, ang
	if not IsValid(ent) then return Vector(0, 0, 0), Angle(0, 0, 0) end

	if tabl.rel and tabl.rel ~= "" and not tabl.bonemerge then
		local v = basetabl[tabl.rel]
		if (not v) then return end
		local boneName = bone_override or tabl.bone
		if v.curmodel and ent ~= v.curmodel and (v.bonemerge or (boneName and boneName ~= "" and v.curmodel:LookupBone(boneName))) then
			v.curmodel:SetupBones()
			pos, ang = self:GetBoneOrientation(basetabl, v, v.curmodel, boneName)
			if pos and ang then return pos, ang end
		else
			--As clavus states in his original code, don't make your elements named the same as a bone, because recursion.
			pos, ang = self:GetBoneOrientation(basetabl, v, ent)
			if pos and ang then
				pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
				ang:RotateAroundAxis(ang:Up(), v.angle.y)
				ang:RotateAroundAxis(ang:Right(), v.angle.p)
				ang:RotateAroundAxis(ang:Forward(), v.angle.r)
				-- For mirrored viewmodels.  You might think to scale negatively on X, but this isn't the case.

				return pos, ang
			end
		end
	end

	if isnumber(bone_override) then
		bone = bone_override
	else
		bone = ent:LookupBone(bone_override or tabl.bone) or 0
	end

	if (not bone) or (bone == -1) then return end
	pos, ang = Vector(0, 0, 0), Angle(0, 0, 0)
	local m = ent:GetBoneMatrix(bone)
	if (m) then
		pos, ang = m:GetTranslation(), m:GetAngles()
        return pos, ang
	end
	return pos, ang
end

local cog = Material("icon16/bullet_wrench.png")
function SLOT:DoClick()
    if (IsValid(wpn_pnl)) then
        wpn_pnl:Remove()
    end

    local x, y = self:LocalToScreen(0, 0)
    wpn_pnl = vgui.Create("XeninUI.Frame")
    wpn_pnl:SetTitle(self.Kind)
    wpn_pnl.Scroll = vgui.Create("XeninUI.ScrollPanel", wpn_pnl)
    wpn_pnl.Scroll:Dock(FILL)
    local i = 0
    local tall = 36
    local dataTable = asapArena.Weapons
    local isTaunt = false
    local isModel = false

    if (self.Kind == "Taunt") then
        dataTable = asapArena.Taunts
        isTaunt = true
    elseif (self.Kind == "PlayerModel") then
        dataTable = asapArena.Models
        isModel = true
    end

    local isStuck = false

    for k, v in SortedPairsByMemberValue(dataTable, "Level") do
        local shouldHide = true
        if (self.Kind == "Secondary" and LocalPlayer()._arenaPrimary) then
            shouldHide = v.Slot != "Primary"
        elseif (self.Kind == "Primary" and LocalPlayer()._arenaSecondary) then
            shouldHide = v.Slot != "Secondary"
        else
            shouldHide = v.Slot != self.Kind
        end
        if ((not isTaunt and not isModel) and shouldHide) then continue end
        local wep = vgui.Create("DButton", wpn_pnl.Scroll)
        wep:Dock(TOP)
        wep:DockMargin(4, 2, 4, 6)
        wep:SetText("")
        wep.Hover = 0
        wep.ID = k

        if (isStuck) then
            wep.CanSelect = false
            wep:SetTall(28)
        end

        if (not isStuck and v.Challenge) then
            wep.CanSelect, wep.ourData, wep.challenge = asapArena:CanEquipWeapon(LocalPlayer(), k)

            if (not wep.CanSelect and not isStuck) then
                isStuck = wep
                wep:SetTall(86)
                local wepData = weapons.GetStored(v.Challenge.Class)
                wep:SetTooltip("Unlock by using " .. wepData.PrintName)
            elseif (wep.CanSelect) then
                wep:SetTall(86)
            end
        elseif (not isStuck) then
            wep.CanSelect = LocalPlayer():GetArenaLevel() >= v.Level
            wep:SetTall(48)
        end

        wep.Paint = function(s, w, h)
            surface.SetDrawColor(255, 255, 255, 50)
            surface.DrawOutlinedRect(0, 0, w, h)
            s.Hover = Lerp(FrameTime() * 5, s.Hover, s:IsHovered() and 100 or 0)
            surface.SetTexture(deg)
            surface.SetDrawColor(255, 192, 0, s.Hover)
            surface.DrawTexturedRect(1, 1, w - 2, h - 2)
            draw.SimpleText(v.Name, "Arena.Small", 4, 4, Color(255, 255, 255, s.CanSelect and 200 or 20))

            if (v.Challenge and s.ourData) then
                local data = s.ourData
                local chall = s.challenge
                local tx, _ = draw.SimpleText("Kills: ", "Arena.Small", 4, 24, Color(255, 255, 255, 50))
                draw.SimpleText(math.min(data[1] or 0, chall.Kills or 1) .. "/" .. (chall.Kills or 1), "Arena.Small", 4 + tx, 24, (data[1] >= chall.Kills) and color_white or Color(255, 100, 0, 200))
                local tx, _ = draw.SimpleText("Headshots: ", "Arena.Small", 4, 24 + 18, Color(255, 255, 255, 50))
                draw.SimpleText(math.min(data[2] or 0, chall.Headshots) .. "/" .. chall.Headshots, "Arena.Small", 4 + tx, 24 + 18, (data[2] >= chall.Headshots) and color_white or Color(255, 100, 0, 200))
                local tx, _ = draw.SimpleText("Damage: ", "Arena.Small", 4, 24 + 36, Color(255, 255, 255, 50))
                draw.SimpleText(math.min(math.Round(data[3]) or 0, chall.Damage) .. "/" .. chall.Damage, "Arena.Small", 4 + tx, 24 + 36, (data[3] >= chall.Damage) and color_white or Color(255, 100, 0, 200))
            elseif (v.Level ~= 0) then
                local tx, _ = draw.SimpleText("Level: ", "Arena.Small", 4, 24, Color(255, 255, 255, 50))
                draw.SimpleText(v.Level, "Arena.Small", 4 + tx, 24, s.CanSelect and color_white or Color(255, 100, 0, 200))
            else
                draw.SimpleText("Starter weapon", "Arena.Small", 4, 24, Color(255, 255, 255, 50))
            end
        end
        wep.DoClick = function()
            local CanSelect = (not v.Challenge and v.Level <= LocalPlayer():GetArenaLevel())

            if (not CanSelect) then
                local valid, _, _ = asapArena:CanEquipWeapon(LocalPlayer(), k)
                CanSelect = valid
            end

            if (CanSelect) then
                if (not isTaunt and not isModel) then
                    ARENA_LOADOUT:SetWeapon(k, v)
                elseif (isTaunt) then
                    ARENA_LOADOUT.Player.Model:GetEntity():SetSequence("idle_passive")
                elseif (isModel) then
                    ARENA_LOADOUT.Player.Model:SetModel(v.Models[1])

                    timer.Simple(0, function()
                        if not IsValid(self) or not v.Models then return end
                        self.Model:SetModel(v.Models[1])
                        self.Model:GetEntity():SetLocalAngles(Angle(0, 65, 0))

                        if (self.Kind == "PlayerModel") then
                            self.Model:SetFOV(45)
                            self.Model:SetCamPos(Vector(0, 70, 35))
                            self.Model:SetLookAt(Vector(0, 0, 40))
                        else
                            self.Model:SetFOV(40)
                            self.Model:SetCamPos(Vector(0, 60, 46))
                            self.Model:SetLookAt(Vector(0, 0, 51))
                        end
                    end)
                end

                net.Start(isTaunt and "ASAP.Arena.EquipTaunt" or (isModel and "ASAP.Arena.EquipModel" or "ASAP.Arena.EquipWeapon"))
                net.WriteString(self.Kind)
                net.WriteString(k)
                net.SendToServer()

                if (not LocalPlayer()._arenaEquipment) then
                    LocalPlayer()._arenaEquipment = {}
                end

                LocalPlayer()._arenaEquipment[self.Kind] = k

                if (self.IsLevel) then
                    self:UpdateInfo()
                end
                ARENA_LOADOUT.ShouldSave = true
                wpn_pnl:Remove()
            end
        end

        wep.OnCursorEntered = function(s)
            if (isTaunt) then
                ARENA_LOADOUT.Player.Model:GetEntity():SetSequence(v.Anim)
            elseif (not isModel) then
                ARENA_LOADOUT:SetWeapon(k, v)
            else
                ARENA_LOADOUT.Player.Model:SetModel(v.Models[1])

                if IsValid(ARENA_LOADOUT._weapon) then
                    ARENA_LOADOUT._weapon:Remove()
                end
            end
            if IsValid(s.Config) then
                s.Config:SetVisible(true)
            end
        end

        wep.OnCursorExited = function(s)
            if (isTaunt) then
                ARENA_LOADOUT.Player.Model:GetEntity():SetSequence("idle_all_01")

                return
            elseif (isModel) then
                local oldmodel = tonumber(LocalPlayer()._arenaEquipment["PlayerModel"]) or 1

                if (ARENA_LOADOUT.Player) then
                    if (not asapArena.Models) then
                        include("arena/sh_models.lua")
                    end

                    ARENA_LOADOUT.Player.Model:SetModel((asapArena.Models[oldmodel] or {}).Models[1] or "models/player/alyx.mdl")
                end

                return
            end

            if (LocalPlayer()._arenaEquipment[self.Kind]) then
                ARENA_LOADOUT:SetWeapon(LocalPlayer()._arenaEquipment[self.Kind], asapArena.Weapons[LocalPlayer()._arenaEquipment[self.Kind]])
            end
        end

        lastClass = k
        i = i + 1
        tall = tall + wep:GetTall() + 8
    end

    wpn_pnl:SetPos(x + self:GetWide() + 4, y)
    wpn_pnl:SetSize(272, 32)
    wpn_pnl:SizeTo(272, math.min(ScrH() - y - 8, tall), .1, 0, -1)

    wpn_pnl.OnFocusChanged = function(s, b)
        if (not b) then
            s:Remove()
        end
    end

    wpn_pnl:MakePopup()
end

vgui.Register("asap.Arena.Slot", SLOT, "DButton")

if (IsValid(ARENA_LOADOUT)) then
    ARENA_LOADOUT:Remove()
end
