local RedHealth = _G.RedHealth
BLT.AssetManager:CreateEntry(Idstring("guis/textures/custom/hud_health_below_225"), Idstring("texture"), ModPath.. "guis/textures/pd2/hud_health_below_225.texture")

-- // HUD compatibility checks \\ --

if _G.ArmStatic then
	if _G.MUIMenu:ClassEnabled(MUITeammate) == true then
		MUIIsActive = true
	end
end

if _G.VoidUI then
	if _G.VoidUI.options.teammate_panels then
		VoidUIIsActive = true
	end
end 

if _G.VHUDPlus then
	if _G.VHUDPlus:getSetting({"CustomHUD", "HUDTYPE"}, 2) == 3 then
		CustomHudIsActive = true
	end
end

-- // RedHealth functions \\ --

if CustomHudIsActive == true and tostring(RequiredScript) == "lib/managers/hud/hudteammate" and MUIIsActive ~= true and VoidUIIsActive ~= true then
	Hooks:PostHook(PlayerInfoComponent.PlayerStatus, "init", "radial_health_red_customhud_init", function (self, panel, owner, width, height, settings)
		self._size = height
		Radial_health_panel_customhud = self._panel
		self._radial_health_red = self._panel:bitmap({
			name = "health_radial_red",
			texture = "guis/textures/custom/hud_health_below_225",
			render_template = "VertexColorTexturedRadial",
			texture_rect = {
				128,
				0,
				-128,
				128
			},
			blend_mode = "add", --"normal" and VHUDPlus:getSetting({"CustomHUD", "DisableBlend"}, false) or "add",
			color = Color(1, 0, 1, 1),
			h = self._size,
			w = self._size,
			layer = 4,
		})
	end)

	Hooks:PostHook(PlayerInfoComponent.PlayerStatus, "set_health", "radial_health_red_customhud", function (self, current, total)
		
		local red = (current / total) -- New health percentage (*100)
		local currentHealth = current * 10
		local radial_health_red = self._panel:child("health_radial_red")
		local radial_health = self._panel:child("health_radial")

		if red ~= nil then

			
			if not managers.player:player_unit() then return end -- So this beautiful game doesn't crash for soem reason when calling managers.player:yaddayadda

			local damage_reduction = managers.player:damage_reduction_skill_multiplier("bullet")
			local real_damage_reduction = 1 - damage_reduction

			local realHealth = currentHealth + (currentHealth * real_damage_reduction) -- Number of health points player has with added damage reductions

			if realHealth <= RedHealth._data.health_value then

				radial_health:set_visible(false)
				radial_health_red:set_visible(true)
	
				if red > radial_health:color().red then -- If new health is higher than old health
	
					radial_health_red:animate(function (o)
						local s = radial_health_red:color().r
						local e = red
						local health_ratio = nil
		
						over(0.2, function (p)
							health_ratio = math.lerp(s, e, p)
							radial_health_red:set_color(Color(1, health_ratio, 1, 1))
						end)
					end)
	
				else
					radial_health_red:set_color(Color(1, red, 1, 1))
				end
				
			else
				radial_health_red:set_color(Color(1, red, 1, 1))
				radial_health_red:set_visible(false)
				radial_health:set_visible(true)
			end

		end
	end)
end

