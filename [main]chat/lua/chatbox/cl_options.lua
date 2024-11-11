local options = {
	{
		catname = "general",
		ops = {
			{type = TYPE_NUMBER, name = "chat_x", cvar = "lounge_chat_x", min = 0, max = 1},
			{type = TYPE_NUMBER, name = "chat_y", cvar = "lounge_chat_y", min = 0, max = 1},
			{type = TYPE_NUMBER, name = "chat_width", cvar = "lounge_chat_w", min = 0.1, max = 1},
			{type = TYPE_NUMBER, name = "chat_height", cvar = "lounge_chat_h", min = 0.1, max = 1},
			{type = TYPE_NUMBER, name = "time_before_messages_hide", cvar = "lounge_chat_hidetime", min = 1, max = 300},
			{type = TYPE_BOOL, name = "show_timestamps", cvar = "lounge_chat_timestamps"},
			{type = TYPE_BOOL, name = "dont_scroll_chat_while_open", cvar = "lounge_chat_no_openscroll"},
			{
				type = "action",
				name = function()
					local siz = 0

					local pa = LOUNGE_CHAT.ImageDownloadFolder .. "/"
					local fil = file.Find(pa .. "*.png", "DATA")
					for _, f in pairs (fil) do
						siz = siz + file.Size(pa .. f, "DATA")
					end

					return LOUNGE_CHAT.Lang("clear_downloaded_images", string.NiceSize(siz))
				end
			},
		}
	},
	{
		catname = "display",
		ops = {
			{type = TYPE_BOOL, name = "hide_images", cvar = "lounge_chat_hide_images"},
			{type = TYPE_BOOL, name = "hide_avatars", cvar = "lounge_chat_hide_avatars"},
			{type = TYPE_BOOL, name = "use_rounded_avatars", cvar = "lounge_chat_roundavatars"},
			{type = TYPE_BOOL, name = "disable_flashes", cvar = "lounge_chat_disable_flashes"},
			{type = TYPE_BOOL, name = "no_url_parsing", cvar = "lounge_chat_no_url_parsing"},
			{type = TYPE_BOOL, name = "autoload_external_images", cvar = "lounge_chat_imgurl_autoload"},
			{type = TYPE_BOOL, name = "hide_options_button", cvar = "lounge_chat_hide_options"},
		}
	},
}

local matClose = Material("shenesis/chat/close.png", "noclamp smooth")

function LOUNGE_CHAT:ShowOptions()
	if (IsValid(_LOUNGE_CHAT_OPTIONS)) then
		_LOUNGE_CHAT_OPTIONS:Remove()
	end

	local scale = math.Clamp(ScrH() / 1080, 0.7, 1)
	local wi, he = 600 * scale, 700 * scale

	local pnl = vgui.Create("nebula.frame")
	pnl:SetSize(wi, he)
	pnl:Center()
	pnl:SetTitle("Chat Options")
	pnl:MakePopup()
	pnl.m_bF4Down = true
	pnl.Think = function(me)
		if (input.IsKeyDown(KEY_ESCAPE)) then
			me:Close()

			gui.HideGameUI()
			timer.Simple(0, gui.HideGameUI)
		end
	end
	pnl.Close = function(me)
		if (me.m_bClosing) then
			return end

		me.m_bClosing = true
		me:AlphaTo(0, self.Anims.FadeOutTime, 0, function()
			me:Remove()
		end)
	end
	_LOUNGE_CHAT_OPTIONS = pnl

		local th = 48 * scale
		local m = th * 0.25
		local m5 = m * 0.5

		local body = vgui.Create("DScrollPanel", pnl)
		self.PaintScroll(body)
		body:SetDrawBackground(false)
		body:GetCanvas():DockPadding(m5, m5, m5, m5)
		body:Dock(FILL)

		for _, cat in ipairs (options) do
			local lbl = self.Label(self.Lang(cat.catname), "LOUNGE_CHAT_24", self.Color("text"), body)
			lbl:Dock(TOP)
			lbl:DockMargin(0, 0, 0, m5)

			for i, op in ipairs (cat.ops) do
				local name = isfunction(op.name) and op.name() or op.name
				local mu, md = 0, 0

				local el
				if (op.type == TYPE_NUMBER) then
					local lbl = self.Label(self.Lang(name), "LOUNGE_CHAT_20", self.Color("text"), body)
					lbl:Dock(TOP)

					el = self.NumSlider(body)
					el.TextArea:SetWide(35)
					el:SetMinMax(op.min or 0, op.max or 1)
					el:SetValue(GetConVar(op.cvar):GetFloat())
					el:SetConVar(op.cvar)
				elseif (op.type == TYPE_BOOL) then
					el = self.Checkbox(name, op.cvar, body)
					mu = m5 * 0.25
					md = m5 * 0.25
				elseif (op.type == "action") then
					el = self.Button(name, body, function(me)
						local pa = LOUNGE_CHAT.ImageDownloadFolder .. "/"
						local fil = file.Find(pa .. "*.png", "DATA")
						for _, f in pairs (fil) do
							file.Delete(pa .. f)
							me:SetText(self.Lang("clear_downloaded_images", string.NiceSize(0)))
						end
					end)
					mu = m5
					el.m_bAlternateBG = true
				end

				if (IsValid(el)) then
					if (i == #cat.ops) then
						md = m5
					end

					el:Dock(TOP)
					el:DockMargin(0, mu, 0, md)
				end
			end
		end

	pnl:SetAlpha(0)
	pnl:AlphaTo(255, self.Anims.FadeInTime)
end

concommand.Add("lounge_chat_options", function()
	LOUNGE_CHAT:ShowOptions()
end)