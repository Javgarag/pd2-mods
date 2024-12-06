PlaceMyECMDown = PlaceMyECMDown or class()
PlaceMyECMDown._path = ModPath
PlaceMyECMDown._data_path = SavePath .. "PlaceMyECMDown_data.txt"
PlaceMyECMDown._data = {}

function PlaceMyECMDown:Save()
	local file = io.open( self._data_path, "w+" )
	if file then
		file:write( json.encode( self._data ) )
		file:close()
	end
end

function PlaceMyECMDown:Load()
	local file = io.open( self._data_path, "r" )
	if file then
		self._data = json.decode( file:read("*all") )
		file:close()
	end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_PlaceMyECMDown", function( loc )
	loc:load_localization_file( PlaceMyECMDown._path .. "loc/en.json", false)
end)

Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_PlaceMyECMDown", function( menu_manager )

	MenuCallbackHandler.pmed_save = function(self, item)
		PlaceMyECMDown:Save()
	end

	MenuCallbackHandler.callback_pmedenabled_input = function(self, enableditem)
		PlaceMyECMDown._data.enabled = enableditem:value() == "on"
		local menu = MenuHelper:GetMenu("pmed")
		for _, item in pairs(menu and menu._items_list or {}) do
  		  if item:name() ~= "toggle_pmedenabled" then
       	 	item:set_enabled(enableditem:value() == "on")
   		 end
		end
		PlaceMyECMDown:Save()
	end

	MenuCallbackHandler.callback_ignore_joat_pmed_input = function(self, item)
		PlaceMyECMDown._data.ignore_joat = item:value() == "on"
		PlaceMyECMDown:Save()
	end

	-- Keybinds

	MenuCallbackHandler.haltexec_pmed = function(self)
		PlaceMyECMDown.haltexec = true
		managers.mission._fading_debug_output:script().log("Place My ECM Down", tweak_data.system_chat_color)
		managers.mission._fading_debug_output:script().log("Execution halted for mod:", Color("a7ddf4"))
	end
	MenuCallbackHandler.skip_ecm_pmed = function(self)
		PlaceMyECMDown.skip_check = true
		managers.mission._fading_debug_output:script().log("Skipping next ECM check, resuming on next ECM drop", tweak_data.system_chat_color)
		managers.mission._fading_debug_output:script().log("Place My ECM Down", Color("a7ddf4"))
	end

	PlaceMyECMDown:Load()

	if PlaceMyECMDown._data.enabled == nil then
		PlaceMyECMDown._data.enabled = true
		PlaceMyECMDown:Save()
	end
	if PlaceMyECMDown._data.ignore_joat == nil then
		PlaceMyECMDown._data.ignore_joat = false
		PlaceMyECMDown:Save()
	end
	
	MenuHelper:LoadFromJsonFile( PlaceMyECMDown._path .. "menu/pmed_menu.json", PlaceMyECMDown, PlaceMyECMDown._data )
end )

PlaceMyECMDown:Load()