RedHealth = RedHealth or class()
RedHealth.mod_name = "Health Turns Red When Under 225"
BLT.AssetManager:CreateEntry(Idstring("guis/textures/custom/hud_health_below_225"), Idstring("texture"), ModPath.. "guis/textures/pd2/hud_health_below_225.texture")

function RedHealth:health_bitmap(name, w, h, blend_mode)
	return {
		texture = "guis/textures/custom/hud_health_below_225",
		name = name,
		layer = 4,
		blend_mode = blend_mode or "add",
		render_template = "VertexColorTexturedRadial",
		texture_rect = {
			128,	
			0,
			-128,
			128
		},
		color = Color(1, 0, 1, 1),
		w = w,
		h = h
	}
end

function RedHealth:calculate_health_with_reductions(health)
	if not managers.player:player_unit() then return end

	local damage_reduction = managers.player:damage_reduction_skill_multiplier("bullet")
	local damage_reduction_multiplier = 1 - damage_reduction

	return health + (health * damage_reduction_multiplier)
end

function RedHealth:set_health(health_data, armor_data, radial_health, radial_health_red)
	local health_percentage = health_data.current / health_data.total
	local currentHealth = health_data.current * 10

	local health_damage_reductions = self:calculate_health_with_reductions(currentHealth)

	if health_damage_reductions and RedHealth._data.substract_armor then
		health_damage_reductions = health_damage_reductions - (armor_data and armor_data.current * 10 or 0)
	end

	if health_damage_reductions and health_damage_reductions <= self._data.health_value then
		radial_health:set_visible(false)
		radial_health_red:set_visible(true)

		if health_percentage > radial_health:color().red then -- current health < threshold but > than old health
			radial_health_red:animate(function (o)
				local anim_start = radial_health_red:color().r
				local anim_end = health_percentage

				over(0.2, function(anim_percentage)
					local health_ratio = math.lerp(anim_start, anim_end, anim_percentage)
					radial_health_red:set_color(Color(1, health_ratio, 1, 1))
				end)
			end)
		else -- more damage under threshold
			radial_health_red:set_color(Color(1, health_percentage, 1, 1))
		end
	
	else
		radial_health_red:set_color(Color(1, health_percentage, 1, 1))
		radial_health_red:set_visible(false)
		radial_health:set_visible(true)
	end
end

function RedHealth:setup()
	log("[INFO] [RedHealth] Setting up RedHealth")

	Hooks:PostHook(HUDTeammate, "_create_radial_health", "radial_health_red_create", function (self, radial_health_panel)
		radial_health_panel:bitmap(RedHealth:health_bitmap("radial_health_red", radial_health_panel:w(), radial_health_panel:h()))
	end)

	Hooks:PostHook(HUDTeammate, "set_health", "radial_health_red_set_health", function(self, data)
		if self._radial_health_panel:child("radial_health_red") then
			RedHealth:set_health(data, self._armor_data, self._radial_health_panel:child("radial_health"), self._radial_health_panel:child("radial_health_red"))
		elseif not RedHealth.incompatible then
			log("[ERROR] [RedHealth] The current version of " .. RedHealth.mod_name .. " is incompatible with your HUD setup. You can report this at https://modworkshop.net/mod/39211")
			RedHealth.incompatible = true
		end
	end)

	self.done = true
end

-- // Death Sentence check \\ --
if RedHealth._data and Global.game_settings.difficulty ~= "sm_wish" and RedHealth._data.death_sentence_only then
	return
end

-- // HUD compatibility hooking \\ --
if _G.ArmStatic and _G.MUIMenu:ClassEnabled(MUITeammate) == true and RequiredScript == "lib/managers/hudmanagerpd2" then
	log("[INFO] [RedHealth] Setting up RedHealth for MUI compatibility")
	RedHealth.done = true

	Hooks:PostHook(HUDManager, "_create_teammates_panel", "radial_health_red_mui", function(self)
		for i = 1, self.PLAYER_PANEL do
			local current_panel = self._teammate_panels[i]
			current_panel._radial_health_panel:bitmap(RedHealth:health_bitmap("radial_health_red", current_panel._radial_health_panel:w(), current_panel._radial_health_panel:h()))
			current_panel._radial_health_panel:set_visible(true)
		end
	end)

	Hooks:PostHook(HUDManager, "set_teammate_health", "redHealthBelow225_mui", function(self, i, data)
		RedHealth:set_health(data, self._armor_data, self._teammate_panels[i]._radial_health_panel:child("radial_health"), self._teammate_panels[i]._radial_health_panel:child("radial_health_red"))
	end)
end

if not RedHealth.done and _G.VHUDPlus and _G.VHUDPlus:getSetting({"CustomHUD", "HUDTYPE"}, 2) == 3 then
	log("[INFO] [RedHealth] Setting up RedHealth for CustomHUD compatibility")
	RedHealth.done = true

	Hooks:PostHook(PlayerInfoComponent.PlayerStatus, "init", "radial_health_red_customhud_init", function (self, panel, owner, width, height, settings)
		local blend_mode = "normal" and VHUDPlus:getSetting({"CustomHUD", "DisableBlend"}, false) or "add"
		self._panel:bitmap(RedHealth:health_bitmap("health_radial_red", width, height, blend_mode))
	end)

	Hooks:PostHook(PlayerInfoComponent.PlayerStatus, "set_health", "radial_health_red_customhud", function (self, current, total)
		RedHealth:set_health({
			current = current,
			total = total
		}, self._armor_data, self._panel:child("health_radial"), self._panel:child("health_radial_red"))
	end)
