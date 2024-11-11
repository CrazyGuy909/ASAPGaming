-- Configuration variables
local EVENT_CHAT_CMD = "/event"
local EVENT_CHAT_TAG = "[Event]"
local EVENT_CHAT_TAG_COLOR = Color(255, 255, 0) -- Yellow color
local ALLOWED_USERGROUP = "admin" -- The usergroup allowed to use the command

if SERVER then
    util.AddNetworkString("event_chat")

    hook.Add("PlayerSay", "event_chat", function(ply, text)
        if string.lower(text) == EVENT_CHAT_CMD then
            return "" -- Prevents the command from being displayed in chat
        end

        if string.StartsWith(text, EVENT_CHAT_CMD .. " ") then
            if not ply:IsUserGroup(ALLOWED_USERGROUP) then
                ply:ChatPrint("You do not have permission to use this command!")
                return ""
            end

            local msg = string.Trim(string.sub(text, string.len(EVENT_CHAT_CMD) + 2)) -- Extract the message
            if msg == "" then return end -- Ignore empty messages

            net.Start("event_chat")
            net.WriteString(EVENT_CHAT_TAG)
            net.WriteColor(EVENT_CHAT_TAG_COLOR)
            net.WriteString(ply:Nick())
            net.WriteString(msg)
            net.Broadcast() -- Sends the message to all clients
            return "" -- Prevents the command and message from being displayed in chat
        end
    end)
else
    net.Receive("event_chat", function()
        local tag = net.ReadString()
        local tagColor = net.ReadColor()
        local playerName = net.ReadString()
        local message = net.ReadString()
        
        -- Display the message in the chat with the appropriate formatting
        chat.AddText(tagColor, tag, " ", Color(255, 255, 255), playerName, ": ", message)
    end)
end