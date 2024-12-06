if Global.game_settings and Global.game_settings.level_id == "corp" then

	if managers.worlddefinition:get_unit(500010) then -- Remove prop duplicate of 500010
		local unit = managers.worlddefinition:get_unit(500010)
		if Network:is_server() or unit:id() == -1 then
			World:delete_unit(unit)
		else
			unit:set_visible(false)
			unit:set_enabled(false)
		end
	end

	PlayerEquipment = PlayerEquipment or class()
	function PlayerEquipment:use_ecm_jammer()
		if self._ecm_jammer_placement_requested then
			return
		end
	
		local ray = self:valid_look_at_placement()
	
		if ray then
			local attach_unit = ray.unit
			local attach_sync_unit, attach_sync_unit_id = nil
	
			if attach_unit:id() ~= -1 then
				attach_sync_unit = attach_unit
				attach_sync_unit_id = ""
			else
				local attach_unit_key = attach_unit:key()
	
				-- Lines 273-281
				local function verify_id_for_sync(id)
					local world_unit = managers.worlddefinition:get_unit(id)
	
					if alive(world_unit) and world_unit:key() == attach_unit_key then
						return id
					elseif attach_unit:name() == Idstring("units/pd2_dlc_corp/architecture/int/corp_main_mid/corp_int_main_mid") then -- attach_unit and world_unit will never match since they're the same editor ID
						return id
					end
				end
	
				local attach_unit_id = attach_unit:unit_data().unit_id
				attach_sync_unit_id = attach_unit_id ~= 0 and verify_id_for_sync(attach_unit_id) or verify_id_for_sync(attach_unit:editor_id()) or nil
	
				if type(attach_sync_unit_id) == "number" then
					attach_sync_unit_id = tostring(attach_sync_unit_id) .. "ISNUMBER"
				end
			end
	
			if attach_sync_unit or attach_sync_unit_id then
				managers.mission:call_global_event("player_deploy_ecmjammer")
				managers.statistics:use_ecm_jammer()
	
				local attach_body = ray.body
				local world_pos = ray.position
				local world_rot = Rotation()
	
				mrotation.set_look_at(world_rot, ray.normal, math.UP)
	
				local relative_pos = mvector3.copy(world_pos)
	
				mvector3.subtract(relative_pos, attach_body:position())
	
				local relative_rot = attach_body:rotation()
	
				mrotation.invert(relative_rot)
				mvector3.rotate_with(relative_pos, relative_rot)
				mrotation.multiply(relative_rot, world_rot)
	
				relative_rot = Rotation(relative_rot:yaw(), relative_rot:pitch(), relative_rot:roll())
				local sync_body_index = attach_unit:get_body_index(attach_body:name())
				local duration_multiplier = managers.player:upgrade_level("ecm_jammer", "duration_multiplier", 0) + managers.player:upgrade_level("ecm_jammer", "duration_multiplier_2", 0) + 1
	
				if Network:is_client() then
					self._ecm_jammer_placement_requested = true
	
					managers.network:session():send_to_host("request_place_ecm_jammer", attach_sync_unit, attach_sync_unit_id, sync_body_index, mvector3.copy(world_pos), world_rot, relative_pos, relative_rot, duration_multiplier)
				else
					local unit = ECMJammerBase.spawn(world_pos, world_rot, duration_multiplier, self._unit, managers.network:session():local_peer():id())
	
					unit:base():set_active(true)
					unit:base():link_attachment(attach_body, relative_pos, relative_rot)
					managers.network:session():send_to_peers_synched("sync_deployable_attachment", unit, attach_sync_unit, attach_sync_unit_id, sync_body_index, relative_pos, relative_rot)
				end
			else
				Application:error("[PlayerEquipment:use_ecm_jammer] Attach unit is not networked and cannot be found in world definition, preventing placement. Unit id: " .. tostring(attach_unit:unit_data().unit_id) .. " | Editor id: " .. tostring(attach_unit:editor_id()) .. " | Unit:", inspect(attach_unit))
			end
	
			return true
		end
	
		return false
	end
end