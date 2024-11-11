BATTLEPASS:CreateFont("Party.Help.Question", 24)
BATTLEPASS:CreateFont("Party.Help.Answer", 18)

local PANEL = {}

function PANEL:Init()
	local ply = LocalPlayer()

	self.layout = vgui.Create("DListLayout", self)
	self.layout:Dock(FILL)
	self.layout:DockMargin(24, 16, 16, 12)

	self:AddInfo("What is this?", {
	"The Battle Pass system is similar to other Battle Pass systems in other games.",
	"Complete challenges in the 'Challenges' tab to earn stars, once you have 10 stars you level up",
	"New Challegens get added once a week after battle pass is released"
	})
  self:AddInfo("What rewards?", {
    "In the 'rewards' tab you can see which rewards you get in each tier",
    { "The blue row is free items, everyone can unlock those by leveling up", Color(41, 128, 185) },
    { "The golden row is paid items, if you purchase the Battle Pass you can unlock the items in this row", Color(230, 176, 65, 160) }
  })
	self:AddInfo("How do I buy?", {
		"You can buy the Battle Pass by pressing 'Purchase Battle Pass' button in the 'Battle Pass' tab at the lower bottom left",
		"The Battle Pass costs 1000 credits, which you can purchase on our website",
    "If you don't have enough credits, there is an option to go to the website upon pressing the 'Purchase Battle Pass' button"
	})
end

function PANEL:AddInfo(questionStr, answers)
	local question = self.layout:Add("DLabel")
	question:Dock(TOP)
	question:DockMargin(0, 8, 0, 4)
	question:SetText(questionStr)
	question:SetFont("Party.Help.Question")
	question:SetTextColor(Color(235, 235, 235))

	for i, v in ipairs(answers) do
		local answer = self.layout:Add("DLabel")
		answer:Dock(TOP)
		answer:DockMargin(8, 0, 0, i == #answers and 8 or 0)
		answer:SetFont("Party.Help.Answer")
		answer:SetTextColor(Color(160, 160, 160))
	
		if (istable(v)) then
			answer:SetText("- " .. v[1])
			answer:SetTextColor(v[2])
		else
			answer:SetText("- " .. v)
		end
	end
end
vgui.Register("BATTLEPASS.Help", PANEL)