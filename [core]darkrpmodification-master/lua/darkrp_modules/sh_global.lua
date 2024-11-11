-- Configuration variables
local GLOBAL_CHAT_CMD = "/global"
local GLOBAL_CHAT_TAG = "[Global]"
local GLOBAL_CHAT_TAG_COLOR = Color(255, 255, 255) -- White color

if SERVER then
    util.AddNetworkString("global_chat")

    hook.Add("PlayerSay", "global_chat", function(ply, text)
        if string.lower(text) == GLOBAL_CHAT_CMD then
            return "" -- Prevents the command from being displayed in chat
        end

        if string.StartsWith(text, GLOBAL_CHAT_CMD .. " ") then
            local msg = string.Trim(string.sub(text, string.len(GLOBAL_CHAT_CMD) + 2)) -- Extract the message
            if msg == "" then return end -- Ignore empty messages

            net.Start("global_chat")
            net.WriteString(GLOBAL_CHAT_TAG)
            net.WriteColor(GLOBAL_CHAT_TAG_COLOR)
            net.WriteString(ply:Nick())
            net.WriteString(msg)
            net.Broadcast() -- Sends the message to all clients
            return "" -- Prevents the command and message from being displayed in chat
        end
    end)
else
    net.Receive("global_chat", function()
        local tag = net.ReadString()
        local tagColor = net.ReadColor()
        local playerName = net.ReadString()
        local message = net.ReadString()
        
        -- Display the message in the chat with the appropriate formatting
        chat.AddText(tagColor, tag, " ", Color(255, 255, 255), playerName, ": ", message)
    end)
end