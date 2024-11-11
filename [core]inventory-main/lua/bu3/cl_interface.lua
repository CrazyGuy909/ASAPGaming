--This file is pretty much used to control all of the UI. 
--It has a simular system to blue's double or nothing in a sense that things 
--are make of scenes, scenes can be loaded or destroyed. Scenes are also there own objects
--so they can store data, or pass it on to other scenes
BU3.UI = BU3.UI or {}
BU3.UI.EventHistory = BU3.UI.EventHistory or {}
BU3.UI.Fonts = {}
BU3.UI.Fonts["smallest_reg"] = "bu3_smallest_reg"

surface.CreateFont("bu3_smallest_reg", {
    font = "Montserrat",
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

BU3.UI.Fonts["small_reg"] = "bu3_small_reg"

surface.CreateFont("bu3_small_reg", {
    font = "Montserrat",
    extended = false,
    size = 22,
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

BU3.UI.Fonts["small_reg_blur"] = "bu3_small_reg_blur"

surface.CreateFont("bu3_small_reg_blur", {
    font = "Montserrat",
    extended = false,
    size = 22,
    weight = 200,
    blursize = 4,
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

BU3.UI.Fonts["small_bold"] = "bu3_small_bold"

surface.CreateFont("bu3_small_bold", {
    font = "Montserrat",
    extended = false,
    size = 25,
    weight = 800,
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

BU3.UI.Fonts["small_bold_blur"] = "bu3_small_bold_blur"

surface.CreateFont("bu3_small_bold_blur", {
    font = "Montserrat",
    extended = false,
    size = 25,
    weight = 800,
    blursize = 4,
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

BU3.UI.Fonts["med_bold"] = "bu3_med_bold"

surface.CreateFont("bu3_med_bold", {
    font = "Montserrat",
    extended = false,
    size = 36,
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

BU3.UI.Fonts["large_bold"] = "bu3_large_bold"

surface.CreateFont("bu3_large_bold", {
    font = "Montserrat",
    extended = false,
    size = 45,
    weight = 800,
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

BU3.UI.Fonts["xlarge_bold"] = "bu3_xlarge_bold"

surface.CreateFont("bu3_xlarge_bold", {
    font = "Montserrat",
    extended = false,
    size = 50,
    weight = 800,
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

--These are default materials, more will be added via loading
BU3.UI.Materials = {
    iconHome = Material("materials/bu3/home.png", "noclamp smooth"),
    iconPricetag = Material("materials/bu3/pricetags.png", "noclamp smooth"),
    iconHelp = Material("materials/bu3/help-circled.png", "noclamp smooth"),
    iconGear = Material("materials/bu3/gear-b.png", "noclamp smooth"),
    iconCube = Material("materials/bu3/cube.png", "noclamp smooth"),
    iconClose = Material("materials/bu3/close-round.png", "noclamp smooth"),
    iconBag = Material("materials/bu3/bag.png", "noclamp smooth"),
    iconSwap = Material("materials/bu3/arrow-swap.png", "noclamp smooth"),
    defaultCase = Material("materials/bu3/case.png", "noclamp smooth"),
    defaultKey = Material("materials/bu3/key.png", "noclamp smooth"),
    defaultWeapon = Material("materials/bu3/weapon.png", "noclamp smooth"),
    defaultEntity = Material("materials/bu3/entity.png", "noclamp smooth"),
    defaultMoney = Material("materials/bu3/money.png", "noclamp smooth"),
    defaultPoints = Material("materials/bu3/points.png", "noclamp smooth"),
    loading = Material("materials/bu3/loading.png", "noclamp smooth"),
    placeholder = Material("materials/bu3/placeholder.png", "noclamp smooth"),
    arrow = Material("materials/bu3/down.png", "noclamp smooth"),
    refresh = Material("materials/bu3/refresh.png", "noclamp smooth"),
    marker = Material("materials/bu3/marker.png", "noclamp smooth"),
    gradient = Material("materials/bu3/gradient.png"),
    shadow = Material("materials/bu3/itemshadow.png"),
    lua = Material("materials/bu3/lua.png")
}

--[[-------------------------------------------------------------------------
Pages stuff
---------------------------------------------------------------------------]]
BU3.UI.Pages = BU3.UI.Pages or {}

function BU3.UI.RegisterPage(name, page)
    BU3.UI.Pages[name] = page
    print("Registered page '" .. name .. "'")
end

--Returns a page, or false if not found
function BU3.UI.GetPage(name)
    return BU3.UI.Pages[name] or false
end

--Now load all the pages
local files, folders = file.Find("bu3/pages/*", "LUA")

for _, v in pairs(files) do
    include("bu3/pages/" .. v)
end

--[[-------------------------------------------------------------------------
This is the "UI" framework, with usefull items for drawing UI elements
---------------------------------------------------------------------------]]
--Adds history to the event list
function BU3.UI.AddEventHistory(line)
    for i = 1, 12 do
        local _i = 12 - i
        BU3.UI.EventHistory[_i + 1] = BU3.UI.EventHistory[_i]
    end

    BU3.UI.EventHistory[1] = line
end

net.Receive("BU3:AddEventHistory", function()
    BU3.UI.AddEventHistory(net.ReadString())
end)

BU3.UI.Elements = {}

--Create a box with a title, and some text in it
function BU3.UI.Elements.CreateInfoPanel(title, info, parent)
    local p = vgui.Create("DPanel", parent)

    p.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(46, 46, 46, 255))
        --Draw text
        draw.SimpleText(title, BU3.UI.Fonts["xlarge_bold"], w / 2, h / 3, Color(225, 225, 225), 1, 1)
        draw.SimpleText(info, BU3.UI.Fonts["small_reg"], w / 2, h / 1.39, Color(120, 120, 120), 1, 1)
    end

    return p
end

--Create a box with a title, and some text in it
function BU3.UI.Elements.CreateSlider(color, minValue, maxValue, parent, onValueChanged)
    --Credit to wiki
    local function drawCircle(x, y, radius, seg)
        local cir = {}

        table.insert(cir, {
            x = x,
            y = y,
            u = 0.5,
            v = 0.5
        })

        for i = 0, seg do
            local a = math.rad((i / seg) * -360)

            table.insert(cir, {
                x = x + math.sin(a) * radius,
                y = y + math.cos(a) * radius,
                u = math.sin(a) / 2 + 0.5,
                v = math.cos(a) / 2 + 0.5
            })
        end

        local a = math.rad(0) -- This is needed for non absolute segment counts

        table.insert(cir, {
            x = x + math.sin(a) * radius,
            y = y + math.cos(a) * radius,
            u = math.sin(a) / 2 + 0.5,
            v = math.cos(a) / 2 + 0.5
        })

        surface.DrawPoly(cir)
    end

    local p = vgui.Create("DPanel", parent)
    --p:NoClipping(true)
    p.slideAmount = 100 --This is between 0 and 100, regardless of the min and max value as there mapped to it

    p.Paint = function(s, w, h)
        local slideAmountPixel = math.Clamp(w / 100 * (s.slideAmount) - h / 2, h / 2, w - (h / 2))
        --Draw background and rounded edges
        draw.RoundedBox(0, h / 2, 2, w - h, h - 4, Color(40, 40, 45))
        draw.NoTexture()
        surface.SetDrawColor(Color(40, 40, 45))
        drawCircle(w - (h / 2), h / 2, (h / 2) - 2, 16)
        --Draw the color section
        draw.RoundedBox(0, h / 2, 2, slideAmountPixel - (h / 2), h - 4, color)
        draw.NoTexture()
        surface.SetDrawColor(color)
        drawCircle((h / 2), h / 2, (h / 2) - 2, 16)
        --Slider end
        surface.SetDrawColor(Color(40, 40, 45))
        drawCircle(slideAmountPixel, h / 2, (h / 2) + 2, 16)
        surface.SetDrawColor(color)
        drawCircle(slideAmountPixel, h / 2, (h / 2) - 1, 16)
    end

    p.PerformLayout = function(s, w, h)
        s.sliderButton:SetSize(w, h)
    end

    --Create the slider end button
    local sliderButton = vgui.Create("DButton", p)
    sliderButton:SetText("")
    sliderButton.skipFrames = 0 --Skip frames are used becuase gui uses cached results
    sliderButton.Paint = function() end --Hide button

    sliderButton.OnMousePressed = function(s, keycode)
        if keycode == MOUSE_LEFT then
            s.sliding = true
            s.skipFrames = 1
        end
    end

    sliderButton.Think = function(s)
        if s.skipFrames > 0 then
            s.skipFrames = s.skipFrames - 1
        else
            if not input.IsMouseDown(MOUSE_LEFT) and s.sliding then
                s.sliding = false
            end
        end

        if s.sliding then
            --Work out new slider position
            local x, y = s:ScreenToLocal(gui.MouseX(), gui.MouseY())
            local newSlidePos = (100 / s:GetWide()) * math.Clamp(x + (p:GetTall() / 2), 0, p:GetWide())
            p.slideAmount = newSlidePos
            onValueChanged(p.slideAmount / 100 * maxValue)
        end
    end

    p.sliderButton = sliderButton

    return p
end

--Create a box with a title, and some text in it
function BU3.UI.Elements.CreateComboBox(option, parent)
    local p = vgui.Create("DComboBox", parent)
    p:SetValue(option)

    p.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 45, 255))
        surface.SetDrawColor(Color(149, 152, 154))
        surface.SetMaterial(BU3.UI.Materials.arrow)
        surface.DrawTexturedRectRotated(w - 25, h / 2, 20, 20, 0)
    end

    p.DropButton.Paint = function() end --Clear drop down arrow

    function p:PerformLayout(width, height)
        self:SetFontInternal(BU3.UI.Fonts["small_bold"])
        self:SetTextColor(Color(149, 152, 154))
        self.DropButton:SetSize(20, 20)
        self.DropButton:AlignRight(4)
        self.DropButton:CenterVertical()
    end

    return p
end

function BU3.UI.Elements.CreateCheckBox(state, parent)
    --Credit to wiki
    local function drawCircle(x, y, radius, seg)
        local cir = {}

        table.insert(cir, {
            x = x,
            y = y,
            u = 0.5,
            v = 0.5
        })

        for i = 0, seg do
            local a = math.rad((i / seg) * -360)

            table.insert(cir, {
                x = x + math.sin(a) * radius,
                y = y + math.cos(a) * radius,
                u = math.sin(a) / 2 + 0.5,
                v = math.cos(a) / 2 + 0.5
            })
        end

        local a = math.rad(0) -- This is needed for non absolute segment counts

        table.insert(cir, {
            x = x + math.sin(a) * radius,
            y = y + math.cos(a) * radius,
            u = math.sin(a) / 2 + 0.5,
            v = math.cos(a) / 2 + 0.5
        })

        surface.DrawPoly(cir)
    end

    local function burp(v, s, e)
        v = (math.sin(v * math.pi * (0.2 + 2.5 * v * v * v)) * math.pow(1 - v, 2.2) + v) * (1 + (1.2 * (1 - v)))

        return s + (e - s) * v
    end

    local function ColorLerp(t, col1, col2)
        local col3 = Color(0, 0, 0)
        col3.r = Lerp(t, col1.r, col2.r)
        col3.g = Lerp(t, col1.g, col2.g)
        col3.b = Lerp(t, col1.b, col2.b)
        col3.a = Lerp(t, col1.a, col2.a)

        return col3
    end

    local p = vgui.Create("DButton", parent)
    p:SetText("")
    p.state = state
    p.slideValue = 0 --Between 0 and 1

    p.Paint = function(s, w, h)
        draw.NoTexture()
        local color = ColorLerp(s.slideValue, Color(40, 40, 45, 255), Color(39, 174, 96, 255))
        --Draw outer circles
        surface.SetDrawColor(color)
        drawCircle(h / 2, h / 2, h / 2, 32)
        drawCircle(w - (h / 2), h / 2, h / 2, 32)
        draw.RoundedBox(6, h / 2, 0, w - (h), h, color)
        local circlePixelPos = burp(s.slideValue, h / 2 + 1, w - (h / 2) - 1)

        if s.state then
            p.slideValue = Lerp(5 * FrameTime(), p.slideValue, 1)
        else
            p.slideValue = Lerp(5 * FrameTime(), p.slideValue, 0)
            circlePixelPos = burp(1 - s.slideValue, w - (h / 2) - 1, h / 2 + 1)
        end

        draw.NoTexture()
        surface.SetDrawColor(Color(255, 255, 255, 255))
        drawCircle(circlePixelPos, h / 2, (h / 2) - (h / 8), 32)
    end

    p.DoClick = function(s)
        s.state = not s.state
    end

    return p
end

--Creates a button with an arrow in a direction
function BU3.UI.Elements.CreateArrowButton(rotation, parent, onclick)
    local p = vgui.Create("DButton", parent)
    p:SetText("")
    p.buttonActive = true

    p.Paint = function(s, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(40, 40, 45, 255))

        if s.buttonActive then
            surface.SetDrawColor(Color(149, 152, 154))
        else
            surface.SetDrawColor(Color(149 * 0.4, 152 * 0.4, 154 * 0.4))
        end

        surface.SetMaterial(BU3.UI.Materials.arrow)
        surface.DrawTexturedRectRotated(w / 2, h / 2, 16, 16, rotation)
    end

    p.DoClick = function(s)
        onclick(s)
    end

    return p
end

function BU3.UI.Elements.Prompt(title, body)
    local item = BU3.Items.Items[itemID]
    local p = vgui.Create("DFrame")
    p:SetSize(400, 150)
    p:SetTitle("")
    p:SetPaintShadow(true)
    p:SetBackgroundBlur(true)
    p:ShowCloseButton(false)

    p.Paint = function(s, w, h)
        draw.RoundedBoxEx(6, 0, 0, w, h - 1, Color(45, 220, 255, 255), true, true, true, true)
        draw.RoundedBoxEx(6, 1, 1, w - 2, 40, Color(40, 40, 45), true, true, false, false)
        draw.RoundedBoxEx(6, 1, 40, w - 2, h - 40 - 2, Color(27, 27, 30, 255), false, false, true, true)
        --Pain the item name
        draw.SimpleText(title, BU3.UI.Fonts["med_bold"], w / 2, 20, Color(255, 255, 255, 150), 1, 1)
        draw.SimpleText(body, BU3.UI.Fonts["small_reg"], w / 2, 70, Color(255, 255, 255, 150), 1, 1)
    end

    local okayButton = BU3.UI.Elements.CreateStandardButton("Okay", p, function()
        p:Close()
    end)

    okayButton:SetPos(200 - 150, 150 - 50)
    okayButton:SetSize(300, 40)
    p:Center()
    p:MakePopup()

    return p
end

--Creates a yes no dialog for purchasing an item with callbacks
function BU3.UI.Elements.PurchasePrompt(itemID, amount, onYes, onNo)
    local item = BU3.Items.Items[itemID]
    local p = vgui.Create("DFrame")
    p:SetSize(400, 250)
    p:SetTitle("")
    p:SetPaintShadow(true)
    p:SetBackgroundBlur(true)
    p:ShowCloseButton(false)

    p.Paint = function(s, w, h)
        draw.RoundedBoxEx(6, 0, 0, w, h - 1, Color(45, 220, 255, 255), true, true, true, true)
        draw.RoundedBoxEx(6, 1, 1, w - 2, 40, Color(40, 40, 45), true, true, false, false)
        draw.RoundedBoxEx(6, 1, 40, w - 2, h - 40 - 2, Color(27, 27, 30, 255), false, false, true, true)
        --Pain the item name
        draw.SimpleText("Are you sure?", BU3.UI.Fonts["med_bold"], w / 2, 20, Color(255, 255, 255, 150), 1, 1)
        draw.SimpleText("Price : " .. string.Comma(item.price), BU3.UI.Fonts["small_reg"], 205, 50 - 2, Color(255, 255, 255, 150), 0, 0)
        draw.SimpleText("Quantity : " .. amount, BU3.UI.Fonts["small_reg"], 205, 50 - 2 + 25, Color(255, 255, 255, 150), 0, 0)
        draw.SimpleText("Total Price : " .. string.Comma(item.price * amount), BU3.UI.Fonts["small_reg"], 205, 50 - 2 + 140 - 20, Color(255, 255, 255, 150), 0, 0)
    end

    local cancelButton = BU3.UI.Elements.CreateStandardButton("Cancel", p, function()
        if onNo then
            onNo()
        end

        p:Close()
    end)

    cancelButton:SetPos(10, 250 - 50)
    cancelButton:SetSize((400 / 2) - 15, 40)

    local purchaseButton = BU3.UI.Elements.CreateStandardButton("Purchase", p, function()
        if onYes then
            onYes()
        end

        p:Close()
    end)

    purchaseButton:SetPos(200 + 5, 250 - 50)
    purchaseButton:SetSize((400 / 2) - 15, 40)
    local borderColor = item.itemColorCode or 1
    local borderColorRGB = BU3.Items.RarityToColor[borderColor]
    --Create the icon preview
    local _p = vgui.Create("DPanel", p)
    _p:SetPos(10, 50)
    _p:SetSize(185, 140)

    _p.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, borderColorRGB)
        draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(40, 40, 45, 255))
        --Draw the item name
        local name = item.name

        if string.len(name) >= 25 then
            name = string.sub(name, 1, 25) .. "..."
        end

        draw.SimpleText(name, BU3.UI.Fonts["small_reg"], w / 2, 17, Color(200, 200, 200, 255), 1, 1)
    end

    --Create the item preview
    local iconPreview = nil

    if item.iconIsModel then
        iconPreview = BU3.UI.Elements.ModelView(item.iconID, item.zoom, _p)
    else
        iconPreview = BU3.UI.Elements.IconView(item.iconID, item.color, _p, false)
    end

    iconPreview:SetPos((185 / 2) - ((130 - 24) / 2), 25 + 3)
    iconPreview:SetSize(130 - 24, 130 - 24)
    iconPreview.zoom = item.zoom
    _p.iconPreview = iconPreview
    p:Center()
    p:MakePopup()

    return p
end

--Creates a pop up box asking if you want to delete the ite,
function BU3.UI.Elements.DeletePrompt(itemID)
    local item = BU3.Items.Items[itemID]
    local p = vgui.Create("DFrame")
    p:SetSize(400, 250)
    p:SetTitle("")
    p:SetPaintShadow(true)
    p:SetBackgroundBlur(true)
    p:ShowCloseButton(false)

    p.Paint = function(s, w, h)
        draw.RoundedBoxEx(6, 0, 0, w, h - 1, Color(45, 220, 255, 255), true, true, true, true)
        draw.RoundedBoxEx(6, 1, 1, w - 2, 40, Color(40, 40, 45), true, true, false, false)
        draw.RoundedBoxEx(6, 1, 40, w - 2, h - 40 - 2, Color(27, 27, 30, 255), false, false, true, true)
        --Paint the item name
        draw.SimpleText("Are you sure?", BU3.UI.Fonts["med_bold"], w / 2, 20, Color(255, 255, 255, 150), 1, 1)
        draw.SimpleText("Once you delete items", BU3.UI.Fonts["small_reg"], 205, 50 - 2, Color(255, 255, 255, 150), 0, 0)
        draw.SimpleText("You should restart", BU3.UI.Fonts["small_reg"], 205, 50 - 2 + 25, Color(255, 255, 255, 150), 0, 0)
    end

    local cancelButton = BU3.UI.Elements.CreateStandardButton("No", p, function()
        p:Close()
    end)

    cancelButton:SetPos(10, 250 - 50)
    cancelButton:SetSize((400 / 2) - 15, 40)

    local purchaseButton = BU3.UI.Elements.CreateStandardButton("Yes", p, function()
        net.Start("BU3:DeleteRegisteredItem")
        net.WriteInt(itemID, 32)
        net.SendToServer()
        p:Close()
        BU3.UI.ContentFrame.MainFrame:Close()
        BU3.UI.SetMenuOpen(false)
    end)

    purchaseButton:SetPos(200 + 5, 250 - 50)
    purchaseButton:SetSize((400 / 2) - 15, 40)
    local borderColor = item.itemColorCode or 1
    local borderColorRGB = BU3.Items.RarityToColor[borderColor]
    --Create the icon preview
    local _p = vgui.Create("DPanel", p)
    _p:SetPos(10, 50)
    _p:SetSize(185, 140)

    _p.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, borderColorRGB)
        draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(40, 40, 45, 255))
        --Draw the item name
        local name = item.name

        if string.len(name) >= 25 then
            name = string.sub(name, 1, 25) .. "..."
        end

        draw.SimpleText(name, BU3.UI.Fonts["small_reg"], w / 2, 17, Color(200, 200, 200, 255), 1, 1)
    end

    --Create the item preview
    local iconPreview = nil

    if item.iconIsModel then
        iconPreview = BU3.UI.Elements.ModelView(item.iconID, item.zoom, _p)
    else
        iconPreview = BU3.UI.Elements.IconView(item.iconID, item.color, _p, false)
    end

    iconPreview:SetPos((185 / 2) - ((130 - 24) / 2), 25 + 3)
    iconPreview:SetSize(130 - 24, 130 - 24)
    iconPreview.zoom = item.zoom
    _p.iconPreview = iconPreview
    p:Center()
    p:MakePopup()

    return p
end

--An element to display models with a zoom variable option (scale to bounds by default)
function BU3.UI.Elements.ModelView(modelPath, zoom, parent)
    local mod = vgui.Create("DModelPanel", parent)
    mod:SetPos(0, 0)
    mod:SetSize(180, 180)
    mod:SetModel(modelPath)
    mod:SetAnimated(true)
    --mod.bAnimated = true
    if not IsValid(mod:GetEntity()) then
        mod:SetModel("models/props_borealis/bluebarrel001.mdl") 
        return mod
    end
    mod.zoom = zoom
    mod.ang = mod:GetEntity():GetAngles()
    --function mod:LayoutEntity(Entity)
    --	if ( self.bAnimated ) then
    --		self:RunAnimation()
    --	end
    --end
    local min, max = mod:GetEntity():GetRenderBounds()

    mod.Think = function(s)
        mod:SetCamPos(min:Distance(max) * Vector(0.8 * (1 - s.zoom), 0.8 * (1 - s.zoom), 0.8 * (1 - s.zoom)))
        mod:SetLookAt((max + min) / 2)
    end

    return mod
end

local cache = {}
--An element usefull for displaying icons / imgur images
function BU3.UI.Elements.IconView(idOrName, color, parent, previewOutline)
    local p = vgui.Create("DPanel", parent)

    if idOrName == "case" then
        p.type = "case"
    elseif idOrName == "key" then
        p.type = "key"
    elseif idOrName == "weapon" then
        p.type = "weapon"
    elseif idOrName == "entity" then
        p.type = "entity"
    elseif idOrName == "money" then
        p.type = "money"
    elseif idOrName == "points" then
        p.type = "points"
    elseif idOrName == "lua" then
        p.type = "lua"
    elseif idOrName == "help" then
        p.type = "help"
    elseif idOrName == "credits" then
        p.type = "credits"
        p.mat = nil
        BU3.ImageLoader.GetMaterial("3Kuh0KA", function(__mat)
            if IsValid(p) then
                p.mat = __mat
            end
        end)
    else
        p.mat = nil

        --Try to get the html icon
        idOrName = idOrName or ""
        if (string.find(idOrName, "/", 1, true)) then
            p.mat = Material(idOrName)
        else
            BU3.ImageLoader.GetMaterial(idOrName, function(__mat)
                if IsValid(p) then
                    p.mat = __mat
                end
            end)
        end
    end

    p.placeholder = false
    p._color = color
    p.zoom = 0

    p.Paint = function(s, w, h)
        if previewOutline then
            surface.SetDrawColor(Color(40, 40, 45, 255))
            s:DrawOutlinedRect()
        end

        --Draw shadow first
        surface.SetDrawColor(Color(255, 255, 255, 255))
        surface.SetMaterial(BU3.UI.Materials.shadow)
        surface.DrawTexturedRect(0, h - (h / 5), w, h / 5)
        draw.NoTexture()
        surface.SetDrawColor(s._color or color_white)

        if s.placeholder then
            surface.SetMaterial(BU3.UI.Materials.placeholder)
            surface.DrawTexturedRectRotated(w / 2, h / 2, w - 10, h - 10, 0)

            return
        end

        if s.type == "case" then
            surface.SetMaterial(BU3.UI.Materials.defaultCase)
            surface.DrawTexturedRectRotated(w / 2, h / 2, (w - 10) * (s.zoom + 1), (h - 10) * (s.zoom + 1), 0)
        elseif s.type == "key" then
            surface.SetMaterial(BU3.UI.Materials.defaultKey)
            surface.DrawTexturedRectRotated(w / 2, h / 2, (w - 10) * (s.zoom + 1), (h - 10) * (s.zoom + 1), 0)
        elseif s.type == "weapon" then
            if parent.Item and not cache[parent.Item.className] then
                cache[parent.Item.className] = Material("entities/" .. parent.Item.className .. ".png")
                if (cache[parent.Item.className]:IsError()) then
                    cache[parent.Item.className] = false
                end
            end

            surface.SetMaterial(parent.Item and cache[parent.Item.className] or BU3.UI.Materials.defaultWeapon)
            surface.DrawTexturedRectRotated(w / 2, h / 2, (w - 10) * (s.zoom + 1.25), (h - 10) * (s.zoom + 1.25), 0)
        elseif s.type == "entity" then
            surface.SetMaterial(BU3.UI.Materials.defaultEntity)
            surface.DrawTexturedRectRotated(w / 2, h / 2, (w - 10) * (s.zoom + 1), (h - 10) * (s.zoom + 1), 0)
        elseif s.type == "money" then
            surface.SetMaterial(BU3.UI.Materials.defaultMoney)
            surface.DrawTexturedRectRotated(w / 2, h / 2, (w - 10) * (s.zoom + 1), (h - 10) * (s.zoom + 1), 0)
        elseif s.type == "points" then
            surface.SetMaterial(BU3.UI.Materials.defaultPoints)
            surface.DrawTexturedRectRotated(w / 2, h / 2, (w - 10) * (s.zoom + 1), (h - 10) * (s.zoom + 1), 0)
        elseif s.type == "lua" then
            surface.SetMaterial(BU3.UI.Materials.lua)
            surface.DrawTexturedRectRotated(w / 2, h / 2, (w - 10) * (s.zoom + 1), (h - 10) * (s.zoom + 1), 0)
        elseif s.type == "help" then
            surface.SetMaterial(BU3.UI.Materials.iconHelp)
            surface.DrawTexturedRectRotated(w / 2, h / 2, (w - 10) * (s.zoom + 1), (h - 10) * (s.zoom + 1), 0)
        else
            if s.mat ~= nil then
                if s.mat == false then
                    surface.SetDrawColor(Color(255, 255, 255, 255))
                    surface.SetMaterial(BU3.UI.Materials.placeholder)
                else
                    surface.SetMaterial(s.mat)
                end

                surface.DrawTexturedRectRotated(w / 2, h / 2, (w - 10) * ((s.zoom or 0) + 1), (h - 10) * ((s.zoom or 0) + 1), 0)
            else
                surface.SetDrawColor(Color(255, 255, 255, 255))
                surface.SetMaterial(BU3.UI.Materials.loading)
                surface.DrawTexturedRectRotated(w / 2, h / 2, (w - 10) * ((s.zoom or 0) + 1), (h - 10) * ((s.zoom or 0) + 1), 360 - ((CurTime() * 150) % 360))
            end
        end
    end

    return p
end

--Creates a step counter, shows progress 
function BU3.UI.Elements.CreateStepCounter(numberOfSteps, parent)
    --Credit to wiki
    local function drawCircle(x, y, radius, seg)
        local cir = {}

        table.insert(cir, {
            x = x,
            y = y,
            u = 0.5,
            v = 0.5
        })

        for i = 0, seg do
            local a = math.rad((i / seg) * -360)

            table.insert(cir, {
                x = x + math.sin(a) * radius,
                y = y + math.cos(a) * radius,
                u = math.sin(a) / 2 + 0.5,
                v = math.cos(a) / 2 + 0.5
            })
        end

        local a = math.rad(0) -- This is needed for non absolute segment counts

        table.insert(cir, {
            x = x + math.sin(a) * radius,
            y = y + math.cos(a) * radius,
            u = math.sin(a) / 2 + 0.5,
            v = math.cos(a) / 2 + 0.5
        })

        surface.DrawPoly(cir)
    end

    local p = vgui.Create("DPanel", parent)
    p.selectedStage = 1

    p.Paint = function(s, w, h)
        distance = (w - 25) / numberOfSteps
        draw.NoTexture()
        draw.RoundedBox(0, 25, h / 2 - 5, w - distance, 10, Color(40, 40, 45))

        for i = 0, numberOfSteps - 1 do
            if i + 1 == s.selectedStage then
                surface.SetDrawColor(Color(45, 220, 255))
            else
                surface.SetDrawColor(Color(40, 40, 45))
            end

            drawCircle((distance * i) + 25, h / 2, 25, 32)
            draw.SimpleText(i + 1, BU3.UI.Fonts["med_bold"], (distance * i) - 1 + 25, h / 2, Color(255, 255, 255, 200), 1, 1)
        end
    end

    return p
end

--Create a textbox with an x to clear text and a ghost button
function BU3.UI.Elements.CreateTextEntry(ghostText, parent, shouldMakeSmaller, hasCloseButton)
    local p = vgui.Create("DTextEntry", parent)
    p:SetPaintBackground(false)
    p:SetUpdateOnType(true)
    p.lerpValue = 0

    p.Paint = function(s, w, h)
        if not shouldMakeSmaller then
            s.lerpValue = 1
        end

        local lerpPixelValue = (1 - s.lerpValue) * 125
        draw.RoundedBox(4, lerpPixelValue, 0, w - lerpPixelValue, h, Color(46, 46, 46, 255))

        --Draw ghost text
        if s:GetText() == "" and not s:IsEditing() then
            draw.SimpleText(ghostText, "aMenu18", lerpPixelValue + 5, h / 2, Color(149, 152, 154), 0, 1)
        end

        s:DrawTextEntryText(Color(149, 152, 154), Color(255, 152, 154), Color(255, 255, 255))

        if s:IsHovered() or s:IsEditing() or s:GetText() ~= "" then
            s.lerpValue = Lerp(15 * FrameTime(), s.lerpValue, 1)
        else
            s.lerpValue = Lerp(15 * FrameTime(), s.lerpValue, 0)
        end
    end

    function p:PerformLayout()
    end

    function p:PerformLayout(width, height)
        if hasCloseButton then
            self.b:SetPos(width - height, 0)
            self.b:SetSize(height, height)
        end

        self:SetFontInternal("aMenu18")
    end

    if hasCloseButton then
        --Now create the clear button
        local b = vgui.Create("DButton", p)
        b:SetText("")

        b.DoClick = function()
            p:SetText("")
        end

        b.Paint = function(s, w, h)
            surface.SetDrawColor(Color(149, 152, 154))
            surface.SetMaterial(BU3.UI.Materials.iconClose)
            surface.DrawTexturedRect(7, 7, w - 14, h - 14)
        end

        p.b = b
    end

    return p
end

--Create a textbox with an x to clear text and a ghost button
function BU3.UI.Elements.CreateImgurEntry(ghostText, parent, onRefresh)
    shouldMakeSmaller = false
    hasCloseButton = true
    local p = vgui.Create("DTextEntry", parent)
    p:SetPaintBackground(false)
    p.lerpValue = 0
    p.canEdit = false

    p.Paint = function(s, w, h)
        if not shouldMakeSmaller then
            s.lerpValue = 1
        end

        local lerpPixelValue = (1 - s.lerpValue) * 125
        draw.RoundedBox(4, lerpPixelValue, 0, w - lerpPixelValue, h, Color(40, 40, 45, 255))

        --Draw ghost text
        if s:GetText() == "" and not s:IsEditing() then
            if s.canEdit then
                draw.SimpleText(ghostText, BU3.UI.Fonts["small_reg"], lerpPixelValue + 5, (h / 2) - 2, Color(149, 152, 154), 0, 1)
            else
                draw.SimpleText(ghostText, BU3.UI.Fonts["small_reg"], lerpPixelValue + 5, (h / 2) - 2, Color(149 * 0.5, 152 * 0.5, 154 * 0.5), 0, 1)
            end
        end

        if s.canEdit then
            s:DrawTextEntryText(Color(149, 152, 154), Color(255, 152, 154), Color(255, 255, 255))
        else
            s:DrawTextEntryText(Color(149 * 0.5, 152 * 0.5, 154 * 0.5), Color(255, 152, 154), Color(255, 255, 255))
        end

        if s:IsHovered() or s:IsEditing() or s:GetText() ~= "" then
            s.lerpValue = Lerp(15 * FrameTime(), s.lerpValue, 1)
        else
            s.lerpValue = Lerp(15 * FrameTime(), s.lerpValue, 0)
        end
    end

    p.AllowInput = function(self, stringValue) return not self.canEdit end

    function p:PerformLayout()
    end

    function p:PerformLayout(width, height)
        if hasCloseButton then
            self.b:SetPos(width - height, 0)
            self.b:SetSize(height, height)
        end

        self:SetFontInternal(BU3.UI.Fonts["small_reg"])
    end

    if hasCloseButton then
        --Now create the clear button
        local b = vgui.Create("DButton", p)
        b:SetText("")

        b.DoClick = function()
            if p.canEdit then
                onRefresh(p:GetText())
            end
        end

        b.Paint = function(s, w, h)
            if p.canEdit then
                surface.SetDrawColor(Color(149, 152, 154))
            else
                surface.SetDrawColor(Color(149 * 0.5, 152 * 0.5, 154 * 0.5))
            end

            surface.SetMaterial(BU3.UI.Materials.refresh)
            surface.DrawTexturedRect(7, 7, w - 14, h - 14)
        end

        p.b = b
    end

    return p
end

--Create a textbox with an x to clear text and a ghost button
function BU3.UI.Elements.CreateMultilineTextEntry(ghostText, parent, hasCloseButton)
    local p = vgui.Create("DTextEntry", parent)
    p:SetPaintBackground(false)
    p.lerpValue = 0
    p:SetUpdateOnType(true)
    p:SetMultiline(true)

    p.Paint = function(s, w, h)
        if not shouldMakeSmaller then
            s.lerpValue = 1
        end

        local lerpPixelValue = (1 - s.lerpValue) * 125
        draw.RoundedBox(4, lerpPixelValue, 0, w - lerpPixelValue, h, Color(40, 40, 45, 255))

        --Draw ghost text
        if s:GetText() == "" and not s:IsEditing() then
            draw.SimpleText(ghostText, BU3.UI.Fonts["small_bold"], 3, 3, Color(149, 152, 154), 0, 0)
        end

        s:DrawTextEntryText(Color(149, 152, 154), Color(255, 152, 154), Color(255, 255, 255))
    end

    function p:PerformLayout()
    end

    function p:PerformLayout(width, height)
        if hasCloseButton then
            self.b:SetPos(width - 41, 0)
            self.b:SetSize(41, 41)
        end

        self:SetFontInternal(BU3.UI.Fonts["small_bold"])
    end

    if hasCloseButton then
        --Now create the clear button
        local b = vgui.Create("DButton", p)
        b:SetText("")

        b.DoClick = function()
            p:SetText("")
        end

        b.Paint = function(s, w, h)
            surface.SetDrawColor(Color(149, 152, 154))
            surface.SetMaterial(BU3.UI.Materials.iconClose)
            surface.DrawTexturedRect(7, 7, w - 14, h - 14)
        end

        p.b = b
    end

    return p
end

--A standard button with curves that is blue
function BU3.UI.Elements.CreateStandardButton(text, parent, onClick)
    local p = vgui.Create("DButton", parent)
    p:SetText("")

    p.Paint = function(s, w, h)
        if not s:IsHovered() then
            draw.RoundedBox(4, 0, 0, w, h, Color(45, 220, 255, 255))
        else
            draw.RoundedBox(4, 0, 0, w, h, Color(39 * 1.1, 121 * 1.1, 189 * 1.1, 255))
        end

        --Draw text
        draw.SimpleText(text, BU3.UI.Fonts["small_bold"], w / 2, h / 2, Color(255, 255, 255), 1, 1)
    end

    p.DoClick = onClick

    return p
end

--Create a navbar with buttons etc.
function BU3.UI.Elements.CreateNavbar(parent)
    local p = vgui.Create("DPanel", parent)
    p:Dock(TOP)
    p:SetTall(54)

    p.Paint = function(s, w, h)
        --Draw background
        surface.SetDrawColor(Color(46, 46, 46))
        surface.DrawRect(0, 0, w, h)
    end

    p.buttons = {}
    local buttonOffset = 0 --The offset of the button, vertically positive

    --first deselects all buttons, then selects the right one
    function p:SelectButton(buttonname)
        for k, v in pairs(self.buttons) do
            v.selected = false
        end

        for k, v in pairs(self.buttons) do
            if v.name == buttonname then
                v.selected = true
                self.selectedButton = v
            end
        end
    end

    local function registerButton(name, icon, canPress, onClick)
        local b = vgui.Create("DButton", p)
        b.icon = icon
        b.name = name
        b:Dock(LEFT)
        b:SetWide(196)
        b:SetPos(0, buttonOffset)
        b.canPress = canPress

        b.DoClick = function(self)
            if self.canPress then
                onClick(self)
            end
        end

        b.hoverAmount = -10 --Between 0 and 100
        b.selected = false
        b.selectedAmount = 0
        b:SetText("")

        b.Paint = function(s, w, h)
            if (s.selectedAmount) then
                surface.SetDrawColor(Color(45, 220, 255, 255))
                surface.DrawRect(w / 2 - (w * s.selectedAmount) / 2 - 4, h - 2, (w - 8) * s.selectedAmount, 2)
            end

            local tx, _ = draw.SimpleText(string.upper(name), "XeninUI.TextEntry", w / 2, h / 2, (s:IsHovered() or s.selected) and Color(45, 220, 255) or Color(255, 255, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            --Draw icon
            surface.SetDrawColor((s:IsHovered() or s.selected) and Color(45, 220, 255) or Color(255, 255, 255, 170))
            surface.SetMaterial(s.icon)
            surface.DrawTexturedRect(w / 2 - tx / 2 - 32, h / 2 - 12, 24, 24)
        end

        --Animation logic
        b.Think = function(s)
            if s:IsHovered() then
                s.hoverAmount = Lerp(10 * FrameTime(), s.hoverAmount, 1)
            else
                s.hoverAmount = Lerp(10 * FrameTime(), s.hoverAmount, -.1)
            end

            if s.selected then
                s.selectedAmount = Lerp(10 * FrameTime(), s.selectedAmount, 1)
            else
                s.selectedAmount = Lerp(10 * FrameTime(), s.selectedAmount, -.1)
            end
        end

        buttonOffset = buttonOffset + 75
        table.insert(p.buttons, b)
    end

    --Add the buttons for all the panel
    registerButton("stats", BU3.UI.Materials.iconHome, true, function(s)
        p:SelectButton("stats")
        BU3.UI.ContentFrame:LoadPage("stats")
    end)

    registerButton("inventory", BU3.UI.Materials.iconCube, true, function(s)
        p:SelectButton("inventory")
        BU3.UI.ContentFrame:LoadPage("inventory")
    end)

    registerButton("store", BU3.UI.Materials.iconBag, true, function(s)
        p:SelectButton("store")
        BU3.UI.ContentFrame:LoadPage("shop")
    end)
	
	registerButton("crafting", Material("asap/craft_icon"), true, function(s)
        p:SelectButton("crafting")
        BU3.UI.ContentFrame:LoadPage("crafting")
    end)

    --registerButton("trade", BU3.UI.Materials.iconSwap, true, function(s) p:SelectButton("trade") end)
    --registerButton("market", BU3.UI.Materials.iconPricetag, true, function(s) p:SelectButton("market") end)
    --Now reverse
    buttonOffset = 750 - 75

    if table.HasValue(BU3.Config.AdminRanks, LocalPlayer():GetUserGroup()) then
        buttonOffset = buttonOffset - (75 * 2)

        registerButton("settings", BU3.UI.Materials.iconGear, true, function(s)
            p:SelectButton("settings")

            if IsValid(BU3.UI.ContentFrame) then
                BU3.UI.ContentFrame:LoadPage("settings")
            end
        end)
    end

    buttonOffset = buttonOffset - (75 * 2)

    return p
end

--Creates a content frame, with functions to load, unload or transistions scenes/pages on it
function BU3.UI.Elements.CreateContentFrame(parent)
    local contentFrame = vgui.Create("DPanel", parent)
    contentFrame:Dock(FILL)

    contentFrame.Paint = function(s, w, h)
        draw.RoundedBoxEx(16, 0, 0, w, h, Color(26, 26, 26), false, false, false, true)
    end

    contentFrame.loadedPage = nil

    function contentFrame:LoadPage(pagename, metaData)
        if istable(self.loadedPage) and self.loadedPage.Unload then
            self.loadedPage:Unload(self)
        end

        self.loadedPageName = pagename
        self.loadedPage = BU3.UI.GetPage(pagename)

        --Sanity check
        if self.loadedPage == false then
            error("Failed to load page " .. pagename .. ", the page does not exist!")
        end

        self.loadedPage:Load(self, metaData)
    end

    --These two functions create a fake loader that covers the entire contentframe panel
    function contentFrame:ShowLoader()
        local p = vgui.Create("DPanel", contentFrame)
        p:SetPos(0, 0)
        p:SetSize(900 - 75, 750)
        p:SetDrawOnTop(true)

        p.Paint = function(s, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(27, 27, 32))
            surface.SetDrawColor(Color(255, 255, 255, 255))
            surface.SetMaterial(BU3.UI.Materials.loading)
            surface.DrawTexturedRectRotated(w / 2, h / 2, 200, 200, (CurTime() * -500) % 360)
        end

        self.loader = p
    end

    function contentFrame:HideLoader()
        if self.loader ~= nil then
            self.loader:Remove()
            self.loader = nil
        end
    end

    return contentFrame
end

net.Receive("BU3:PromptUser", function()
    local title = net.ReadString()
    local body = net.ReadString()
    BU3.UI.ContentFrame:HideLoader()
    local shouldReturnToSettings = net.ReadBool()

    if shouldReturnToSettings then
        BU3.UI.ContentFrame:LoadPage("settings")
    end

    --Create prompt
    BU3.UI.Elements.Prompt(title, body)
end)

--[[-------------------------------------------------------------------------
UI Logic
---------------------------------------------------------------------------]]
BU3.UI._MENU_OPEN = false
BU3.UI._MENU_ACTIVE = true --If false, this will not allow people to press any buttons (usefull for animations)

--Returns if the menu is open
function BU3.UI.MenuOpen()
    return BU3.UI._MENU_OPEN
end

--Return is the menu is interactable
function BU3.UI.MenuActive()
    return BU3.UI._MENU_ACTIVE
end

--Sets if it window is open or not
function BU3.UI.SetMenuOpen(bool)
    BU3.UI._MENU_OPEN = bool
end

--Sets if you can interact with the menu or not
function BU3.UI.SetMenuActive(bool)
    BU3.UI._MENU_ACTIVE = bool
end

--Calling this function will open the menu
function BU3.UI.CreateMenu()
    if BU3.UI.MenuOpen() then return end --Sanity check
    BU3.UI.SetMenuOpen(true)
    --Now create the frame
    local frame = vgui.Create("DFrame")
    frame:SetSize(900, 750)
    frame:Center()
    frame:MakePopup()

    frame.Close = function(s)
        s:Remove()
        BU3.UI.SetMenuOpen(false)
    end

    --Now devide the winow, one into the navbar, and the other for the content frame
    local navbar = BU3.UI.Elements.CreateNavbar(frame)
    navbar:SetPos(0, 0)
    navbar:SelectButton("inventory") --Set default button to "home"
    --Content frame
    BU3.UI.ContentFrame = BU3.UI.Elements.CreateContentFrame(frame)
    BU3.UI.ContentFrame:SetPos(75, 0)
    BU3.UI.ContentFrame:LoadPage("inventory")
    BU3.UI.ContentFrame.NavBar = navbar
    BU3.UI.ContentFrame.MainFrame = frame
end

local PANEL = {}

function PANEL:Init()
    BU3.UI.SetMenuOpen(true)
    self:Dock(FILL)
    --Now devide the winow, one into the navbar, and the other for the content frame
    local navbar = BU3.UI.Elements.CreateNavbar(self)
    navbar:SelectButton("inventory") --Set default button to "home"
    --Content frame
    BU3.UI.ContentFrame = BU3.UI.Elements.CreateContentFrame(self)
    BU3.UI.ContentFrame:LoadPage("inventory")
    BU3.UI.ContentFrame.NavBar = navbar
    BU3.UI.ContentFrame.MainFrame = self
end

function PANEL:OnRemove()
    BU3.UI.SetMenuOpen(false)
end

function PANEL:Paint(w, h)
end

vgui.Register("Unbox.Wrapper", PANEL, "DPanel")

net.Receive("BU3:OpenGUI", function()
    if (LocalPlayer():InArena()) then return end

    if aMenu.Base then
        aMenu.Base.Settings:DoClick()
    else
        aMenu.Base = vgui.Create("aMenuBase")
        aMenu.Base:SetCategory("Unbox")
    end
end)

--Anounce a winner
net.Receive("BU3:UnboxAnounce", function()
    local itemID = net.ReadInt(32)
    local ply = net.ReadEntity()
    local item = BU3.Items.Items[itemID]
    local borderColor = item.itemColorCode or 1
    local borderColorRGB = BU3.Items.RarityToColor[borderColor]
    chat.AddText(Color(255, 255, 255, 255), "[UNBOX] ", team.GetColor(ply:Team()), ply:Name(), Color(255, 255, 255, 255), " Just unboxed a ", borderColorRGB, item.name, "!")
end)

hook.Add("OnPopulateF4Categories", "Unbox.Tab", function(pnl)
    pnl.UnboxTab = vgui.Create("Unbox.Wrapper", pnl)

    pnl:AddCat("Inventory", Material("asapf4/unbox.png"), pnl.UnboxTab, {Color(11, 61, 96), Color(45, 220, 255)})
end)
