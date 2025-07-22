_G.RedHealth = _G.RedHealth or {}
RedHealth._path = ModPath
RedHealth._data_path = SavePath .. "RedHealth_data.txt"
RedHealth._data = {}

function RedHealth:Save()
	local file = io.open( self._data_path, "w+" )
	if file then
		file:write( json.encode( self._data ) )
		file:close()
	end
end

function RedHealth:Load()
	local file = io.open( self._data_path, "r" )
	if file then
		self._data = json.decode( file:read("*all") )
		file:close()
	end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_RedHealth", function( loc )
	loc:load_localization_file( RedHealth._path .. "loc/en.json", false)
end)

Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_RedHealth", function( menu_manager )

	MenuCallbackHandler.redhealth_save = function(self, item)
		RedHealth:Save()
	end

	MenuCallbackHandler.callback_rh_health_value = function(self, item)
		RedHealth._data.health_value = item:value()
		RedHealth:Save()
	end

	MenuCallbackHandler.callback_rh_death_sentence_only = function(self, item)
		RedHealth._data.death_sentence_only = item:value() == "on" or false
		RedHealth:Save()
	end

	RedHealth:Load()

	if RedHealth._data.health_value == nil then
		RedHealth._data.health_value = 225
		RedHealth:Save()
	end

	if RedHealth._data.death_sentence_only == nil then
		RedHealth._data.death_sentence_only = false
		RedHealth:Save()
	end
	
	MenuHelper:LoadFromJsonFile( RedHealth._path .. "menu/health225menu.json", RedHealth, RedHealth._data )
end )

RedHealth:Load()