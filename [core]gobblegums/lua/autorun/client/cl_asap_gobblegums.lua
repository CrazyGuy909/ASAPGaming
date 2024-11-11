ASAP_GOBBLEGUMS = ASAP_GOBBLEGUMS or {}
ASAP_GOBBLEGUMS.gumballs = ASAP_GOBBLEGUMS.gumballs or {}
ASAP_GOBBLEGUMS.cooldowns = ASAP_GOBBLEGUMS.cooldowns or {}
ASAP_GOBBLEGUMS.slots = ASAP_GOBBLEGUMS.slots or {}
ASAP_GOBBLEGUMS.gobblegumsslotcount = ASAP_GOBBLEGUMS.gobblegumsslotcount or 2
ASAP_GOBBLEGUMS.gobblegumcredits = ASAP_GOBBLEGUMS.gobblegumcredits or 0
ASAP_GOBBLEGUMS.gobblegumabilities = ASAP_GOBBLEGUMS.gobblegumabilities or {}
ASAP_GOBBLEGUMS.xp = ASAP_GOBBLEGUMS.xp or 0
ASAP_GOBBLEGUMS.level = ASAP_GOBBLEGUMS.level or 1
ASAP_GOBBLEGUMS.xpToNextLevel = ASAP_GOBBLEGUMS.xpToNextLevel or 100
ASAP_GOBBLEGUMS.spentOnSlots = ASAP_GOBBLEGUMS.spentOnSlots or 0

surface.CreateFont("GOBBLEGUMS:Buttons", {
    font = "Roboto",
    extended = false,
    size = 20,
    weight = 200,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
})

surface.CreateFont("GOBBLEGUMS:Buttons2", {
    font = "Roboto Lt",
    extended = false,
    size = 16,
    weight = 200,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
})

surface.CreateFont("GOBBLEGUMS:Buttons3", {
    font = "Roboto Lt",
    extended = false,
    size = 16,
    weight = 200,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
})

surface.CreateFont("GOBBLEGUMS:Buttons4", {
    font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 20,
    weight = 0,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
})

surface.CreateFont("GOBBLEGUMS:Buttons5", {
    font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 24,
    weight = 200,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
})

surface.CreateFont("GOBBLEGUMS:Buttons6", {
    font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 16,
    weight = 0,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
})

surface.CreateFont("GOBBLEGUMS:Buttons7", {
    font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 28,
    weight = 0,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
})

surface.CreateFont("GOBBLEGUMS:Buttons8", {
    font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 18,
    weight = 700,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
})

surface.CreateFont("GOBBLEGUMS:Buttons9", {
    font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = 17,
    weight = 300,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
})

surface.CreateFont("GOBBLEGUMS:Buttons10", {
    font = "Roboto",
    extended = false,
    size = 70,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
})

surface.CreateFont("GOBBLEGUMS:Buttons11", {
    font = "Roboto",
    extended = false,
    size = 100,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false
})

local MATERIAL_TROPHY = Material("asap_gumballs/trophy.png", "noclamp smooth")
local MATERIAL_CLOSE = Material("asap_gumballs/close.png", "noclamp smooth")
local MATERIAL_LOGO = Material("asap_gumballs/logo1.png", "noclamp smooth")
local MATERIAL_WEAPONS = Material("asap_gumballs/weapons.png", "noclamp smooth")
local MATERIAL_GUM = Material("asap_gumballs/gum.png", "noclamp smooth")
local MATERIAL_ABILITIES = Material("asap_gumballs/abilities.png", "noclamp smooth")
local MATERIAL_SLOTS = Material("asap_gumballs/slots.png", "noclamp smooth")
local MATERIAL_UNKNOWN = Material("asap_gumballs/balls/questionmark.png", "smooth")
--[[-------------------------------------------------------------------------
UI/Scene management
---------------------------------------------------------------------------]]
local Scenes = {}
--Stores all the registered scenes
Scenes.Scenes = {}
--Stores the name of the current scene
Scenes.CurrentScene = "_"

