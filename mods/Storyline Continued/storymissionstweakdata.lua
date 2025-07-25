--[[ FORMAT
	table.insert(self.missions, self:_mission("sm_+1", {
		reward_id = "menu_sm_default_reward",
		voice_line = "Play_pln_stq_01",
		objectives = {
			{
				self:_level_progress("story_very_hard_LEVELID", 1, {
					name_id = "menu_sm_very_hard_LEVELID" -- Where this would be the ID of the complete_heist_achievements table
				})
			}
		},
		rewards = self:_default_reward()
	}))
]]

local orig_td = StoryMissionsTweakData._init_missions
function StoryMissionsTweakData:_init_missions(tweak_data)

	orig_td(self, tweak_data)

	table.remove(self.missions, #self.missions) -- Remove end message
	
	-- Divider
	table.insert(self.missions, self:_mission("sm_act_4", {
		rewarded = true,
		completed = true,
		is_header = true,
		objectives = {}
	}))

	--// SILK ROAD CAMPAIGN \\--

	table.insert(self.missions, self:_mission("sm_54", {
		reward_id = "menu_sm_default_reward",
		objectives = {
			{
				self:_level_progress("story_very_hard_mex", 1, {
					name_id = "menu_sm_very_hard_mex"
				})
			}
		},
		rewards = self:_default_reward()
	}))
	table.insert(self.missions, self:_mission("sm_55", {
		reward_id = "menu_sm_default_reward",
		objectives = {
			{
				self:_level_progress("story_very_hard_bex", 1, {
					name_id = "menu_sm_very_hard_bex"
				})
			}
		},
		rewards = self:_default_reward()
	}))
	table.insert(self.missions, self:_mission("sm_56", {
		reward_id = "menu_sm_default_reward",
		objectives = {
			{
				self:_level_progress("story_very_hard_pex", 1, {
					name_id = "menu_sm_very_hard_pex"
				})
			}
		},
		rewards = self:_default_reward()
	}))
	table.insert(self.missions, self:_mission("sm_57", {
		reward_id = "menu_sm_default_reward",
		objectives = {
			{
				self:_level_progress("story_very_hard_fex", 1, {
					name_id = "menu_sm_very_hard_fex"
				})
			}
		},
		rewards = self:_default_reward()
	}))

	--// CITY OF GOLD CAMPAIGN \\--

	table.insert(self.missions, self:_mission("sm_58", {
		reward_id = "menu_sm_default_reward",
		objectives = {
			{
				self:_level_progress("story_very_hard_chas", 1, {
					name_id = "menu_sm_very_hard_chas"
				})
			}
		},
		rewards = self:_default_reward()
	}))
	table.insert(self.missions, self:_mission("sm_59", {
		reward_id = "menu_sm_default_reward",
		objectives = {
			{
				self:_level_progress("story_very_hard_sand", 1, {
					name_id = "menu_sm_very_hard_sand"
				})
			}
		},
		rewards = self:_default_reward()
	}))
	table.insert(self.missions, self:_mission("sm_60", {
		reward_id = "menu_sm_default_reward",
		objectives = {
			{
				self:_level_progress("story_very_hard_chca", 1, {
					name_id = "menu_sm_very_hard_chca"
				})
			}
		},
		rewards = self:_default_reward()
	}))
	table.insert(self.missions, self:_mission("sm_61", {
		reward_id = "menu_sm_default_reward",
		objectives = {
			{
				self:_level_progress("story_very_hard_pent", 1, {
					name_id = "menu_sm_very_hard_pent"
				})
			}
		},
		rewards = self:_default_reward()
	}))

	--// TEXAS HEAT CAMPAIGN \\--

	table.insert(self.missions, self:_mission("sm_62", {
		reward_id = "menu_sm_default_reward",
		objectives = {
			{
				self:_level_progress("story_very_hard_ranc", 1, {
					name_id = "menu_sm_very_hard_ranc"
				})
			}
		},
		rewards = self:_default_reward()
	}))
	table.insert(self.missions, self:_mission("sm_63", {
		reward_id = "menu_sm_default_reward",
		objectives = {
			{
				self:_level_progress("story_very_hard_trai", 1, {
					name_id = "menu_sm_very_hard_trai"
				})
			}
		},
		rewards = self:_default_reward()
	}))
	table.insert(self.missions, self:_mission("sm_64", {
		reward_id = "menu_sm_default_reward",
		objectives = {
			{
				self:_level_progress("story_very_hard_corp", 1, {
					name_id = "menu_sm_very_hard_corp"
				})
			}
		},
		rewards = self:_default_reward()
	}))
	table.insert(self.missions, self:_mission("sm_65", {
		reward_id = "menu_sm_default_reward",
		objectives = {
			{
				self:_level_progress("story_very_hard_deep", 1, {
					name_id = "menu_sm_very_hard_deep"
				})
			}
		},
		rewards = self:_default_reward()
	}))

	table.insert(self.missions, self:_mission("sm_end", {
		rewarded = true,
		completed = true,
		last_mission = true,
		objectives = {}
	})) -- Reinsert end message

end