local deg = surface.GetTextureID("vgui/gradient-l")
local WEP = {}
WEP.Extra = Vector(0, 0, 0)

function WEP:Init()
    self:Dock(FILL)
    self.Model = vgui.Create("DModelPanel", self)
    self.Model:Dock(FILL)
    self.Model:SetModel("models/weapons/w_pist_elite_dropped.mdl")
    self.Model:SetFOV(40)
    self.Model:SetDirectionalLight(BOX_TOP, Color(255, 255, 255))
    self.Model:SetDirectionalLight(BOX_FRONT, color_white)
    self.Model:SetDirectionalLight(BOX_BACK, Color(0, 125, 255))
    self.Model:SetAmbientLight(Color(255, 255, 255))
    self.Model.LayoutEntity = function() end

    self.Model.PreDrawModel = function(s, ent)
        self:DrawHalo(ent, false)
    end

    self.Model.PostDrawModel = function(s, ent)
        if self.LastData.VElements then
            for k, v in pairs(self.LastData.VElements) do
                if IsValid(v) then
                    v:DrawModel()
                end
            end
        end
    end

    self.Model.OPaint = self.Model.Paint

    self.Model.Paint = function(s, w, h)
        if self.Class then
            s:OPaint(w, h)
        end

        self:DrawData(w, h)
    end

    self:PrepareCamera()
    self.Model:SetCamPos(Vector(0, 0, 60))
    self.Model:SetLookAt(Vector(0, 0, 0))

    if LocalPlayer():IsAdmin() and GetConVar("developer"):GetInt() >= 2 then
        self:CreateDev()
    end
    --self.Guides:SetPos(self:GetWide() - self.Guides:GetWide() - 32, 32)
end

function WEP:CreateSlider(axis)
    local slider = self.Guides:AddControl("slider", {
        label = axis .. " Pos",
        min = -64,
        max = 64,
        type = "float"
    })

    slider:SetDark(false)

    slider.OnValueChanged = function(s, old)
        if not self.modify then
            self.Extra[axis] = math.Round(old, 2)

            if self.IsGloves then
                self.Model:SetCamPos(self.Extra)
                --self.Model:SetLookAt(self.Extra)
            else
                self.Model:SetCamPos(self.BestPos + self.Extra)
                self.Model:SetLookAt(self.BestLook + self.Extra)
            end
        end
    end

    slider:GetTextArea():SetTextColor(color_white)

    return slider
end

function WEP:CreateDev()
    self:InvalidateLayout(true)
    self.Guides = vgui.Create("ControlPanel", self.Model)
    self.Guides:SetLabel("Weapon fixes")

    self.Guides.Paint = function(s, w, h)
        surface.SetDrawColor(36, 36, 36, 128)
        draw.RoundedBoxEx(8, 0, 0, w, 24, Color(36, 36, 36, 128), true, true, false, false)
        draw.RoundedBoxEx(8, 0, 24, w, h - 24, Color(26, 26, 26, 128), false, false, true, true)
    end

    self.Guides:SetMouseInputEnabled(true)
    self.Guides:Dock(RIGHT)
    self.Guides:SetWide(300)
    self.Guides:DockMargin(16, 16, 16, 16)
    self.sx = self:CreateSlider("x")
    self.sy = self:CreateSlider("y")
    self.sz = self:CreateSlider("z")

    self.Guides:AddControl("button", {
        label = "Copy to clipboard",
    }).DoClick = function()
        SetClipboardText(self.Class .. " = Vector(" .. math.Round(self.Extra.x, 2) .. "," .. math.Round(self.Extra.y, 2) .. "," .. math.Round(self.Extra.z, 2) .. "),\n\t")
    end
end

local mat_Copy = Material("pp/copy")
local mat_Add = Material("pp/add")
local mat_Sub = Material("pp/sub")
local rt_Store = render.GetScreenEffectTexture(0)
local rt_Blur = render.GetScreenEffectTexture(1)

