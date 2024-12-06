core:module("CoreMissionScriptElement")
core:import("CoreXml")
core:import("CoreCode")
core:import("CoreClass")

MissionScriptElement = MissionScriptElement or class()

if not Global.game_settings or (Global.game_settings.level_id ~= "pent") then
	return
end

Hooks:PostHook(MissionScriptElement, "on_script_activated", "F_"..Idstring("PostHook:MissionScriptElement:on_script_activated:Fix Mountain Master Door Preplan"):key(), function(self)
	if Global.game_settings and Global.game_settings.level_id == "pent" then
		if self._id == 103228 then
			self._values.event_list[1].event = "open_doors"
		end
	end
end)