SoundTheAlarm = SoundTheAlarm or class()
SoundTheAlarm._path = ModPath
SoundTheAlarm._data_path = SavePath.. "SoundTheAlarm_data.txt"

-- Menu save
function SoundTheAlarm:Save()
	local file = io.open( self._data_path.. "", "w+" )
	if file then
		file:write( json.encode( self._data ) )
		file:close()
	end
end

-- Menu load
function SoundTheAlarm:Load()
	local file = io.open( self._data_path, "r" )
	if file then
		self._data = json.decode( file:read("*all") )
		file:close()
	end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_SoundTheAlarm", function( loc )
	loc:load_localization_file( SoundTheAlarm._path .. "loc/en.txt", false)
end)

Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_SoundTheAlarm", function( menu_manager )

	MenuCallbackHandler.sta_save = function(self, item)
		SoundTheAlarm:Save()
	end

	-- Keybinds

	MenuCallbackHandler.activate_sta = function(self)
		managers.groupai:state():set_wave_mode("besiege")
		managers.groupai:state():on_police_called(managers.groupai:state().analyse_giveaway("cop_alarm", nil, {
			"vo_cbt"
		}))
	end
	
	MenuHelper:LoadFromJsonFile( SoundTheAlarm._path .. "menu/menu.json", SoundTheAlarm, SoundTheAlarm._data )
	SoundTheAlarm:Save()
end )