function WEP:DrawHalo(ent, isadd)
    local x, y = self:LocalToScreen(0, 0)
    local w, h = self:GetSize()
    local rt_Scene = render.GetRenderTarget()
    -- Store a copy of the original scene
    render.CopyRenderTargetToTexture(rt_Store)
    render.ClearStencil()

    -- Clear our scene so that additive/subtractive rendering with it will work later
    if not isadd then
        render.Clear(255, 255, 255, 255, false, true)
    else
        render.Clear(0, 0, 0, 255, false, true)
    end

    render.SetStencilEnable(true)
    render.SetStencilWriteMask(1)
    render.SetStencilTestMask(1)
    render.SetStencilReferenceValue(1)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)
    ent:DrawModel()
    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.SetStencilPassOperation(STENCIL_KEEP)
    -- render.SetStencilFailOperation( STENCIL_KEEP )
    -- render.SetStencilZFailOperation( STENCIL_KEEP )
    cam.Start2D()
    surface.SetDrawColor(isadd and Color(150, 255, 50) or color_black)
    surface.DrawRect(0, 0, ScrW(), ScrH())
    cam.End2D()
    render.SetStencilEnable(false)
    -- Store a blurred version of the colored props in an RT
    render.CopyRenderTargetToTexture(rt_Blur)
    render.BlurRenderTarget(rt_Blur, 2, 2, 1)
    -- Restore the original scene
    render.SetRenderTarget(rt_Scene)
    mat_Copy:SetTexture("$basetexture", rt_Store)
    render.SetMaterial(mat_Copy)
    render.DrawScreenQuad()
    -- Draw back our blured colored props additively/subtractively, ignoring the high bits
    render.SetStencilEnable(true)
    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.ClearStencilBufferRectangle(x, y, x + w, y + h, 1)
    render.SetStencilCompareFunction(STENCIL_EQUAL)

    if not isadd then
        mat_Sub:SetTexture("$basetexture", rt_Blur)
        render.SetMaterial(mat_Sub)
    else
        mat_Add:SetTexture("$basetexture", rt_Blur)
        render.SetMaterial(mat_Add)
    end

    for i = 0, 2 do
        render.DrawScreenQuad()
    end

    render.SetStencilEnable(false)
end

function WEP:PrepareCamera(world)
    local ent = self.Model.Entity
    local minx, maxx = ent:GetRenderBounds()
    local size = maxx - minx
    local isTaller = (maxx - minx).z < (maxx - minx).x or (maxx - minx).z < (maxx - minx).y

    if not world then
        self.BestPos = Vector(size.x / 3, size.x * 1.5, -size.z / 4)
        self.BestLook = Vector(size.x / 3, 0, -size.z / 4)
    else
        self.BestPos = Vector(-size.x / 4, size.x * 1.5, size.z / 4)
        self.BestLook = Vector(-size.x / 4, 0, size.z / 4)
    end

    --self.Model:SetCamPos(Vector(0,-40,20))
    self.Model:SetCamPos(self.BestPos)
    self.Model:SetLookAt(self.BestLook)
end

local blacklist = {"hands", "sleeve"}