if MUIIsActive and CustomHudIsActive ~= true and VoidUIIsActive ~= true then
	log("Doing MUI RedHealth")
	if tostring(RequiredScript) == "lib/managers/hudmanagerpd2" then

		Hooks:PostHook(HUDManager, "_create_teammates_panel", "radial_health_red_mui", function(self)

			for i = 1, self.PLAYER_PANEL do
				self["radial_health_red_mui_player_"..tostring(i)] = self._teammate_panels[i]._radial_health_panel:bitmap({
					texture = "guis/textures/custom/hud_health_below_225",
					name = "radial_health_red_mui",
					layer = 4,
					blend_mode = "add",
					render_template = "VertexColorTexturedRadial",
					texture_rect = {
						128,	
						0,
						-128,
						128
					},
					color = Color(1, 0, 1, 1),
					w = self._teammate_panels[i]._radial_health_panel:w(),
					h = self._teammate_panels[i]._radial_health_panel:h()
				})
				self["radial_health_red_mui_player_"..tostring(i)]:set_visible(true)
			end
			
		end)

		Hooks:PostHook(HUDManager, "set_teammate_health", "redHealthBelow225_mui", function(self, i, data)
				local red = data.current / data.total -- New health percentage (*100)
				local currentHealth = data.current * 10
				local radial_health_red = self["radial_health_red_mui_player_"..tostring(i)]
				local radial_health = self._teammate_panels[i]._radial_health -- Access to MUITeammate
		
				if red ~= nil then
					
					if not managers.player:player_unit() then return end -- So this beautiful game doesn't crash for soem reason when calling managers.player:yaddayadda

					local damage_reduction = managers.player:damage_reduction_skill_multiplier("bullet")
					local real_damage_reduction = 1 - damage_reduction

					local realHealth = currentHealth + (currentHealth * real_damage_reduction) -- Number of health points player has with added damage reductions

					if realHealth <= RedHealth._data.health_value then
		
						radial_health:set_visible(false)
						radial_health_red:set_visible(true)
		
						if red > radial_health:color().red then -- If new health is higher than old health but still lower than the health_value
		
							radial_health_red:animate(function (o)
								local s = radial_health_red:color().r
								local e = red
								local health_ratio = nil
			
								over(0.2, function (p)
									health_ratio = math.lerp(s, e, p)
									radial_health_red:set_color(Color(1, health_ratio, 1, 1))
								end)
							end)
		
						else -- If it's more damage
							radial_health_red:set_color(Color(1, red, 1, 1))
						end
					
					else -- If it's higher than old health and higher than health_value
						radial_health_red:set_color(Color(1, red, 1, 1))
						radial_health_red:set_visible(false)
						radial_health:set_visible(true)
					end
		
				end
		end)
	end
end

