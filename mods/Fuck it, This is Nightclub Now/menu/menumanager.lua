local modpath = ModPath

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_FitWeBalling", function( loc )
	loc:load_localization_file( modpath .. "loc/en.txt", false)
end)

Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_FitWeBalling", function( menu_manager )

	MenuCallbackHandler.fiwb_save = function(self, item)
		managers.fiwb:Save()
	end

	MenuCallbackHandler.callback_fiwb_enabled = function(self, item)
		managers.fiwb._data.enabled = item:value() == "on"
		managers.fiwb:Save()
	end

	MenuCallbackHandler.callback_fiwb_enabled_assets = function(self, item)
		managers.fiwb._data.assets_enabled = item:value() == "on"
		managers.fiwb:Save()
	end
	
	MenuCallbackHandler.callback_fiwb_custom_sound = function(self, item)
		managers.fiwb._data.custom_sound_id = item:value()
		log(item:value())
		managers.fiwb:Save()
	end

	MenuCallbackHandler.callback_fiwb_custom_sound_stop = function(self, item)
		managers.fiwb._data.custom_sound_id_stop = item:value()
		log(item:value())
		managers.fiwb:Save()
	end

	-- Keybinds

	MenuCallbackHandler.activate_fiwb = function(self)
		managers.fiwb:activate()
	end
	MenuCallbackHandler.deactivate_fiwb = function(self)
		managers.fiwb:deactivate()
	end
	
	MenuHelper:LoadFromJsonFile( managers.fiwb._path .. "menu/menu.json", managers.fiwb, managers.fiwb._data )
	managers.fiwb:Save()
end )

-- Hooking stuff to avoid crash on mission reload
Hooks:PostHook(MenuManager, "on_leave_lobby", "on_leave_lobby_fiwb", function (self)
	managers.fiwb:delete_assets()
	managers.fiwb:unload_packages()
end)

Hooks:PostHook(MenuCallbackHandler, "load_start_menu_lobby", "load_start_menu_lobby_fiwb", function (self)
	managers.fiwb:delete_assets()
	managers.fiwb:unload_packages()
end)

Hooks:PostHook(MenuCallbackHandler, "load_start_menu", "load_start_menu_fiwb", function (self)
	managers.fiwb:delete_assets()
	managers.fiwb:unload_packages()
end)

Hooks:PostHook(MenuCallbackHandler, "_dialog_end_game_yes", "_dialog_end_game_yes_fiwb", function (self)
	managers.fiwb:delete_assets()
	managers.fiwb:unload_packages()
end)