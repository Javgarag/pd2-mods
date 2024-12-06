_G.PoolAlert = _G.PoolAlert or {}
PoolAlert._path = ModPath
PoolAlert._data_path = SavePath .. "PoolAlert_data.txt"
PoolAlert._data = {}

function PoolAlert:Save()
	local file = io.open( self._data_path, "w+" )
	if file then
		file:write( json.encode( self._data ) )
		file:close()
	end
end

function PoolAlert:Load()
	local file = io.open( self._data_path, "r" )
	if file then
		self._data = json.decode( file:read("*all") )
		file:close()
	end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_PoolAlert", function( loc )
	loc:load_localization_file( PoolAlert._path .. "loc/en.json", false)
end)

Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_PoolAlert", function( menu_manager )

	MenuCallbackHandler.poolalert_save = function(self, item)
		PoolAlert:Save()
	end

	MenuCallbackHandler.clbk_poolalert_interval = function(self, item)
		PoolAlert._data.interval = item:value()
		PoolAlert:Save()
	end

	PoolAlert:Load()

	if PoolAlert._data.interval == nil then
		PoolAlert._data.interval = 120
		PoolAlert:Save()
	end
	
	MenuHelper:LoadFromJsonFile( PoolAlert._path .. "menu/poolalertmenu.json", PoolAlert, PoolAlert._data )
end )

PoolAlert:Load()