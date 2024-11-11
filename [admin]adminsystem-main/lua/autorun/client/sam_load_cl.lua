SAM = SAM or {}

-- Include
include("sam/server/configs/sam_default_config.lua")
include("sam/client/sam_general_client.lua")

-- Module Loader
local to_include = file.Find("sam/modules/*.lua", "LUA")
for k,v in pairs(to_include) do
    include("sam/modules/"..v)
end