function WEP:SetClass(tbl, isgloves)
    for k, v in pairs(self.LastData.VElements or {}) do
        v:Remove()
    end

    self.IsGloves = isgloves

    if not isgloves then
        local exists = true --file.Exists(tbl.ViewModel, "GAME")
        local validModel = exists and tbl.ViewModel or tbl.WorldModel
        self.Model:SetModel(validModel)
        local ent = self.Model.Entity

        for k, v in pairs(ent:GetMaterials()) do
            for _, black in pairs(blacklist) do
                if string.find(v, black, 1, true) then
                    ent:SetSubMaterial(k - 1, "null")
                end
            end
        end

        self.VElements = tbl.VElements
        self:PrepareCamera(not exists)
        self.Extra = Vector(0, 0, 0)
        self.modify = true

        if LocalPlayer():IsAdmin() and self.Guides then
            self.sx:SetValue(self.Extra.x)
            self.sy:SetValue(self.Extra.y)
            self.sz:SetValue(self.Extra.z)
        end

        self.modify = false
        self.Model:SetCamPos(self.BestPos + self.Extra)
        self.Model:SetLookAt(self.BestLook + self.Extra)

        if not self.Mods.List then
            self.Mods.List = {}
        end

        for k, v in pairs(self.Mods.List or {}) do
            v:Remove()
        end

        local cleanCopy = {}

        for id, atts in pairs(tbl.Attachments) do
            cleanCopy[id] = table.Copy(atts)
        end

        table.sort(cleanCopy[1] or {}, function(a, b) return asapArena.Attachments[a].weplevel or 1 > asapArena.Attachments[b].weplevel or 1 end)

        for k, v in SortedPairsByMemberValue(cleanCopy, "weplevel") do
            local modSlot = vgui.Create("ASAP.WepCustom.Slot", self.Mods)
            modSlot:SetData(v)
            modSlot.Controller = self
            modSlot.Slot = k
            modSlot.IsGloves = isgloves

            if LocalPlayer()._arenaData.Weapons and LocalPlayer()._arenaData.Weapons[self.Class] and LocalPlayer()._arenaData.Weapons[self.Class].equipped and LocalPlayer()._arenaData.Weapons[self.Class].equipped[k] then
                local data = TFA.Attachments.Atts[LocalPlayer()._arenaData.Weapons[self.Class].equipped[k]]

                timer.Simple(0, function()
                    self:Setup(true, data, true)
                end)

                modSlot.Equipped = data
            end

            table.insert(self.Mods.List, modSlot)
        end
    else
        self:PrepareGloves(tbl)
    end
end

local styles = {
    camo = {"Forest DDPAT", 0},
    fade = {"Fade", 1},
    webs = {"Crimsom Web", 2},
    foundation = {"Foundation", 3},
    kimono = {"Kimono", 4}
}

function WEP:BuildStyles()
    local output = {}

    for k, v in pairs(styles) do
        local data = {
            Name = v[1],
            Icon = "asapf4/weapon_customs/gloves/" .. k .. ".png",
            Preview = function(s, ent)
                self.LastSkin = ent:GetSkin()
                ent:SetSkin(v[2])
            end,
            OnExit = function(s, ent)
                ent:SetSkin(self.LastSkin)
            end,
            ID = "specialist." .. k,
            Slot = 1
        }

        table.insert(output, data)
    end

    return output
end

local colors = {
    {"Lavander", Color(122, 94, 211), Vector(.5, .3, .8)},
    {"Fire Red", Color(255, 0, 0), Vector(1.5, .2, 0)},
    {"Acqua Blue", Color(56, 150, 250), Vector(.2, .6, 1)},
    {"Poison Green", Color(132, 250, 56), Vector(.5, 1, .2)},
    {"Flash Yellow", Color(250, 231, 56), Vector(1, .9, .2)},
    {"Pink Demon", Color(255, 100, 200), Vector(1, .4, .8)},
    {"Smoke Curtain", Color(230, 230, 230), Vector(.85, .85, .85)},
    {"Dark Shadow", Color(58, 58, 58), Vector(.15, .15, .15)},
}

function WEP:BuildColors()
    local output = {}

    for k, v in pairs(colors) do
        local data = {
            Name = v[1],
            Draw = function(s, w, h)
                surface.SetMaterial(Material("sgm/playercircle"))
                surface.SetDrawColor(v[2])
                surface.DrawTexturedRect(0, 0, w, h)
            end,
            Preview = function(s, ent)
                if ent.GetPlayerColor then
                    self.LastColor = ent:GetPlayerColor()
                end

                ent.GetPlayerColor = function() return v[3] / 2 end
            end,
            OnExit = function(s, ent)
                ent.lastColor = self.LastColor
                ent.GetPlayerColor = function(s) return s.lastColor end
            end,
            ID = "specialist." .. string.lower(string.Replace(v[1], " ", "")),
            Slot = 2
        }

        table.insert(output, data)
    end

    return output
end