--Registers a scene
function Scenes:RegisterScene(name, scene)
    scene.name = name

    if Scenes.Scenes[scene] ~= nil then
        Error("Scene already has the same name! ('" .. scene.name .. "')")

        return false
    end

    Scenes.Scenes[scene.name] = scene
    --print("Registered Scene '"..scene.name.."'")
end

function Scenes:LoadScenes()
    local files, directories = file.Find("asap_gobblegums_scenes/*", "LUA")

    for k, v in pairs(files) do
        include("asap_gobblegums_scenes/" .. v)
    end
end

ASAP_GOBBLEGUMS.Scenes = Scenes
--Is the menu open?
local isMenuOpen = false

--Creates the menu and opens it
local function OpenMenu(f4)

    if not f4 then
        local disallowOpening = hook.Run("CanOpenGobblegums")
        if (disallowOpening == false) then return end
        if not isMenuOpen then
            isMenuOpen = true
        else
            return
        end
    end

    local f = vgui.Create(f4 and "DPanel" or "DFrame")
    if not f4 then
        f:SetSize(1048, 600)
        f:SetTitle("")
        f:Center()
        f:ShowCloseButton(false)
    else
        f:SetParent(f4)
        f:Dock(FILL)
    end

    f.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(16, 16, 16, 255))
    end

    f.Close = function(s)
        isMenuOpen = false
        s:Remove()
    end

    --[[-------------------------------------------------------------------------
Nav Bar
---------------------------------------------------------------------------]]
    local navBar = vgui.Create("DPanel", f)
    navBar:Dock(TOP)
    navBar:DockMargin(5, 5, 5, 5)
    navBar:SetTall(32)
    navBar.buttons = {}
    navBar.buttonPos = 5

    navBar.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(16, 16, 16, 255))
    end

    navBar.PerformLayout = function(s, w, h)
        local wide = (w / 4) - 4
        for k, v in pairs(s:GetChildren()) do
            v:SetWide(wide, h)
            v:SetPos((k - 1) * (wide + 5), 0)
        end
    end

    --Navbar close button
    if not f4 then
        local cls = vgui.Create("DButton", navBar)
        cls:SetSize(30, 30)
        cls:SetPos(navBar:GetWide() - 35, 5)

        cls.DoClick = function(s)
            f:Close()
        end

        cls:SetText("")

        cls.Paint = function(s, w, h)
            surface.SetDrawColor(Color(255, 255, 255))
            surface.SetMaterial(MATERIAL_CLOSE)
            surface.DrawTexturedRect(0, 0, w, h)
        end
    end

    local butts = {}

    --Use this to add buttons to the nav bar
    function navBar:AddButton(text, icon, onClick)
        local b = vgui.Create("DButton", navBar)
        b:SetText("")
        b:SetTall(32)
        b.selected = false
        b.DoClick = onClick

        b.Paint = function(s, w, h)
            if s.selected then
                draw.RoundedBox(8, 0, 0, w, h, Color(255, 136, 0, 255))
            else
                draw.RoundedBox(8, 0, 0, w, h, Color(36, 36, 36, 255))
            end

            local tx, _ = draw.SimpleText(text, "Arena.Small", w / 2, h / 2, Color(255, 255, 255, 255), 1, 1)
            surface.SetDrawColor(Color(255, 255, 255, s.selected and 255 or s:IsHovered() and 200 or 175))
            surface.SetMaterial(icon)
            surface.DrawTexturedRect(w / 2 - tx / 2 - h, 4, h - 8, h - 8)
        end

        table.insert(butts, b)
    end

    navBar:AddButton("Gobble Gums", MATERIAL_GUM, function(b)
        ASAP_GOBBLEGUMS.Scenes.ContentFrame:LoadScene("gobblegums")

        for k, v in pairs(butts) do
            v.selected = false
        end

        b.selected = true
    end)

    navBar:AddButton("Abilities", MATERIAL_ABILITIES, function(b)
        ASAP_GOBBLEGUMS.Scenes.ContentFrame:LoadScene("abilities")

        for k, v in pairs(butts) do
            v.selected = false
        end

        b.selected = true
    end)

    navBar:AddButton("Slots", MATERIAL_SLOTS, function(b)
        ASAP_GOBBLEGUMS.Scenes.ContentFrame:LoadScene("slots")

        for k, v in pairs(butts) do
            v.selected = false
        end

        b.selected = true
    end)

    navBar:AddButton("Prestige", MATERIAL_TROPHY, function(b)
        ASAP_GOBBLEGUMS.Scenes.ContentFrame:LoadScene("prestige")

        for k, v in pairs(butts) do
            v.selected = false
        end

        b.selected = true
    end)

    butts[1].selected = true
    --[[-------------------------------------------------------------------------
Notification Bar/Balance Bar
---------------------------------------------------------------------------]]
    local notiBar = vgui.Create("DPanel", f)
    notiBar:Dock(TOP)
    notiBar:DockMargin(5, 5, 5, 5)
    notiBar:SetTall(40)
    notiBar.text = ""

    notiBar.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(26, 26, 26, 255))
        draw.SimpleText(s.text, "GOBBLEGUMS:Buttons2", 70 + 15, 30 / 2 - 1, Color(255, 255, 255, 150), 0, 1)
    end

    local balanceAmount = vgui.Create("DPanel", notiBar)
    balanceAmount:SetPos(3, 3)
    balanceAmount:SetSize(70, 30 - 6)

    balanceAmount.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(36, 36, 36, 255))
        surface.SetDrawColor(Color(255, 255, 255, 255))
        surface.SetMaterial(MATERIAL_LOGO)
        surface.DrawTexturedRectRotated(20 / 2, h / 2 + 1, 20, 20, 0)
        draw.SimpleText(string.Comma(ASAP_GOBBLEGUMS.gobblegumcredits), "GOBBLEGUMS:Buttons3", w - 5, h / 2, Color(255, 255, 255, 120), 2, 1)
    end

    --[[-------------------------------------------------------------------------
Content frame
---------------------------------------------------------------------------]]
    local contentFrame = vgui.Create("DPanel", f)
    contentFrame:Dock(FILL)
    contentFrame:DockMargin(5, 5, 5, 5)
    contentFrame.curScene = "gobblegums"
    contentFrame.Paint = function() end
    ASAP_GOBBLEGUMS.Scenes.ContentFrame = contentFrame

    --Loads a scene, removes the old one
    function contentFrame:LoadScene(sceneName)
        if ASAP_GOBBLEGUMS.Scenes.Scenes[sceneName] ~= nil then
            ASAP_GOBBLEGUMS.Scenes.Scenes[self.curScene]:OnUnload(self)
            ASAP_GOBBLEGUMS.Scenes.Scenes[self.curScene].OPEN = false

            --Clear the content frame
            for k, v in pairs(self:GetChildren()) do
                v:Remove()
            end

            self.curScene = sceneName
            --print("ABOUT TO LOAD SCENE!", sceneName, self)
            ASAP_GOBBLEGUMS.Scenes.Scenes[sceneName]:OnLoad(self)
            ASAP_GOBBLEGUMS.Scenes.Scenes[sceneName].OPEN = true
            notiBar.text = ASAP_GOBBLEGUMS.Scenes.Scenes[sceneName].Description
        else
            Error("Failed to load scene '" .. sceneName .. "'. The scene does not exist.")

            return false
        end
    end

    timer.Simple(0.1, function()
        if IsValid(contentFrame) then
            contentFrame:LoadScene("slots")
        end
    end)

    function contentFrame:Think()
        if ASAP_GOBBLEGUMS.Scenes.Scenes[self.curScene] ~= nil then
            ASAP_GOBBLEGUMS.Scenes.Scenes[self.curScene]:Think(self)
        end
    end

    if not f4 then
        f:MakePopup()
    end

    return f
