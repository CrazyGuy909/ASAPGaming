--aMenu (1.6.1) by arie - STEAM_0:0:22593800
--Main Table
aMenu = {}
--The overall colour of aMenu (uncomment to enable, make sure only one is active at a time though!)
--aMenu.Color 				= Color(66, 139, 202) 	--Blue
aMenu.Color = Color(36, 36, 36) --Red
--aMenu.Color 				= Color(26, 188, 156)	--Turquoise
--aMenu.Color 				= Color(92, 184, 92)	--Green
--aMenu.Color 				= Color(91, 192, 222)	--Light blue
--aMenu.Color 				= Color(228, 100, 75)	--Orange



aMenu.SubTitle = "Galaxium"
--Do we show VIP jobs in the jobs tab?
aMenu.ShowVIP = false
--Do we show all weapons in the entity-based tabs (entities, weapons, shipments etc.) even if we can't afford them?
aMenu.ShowAllEntities = true
--Sort categories in jobs and entity tabs according to their default sortOrder value?
aMenu.SortOrder = true
-----Disabling main tabs stuff
--In order to disable a tab, change its value from true to false and change map
aMenu.AllowedTabs = {}
aMenu.AllowedTabs["Dashboard"] = true
aMenu.AllowedTabs["Jobs"] = true
aMenu.AllowedTabs["Entities"] = true
aMenu.AllowedTabs["Weapons"] = false
aMenu.AllowedTabs["Shipments"] = true
aMenu.AllowedTabs["Ammo"] = true
aMenu.AllowedTabs["Discord"] = false
aMenu.AllowedTabs["Website"] = false
aMenu.AllowedTabs["Rules"] = true
aMenu.AllowedTabs["Food"] = false
aMenu.AllowedTabs["Donate"] = true
aMenu.AllowedTabs["Workshop"] = true
aMenu.AllowedTabs["Skills"] = true
aMenu.AllowedTabs["Settings"] = true
-----Dashboard stuff
--Put the names of the user ranks that you wish to appear inside the online staff list here, alongside their display names.
--For example, listing "superadmin" here will not only make users with that rank show up in the staff 
--list, but also show their rank as "Super Admin" rather than "superadmin"
aMenu.StaffGroups = {}
aMenu.StaffGroups["owner"] = "Owner"
aMenu.StaffGroups["staffmanager"] = "Staff Manager"
aMenu.StaffGroups["superadmin"] = "Super Admin"
aMenu.StaffGroups["senioradmin"] = "Senior Admin"
aMenu.StaffGroups["admin"] = "Admin"
aMenu.StaffGroups["jradmin"] = "Junior Admin"
aMenu.StaffGroups["moderator"] = "Moderator"
aMenu.StaffGroups["trialmoderator"] = "Trial Moderator"
-----Extra tabs stuff
--All web addresses have to start with either http:// or https://
--Leave variable blank as "" if you don't want a certain button
--Website link
aMenu.DiscordLink = "https://discord.gg/RvwksDnBHH"
aMenu.WebsiteLink = "https://discord.gg/RvwksDnBHH"
--Donation link
aMenu.DonationLink = "https://discord.gg/RvwksDnBHH"
--Workshop collection link
aMenu.WorkshopLink = "https://discord.gg/RvwksDnBHH"
-----Descriptions stuff
aMenu.Descriptions = {}
--If you wish a certain item to have a description when selected, you can set it here.
--Works for entities, weapons, shipments and ammo.
--Usage: aMenu.Descriptions["entitynamehere"] = [[description here]] 
aMenu.Descriptions["Overclocked Printer"] = [[This is a printer that has been overclocked to be more efficient.
											It will produce much greater sums of money at a faster rate - but at an increase to the original price.]]
aMenu.Descriptions["P228"] = [[A low-recoil firearm with a high rate of fire, the P228 is a relatively inexpensive choice against armored opponents.]]
-----Rules stuff
--Do we want to use a webpage for the rules? Chances are you'll want to so set this to true and link to your webpage below
aMenu.UseHTMLRules = false
--Link to a rules.txt file if the above is set to false, if not link to your normal rules webpage
aMenu.RulesLink = "https://discord.gg/RvwksDnBHH"
--So unless you want to go ahead and use your own rules for the rules page feel free to leave this as it is.
--However, if you DO want to use your own rules, set the variable below to false and enter your rules in the rules variable.
aMenu.UseLink = true
aMenu.Rules = [[

--General Rules
	1. Don't RDM other players
	2. Don't annoy the admins
	3. Use common sense
]]
-----Misc stuff
--Do we display a list of weapons in each job's description box?
aMenu.DisplayWeapons = false
--Do we show the theme colour in the preview box on the right when we click on a job?
aMenu.PreviewThemeColour = true
--Do we preview the job's full colour in the pie chart's key?
aMenu.ChartFullColour = false
--Blur behind the F4 menu?
aMenu.BlurBackground = true
-----Levels stuff
--What colour do we want the job's level bar in the jobs list to be if we can't be the job?
aMenu.LevelAcceptColor = aMenu.Color
--What colour do we want the job's level bar in the jobs list to be if we can be the job?
aMenu.LevelDenyColor = Color(31, 31, 31)

-----Fonts 
--Feel free to edit if you need to
surface.CreateFont("aMenuJobCat", {
    font = "Montserrat",
    size = 42,
    weight = 500
})

surface.CreateFont("aMenuTitle", {
    font = "Montserrat",
    size = 32,
    weight = 500
})

surface.CreateFont("aMenuSubTitle", {
    font = "Montserrat",
    size = 24,
    weight = 500
})

