Hooks:PreHook(ExplosionManager, "play_sound_and_effects", "DisableHE", function (self, position, normal, range, effect_params)
	if effect_params.sound_event and effect_params.sound_event == "round_explode" and effect_params.sound_muffle_effect == true and effect_params.effect == "effects/payday2/particles/impacts/shotgun_explosive_round" then
		effect_params.sound_event = ""
		effect_params.sound_muffle_effect = false
	end
end)