end

net.Receive("ASAPGGOBBLEGUMS:RefreshTab", function()
    if isMenuOpen then
        ASAP_GOBBLEGUMS.Scenes.ContentFrame:LoadScene(ASAP_GOBBLEGUMS.Scenes.ContentFrame.curScene)
    end
end)

GobblegumAdd("OnPlayerChat", "ASAP_GOBBLEGUMS:OpenMenu", function(ply, text)
    if string.lower(string.sub(text, 1, 11)) == "!gobblegums" and ply == LocalPlayer() then
        OpenMenu()
    end
end)

concommand.Add("gobblegums", function()
    OpenMenu()
end)

net.Receive("OpenGobblegumMenu", function()
    OpenMenu()
end)

--Now do the menu for the gobble gums
Scenes:LoadScenes()
--[[-------------------------------------------------------------------------
Slot selector/Circle
---------------------------------------------------------------------------]]
local isSelectorOpen = false
local selectorWindow = nil
local canOpenMenu = true

local function drawCircle(x, y, radius, seg)
    local cir = {}

    table.insert(cir, {
        x = x,
        y = y,
        u = 0.5,
        v = 0.5
    })

    for i = 0, seg do
        local a = math.rad((i / seg) * -360.0)

        table.insert(cir, {
            x = x + math.sin(a) * radius,
            y = y + math.cos(a) * radius,
            u = math.sin(a) / 2 + 0.5,
            v = math.cos(a) / 2 + 0.5
        })
    end

    --local a = math.rad( 0.1 ) -- This is needed for non absolute segment counts
    --table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
    surface.DrawPoly(cir)
