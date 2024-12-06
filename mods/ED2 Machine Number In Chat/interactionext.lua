_G.ED2ChatHelper = _G.ED2ChatHelper or class()
_G.ED2ChatHelper.current_machine = 0
local delay = false
local startDelayDone = false

if tostring(RequiredScript) == "lib/units/interactions/interactionext" then

	if Global.game_settings.level_id ~= "election_day_2" then
		return
	end

	_G.ED2ChatHelper.current_machine = 0

	startDelayDone = false

	DelayedCalls:Add("AllowED2ElementExecutionCounting", 10, function()
		startDelayDone = true
	end )

	Hooks:PostHook(MissionScriptElement, "on_executed", "ED2ChatHelper_executed", function(self)
		if string.find(tostring(self._editor_name), "enable_voting_machine") and managers.briefing:event_playing() == false and startDelayDone == true then--if table.find(sequence_trigger_ids, tostring(self._id)) then
			_G.ED2ChatHelper.current_machine = _G.ED2ChatHelper.current_machine + 1
			if ED2ChatHelper._data.takeover ~= false and ED2ChatHelper._data.takeover ~= "off" then
				log(tostring(ED2ChatHelper._data.takeover))
				managers.chat:send_message(ChatManager.GAME, managers.network.account:username() or "Offline", ED2ChatHelper._data.prefix..tostring(_G.ED2ChatHelper.current_machine))
			end
		end
	end)

	if ED2ChatHelper._data.takeover ~= false and ED2ChatHelper._data.takeover ~= "off" then
		return
	end

	Hooks:PostHook(BaseInteractionExt, "interact_start", "ED2ChatHelper_interact_start", function (self,player,data)
		if self._tweak_data.text_id == "debug_interact_hack_ipad" then
			if delay == false then
				delay = true
				managers.chat:send_message(ChatManager.GAME, managers.network.account:username() or "Offline", ED2ChatHelper._data.prefix..tostring(_G.ED2ChatHelper.current_machine))
			end
		end

	end)

	Hooks:PostHook(BaseInteractionExt, "interact", "ED2ChatHelper_interact_end", function (self,player)
		if self._tweak_data.text_id == "debug_interact_hack_ipad" then
			delay = false
		end

	end)
	
end