FitWeBalling = FitWeBalling or class()
local Net = _G.LuaNetworking
local modpath = ModPath
local savepath = SavePath

-- Menu save
function FitWeBalling:Save()
	local file = io.open( self._data_path, "w+" )
	if file then
		file:write( json.encode( self._data ) )
		file:close()
	end
end

-- Menu load
function FitWeBalling:Load()
	local file = io.open( self._data_path, "r" )
	if file then
		self._data = json.decode( file:read("*all") )
		file:close()
	end
end

-- Called on instance creation
function FitWeBalling:init()
	self._path = modpath
	self._data_path = savepath .. "FuckItWeBalling_data.txt"
	self._data = {}
	self._asset_package = "levels/narratives/vlad/nightclub/world/world"
	self._sender_decorations = {}
	self._peer_unit = {}
	self._asset_units = {
		discoball = Idstring("units/payday2/props/com_prop_club_discoball/com_prop_club_discoball"),
		light_laser = Idstring("units/payday2/props/com_prop_club_light_laser/com_prop_club_light_laser"),
		light_moving = Idstring("units/payday2/props/com_prop_club_light_moving/com_prop_club_light_moving")
	}
	self._sound_events = {
		"dah_party_music",
		"diegetic_club_music",
		"diegetic_lounge_music"
	}
	self:Load()
	if self._data.enabled == nil then
		self._data.enabled = true
		self:Save()
	end
	if self._data.assets_enabled == nil then
		self._data.assets_enabled = true
		self:Save()
	end
	if self._data.custom_sound_id == nil then
		self._data.custom_sound_id = 1
		self:Save()
	end
end

-- Called on keybind pressed
function FitWeBalling:activate()
	self:Load()
	if not self._data.enabled then return end

	self._player_unit = managers.player:player_unit()

	if alive(self._player_unit) then
		self._player_unit:sound():play(self._currently_playing_sound_event and self._currently_playing_sound_event.."_stop" or self._sound_events[self._data.custom_sound_id].. "_stop", nil, true)
		self._player_unit:sound():play(self._sound_events[self._data.custom_sound_id], nil, true)
		self._currently_playing_sound_event = self._sound_events[self._data.custom_sound_id]
		self:delete_assets()
		self:load_packages()
		self:spawn_assets()
	end
end

-- Called on keybind pressed
function FitWeBalling:deactivate()

	if not self._data.enabled or not self._currently_playing_sound_event then return end

	self._player_unit = managers.player:player_unit()

	if alive(self._player_unit) then
		self._player_unit:sound():play(self._currently_playing_sound_event.. "_stop", nil, true)
		self._currently_playing_sound_event = nil
	end

	managers.fiwb:delete_assets()
end

-- Loads asset package for the mod
function FitWeBalling:load_packages()
	if not PackageManager:loaded(self._asset_package) then
		if PackageManager:package_exists(self._asset_package) then
			PackageManager:set_resource_loaded_clbk(Idstring("unit"), nil)
			PackageManager:load(self._asset_package.."_init")
			PackageManager:load(self._asset_package)
			PackageManager:set_resource_loaded_clbk(Idstring("unit"), callback(managers.sequence, managers.sequence, "clbk_pkg_manager_unit_loaded"))
		end
	end
end

-- Unloads asset package for the mod
function FitWeBalling:unload_packages()
	if PackageManager:loaded(self._asset_package) and Global.game_settings.level_id ~= "nightclub" then
		PackageManager:unload(self._asset_package)
	end
end

-- Spawns the corresponding assets and animates them
function FitWeBalling:spawn_assets(peer)

	if not self._data.assets_enabled then return end

	if PackageManager:loaded(self._asset_package) then

		if not peer then -- Local mode
			self._local_assets = {}

			self._local_assets._discoball = safe_spawn_unit(self._asset_units.discoball, Vector3() , Rotation())

			self._local_assets._light_laser = safe_spawn_unit(self._asset_units.light_laser, Vector3() , Rotation(180,0,0))
			self._local_assets._light_laser_2 = safe_spawn_unit(self._asset_units.light_laser, Vector3() , Rotation())

			self._local_assets._light_moving = safe_spawn_unit(self._asset_units.light_moving, Vector3() , Rotation(180,0,180))
			self._local_assets._light_moving:anim_play_loop(Idstring("show"), 0, self._local_assets._light_moving:anim_length(Idstring("show")))
			self._local_assets._light_moving_2 = safe_spawn_unit(self._asset_units.light_moving, Vector3() , Rotation(0,0,180))
			self._local_assets._light_moving_2:anim_play_loop(Idstring("show"), 0, self._local_assets._light_moving_2:anim_length(Idstring("show")))

		else -- Peer mode
			self._sender_decorations[peer] = {}

			self._sender_decorations[peer]._discoball = safe_spawn_unit(self._asset_units.discoball, Vector3() , Rotation())

			self._sender_decorations[peer]._light_laser = safe_spawn_unit(self._asset_units.light_laser, Vector3() , Rotation(0,180,0))
			self._sender_decorations[peer]._light_laser_2 = safe_spawn_unit(self._asset_units.light_laser, Vector3() , Rotation())

			self._sender_decorations[peer]._light_moving = safe_spawn_unit(self._asset_units.light_moving, Vector3() , Rotation(180,0,180))
			self._sender_decorations[peer]._light_moving:anim_play_loop(Idstring("show"), 0, self._sender_decorations[peer]._light_moving:anim_length(Idstring("show")))
			self._sender_decorations[peer]._light_moving_2 = safe_spawn_unit(self._asset_units.light_moving, Vector3() , Rotation(0,0,180))
			self._sender_decorations[peer]._light_moving_2:anim_play_loop(Idstring("show"), 0, self._sender_decorations[peer]._light_moving_2:anim_length(Idstring("show")))
		end
	end
