-- Used some ECM Rush Helper functions to manage the rush order logic.

PlaceMyECMDown = PlaceMyECMDown or class()
PlaceMyECMDown.time = 2.75
PlaceMyECMDown.action_started = false
PlaceMyECMDown.peer_database = {
	{"", "", "", ""}, -- ecm each peer
	{"", "", "", ""}, -- ecm amount each peer
}
local counter = 0

if PlaceMyECMDown._data and PlaceMyECMDown._data.enabled ~= true then
	return
end

Hooks:PostHook(PlayerManager, "set_synced_deployable_equipment", "pmed_set_synced_deployable_equipment", function(self, peer, deployable, amount)
	if deployable == "ecm_jammer" or amount == 0 then
		PlaceMyECMDown.peer_database[1][peer._id] = deployable
		PlaceMyECMDown.peer_database[2][peer._id] = amount
	end
end)

Hooks:PostHook(UnitNetworkHandler, "set_unit", "pmed_set_unit", function(self, unit, character_name, outfit_string, outfit_version, peer_id, team_id, visual_seed)
	local outfit = string.split(outfit_string, " ") or {}
	if outfit[13] == "ecm_jammer" then
		PlaceMyECMDown.peer_database[1][peer_id] = "ecm_jammer"
		PlaceMyECMDown.peer_database[2][peer_id] = 1
	end
end)

function PlaceMyECMDown:has_ecm(peerid)
	if PlaceMyECMDown.peer_database[1][peerid] == "ecm_jammer" and PlaceMyECMDown.peer_database[2][peerid] ~= 0 then --and managers.network:session():peer(peerid):unit():base():upgrade_value("ecm_jammer", "affects_pagers") then
		return true
	end
	return false
end

Hooks:PostHook(ECMJammerBase, "init", "pmed_spawn", function (self)
	counter = counter + 1
	PlaceMyECMDown.skip_check = false
	--log("Inited an ECM! Current ECM count: " .. counter)
end)

Hooks:PostHook(ECMJammerBase, "update", "pmed_update", function(self, unit, t, dt) -- GET ECM REMAINING TIME

	if PlaceMyECMDown.haltexec then return end

	if managers.player:has_category_upgrade("player", "deploy_interact_faster") and PlaceMyECMDown._data.ignore_joat == false then
		PlaceMyECMDown.time = 1.75
	end

	if self:active() == true and self._battery_life <= PlaceMyECMDown.time and not self._done_check then -- If it's our turn

			self._done_check = true
			local plr_state = managers.player:player_unit():movement():current_state()
			local plr_state_name = managers.player:player_unit():movement():current_state_name()
			local local_peer_id = managers.network:session():local_peer():id()
			self.next_player = nil

			if counter > 0 then
				counter = counter - 1
			end


			--log("Current ECM Count: ".. counter)

			if managers.player:selected_equipment_id() == "ecm_jammer" and managers.network:session() and counter <= 1 and not PlaceMyECMDown.skip_check then

				if counter == 0 then
					for i, peer in pairs(managers.network:session():all_peers()) do
						if PlaceMyECMDown:has_ecm(peer._id) and not self.next_player then
							self.next_player = peer._id
							--log("Next player is: ".. (self.next_player or "none"))
						end
					end
				end

				if plr_state_name == "standard" or plr_state_name == "carry" then -- Place!
					if self.next_player == local_peer_id and counter == 0 and self._battery_life <= PlaceMyECMDown.time and self.next_player then 
						--log(self._battery_life)

						if alive(plr_state._interaction._active_unit) then -- If unit interaction
							if plr_state._interaction._active_unit:interaction()._tweak_data.text_id == "hud_int_disable_alarm_pager" then
								--log("PAGER! NOT CONTINUING EXECUTION")
								return -- If a current interaction is a pager, prevent the code from running.
							end
						end

						plr_state:_interupt_action_interact()
						plr_state:_start_action_use_item(Application:time())
					--	log("Started action")
						PlaceMyECMDown.its_my_turn_to_shine = true

						local camera_unit = managers.player:player_unit():camera():camera_unit()
						PlaceMyECMDown.pitch = camera_unit:base()._camera_properties.pitch
						camera_unit:base():animate_pitch(Application:time(), nil, -90, 0.95) -- animate_pitch(start_t, start_pitch, end_pitch, total_duration)

						done = 1

					end

				end

			end
	end
end)

Hooks:PostHook(PlayerStandard, "_end_action_use_item", "pmed_end_action_use_item_post", function(self, valid) -- END EQUIPMENT PLACEMENT
	if PlaceMyECMDown.its_my_turn_to_shine then 

		PlaceMyECMDown.its_my_turn_to_shine = false

		local camera_unit = managers.player:player_unit():camera():camera_unit()
		camera_unit:base():animate_pitch(Application:time(), -90, PlaceMyECMDown.pitch or 0, 0.5) -- animate_pitch(start_t, start_pitch, end_pitch, total_duration)

		PlaceMyECMDown.action_started = nil

	end
end)