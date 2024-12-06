_G.ED2ChatHelper = _G.ED2ChatHelper or {}
ED2ChatHelper._path = ModPath
ED2ChatHelper._data_path = SavePath .. "ED2ChatHelper_data.txt"
ED2ChatHelper._data = {}

function ED2ChatHelper:Save()
	local file = io.open( self._data_path, "w+" )
	if file then
		file:write( json.encode( self._data ) )
		file:close()
	end
end

function ED2ChatHelper:Load()
	local file = io.open( self._data_path, "r" )
	if file then
		self._data = json.decode( file:read("*all") )
		file:close()
	end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_ED2ChatHelper", function( loc )
	loc:load_localization_file( ED2ChatHelper._path .. "loc/en.json", false)
end)

Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_ED2ChatHelper", function( menu_manager )

	MenuCallbackHandler.ED2ChatHelper_save = function(self, item)
		ED2ChatHelper:Save()
	end

	MenuCallbackHandler.callback_prefix_input = function(self, item)
		ED2ChatHelper._data.prefix = item:value()
		ED2ChatHelper:Save()
	end

	MenuCallbackHandler.callback_takeover_input = function(self, item)
		ED2ChatHelper._data.takeover = item:value() == "on"
		ED2ChatHelper:Save()
	end

	ED2ChatHelper:Load()

	if ED2ChatHelper._data.prefix == nil then
		ED2ChatHelper._data.prefix = "Got #"
		ED2ChatHelper:Save()
	end

	if ED2ChatHelper._data.takeover == nil then
		ED2ChatHelper._data.takeover = false
		ED2ChatHelper:Save()
	end
	
	MenuHelper:LoadFromJsonFile( ED2ChatHelper._path .. "menu/ed2machinechathelper.json", ED2ChatHelper, ED2ChatHelper._data )
end )

ED2ChatHelper:Load()