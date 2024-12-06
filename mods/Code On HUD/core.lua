--Adapted from fragtrane's ECM timer
local function look_for_code_parts(message)
	message = message:lower()
	return message:find('r') ~= nil, message:find('g') ~= nil, message:find('b') ~= nil
end

local function look_for_code(message)
	local hud_manager = managers.hud
	if not hud_manager or not hud_manager._hud_code_display then
		return
	end
	
	local msg_length = string.len(message)
	if msg_length == 2 then
		local r, g, b = look_for_code_parts(message)
		if r or g or b then
			hud_manager._hud_code_display.code = message:match("(%d)")
			hud_manager._hud_code_display.is_part = true
			hud_manager._hud_code_display.is_rgb = false
		end
	elseif msg_length == 3 then
		hud_manager._hud_code_display.code = message
		hud_manager._hud_code_display.is_part = false
		hud_manager._hud_code_display.is_rgb = true
	elseif msg_length == 4 then
		if tonumber(message) ~= nil and tonumber(message) > 0 then
			hud_manager._hud_code_display.code = message
			hud_manager._hud_code_display.is_part = false
			hud_manager._hud_code_display.is_rgb = false
		end
	end
end

HUDCodeDisplay = HUDCodeDisplay or class()

function HUDCodeDisplay:init(hud)
	self._hud_panel = hud.panel

	self._panel = self._hud_panel:panel({
		name = "code_panel",
		visible = false,
		w = 98,
		h = 38,
		center_x = self._hud_panel:w() / 2,
		y = 50
	})
	
	local code_icon = self._panel:bitmap({
		name = "code_icon",
		texture = "guis/textures/pd2/skilltree/icons_atlas",
		texture_rect = {0*64, 8*64, 64, 64},
		valign = "center",
		align = "left",
		layer = 1,
		h = 38,
		w = 38
	})
	
	local box = HUDBGBox_create(self._panel, {w = 60, h = 38},  {})
	box:set_left(code_icon:right())
	box:set_center_y(code_icon:h() / 2)
	
	self._code = box:text({
		name = "code",
		text = "",
		valign = "center",
		align = "center",
		vertical = "center",
		w = box:w(),
		h = box:h(),
		layer = 1,
		color = Color.white,
		font = tweak_data.hud_stats.objectives_font,
		font_size = tweak_data.hud_stats.objectives_title_size
	})

	self._digit_red = box:text({
		name = "digit_red",
		text = "",
		valign = "center",
		align = "center",
		vertical = "center",
		w = box:w() / 3,
		h = box:h(),
		x = box:w() / 3 / 2,
		layer = 1,
		color = Color.red,
		font = tweak_data.hud_stats.objectives_font,
		font_size = tweak_data.hud_stats.objectives_title_size
	})

	self._digit_green = box:text({
		name = "digit_green",
		text = "",
		valign = "center",
		align = "center",
		vertical = "center",
		w = box:w() / 3,
		h = box:h(),
		x = self._digit_red:right() - box:w() / 3 / 2,
		layer = 1,
		color = Color.green,
		font = tweak_data.hud_stats.objectives_font,
		font_size = tweak_data.hud_stats.objectives_title_size
	})

	self._digit_blue = box:text({
		name = "digit_blue",
		text = "",
		valign = "center",
		align = "center",
		vertical = "center",
		w = box:w() / 3,
		h = box:h(),
		x = self._digit_green:right() - box:w() / 3 / 2,
		layer = 1,
		color = Color.blue,
		font = tweak_data.hud_stats.objectives_font,
		font_size = tweak_data.hud_stats.objectives_title_size
	})
end

function HUDCodeDisplay:hide_rgb(r, g, b)
	if r then
		self._digit_red:set_visible(false)
	end
	if g then
		self._digit_green:set_visible(false)
	end
	if b then
		self._digit_blue:set_visible(false)
	end
end

function HUDCodeDisplay:update()
	if self.close_on_next_update then
		self._panel:set_visible(false)
		self.close_on_next_update = false
		self.code = nil
		self.is_part = nil
		self.is_rgb = nil
		return
	end

	if not self.code then return end

	local timer = self._hud_panel:child("heist_timer_panel")
	if timer then
		self._panel:set_center_x(self._hud_panel:center_x() - 10)
		self._panel:set_y(timer:y() + 40)
	end

	if self.is_rgb then
		local r, g, b = self.code:match("([-%d])([-%d])([-%d])")
		self._panel:set_visible(true)

		if r ~= nil and r ~= '-' then
			self._code:set_visible(false)
			self._digit_red:set_text(r)
			self._digit_red:set_visible(true)
		end
		if r ~= nil and g ~= '-' then
			self._code:set_visible(false)
			self._digit_green:set_text(g)
			self._digit_green:set_visible(true)
		end
		if r ~= nil and b ~= '-' then
			self._code:set_visible(false)
			self._digit_blue:set_text(b)
			self._digit_blue:set_visible(true)
		end
		self.code = nil
		self.is_part = nil
		self.is_rgb = nil
		return
	end
	
	if self.is_part then
		local r, g, b = look_for_code_parts(self.code)
		self._panel:set_visible(true)
		self._code:set_visible(false)
		if r then
			self._digit_red:set_text(self.code)
			self._digit_red:set_visible(true)
		elseif g then
			self._digit_green:set_text(self.code)
			self._digit_green:set_visible(true)
		elseif b then
			self._digit_blue:set_text(self.code)
			self._digit_blue:set_visible(true)
		end

		self.code = nil
		self.is_part = nil
		self.is_rgb = nil
		return
	end

	self._panel:set_visible(true)
	self._code:set_visible(true)
	self._code:set_text(self.code)
	self:hide_rgb(true, true, true)

	self.code = nil
	self.is_part = nil
	self.is_rgb = nil
end

Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "_setup_player_info_hud_pd2_coh", function(self)
	self._hud_code_display = HUDCodeDisplay:new(managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2))
end)

Hooks:PostHook(HUDChat, "receive_message", "receive_message_coh", function(self, name, message, color, icon)
	look_for_code(message)
	if string.lower(message) == "close_code" then
		managers.hud._hud_code_display.close_on_next_update = true
	end
end)

Hooks:PostHook(ChatManager, "send_message", "send_message_coh", function(self, channel_id, sender, message)
	look_for_code(message)
	if string.lower(message) == "close_code" then
		managers.hud._hud_code_display.close_on_next_update = true
	end
end)

Hooks:PostHook(HUDManager, "update", "update_coh", function(self)
	self._hud_code_display:update()
end)