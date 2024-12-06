KeybindPage = KeybindPage or class()
KeybindPage._path = ModPath
KeybindPage._data_path = SavePath .. "KeybindPage_data.txt"
KeybindPage._data = {}

function KeybindPage:Save()
	local file = io.open( self._data_path, "w+" )
	if file then
		file:write( json.encode( self._data ) )
		file:close()
	end
end

function KeybindPage:Load()
	local file = io.open( self._data_path, "r" )
	if file then
		self._data = json.decode( file:read("*all") )
		file:close()
	end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_KBP", function( loc )
	loc:load_localization_file( KeybindPage._path .. "loc/en.json", false)
end)

Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_KBP", function( menu_manager )

	MenuCallbackHandler.kbp_save = function(self, item)
		KeybindPage:Save()
	end

	MenuCallbackHandler.np_kbp_func = function(self)
		if managers.menu:active_menu() then
			if managers.menu:active_menu().renderer then
				managers.menu:active_menu().renderer:next_page()
			end
		end
	end
	MenuCallbackHandler.pp_kbp_func = function(self)
		if managers.menu:active_menu() then
			if managers.menu:active_menu().renderer then
				managers.menu:active_menu().renderer:previous_page()
			end
		end
	end

	KeybindPage:Load()
	
	MenuHelper:LoadFromJsonFile( KeybindPage._path .. "menu/kbp_menu.json", KeybindPage, KeybindPage._data )
end )

KeybindPage:Load()