if VoidUIIsActive and CustomHudIsActive ~= true and MUIIsActive ~= true then
	log("Doing VOID RedHealth")

	Hooks:PostHook(HUDTeammate, "init", "radial_health_red_voidui", function(self, i, teammates_panel, is_player, width)
		local health_panel = self._panel:child("custom_player_panel"):child("health_panel")
		local health_texture = "guis/textures/VoidUI/hud_health"

		local health_bar_red = health_panel:bitmap({
			name = "health_bar_red",
			texture = health_texture,
			texture_rect = {203,0,202,472},
			layer = 2,
			w = health_panel:w(),
			h = health_panel:h(),
			alpha = 1,
		})

		local health_value_red = health_panel:text({
			name = "health_value_red",
			w = self._health_value,
			h = self._health_value,
			font_size = self._health_value / 1.4,
			text = "100",
			vertical = "bottom",
			align = "center",
			font = "fonts/font_medium_noshadow_mf",
			layer = 5,
			color = Color.white
		})	

		local health_background_red = health_panel:bitmap({
			name = "health_background_red",
			w = health_panel:w(),
			h = health_panel:h(),
			texture = health_texture,
			texture_rect = {0,0,202,472},
			layer = 1
		})

		local armor_value_red = health_panel:text({
			name = "armor_value_red",
			w = self._armor_value,
			h = self._armor_value,
			font_size = self._armor_value / 2.5,
			text = "",
			vertical = "bottom",
			align = "center",
			font = "fonts/font_medium_noshadow_mf",
			layer = 5,
			color = Color.white
		})

		local detect_value_red = health_panel:text({
			name = "detect_value_red",
			w = self._health_value,
			h = self._health_value,
			font_size = self._main_player and self._health_value / 1.5 or self._health_value / 1.7,
			text = "75%",
			vertical = "top",
			align = "center",
			font = "fonts/font_medium_noshadow_mf",
			layer = 5,
			color = Color.white,
			visible = false
		})	
		detect_value_red:set_top(health_panel:child("health_background"):top() + 3)
		detect_value_red:set_right(health_panel:child("health_background"):right() - (self._main_player and 3 or 1))

		local downs_value_red = health_panel:text({
			name = "downs_value_red",
			w = self._health_value,
			h = self._health_value,
			font_size = self._health_value / 1.5,
			text = "x0",
			vertical = "top",
			align = "center",
			font = "fonts/font_medium_noshadow_mf",
			layer = 5,
			color = Color.white,
		})

		local delayed_damage_health_bar_red = health_panel:bitmap({
			name = "delayed_damage_health_bar_red",
			texture = health_texture,
			texture_rect = {881,0,202,472},
			layer = 3,
			w = health_panel:w(),
			h = health_panel:h(),
			alpha = 1,
			visible = false,
		})	

		downs_value_red:set_top(health_panel:child("health_background"):top() + 3)
		downs_value_red:set_right(health_panel:child("health_background"):right() - (self._main_player and 3 or 1))
		armor_value_red:set_bottom(health_panel:child("health_value"):top() * 1.25)
		health_value_red:set_bottom(health_panel:child("health_background"):bottom() - 3)

		health_value_red:set_visible(false)
		health_bar_red:set_visible(false)
		armor_value_red:set_visible(false)
		health_background_red:set_visible(false)
		downs_value_red:set_visible(false)

	end)

	Hooks:PostHook(HUDTeammate, "set_bodybags", "radial_health_red_bodybags_voidui", function(self)
		local health_panel = self._custom_player_panel:child("health_panel")
		local detect_value = health_panel:child("detect_value_red")
		detect_value:set_text("x"..tostring(managers.player:get_body_bags_amount()))
	end)

	Hooks:PostHook(HUDTeammate, "set_detection", "radial_health_red_detection_voidui", function(self)
		local health_panel = self._custom_player_panel:child("health_panel")
		local detect_value = health_panel:child("detect_value_red")
		if self:peer_id() then
			detect_value:set_text(string.format("%.0f", managers.blackmarket:get_suspicion_offset_of_peer(managers.network:session():peer(self:peer_id()), tweak_data.player.SUSPICION_OFFSET_LERP or 0.75) * 100).."%")
		end
	end)

	Hooks:PostHook(HUDTeammate, "set_callsign", "radial_health_red_callsign_voidui", function(self, id)
		if self._ai then return end
		Color_red = Color(0.98823529411, 0.33725490196, 0.33725490196) -- RGB 194, 68, 68
		local health_panel = self._custom_player_panel:child("health_panel")

		health_panel:child("health_background_red"):set_color(Color_red * 0.2 + Color.black)
		health_panel:child("downs_value_red"):set_color(Color_red * 0.8 + Color.black * 0.5)
		health_panel:child("health_bar_red"):set_color(Color_red * 0.7 + Color.black * 0.9)
		health_panel:child("health_value_red"):set_color(Color_red * 0.4 + Color.black * 0.5)
		health_panel:child("armor_value_red"):set_color(Color_red * 0.4 + Color.black * 0.5)
		health_panel:child("delayed_damage_health_bar_red"):set_color(Color_red * 0.4 + Color.black * 0.5)
		health_panel:child("detect_value_red"):set_color(Color_red * 0.8 + Color.black * 0.5)
	end)

	Hooks:PostHook(HUDTeammate, "set_armor", "radial_health_red_armor_voidui", function(self, data)
		local amount = data.total ~= 0 and math.ceil((data.current / data.total) * 100) / 100 or 0
		local health_panel = self._custom_player_panel:child("health_panel")
		local armor_value_red = health_panel:child("armor_value_red")
		local show_armor_value = self._main_player and VoidUI.options.main_armor or VoidUI.options.mate_armor
		if show_armor_value == 2 then armor_value_red:set_text(self:round(amount * 100))
		elseif show_armor_value == 3 then armor_value_red:set_text(self:round((data.total * 10) * amount))
		else armor_value_red:set_text("") end
		if data.total == 0 or (data.current / data.total) < 0.01 then
			armor_value_red:set_text("")
		end
		
		if self._main_player and VoidUI.options.main_health == 1 or VoidUI.options.mate_health == 1 then
			armor_value_red:set_w(self._health_value)
			armor_value_red:set_font_size(self._armor_value / 2)
			armor_value_red:set_bottom(self._panel:child("custom_player_panel"):child("health_panel"):h() - 5)
		else
			armor_value_red:set_w(self._armor_value)
			armor_value_red:set_font_size(self._armor_value / 2.5)
			armor_value_red:set_bottom(self._panel:child("custom_player_panel"):child("health_panel"):child("health_value"):top() * 1.25)
		end
	end)

	Hooks:PostHook(HUDTeammate, "update_delayed_damage", "radial_health_red_delayed_voidui", function(self)
		local damage = self._delayed_damage or 0

		local health_panel = self._custom_player_panel:child("health_panel")

		local health_bar = health_panel:child("health_bar")
		local delayed_damage_health_bar_red = health_panel:child("delayed_damage_health_bar_red")
		local armor_value_red = health_panel:child("armor_value_red")


		local armor_current = self._armor_data.current
		local health_max = self._health_data.total
		local health_current = self._health_data.current
		local health_ratio = health_bar:h() / self._bg_h
		local armor_damage = damage < armor_current and damage or armor_current
		damage = damage - armor_damage
		local health_damage = damage < health_current and damage or health_current
		local health_damage_ratio = health_damage / health_max
		
		if CurrentHealth == nil then return end

		if not managers.player:player_unit() then return end -- So this beautiful game doesn't crash for soem reason when calling managers.player:yaddayadda

		local damage_reduction = managers.player:damage_reduction_skill_multiplier("bullet")
		local real_damage_reduction = 1 - damage_reduction

		local realHealth = CurrentHealth + (CurrentHealth * real_damage_reduction) -- Number of health points player has with added damage reductions

		if realHealth < RedHealth._data.health_value then
			if health_damage_ratio > 0 then
				health_panel:child("delayed_damage_health_bar"):set_visible(false)
			end
			delayed_damage_health_bar_red:set_visible(health_damage_ratio > 0)
			armor_value_red:set_visible(false)
			delayed_damage_health_bar_red:set_h(self._bg_h * health_damage_ratio)
			delayed_damage_health_bar_red:set_top(health_bar:top())
			delayed_damage_health_bar_red:set_texture_rect(881,((1- health_ratio) * 472),202,472 * health_damage_ratio)
		end
	end)

	Hooks:PostHook(HUDTeammate, "set_revives_amount", "radial_health_red_revives_voidui", function(self, revive_amount)
		if revive_amount then
			local health_panel = self._custom_player_panel:child("health_panel")
			local downs_value_red = health_panel:child("downs_value_red")
			revive_amount = math.max(revive_amount - 1, 0)
			downs_value_red:set_text("x".. tostring(revive_amount))
		end
	end)

	Hooks:PostHook(HUDTeammate, "set_health", "radial_health_red_set_voidui", function(self, data)
		if self:ai() then return end

		local health_panel = self._panel:child("custom_player_panel"):child("health_panel")
		local health_value_red = health_panel:child("health_value_red")
		local health_bar_red = health_panel:child("health_bar_red")
		local downs_value_red = health_panel:child("downs_value_red")
		local armor_value_red = health_panel:child("armor_value_red")
		local health_background_red = health_panel:child("health_background_red")
		local detect_value_red = health_panel:child("detect_value_red")

		local show_health_value = self._main_player and VoidUI.options.main_health or VoidUI.options.mate_health
		local anim_time = self._main_player and VoidUI.options.main_anim_time or VoidUI.options.mate_anim_time
		local amount = math.clamp(data.current / data.total, 0, 1)
		CurrentHealth = data.current * 10

		if amount < math.clamp(health_bar_red:h() / self._bg_h, 0, 1) then self:_damage_taken() end
				
		if managers.player:has_activate_temporary_upgrade("temporary", "copr_ability") and self._id == HUDManager.PLAYER_PANEL then
			local static_damage_ratio = managers.player:upgrade_value_nil("player", "copr_static_damage_ratio")
			
			if static_damage_ratio then
				amount = math.floor((amount + 0.01) / static_damage_ratio) * static_damage_ratio
			end
		end

		health_bar_red:stop()
		health_bar_red:animate(function(o)
			local s = math.clamp(health_bar_red:h() / self._bg_h, 0, 1)
			local c = s
			over(anim_time, function(p)
				if alive(health_bar_red) then
					c =	math.lerp(s, amount, p)
					health_bar_red:set_h(self._bg_h * c)
					health_bar_red:set_texture_rect(203, 0 + ((1- c) * 472),202,472 * c)
					health_bar_red:set_bottom(self._panel:child("custom_player_panel"):child("health_panel"):child("health_background"):bottom())
							
					if show_health_value == 1 then health_value_red:set_text("")
					elseif show_health_value == 2 then health_value_red:set_text(math.clamp(self:round(c * 100), 0, 100))
					elseif show_health_value == 3 then health_value_red:set_text(self:round((data.total * 10) * c)) end

				end
			end)
		end)

		if not managers.player:player_unit() then return end -- So this beautiful game doesn't crash for soem reason when calling managers.player:yaddayadda

		local damage_reduction = managers.player:damage_reduction_skill_multiplier("bullet")
		local real_damage_reduction = 1 - damage_reduction

		local realHealth = CurrentHealth + (CurrentHealth * real_damage_reduction) -- Number of health points player has with added damage reductions

		if realHealth <= RedHealth._data.health_value then

			local is_whisper_mode = managers.groupai and managers.groupai:state():whisper_mode()
			local visible = true

			health_panel:child("health_bar"):set_visible(false)
			health_panel:child("health_value"):set_visible(false)
			health_panel:child("health_background"):set_visible(false)
			health_panel:child("downs_value"):set_visible(false)
			health_panel:child("detect_value"):set_visible(false)

			if is_whisper_mode == true then
				if self._main_player then visible = VoidUI.options.main_stealth 
				else visible = VoidUI.options.mate_stealth end
				detect_value_red:set_visible(visible)
				downs_value_red:set_visible(false)
			elseif is_whisper_mode == false then
				if self._main_player then visible = VoidUI.options.main_loud
				else visible = VoidUI.options.mate_loud end
				detect_value_red:set_visible(false)
				downs_value_red:set_visible(visible)
			end

			health_panel:child("armor_value"):set_visible(false)
			health_panel:child("delayed_damage_health_bar"):set_visible(false)
			health_value_red:set_visible(true)
			health_bar_red:set_visible(true)
			armor_value_red:set_visible(true)
			health_background_red:set_visible(true)

		else -- If it's higher than old health and higher than health_value

			local is_whisper_mode = managers.groupai and managers.groupai:state():whisper_mode()
			local visible = true

			health_panel:child("health_bar"):set_visible(true)
			health_panel:child("health_value"):set_visible(true)
			health_panel:child("health_background"):set_visible(true)
			health_panel:child("delayed_damage_health_bar"):set_visible(true)
			health_panel:child("armor_value"):set_visible(true)
			
			if is_whisper_mode == true then
				if self._main_player then visible = VoidUI.options.main_stealth 
				else visible = VoidUI.options.mate_stealth end
				health_panel:child("detect_value"):set_visible(visible)
				health_panel:child("downs_value"):set_visible(false)
			elseif is_whisper_mode == false then
				if self._main_player then visible = VoidUI.options.main_loud
				else visible = VoidUI.options.mate_loud end
				health_panel:child("detect_value"):set_visible(false)
				health_panel:child("downs_value"):set_visible(visible)
			end

			health_value_red:set_visible(false)
			health_bar_red:set_visible(false)
			armor_value_red:set_visible(false)
			health_background_red:set_visible(false)
			downs_value_red:set_visible(false)
			detect_value_red:set_visible(false)

		end

	end)
