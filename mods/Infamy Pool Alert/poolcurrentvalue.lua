_G.PoolAlert = _G.PoolAlert or {}
local delay_between_hints = false
local mission_started = false

Hooks:PostHook(GameSetup, "update", "poolalertsmod", function (self, t, dt)
	if managers.player:current_state() == "standard" or mission_started == true then
		mission_started = true
		if ExperienceManager._global ~= nil then
			if ExperienceManager:get_current_prestige_xp() >= ExperienceManager:get_max_prestige_xp() then
				if delay_between_hints ~= true then
					delay_between_hints = true
					managers.hud:show_hint({ text = "INFAMY POOL IS MAXED OUT! You will not earn any XP for this mission if you are at level 100", event = "stinger_objectivecomplete" })
					DelayedCalls:Add("infamy_pool_alert_hint_delay", PoolAlert._data.interval, function ()
						delay_between_hints = false
					end)
				end
			else
				if delay_between_hints ~= true then
					delay_between_hints = true
					managers.hud:show_hint({ text = "Infamy pool is not full, good luck!", event = "stinger_objectivecomplete" })
					--[[DelayedCalls:Add("infamy_pool_alert_hint_delay", 500, function ()
						delay_between_hints = false
					end)]] -- Uncomment if you want to be reminded about the xp pool not being full every 500 seconds.
				end
			end
		else
			ExperienceManager:init()
		end
	end
end)

