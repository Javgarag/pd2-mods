-- Mod Request made by a MarcMB video commenter.
core:module("CoreElementPlaySound")
core:import("CoreMissionScriptElement")
core:import("CoreXml")
core:import("CoreCode")
core:import("CoreClass")

ElementPlaySound = ElementPlaySound or class(CoreMissionScriptElement.MissionScriptElement)

local subtitles = {
	["Play_doc_nmh_run_04"] = "doc_nmh_run_04_sub",
	["Play_doc_nmh_run_03"] = "doc_nmh_run_03_sub",
	["Play_doc_nmh_run_02"] = "doc_nmh_run_02_sub",
	["Play_doc_nmh_run_06"] = "doc_nmh_run_06_sub",
	["Play_doc_nmh_run_05"] = "doc_nmh_run_05_sub",
	["Play_doc_nmh_a"] = "doc_nmh_a_sub",
	["Play_doc_nmh_b"] = "doc_nmh_b_sub",
	["Play_doc_nmh_f"] = "doc_nmh_f_sub",
	["Play_doc_nmh_h"] = "doc_nmh_h_sub",
	["Play_doc_nmh_i"] = "doc_nmh_i_sub",
	["Play_doc_nmh_run_01"] = "doc_nmh_run_01_sub",
	["Play_doc_nmh_run_07"] = "doc_nmh_run_07_sub",
	["Play_doc_nmh_run_08"] = "doc_nmh_run_08_sub"
}

Hooks:PreHook(ElementPlaySound, "on_executed", "NurseSubtitles", function(self)

	if not self._values.enabled then
		return
	end

	if subtitles[self._values.sound_event] ~= nil then

		managers.player:player_unit():drama():play_subtitle(subtitles[self._values.sound_event])
		if string.find(self._values.sound_event, "run") then
			_G.DelayedCalls:Add("NoMercyNurseDialogRemoveLong", 11, function ()
				managers.player:player_unit():drama():stop_cue()
			end)
		else
			_G.DelayedCalls:Add("NoMercyNurseDialogRemove", 3, function ()
				managers.player:player_unit():drama():stop_cue()
			end)
		end

	end
end)	