function WEP:PrepareGloves(class)
    self.Model:SetModel("models/weapons/gonzo_asap/v_" .. class .. ".mdl")
    self.Model:SetCamPos(Vector(10, 50, -74))
    self.Model:SetLookAt(Vector(1, 25, -87))

    if not self.Mods.List then
        self.Mods.List = {}
    end

    for k, v in pairs(self.Mods.List or {}) do
        v:Remove()
    end

    local modSlot = vgui.Create("ASAP.WepCustom.Slot", self.Mods)

    modSlot:SetData({
        header = "Design",
        atts = self:BuildStyles()
    })

    modSlot.Slot = 1
    modSlot.Controller = self
    modSlot.IsGloves = true
    table.insert(self.Mods.List, modSlot)
    local modSlot = vgui.Create("ASAP.WepCustom.Slot", self.Mods)

    modSlot:SetData({
        header = "Colors",
        atts = self:BuildColors()
    })

    modSlot.Slot = 2
    modSlot.Controller = self
    modSlot.IsGloves = true
    table.insert(self.Mods.List, modSlot)
end

function WEP:Paint(w, h)
end

function WEP:GetBoneOrientation(basetabl, tabl, ent, bone_override)
    local bone, pos, ang
    if not IsValid(ent) then return Vector(0, 0, 0), Angle(0, 0, 0) end

    if tabl.rel and tabl.rel ~= "" and not tabl.bonemerge then
        local v = basetabl[tabl.rel]
        if not v then return end
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

    if m then
        pos, ang = m:GetTranslation(), m:GetAngles()

        return pos, ang
    end

    return pos, ang
end

WEP.LastData = {}

function WEP:Setup(equip, data, ispreview)
    if istable(data) and data.Preview then
        if equip then
            data:Preview(self.Model.Entity)
        else
            data:OnExit(self.Model.Entity)
        end
    end

    --This is the nice and cool thing we all ask about, how does skins works
    if data and string.StartWith(data.ID, "skin") then
        --We get the goodamn weapon table for skins
        local skinTable = TFACW_SKINNED_WEAPONS[self.Class]
        if not skinTable then return end

        if equip then
            self.LastData.Coords = {}

            for k, v in pairs(skinTable.coordinates.viewmodel) do
                self.LastData.Coords[k] = self.Model.Entity:GetSubMaterial(k)
                --We substract 1 into submaterial and then we go into skin weapon folder, then we use the last 6 letters of the id to know the skin mat
                local change = true

                for _, black in pairs(blacklist) do
                    if string.find(self.Model.Entity:GetMaterials()[k] or "", black, 1, true) then
                        self.Model.Entity:SetSubMaterial(k - 1, "null")
                        change = false
                    end
                end

                if change then
                    self.Model.Entity:SetSubMaterial(k - 1, skinTable.skinDirectory .. v .. "/" .. string.sub(data.ID, 6))
                end
            end
        else
            for k, v in pairs(skinTable.coordinates.viewmodel) do
                --Revert it back faggot
                if self.LastData.Coords then
                    self.Model.Entity:SetSubMaterial(k - 1, self.LastData.Coords[k])
                end

                for k, v in pairs(self.Model.Entity:GetMaterials()) do
                    for _, black in pairs(blacklist) do
                        if string.find(v, black, 1, true) then
                            self.Model.Entity:SetSubMaterial(k - 1, "null")
                        end
                    end
                end
            end
        end

        return
    end

    if data and string.StartWith(data.ID, "trinket") then
        if not self.LastData.VElements then
            self.LastData.VElements = {}
        end

        if equip then
            local wepInfo = weapons.GetStored(self.Class)
            local trinket = weapons.GetStored(self.Class).VElements["trinket"]
            local ent = ClientsideModel(data.WeaponTable.VElements.trinket.model)
            ent.Trinket = true
            table.insert(self.LastData.VElements, ent)
            local pos, ang = self:GetBoneOrientation(wepInfo.VElements, trinket, self.Model.Entity)
            ent:SetPos(pos + ang:Forward() * trinket.pos.x + ang:Right() * trinket.pos.y + ang:Up() * trinket.pos.z)
            ang:RotateAroundAxis(ang:Up(), trinket.angle.y)
            ang:RotateAroundAxis(ang:Right(), trinket.angle.p)
            ang:RotateAroundAxis(ang:Forward(), trinket.angle.r)
            ent:SetAngles(ang)
            local matrix = Matrix()
            matrix:Scale(trinket.size)
            ent:EnableMatrix("RenderMultiply", matrix)

            if not ispreview then
                self.Model:SetLookAt(pos + Vector(0, 0, 0))
                self.Model:SetCamPos(pos + Vector(-20, 20, -self.BestPos.z))
            end
        else
            self.Model:SetCamPos(self.BestPos + self.Extra)
            self.Model:SetLookAt(self.BestLook + self.Extra)

            for k, v in pairs(self.LastData.VElements) do
                if v.Trinket then
                    v:Remove()
                    table.remove(self.LastData.VElements, k)
                    break
                end
            end
        end

        return
    end

    if data and equip then
        if (data.WeaponTable or {}).Bodygroups_V then
            if not self.LastData.Bodygroups then
                self.LastData.Bodygroups = {}
            end

            for k, v in pairs(data.WeaponTable.Bodygroups_V) do
                self.LastData.Bodygroups[k] = self.Model.Entity:GetBodygroup(k)
                self.Model.Entity:SetBodygroup(k, v)
            end
        end

        if (data.WeaponTable or {}).VElements then
            if not self.LastData.VElements then
                self.LastData.VElements = {}
            end

            for k, v in pairs(data.WeaponTable.VElements) do
                if self.VElements[k] and self.VElements[k].type == "Model" then
                    local wepInfo = weapons.GetStored(self.Class)
                    local trinket = self.VElements[k]
                    local ent = ClientsideModel(trinket.model)
                    local pos, ang = self:GetBoneOrientation(wepInfo.VElements, trinket, self.Model.Entity)
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
        if self.LastData.Bodygroups then
            for k, v in pairs(self.LastData.Bodygroups) do
                self.Model.Entity:SetBodygroup(k, v)
                table.RemoveByValue(self.LastData.Bodygroups, v)
            end
        end

        if data and self.LastData.VElements then
            for k, v in pairs(self.LastData.VElements) do
                if v.ID == data.ID then
                    v:Remove()
                    table.remove(self.LastData.VElements, k)
                end
            end
        end
    end