end

if not RedHealth.done and _G.VoidUI and _G.VoidUI.options.teammate_panels and RequiredScript == "lib/managers/hud/hudteammate" then
	log("[INFO] [RedHealth] Setting up RedHealth for VoidUI compatibility")
	RedHealth.done = true

	Hooks:PostHook(HUDTeammate, "set_health", "radial_health_red_set_voidui", function(self, data)
		if self:ai() then return end

		local health_panel = self._panel:child("custom_player_panel"):child("health_panel")
		local current_health = data.current * 10

		local health_damage_reductions = RedHealth:calculate_health_with_reductions(current_health)

		if health_damage_reductions and RedHealth._data.substract_armor then
			health_damage_reductions = health_damage_reductions - (self._armor_data and self._armor_data.current * 10 or 0)
		end

		if health_damage_reductions and health_damage_reductions <= RedHealth._data.health_value then
			local color_red = Color(0.98823529411, 0.33725490196, 0.33725490196) -- RGB 194, 68, 68
			if not self._red_health_saved_colors then
				self._red_health_saved_colors = {
					health_bar = health_panel:child("health_bar"):color(),
					health_value = health_panel:child("health_value"):color(),
					health_background = health_panel:child("health_background"):color(),
					downs_value = health_panel:child("downs_value"):color(),
					detect_value = health_panel:child("detect_value"):color(),
					armor_value = health_panel:child("armor_value"):color(),
					delayed_damage_health_bar = health_panel:child("delayed_damage_health_bar"):color()
				}
			end

			health_panel:child("health_background"):set_color(color_red * 0.2 + Color.black)
			health_panel:child("downs_value"):set_color(color_red * 0.8 + Color.black * 0.5)
			health_panel:child("health_bar"):set_color(color_red * 0.7 + Color.black * 0.9)
			health_panel:child("health_value"):set_color(color_red * 0.4 + Color.black * 0.5)
			health_panel:child("armor_value"):set_color(color_red * 0.4 + Color.black * 0.5)
			health_panel:child("delayed_damage_health_bar"):set_color(color_red * 0.4 + Color.black * 0.5)
			health_panel:child("detect_value"):set_color(color_red * 0.8 + Color.black * 0.5)

		elseif self._red_health_saved_colors then
			health_panel:child("health_bar"):set_color(self._red_health_saved_colors.health_bar)
			health_panel:child("health_value"):set_color(self._red_health_saved_colors.health_value)
			health_panel:child("health_background"):set_color(self._red_health_saved_colors.health_background)
			health_panel:child("delayed_damage_health_bar"):set_color(self._red_health_saved_colors.delayed_damage_health_bar)
			health_panel:child("armor_value"):set_color(self._red_health_saved_colors.armor_value)
			health_panel:child("detect_value"):set_color(self._red_health_saved_colors.detect_value)
			health_panel:child("downs_value"):set_color(self._red_health_saved_colors.downs_value)
		end
	end)
end 

if not RedHealth.done and _G.NepgearsyHUDReborn then
	log("[INFO] [RedHealth] Setting up RedHealth for Sora's HUD compatibility")

	if NepgearsyHUDReborn.Options:GetValue("HealthStyle") == 1 and NepgearsyHUDReborn:TeammateRadialIDToPath(NepgearsyHUDReborn:GetOption("HealthColor")) ~= "NepgearsyHUDReborn/Color/Red" then -- Sora's HUD "thin" health
		local function set_texture(o, texture) -- Borrowed from Sora's HUD (HUDTeammate.lua:381)
			local w,h = o:texture_width(), o:texture_height()
			o:set_image(texture, w, 0, -w, h)
		end
	
		Hooks:PostHook(HUDTeammate, "set_health", "radial_health_red_set_health_sora", function(self, data)
			local current_health = data.current * 10

			local health_damage_reductions = RedHealth:calculate_health_with_reductions(current_health)

			if health_damage_reductions and RedHealth._data.substract_armor then
				health_damage_reductions = health_damage_reductions - (self._armor_data and self._armor_data.current * 10 or 0)
			end

			if health_damage_reductions and health_damage_reductions <= RedHealth._data.health_value then
				set_texture(self._radial_health_panel:child("radial_health"), "NepgearsyHUDReborn/HUD/HealthRed")
			else
				set_texture(self._radial_health_panel:child("radial_health"), NepgearsyHUDReborn:TeammateRadialIDToPath(NepgearsyHUDReborn:GetOption("HealthColor"), "Health"))
			end
		end)

		RedHealth.done = true
	else -- Normal radial
		Hooks:PreHook(HUDTeammate, "set_health", "radial_health_red_set_health_sora", function(self, data)
			if not self._radial_health_panel:child("radial_health_red") then
				self._radial_health_panel:bitmap(RedHealth:health_bitmap("radial_health_red", self._radial_health_panel:w(), self._radial_health_panel:h()))
			end
		end)
		-- Here we don't set RedHealth.done, as vanilla's set_health hook can be used. 
	end
end 

-- // Vanilla compatibility \\ --
if RequiredScript == "lib/managers/hud/hudteammate" and not RedHealth.done then
	RedHealth:setup()
end