end

local function CloseSelectorMenu()
    isSelectorOpen = false
    selectorWindow:Close()
    gui.EnableScreenClicker(false)
    canOpenMenu = false
end

local function ShowSelectorMenu()
    isSelectorOpen = true
    gui.EnableScreenClicker(true)
    local rotation = 180
    local outwardsScale = 0
    local count = ASAP_GOBBLEGUMS.gobblegumsslotcount or 2
    local tex_white = surface.GetTextureID("vgui/white")
    local f = vgui.Create("DFrame")
    f:SetSize(700, 700)
    f:Center()
    f.alpha = 0
    f:SetTitle("")
    f:ShowCloseButton(false)

    f.Paint = function(s, w, h)
        render.ClearStencil()
        render.SetStencilEnable(true)
        render.SetStencilTestMask(255)
        render.SetStencilWriteMask(255)
        render.SetStencilReferenceValue(5)
        render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
        render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
        render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
        surface.SetDrawColor(Color(0, 0, 0, 1))
        drawCircle(w / 2, h / 2, 190 * (outwardsScale / 200), 100)
        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NOTEQUAL)
        render.SetStencilPassOperation(STENCILOPERATION_KEEP)
        render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
        render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
        draw.NoTexture()
        surface.SetDrawColor(Color(22, 30, 40, 255))
        drawCircle(w / 2, h / 2, 220 * (outwardsScale / 200), 100)
        surface.SetDrawColor(Color(36, 50, 67, 255))
        drawCircle(w / 2, h / 2, 210 * (outwardsScale / 200), 100)
        surface.SetDrawColor(Color(22, 30, 40, 255))
        drawCircle(w / 2, h / 2, 200 * (outwardsScale / 200), 100)
        render.SetStencilEnable(false)
    end

    f:MakePopup()
    --Create all the buttons
    local buttons = {}

    for i = 1, count do
        local b = vgui.Create("DButton", f)
        b:SetSize(128, 128)
        b:SetText("")
        b.ID = ASAP_GOBBLEGUMS.slots[i]
        b.slotID = i
        b.scale = 1
        b.alpha = 0

        if ASAP_GOBBLEGUMS.slots[i] ~= nil then
            for k, v in pairs(ASAP_GOBBLEGUMS.cooldowns) do
                if k == ASAP_GOBBLEGUMS.slots[i] then
                    b.cooldown = v
                    break
                end
            end
        end

        b.startTime = CurTime()
        b.rotation = 360 - (((360.0 / count) * i) + 180 - (360 / count))

        b.Think = function(s)
            if (s:IsHovered()) then
                s.scale = Lerp(10 * FrameTime(), s.scale, 1.3)
            else
                s.scale = Lerp(6 * FrameTime(), s.scale, 1)
            end

            s:SetSize(math.floor(128 * s.scale), math.floor(128 * s.scale))
        end

        b.Paint = function(s, w, h)
            draw.NoTexture()
            surface.SetDrawColor(Color(22, 30, 40, 255))
            drawCircle(w / 2, h / 2, w / 2, 42)

            if s.ID ~= nil and s.ID ~= -1 then
                local col = ASAP_GOBBLEGUMS.TYPE_TO_COLOR[ASAP_GOBBLEGUMS.Gumballs[s.ID].type]
                surface.SetDrawColor(col)
            else
                surface.SetDrawColor(Color(36, 50, 67, 255))
            end

            drawCircle(w / 2, h / 2, w / 2 - 5, 42)
            surface.SetDrawColor(Color(22, 30, 40, 255))
            drawCircle(w / 2, h / 2, w / 2 - 10, 42)

            if s.ID == nil or s.ID == -1 then
                surface.SetDrawColor(Color(100, 100, 100, 150))
                surface.SetMaterial(MATERIAL_UNKNOWN)
                surface.DrawTexturedRectRotated(w / 2, h / 2, w - 30, h - 30, 0)
            else
                surface.SetDrawColor(Color(255, 255, 255, Lerp(s.alpha / 255, 50, 255)))
                surface.SetMaterial(ASAP_GOBBLEGUMS.Gumballs[s.ID].icon)
                surface.DrawTexturedRectRotated(w / 2, h / 2, w - 30, h - 30, 180 - (rotation * 3) + 180)
            end

            --Draw the cooldown if there is one
            if s.cooldown ~= nil then
                --On a cooldown, draw a red circle
                if s.cooldown.activeTime ~= -1 and s.cooldown.activeTime < CurTime() then
                    local timeLeft = s.cooldown.cooldown - CurTime()
                    local text = timeLeft

                    if timeLeft >= 0 then
                        if timeLeft > 60 then
                            local mins = math.floor(timeLeft / 60)
                            text = mins .. " MINS"
                        else
                            local seconds = math.floor(timeLeft)
                            text = seconds .. " SECS"
                        end
                    else
                        s.cooldown = nil
                        return
                    end

                    if s.cooldown.activeTime == -1 then
                        text = "DEATH"
                    end

                    draw.NoTexture()
                    surface.SetDrawColor(Color(230, 70, 40, 50))
                    drawCircle(w / 2, h / 2, w / 2 - 10, 42)
                    --Draw the text
                    draw.SimpleText(text, "GOBBLEGUMS:Buttons5", w / 2 + 2, h / 2 + 2, Color(0, 0, 0, 255 - s.alpha), 1, 1)
                    draw.SimpleText(text, "GOBBLEGUMS:Buttons5", w / 2, h / 2, Color(255, 255, 255, 255 - s.alpha), 1, 1)
                else --In use, draw a green circle
                    local timeLeft = s.cooldown.activeTime - CurTime()
                    local text = timeLeft

                    if timeLeft >= 0 then
                        if timeLeft > 60 then
                            local mins = math.floor(timeLeft / 60)
                            text = mins .. " MINS"
                        else
                            local seconds = math.floor(timeLeft)
                            text = seconds .. " SECS"
                        end
                    end

                    if s.cooldown.activeTime == -1 then
                        text = "DEATH"
                    end

                    draw.NoTexture()
                    surface.SetDrawColor(Color(40, 255, 70, 50))
                    drawCircle(w / 2, h / 2, w / 2 - 10, 42)
                    --Draw the text
                    draw.SimpleText(text, "GOBBLEGUMS:Buttons5", w / 2 + 2, h / 2 + 2, Color(0, 0, 0, 255 - s.alpha), 1, 1)
                    draw.SimpleText(text, "GOBBLEGUMS:Buttons5", w / 2, h / 2, Color(255, 255, 255, 255 - s.alpha), 1, 1)
                end

                s.alpha = Lerp(10 * FrameTime(), s.alpha, 0)
            else
                if not s:IsHovered() then
                    s.alpha = Lerp(10 * FrameTime(), s.alpha, 255)
                else
                    s.alpha = Lerp(10 * FrameTime(), s.alpha, 0)
                end

                draw.SimpleText(i, "GOBBLEGUMS:Buttons10", (w / 2) + 2, (h / 2) + 2, Color(0, 0, 0, 255 - s.alpha), 1, 1)
                draw.SimpleText(i, "GOBBLEGUMS:Buttons10", w / 2, h / 2, Color(255, 255, 255, 255 - s.alpha), 1, 1)
            end
        end

        b.DoClick = function(s)
            CloseSelectorMenu()
            net.Start("ASAPGGOBBLEGUMS:Activate")
            net.WriteUInt(s.slotID, 8)
            net.SendToServer()
        end

        function b:OnCursorEntered()
        end

        function b:OnCursorExited()
        end

        buttons[i] = b
    end

    function f:Think()
        for i = 1, count do
            local b = buttons[i]
            local offsetX = math.sin(math.rad(b.rotation + rotation)) * outwardsScale
            local offsetY = math.cos(math.rad(b.rotation + rotation)) * outwardsScale
            b:SetPos(f:GetWide() / 2 + offsetX - math.floor(b:GetWide() / 2), f:GetTall() / 2 + offsetY - math.floor(b:GetTall() / 2))
        end

        rotation = Lerp(8 * FrameTime(), rotation, 0)
        outwardsScale = Lerp(8 * FrameTime(), outwardsScale, 200)
    end

    selectorWindow = f
