-- Define a new panel for the Skills tab
local PANEL = {}

-- Initialize the panel
function PANEL:Init()
    -- Call the function to execute actions when the panel is loaded
    self:OnPanelLoaded()
end

-- Define the function to execute when the panel is loaded
function PANEL:OnPanelLoaded()
    -- Run the command on the player
    LocalPlayer():ConCommand("skills")
    -- You can add more actions or functions here
end

-- Register the PANEL as a VGUI element
vgui.Register("Skills", PANEL, "DPanel")
