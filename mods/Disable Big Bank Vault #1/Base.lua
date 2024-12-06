core:module("CoreMissionScriptElement")
core:import("CoreXml")
core:import("CoreCode")
core:import("CoreClass")

MissionScriptElement = MissionScriptElement or class()

if not Global.game_settings or (Global.game_settings.level_id ~= "big") then
	return
end

Hooks:PostHook(MissionScriptElement, "on_script_activated", "F_"..Idstring("PostHook:MissionScriptElement:on_script_activated:Disable Tuto Vault"):key(), function(self)
	if Global.game_settings and Global.game_settings.level_id == "big" then
		if self._id == 104412 then
			self._values.__re_enabled = false
			self._values.enabled = false
		end
	end
end)