end

GobblegumAdd("Think", "ASAPGOBBLESHITGUMS:CircleMenuCreator", function()
    if not input.IsKeyDown(KEY_G) then
        canOpenMenu = true
    end

    if not input.IsKeyDown(KEY_G) and isSelectorOpen then
        CloseSelectorMenu()
    else
        if not isSelectorOpen and not vgui.CursorVisible() and canOpenMenu then
            if input.IsKeyDown(KEY_G) then
                local disallowOpening = hook.Run("CanOpenGobblegums")

                if (disallowOpening ~= false) then
                    ShowSelectorMenu()
                end
            end
        end
    end
end)

local MATERIAL_LOADING = Material("vgui/alpha-back.png", "noclamp smooth")

surface.CreateFont("aMenu18_blur", {
    font = "Montserrat",
    size = 18,
    weight = 500,
    blursize = 3,
    shadow = true
})

hook.Add("OnPopulateF4Categories", "Gobblegums", function(pnl)
    pnl.GobblegumsPanel = OpenMenu(pnl)
    pnl:AddCat("Gobblegums", Material("asapf4/gobble.png"), pnl.GobblegumsPanel, {Color(206, 76, 156), Color(227, 121, 91)})
    pnl.GobblegumsPanel:Dock(FILL)
end)