end

-- Despawns any assets previously spawned by the local player or the peers
function FitWeBalling:delete_assets()
	if self._local_assets then
		for i, unit in pairs(self._local_assets) do
			World:delete_unit(unit)
			self._local_assets[i] = nil
		end
	end

	for i,peer in ipairs(self._sender_decorations) do
		if not peer then break end
		for ii,unit in ipairs(peer) do
			World:delete_unit(unit)
			self._sender_decorations[i][ii] = nil
		end
	end
end

-- Run on every frame, updates asset position
function FitWeBalling:update(t, dt)
	if not self._data.assets_enabled then return end
	if self._local_assets and alive(self._local_assets._discoball) and alive(self._player_unit) then
		Net:SendToPeers("Fiwb_update")
		self._local_assets._discoball:set_position(self._player_unit:position() + Vector3(0,0,650))
		self._local_assets._light_laser:set_position(self._player_unit:position() + Vector3(0,500,5))
		self._local_assets._light_moving:set_position(self._player_unit:position() + Vector3(0,500,650))
		self._local_assets._light_laser_2:set_position(self._player_unit:position() + Vector3(0,-500,5))
		self._local_assets._light_moving_2:set_position(self._player_unit:position() + Vector3(0,-500,650))
	end
end

-- Run on every frame when called from the Network by another peer, updates their assets position
function FitWeBalling:update_peer(sender)
	if not self._data.enabled then return end
	if not self._data.assets_enabled then return end
	if not self._sender_decorations[sender] then -- Means it's the first update
		self._peer_unit[sender] = managers.network:session():peer(sender):unit()
		if not PackageManager:loaded(self._asset_package) then
			self:load_packages()
		end
		self:spawn_assets(sender)
	end

	if alive(self._peer_unit[sender]) then
		self._sender_decorations[sender]._discoball:set_position(self._peer_unit[sender]:position() + Vector3(0,0,650))
		self._sender_decorations[sender]._light_laser:set_position(self._peer_unit[sender]:position() + Vector3(0,500,5))
		self._sender_decorations[sender]._light_laser_2:set_position(self._peer_unit[sender]:position() + Vector3(0,-500,5))
		self._sender_decorations[sender]._light_moving:set_position(self._peer_unit[sender]:position() + Vector3(0,500,650))
		self._sender_decorations[sender]._light_moving_2:set_position(self._peer_unit[sender]:position() + Vector3(0,-500,650))
	end
end

-- Receiver for the network message
Hooks:Add("NetworkReceivedData", "NetworkReceivedData_FIWB", function(sender, id, data)
	if id == "Fiwb_update" then
		managers.fiwb:update_peer(sender)
	end
end)

-- Hooking stuff for update func and to avoid crash on mission reload
if RequiredScript == "lib/setups/setup" then
	Hooks:PreHook(Setup, "init_managers", "init_managers_fiwb", function (self, managers)
		managers.fiwb = FitWeBalling:new()
	end)

	Hooks:PostHook(Setup, "update", "update_fiwb", function (self, t, dt)
		managers.fiwb:update(t, dt)
	end)
end

if RequiredScript == "lib/managers/gameplaycentralmanager" then
	Hooks:PreHook(GamePlayCentralManager, "restart_the_game", "restart_the_game_fiwb", function (self)
		managers.fiwb:delete_assets()
		managers.fiwb:unload_packages()
	end)

	Hooks:PreHook(GamePlayCentralManager, "start_the_game", "start_the_game_fiwb", function (self)
		managers.fiwb:delete_assets()
		managers.fiwb:unload_packages()
	end)

	Hooks:PreHook(GamePlayCentralManager, "stop_the_game", "stop_the_game_fiwb", function (self)
		managers.fiwb:delete_assets()
		managers.fiwb:unload_packages()
	end)
end