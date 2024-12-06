ExtendedChat = ExtendedChat or class()
ExtendedChat.messageHistory = {}
ExtendedChat.tablePosition = nil

Hooks:PostHook(ChatManager, "send_message", "send_message_uda", function (self, channel_id, sender, message)
	table.insert(ExtendedChat.messageHistory, message)
	for i = 1, #ExtendedChat.messageHistory do
		log(ExtendedChat.messageHistory[i])
	end
	ExtendedChat.tablePosition = nil
end)

Hooks:PostHook(HUDChat, "key_press", "key_press_uda", function (self, o, input)
	if self._skip_first then
		self._skip_first = false

		return
	end

	if not self._enter_text_set then
		self._input_panel:enter_text(callback(self, self, "enter_text"))

		self._enter_text_set = true
	end

	local text = self._input_panel:child("input_text")
	local s, e = text:selection()
	local n = utf8.len(text:text())
	local d = math.abs(e - s)
	self._key_pressed = input

	text:stop()
	text:animate(callback(self, self, "update_key_down"), input)

	if input == Idstring("up") then
		text:set_selection(0, n)
		text:replace_text("")
		if ExtendedChat.tablePosition == nil then
			ExtendedChat.tablePosition = #ExtendedChat.messageHistory
		else
			ExtendedChat.tablePosition = ExtendedChat.tablePosition - 1
			if ExtendedChat.tablePosition <= 0 then
				ExtendedChat.tablePosition = 1
			end
		end
		if ExtendedChat.messageHistory[ExtendedChat.tablePosition] then
			text:replace_text(ExtendedChat.messageHistory[ExtendedChat.tablePosition])
		end
	end
	if input == Idstring("down") then
		text:set_selection(0, n)
		text:replace_text("")
		if ExtendedChat.tablePosition == nil then
			ExtendedChat.tablePosition = #ExtendedChat.messageHistory
		else
			ExtendedChat.tablePosition = ExtendedChat.tablePosition + 1
			if ExtendedChat.tablePosition > #ExtendedChat.messageHistory then
				ExtendedChat.tablePosition = #ExtendedChat.messageHistory
			end
		end
		if ExtendedChat.messageHistory[ExtendedChat.tablePosition] then
			text:replace_text(ExtendedChat.messageHistory[ExtendedChat.tablePosition])
		end
	end

	self:update_caret()
end)