local orig_td = AchievementsTweakData.init

function AchievementsTweakData:init(tweak_data)
	orig_td(self, tweak_data)

	local veryhard_and_above = {
		"overkill",
		"overkill_145",
		"easy_wish",
		"overkill_290",
		"sm_wish"
	}

	--// SILK ROAD CAMPAIGN \\--

	self.complete_heist_achievements.story_very_hard_mex = {
		job = "mex",
		story = "story_very_hard_mex",
		difficulty = veryhard_and_above
	}
	self.complete_heist_achievements.story_very_hard_bex = {
		job = "bex",
		story = "story_very_hard_bex",
		difficulty = veryhard_and_above
	}
	self.complete_heist_achievements.story_very_hard_pex = {
		job = "pex",
		story = "story_very_hard_pex",
		difficulty = veryhard_and_above
	}
	self.complete_heist_achievements.story_very_hard_fex = {
		job = "fex",
		story = "story_very_hard_fex",
		difficulty = veryhard_and_above
	}

	--// CITY OF GOLD CAMPAIGN \\--

	self.complete_heist_achievements.story_very_hard_chas = {
		job = "chas",
		story = "story_very_hard_chas",
		difficulty = veryhard_and_above
	}
	self.complete_heist_achievements.story_very_hard_sand = {
		job = "sand",
		story = "story_very_hard_sand",
		difficulty = veryhard_and_above
	}
	self.complete_heist_achievements.story_very_hard_chca = {
		job = "chca",
		story = "story_very_hard_chca",
		difficulty = veryhard_and_above
	}
	self.complete_heist_achievements.story_very_hard_pent = {
		job = "pent",
		story = "story_very_hard_pent",
		difficulty = veryhard_and_above
	}

	--// TEXAS HEAT CAMPAIGN \\--

	self.complete_heist_achievements.story_very_hard_ranc = {
		job = "ranc",
		story = "story_very_hard_ranc",
		difficulty = veryhard_and_above
	}
	self.complete_heist_achievements.story_very_hard_trai = {
		job = "trai",
		story = "story_very_hard_trai",
		difficulty = veryhard_and_above
	}
	self.complete_heist_achievements.story_very_hard_corp = {
		job = "corp",
		story = "story_very_hard_corp",
		difficulty = veryhard_and_above
	}
	self.complete_heist_achievements.story_very_hard_deep = {
		job = "deep",
		story = "story_very_hard_deep",
		difficulty = veryhard_and_above
	}

end