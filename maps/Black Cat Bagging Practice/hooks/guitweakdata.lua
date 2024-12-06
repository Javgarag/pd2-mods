Hooks:PostHook( GuiTweakData, "init", "rushing_contact", function(self)
	local contact_data = {
		id = "rushing_practice",
		name_id = "contact_rushing_name",
		{
			desc_id = "contact_rushing_desc",
			video = "bain",
			post_event = nil
		}
	}
	
	table.insert(self.crime_net.codex[1], contact_data)
end)