--[[-------------------------------------------------------------------------
Net receivers
---------------------------------------------------------------------------]]
net.Receive("ASAPGGOBBLEGUMS:Gobblegums", function()
    ASAP_GOBBLEGUMS.gumballs = net.ReadTable()
end)

--print("Received Gobble Gum Update")
net.Receive("ASAPGGOBBLEGUMS:Slots", function()
    ASAP_GOBBLEGUMS.slots = net.ReadTable()
    ASAP_GOBBLEGUMS.gobblegumsslotcount = net.ReadInt(16)
end)

--print("Received Gobble Gum Slots Update", ASAP_GOBBLEGUMS.gobblegumsslotcount)
net.Receive("ASAPGGOBBLEGUMS:Cooldown", function()
    ASAP_GOBBLEGUMS.cooldowns = net.ReadTable()
end)

--print("Received Gobble Gum Cooldown Update")
net.Receive("ASAPGGOBBLEGUMS:NetworkXPLevel", function()
    ASAP_GOBBLEGUMS.xp = net.ReadUInt(32)
    ASAP_GOBBLEGUMS.level = net.ReadUInt(32)
    ASAP_GOBBLEGUMS.xpToNextLevel = net.ReadUInt(32)
end)

net.Receive("ASAPGGOBBLEGUMS:Abilities", function()
    ASAP_GOBBLEGUMS.gobblegumabilities = net.ReadTable()
end)

net.Receive("ASAP:SpentOnSlots", function()
    ASAP_GOBBLEGUMS.spentOnSlots = net.ReadInt(32)
end)

net.Receive("ASAPGGOBBLEGUMS:Credits", function()
    ASAP_GOBBLEGUMS.gobblegumcredits = net.ReadUInt(32)
end)