end

local function kmtofeet(km)
    return km * 3280.84
end

local function feettokm(feet)
    return feet / 3280.84
end

local function feettosource(feet)
    return feet * 16
end

local function sourcetofeet(u)
    return u / 16
end

local function metersToUnits(x)
    return x * 39.3701 * 4 / 3
end

local ammoRangeTable = {
    ["SniperPenetratedRound"] = 2,
    ["SniperPenetratedBullet"] = 2,
    ["buckshot"] = 0.5,
    ["ar2"] = 1,
    ["smg1"] = 0.7,
    ["pistol"] = 0.33,
    ["def"] = 1
}

local function ammoRangeMultiplier(data)
    if data.ammoRangeTable then
        return data.AmmoRangeTable[data.Primary.Ammo or "def"] or data.AmmoRangeTable["def"] or 1
    else
        return ammoRangeTable[data.Primary.Ammo or "def"] or 1
    end
end

local bestrange = feettosource(kmtofeet(1))
local worstaccuracy = 0.045
local bestrpm = 1200
local worstmove = 0.8
local bestdamage = 100
local worstrecoil = 1

local stats = {
    Accuracy = function(cls) end,
    Firerate = function(cls) end,
    Mobility = function(cls) end,
    Damage = function(cls)
        local damage = data.Primary.Damage
        local numShots = self:GetStat("Primary.NumShots") * 0.75
        local dmgstr = "Damage: " .. math.Round(damage)

        return (damage * math.Round(numShots)) / bestdamage, dmgstr
    end,
    Range = function(data)
        local range = data.Primary.Range

        if not range then
            local damage = data.Primary.Damage
            range = math.sqrt(damage / 32) * metersToUnits(350) * ammoRangeMultiplier(data)
        end

        return range / bestrange, "Range: " .. math.Round(feettokm(sourcetofeet(range)) * 100) / 100 .. "K"
    end
}

function WEP:DrawData(w, h)
    if not self.Class then return end
end

vgui.Register("ASAP.Arena.WeaponController", WEP, "DPanel")