surface.CreateFont("aMenuBold", {
    font = "Montserrat",
    size = 22,
    weight = 900
})

surface.CreateFont("aMenuJob", {
    font = "Montserrat",
    size = 28,
    weight = 500
})

surface.CreateFont("aMenu22", {
    font = "Montserrat",
    size = 22,
    weight = 500
})

surface.CreateFont("aMenu20", {
    font = "Montserrat",
    size = 20,
    weight = 500
})

surface.CreateFont("aMenu19", {
    font = "Montserrat",
    size = 19,
    weight = 500
})

surface.CreateFont("aMenu18", {
    font = "Montserrat",
    size = 18,
    weight = 500
})

surface.CreateFont("aMenu14", {
    font = "Montserrat",
    size = 15,
    weight = 500
})

surface.CreateFont("aMenu10", {
    font = "Montserrat",
    size = 10,
    weight = 500
})

aMenu.JobColor = {Color(255, 69, 7), Color(255, 126, 48)}
aMenu.HomeColor = {Color(33, 110, 20), Color(38, 200, 72)}
aMenu.EntitiesColor = {Color(14, 89, 140), Color(0, 157, 200)}
aMenu.ShipmentsColor = {Color(82, 16, 97), Color(185, 0, 206)}
aMenu.SkillsColor = {Color(82, 16, 97), Color(185, 0, 206)}
aMenu.AmmoColor = {Color(125, 95, 15), Color(225, 220, 0)}
aMenu.RulesColor = {Color(65, 50, 35), Color(120, 93, 53)}
aMenu.DonateColor = {Color(125, 15, 50), Color(190, 27, 110)}
aMenu.WorkshopColor = {Color(23, 83, 72), Color(50, 190, 160)}
aMenu.SettingsColor = {Color(100, 100, 100), Color(255, 255, 255)}
-----Materials 
--if somehow you can't download them automatically when joining a server then the collection can be found at...
--http://steamcommunity.com/sharedfiles/filedetails/?id=728328781
--Oh yeah and don't touch anything below this line unless you know what you're doing
aMenu.HomeButton = Material("asapf4/home.png")
aMenu.CommandsButton = Material("asapf4/commands.png")
aMenu.JobsButton = Material("asapf4/jobs.png")
aMenu.EntitiesButton = Material("asapf4/entities.png")
aMenu.ShipmentsButton = Material("asapf4/shipments.png")
aMenu.RulesButton = Material("asapf4/rules.png")
aMenu.AmmoButton = Material("asapf4/ammo.png")
aMenu.WeaponsButton = Material("amenu/weapons.png")
aMenu.FoodButton = Material("amenu/food.png")
aMenu.WebButton = Material("amenu/website.png")
aMenu.DiscordButton = Material("amenu/website.png")
aMenu.DonateButton = Material("asapf4/donate.png")
aMenu.WorkshopButton = Material("asapf4/workshop.png")
aMenu.SettingsButton = Material("asapf4/settings.png")
aMenu.GangButton = Material("amenu/players.png")
aMenu.ProfileButton = Material("amenu/profile.png")
aMenu.MessageButton = Material("amenu/message.png")

aMenu.PaintScroll = function(panel)
    local scr = panel:GetVBar()

    scr.Paint = function()
        draw.RoundedBox(4, 0, 0, scr:GetWide(), scr:GetTall(), Color(62, 62, 62))
    end

    scr.btnUp.Paint = function() end
    scr.btnDown.Paint = function() end

    scr.btnGrip.Paint = function()
        draw.RoundedBox(6, 2, 0, scr.btnGrip:GetWide() - 4, scr.btnGrip:GetTall() - 2, aMenu.Color)
    end
end

include("amenu/cl_masterpanel.lua")
include("amenu/cl_dashboard.lua")
include("amenu/cl_entspanel.lua")
include("amenu/cl_jobspanel.lua")
include("amenu/cl_websites.lua")
include("amenu/cl_rules.lua")
include("amenu/cl_skillspanel.lua")
include("amenu/cl_dailyreward.lua")
include("amenu/cl_settings.lua")

timer.Simple(0.8, function()
    function DarkRP.openF4Menu()
        if aMenu.Base then
            aMenu.Base:Remove()
            aMenu.Base = nil
        end

        local disallow = hook.Run("F4MenuOpen")
        if (disallow == false) then return end
        aMenu.Base = vgui.Create("aMenuBase")
        gui.InternalMousePressed(MOUSE_LEFT)
        net.Start("F4.Magic")
        net.WriteBool(true)
        net.SendToServer()
        hook.Add("CreateMove", aMenu.Base, function(s, cmd) end) --            cmd:ClearMovement()
    end

    function DarkRP.closeF4Menu()
        if aMenu.Base then
            aMenu.Base:Remove()
            aMenu.Base = nil
            net.Start("F4.Magic")
            net.WriteBool(false)
            net.SendToServer()
        end
    end

    function DarkRP.toggleF4Menu()
        net.Start("F4.Magic")
        net.WriteBool(aMenu.Base == nil)
        net.SendToServer()

        if aMenu.Base == nil then
            DarkRP.openF4Menu()
        else
            DarkRP.closeF4Menu()
        end
    end

    GAMEMODE.ShowSpare2 = DarkRP.toggleF4Menu

    timer.Simple(3, function()
        DarkRP.openF4Menu()

        timer.Simple(1, function()
            DarkRP.closeF4Menu()
        end)
    end)
end)

MsgC(Color(240, 173, 78), "[aMenu] ", Color(210, 210, 210), "Loaded aMenu by ", Color(240, 173, 78), "arie ", Color(210, 210, 210), "(STEAM_0:0:22593800)\n")