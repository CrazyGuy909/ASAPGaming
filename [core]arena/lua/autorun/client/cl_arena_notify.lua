local back = surface.GetTextureID("ui/asap/notify")
local soundQueue
local colors = {
    [1] = Color(225, 225, 225),
    [2] = Color(54, 196, 255),
    [3] = Color(240, 109, 12),
    [4] = Color(240, 12, 221),
    [5] = Color(240, 216, 12),
    [6] = Color(26, 26, 26)
}

local notifyQueue = {}
local inDuration = .15
local doReturn = false
local hasFinished = true
local progress = inDuration
local colorid = 1
local message = ""
local stayDuration = 1

local function initMsg(msg, color)
    hasFinished = false
    doReturn = false
    stayDuration = 1
    progress = inDuration
    colorid = color
    message = msg
    if soundQueue then
        surface.PlaySound(soundQueue)
        surface.PlaySound(soundQueue)
        surface.PlaySound(soundQueue)
        soundQueue = nil
    end
end

hook.Add("HUDPaint", "Arena.NotifyMaster", function()
    if (hasFinished) then return end

    if (not doReturn and progress > 0) then
        progress = progress - FrameTime()
    elseif (stayDuration >= 0) then
        stayDuration = stayDuration - FrameTime()

        if (stayDuration <= 0) then
            progress = 0
            doReturn = true
        end
    elseif (doReturn) then
        progress = progress + FrameTime()

        if (progress >= inDuration) then
            hasFinished = true

            if (#notifyQueue > 0) then
                initMsg(notifyQueue[1].msg, notifyQueue[1].color)
                table.remove(notifyQueue, 1)

                return
            end
        end
    end

    local y = 172 - (progress / inDuration) * 32
    surface.SetTexture(back)
    surface.SetDrawColor(ColorAlpha(colors[colorid], 255 - math.Clamp(progress / inDuration, 0, 1) * 150))
    surface.DrawTexturedRect(ScrW() / 2 - 256, y, 512, 128)
    draw.SimpleText(message, "Arena.Medium", ScrW() / 2, y + 78, ColorAlpha(color_white, 255 - math.Clamp(progress / inDuration, 0, 1) * 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end)

net.Receive("ASAP.Arena:Notify", function()
    local msg = net.ReadString()
    local color = net.ReadInt(4)

    if (not hasFinished) then
        table.insert(notifyQueue, {
            msg = msg,
            color = color
        })
    else
        initMsg(msg, color)
    end
end)

local meta = FindMetaTable("Player")

function meta:ShowMessage(msg, clr)
    if (not hasFinished) then
        table.insert(notifyQueue, {
            msg = msg,
            color = clr
        })
    else
        initMsg(msg, clr)
    end
end

local killAmount = 0
net.Receive("ASAP.Arena:NotifyDeath", function()
    local isHeadshot = net.ReadBool()
    killAmount = killAmount + 1
    if (killAmount == 2) then
        soundQueue = "arena/double_kill.mp3"
        LocalPlayer():ShowMessage("Double Kill", 1)
    elseif (killAmount == 3) then
        soundQueue = "arena/triple_kill.mp3"
        LocalPlayer():ShowMessage("Triple Kill", 2)
    elseif (killAmount == 5) then
        soundQueue = "arena/unstoppable.mp3"
        LocalPlayer():ShowMessage("Unstoppable", 3)
    elseif (killAmount == 8) then
        soundQueue = "arena/gman_is_really_impressed.mp3"
        LocalPlayer():ShowMessage("LEGENDARY", 3)
    elseif (isHeadshot) then
        soundQueue = "arena/headshot.mp3"
        LocalPlayer():ShowMessage("Headshot", 3)
    end
    timer.Remove("Arena.KillCounter")
    timer.Create("Arena.KillCounter", 10, 1, function()
        killAmount = 0
    end)
end)