end

if not MUIIsActive or CustomHudIsActive or VoidUIIsActive then
	log("Doing Normal RedHealth")
	Hooks:PostHook(HUDTeammate, "_create_radial_health", "radial_health_red", function (self, radial_health_panel) -- Create red circle
		local radial_health_red = radial_health_panel:bitmap({
			texture = "guis/textures/custom/hud_health_below_225",
			name = "radial_health_red",
			layer = 4,
			blend_mode = "add",
			render_template = "VertexColorTexturedRadial",
			texture_rect = {
				128,
				0,
				-128,
				128
			},
			color = Color(1, 0, 1, 1),
			w = radial_health_panel:w(),
			h = radial_health_panel:h()
		})
	end)

	Hooks:PostHook(HUDTeammate, "set_health", "redHealthBelow225", function(self, data)

		local red = data.current / data.total -- New health percentage (*100)
		local currentHealth = data.current * 10

		if not managers.player:player_unit() then return end -- So this beautiful game doesn't crash for soem reason when calling managers.player:yaddayadda

		local damage_reduction = managers.player:damage_reduction_skill_multiplier("bullet")
		local real_damage_reduction = 1 - damage_reduction

		local realHealth = currentHealth + (currentHealth * real_damage_reduction) -- Number of health points player has with added damage reductions

		local radial_health_panel = self._radial_health_panel
		local radial_health_red = radial_health_panel:child("radial_health_red")
		local radial_health = radial_health_panel:child("radial_health")

		if red ~= nil then

			if realHealth <= RedHealth._data.health_value then

				radial_health:set_visible(false)
				radial_health_red:set_visible(true)

				if red > radial_health:color().red then -- If new health is higher than old health but still lower than the health_value

					radial_health_red:animate(function (o)
						local s = radial_health_red:color().r
						local e = red
						local health_ratio = nil
	
						over(0.2, function (p)
							health_ratio = math.lerp(s, e, p)
							radial_health_red:set_color(Color(1, health_ratio, 1, 1))
						end)
					end)

				else -- If it's more damage
					radial_health_red:set_color(Color(1, red, 1, 1))
				end
			
			else -- If it's higher than old health and higher than health_value
				radial_health_red:set_color(Color(1, red, 1, 1))
				radial_health_red:set_visible(false)
				radial_health:set_visible(true)
			end

		end

	end)
end