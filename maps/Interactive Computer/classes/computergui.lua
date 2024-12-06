-- NOTE: ENVIRONMENT BLOOM MUST BE SET TO 0,0,1,0 FOR THE SCREEN TO PROPERLY SHOW UP WITH NO ILLUMINATION ISSUES. 
-- If you desire, you can make a small environment area covering the computer screen with no bloom, so you can apply bloom effects in your map's other areas.

ComputerGui = ComputerGui or class()
ComputerGui.BASE_ASSET_PATH = "guis/textures/computergui/"

-- // INITIALIZATION \\

-- ComputerGui:init -> Initial extension setup, when the game startups.
function ComputerGui:init(unit)
    self._unit = unit
	self._visible = true
	self._cull_distance = self._cull_distance or 5000
	self._size_multiplier = self._size_multiplier or 1
	self._gui_object = self._gui_object or "gui_name"
	self._new_gui = World:newgui()

	self:add_workspace(self._unit:get_object(Idstring(self._gui_object)))
	self:setup()

	self._unit:set_extension_update_enabled(Idstring("computer_gui"), false)
	self._update_enabled = false
end

-- ComputerGui:add_workspace -> Set up GUI workspace for the computer screen.
function ComputerGui:add_workspace(gui_object)
	local gui_width, gui_height = managers.gui_data:get_base_res() -- VERY IMPORTANT. This is so the mouse movement is ALWAYS synced with the user's resolution.
	self._resolution_changed_callback = callback(self, self, "game_resolution_changed")
	managers.viewport:add_resolution_changed_func(self._resolution_changed_callback)
	self._ws = self._new_gui:create_object_workspace(gui_width, gui_height, gui_object, Vector3(0, 0, 0))
	self._gui = self._ws:panel():gui(Idstring("guis/computer_gui/base"))
	self._gui_script = self._gui:script()
	self._pointer = self._gui_script.pointer
end

-- ComputerGui:setup -> Populate the desktop with apps specified in .unit. 
function ComputerGui:setup()
	self._gui_script.panel:set_size(self._gui_script.panel:parent():size())

	-- APPLICATION CONFIGURATION
	local application_file = io.open(BeardLib.current_level._mod.ModPath.. self._application_config.. ".json", "r")
	if not application_file then
		log("[ComputerGui:setup] Could not find applications file. Make sure you have included it inside the unit's configuration.")
		return
	end

	self._applications = json.decode(application_file:read("*all"))
	self._desktop = {}
	for app_id, app in pairs(self._applications) do
		-- Icon setup
		self._desktop["_app_".. app_id.."_icon"] = self._gui_script.panel:panel({
			name = app_id,
			w = 75,
			h = 95,
			x = 30 ,
			y = 30 + 95 * (app_id - 1),
			layer = 2
		})
		self._desktop["_app_".. app_id.."_icon"]:bitmap({
			texture = app.icon,
			name = "app_bg",
			w = 75,
			layer = 1,
			h = 75,
		})
	end
end

-- // AT ENTER \\

function ComputerGui:start()
	if not self._started then
		self:_start()
		if managers.network:session() then
			managers.network:session():send_to_peers_synched("start_computer_gui", self._unit) -- Will sync other clients' units so they too see the computer gui.
		end
	end
end

-- ComputerGui:_start -> Turn on the system, enable mouse control, and lock the camera to the screen.
function ComputerGui:_start()
	self._started = true
	self._unit:set_extension_update_enabled(Idstring("computer_gui"), true)
	self._update_enabled = true
	--self:post_event(self._start_event)

	self:show()
	self._unit:base():start()

	self._camera_pos = self._unit:get_object(Idstring("camera_pos"))
	self._teleport_pos = self._unit:get_object(Idstring("teleport_pos"))
	if not (self._camera_pos or self._teleport_pos) then
		log("[ComputerGui:_start] ERROR: Position object missing. Check model!")
		return
	end

	self:create_camera()
	managers.worldcamera:play_world_camera("computer_gui_camera")

	managers.player:warp_to(self._teleport_pos:position(), self._teleport_pos:rotation())
	local state = managers.player:get_current_state()
	state:_toggle_gadget(state._equipped_unit:base())

	-- [SPACE] to exit text
	self._text_workspace = Overlay:newgui()
	self._hud = self._text_workspace:create_screen_workspace(0, 0, 1, 1)
	self._quit_text = self._hud:panel():text({
		align = "center",
		text = managers.localization:text("computer_gui_hud_string"),
		font = tweak_data.menu.pd2_large_font,
		font_size = 80,
		color = Color.white
	})
	self._quit_text:set_y(self._quit_text:y() + 50)

	-- mouse init
	local data = {
		mouse_move = callback(self, self, "mouse_moved"),
		mouse_press = callback(self, self, "mouse_pressed"),
		mouse_release = callback(self, self, "mouse_released"),
		id = "computer_gui_mouse"
	}
	managers.mouse_pointer:use_mouse(data)
	managers.mouse_pointer:disable()

	self._unit:set_extension_update_enabled(Idstring("computer_gui"), true)
	self._update_enabled = true

	if Network:is_client() then
		return
	end
end

-- ComputerGui:sync_start -> Network version of ComputerGui:start(), called by UnitNetworkHandler (See /hooks/UnitNetworkHandler.lua)
function ComputerGui:sync_start() 
	self:_start()
end

-- ComputerGui:create_camera -> Creates a world camera to run later so the camera can be locked. The model needs to have an object (empty) called "camera_pos".
function ComputerGui:create_camera()
	self._camera = managers.worldcamera:create_world_camera("computer_gui_camera")
	self._camera:set_duration(10000000000)
	self._camera:add_point(self._camera_pos:position(), self._camera_pos:rotation())
end

-- // MOUSE MOVEMENT HANDLING \\

-- ComputerGui:mouse_moved -> Triggers when the mouse is moved by any distance.
function ComputerGui:mouse_moved(o, x, y)
	if not alive(self._unit) then return end -- Prevent crash on restart

	self._pointer:set_x(x)
	self._pointer:set_y(y)

	if self:inside_app_icon(x, y) or self:inside_app_window_close_button(x, y) then
		self._pointer:set_texture_rect(20,0,19,23) -- type "link"
	elseif self:inside_app_window_drag_hitbox(x, y) and not self._dragging then
		self._pointer:set_texture_rect(40,0,19,23) -- type "hand"
	else
		self._pointer:set_texture_rect(0,0,19,23) -- type "arrow"
	end

	if self._dragging then -- Window dragging
		self._window_on_top.panel:set_x(self._pointer:x() - self._dragging_offset_x)
		self._window_on_top.panel:set_y(self._pointer:y() - self._dragging_offset_y)
		self._pointer:set_texture_rect(60,0,19,23) -- type "grab"
	end
end

-- ComputerGui:mouse_pressed -> Triggers when the mouse is pressed.
function ComputerGui:mouse_pressed(o, button, x, y)
	if button == Idstring("0") then

		local inside, app_id = self:inside_app_icon(x, y)
		if inside and not self["_window_opened_".. app_id]  then
			self:open_window(app_id)
			self._pointer:set_texture_rect(0,0,19,23) -- type "arrow"
		end

		-- Close the window if click over the button to close
		local inside, app_id = self:inside_app_window_close_button(x, y)
		if inside and self["_window_opened_".. app_id] then
			self._windows[app_id].panel:set_visible(false)
			self["_window_opened_".. app_id] = false
			self._pointer:set_texture_rect(0,0,19,23) -- type "arrow"
		end

		-- Start dragging
		local inside, app_id = self:inside_app_window_drag_hitbox(x, y)
		if inside and self["_window_opened_".. app_id] then
			self._dragging = true
			self._dragging_offset_x = self._pointer:x() - self._windows[app_id].panel:x()
			self._dragging_offset_y = self._pointer:y() - self._windows[app_id].panel:y()
			self._window_on_top = self._windows[app_id]

			if self._last_window_on_top then
				self._last_window_on_top.panel:set_layer(3)
			end

			self._window_on_top.panel:set_layer(5)
			self._pointer:set_texture_rect(60,0,19,23) -- type "grab"
		end
	end
end

-- ComputerGui:mouse_released -> Triggers when the mouse, which was previously pressed, is released.
function ComputerGui:mouse_released()
	if self._dragging then -- Stop dragging
		self._dragging = false
		self._last_window_on_top = self._window_on_top
		self._window_on_top = nil
		self._dragging_offset_x = nil
		self._dragging_offset_y = nil
		self._pointer:set_texture_rect(0,0,19,23) -- type "arrow"
	end
end

-- ComputerGui:inside_app_icon -> Check if the pointer is currently inside a clickable application button. Returns: is_inside, app_id
function ComputerGui:inside_app_icon(x,y)
	for app_id,_ in pairs(self._applications) do
		if self._desktop["_app_".. app_id.."_icon"]:inside(x,y) and not self:item_obscured(self._desktop["_app_".. app_id.."_icon"]) then
			return true, app_id
		end
	end
	return false
end

-- ComputerGui:inside_app_window_close_button -> Check if the pointer is currently inside a clickable window close button. Returns: is_inside, app_id
function ComputerGui:inside_app_window_close_button(x, y)
	for app_id in pairs(self._applications) do
		if self["_window_opened_".. app_id] and self._windows and self._windows[app_id] and self._windows[app_id].close_button:inside(x,y) and not self:item_obscured(self._windows[app_id].close_button) then
			return true, app_id
		end
	end
	return false
end

-- ComputerGui:inside_app_window_drag_hitbox -> Check if the pointer is currently inside a clickable window drag button hitbox. Returns: is_inside, app_id
function ComputerGui:inside_app_window_drag_hitbox(x, y)
	for app_id in pairs(self._applications) do
		if self["_window_opened_".. app_id] and self._windows and self._windows[app_id] and self._windows[app_id].drag_hitbox:inside(x,y) and not self:item_obscured(self._windows[app_id].drag_hitbox) then
			return true, app_id
		end
	end
	return false
end

function ComputerGui:item_obscured(item)
	if not self._windows then return false end
    local target_rect = {
		x = item:x(),
		y = item:y(),
		w = item:w(),
		h = item:h()
	}

    for _,window in pairs(self._windows) do
        if window.panel ~= item:parent() then -- Revise
            local rect = {
				x = window.panel:x(),
				y = window.panel:y(),
				w = window.panel:w(),
				h = window.panel:h()
			}

            if self:rect_inside(target_rect, rect) then
                return true
            end
        end
    end

    return false
end

function ComputerGui:rect_inside(target, rect)
    return rect.x <= target.x and rect.y <= target.y and rect.x + rect.w >= target.x + target.w and rect.y + rect.h >= target.y + target.h
end
-- // SCREEN ACTIONS \\

-- ComputerGui:open_window -> Open the panel specified in the application configuration of id app_id
function ComputerGui:open_window(app_id)
	self._windows = self._windows or {}
	self["_window_opened_".. app_id] = true

	if DB:has(Idstring("gui"), Idstring(self._applications[app_id].panel)) ~= true then
		log("[ComputerGui:open_window] Couldn't find the .gui file to load the window. Check your paths!")
		return
	end

	if not self._windows[app_id] then -- If the window was previously closed, don't create it again.
		self._windows[app_id] = self._gui_script.panel:gui(Idstring(self._applications[app_id].panel)):script()
	end

	self._windows[app_id].panel:set_visible(true)
	self._windows[app_id].panel:set_layer(self._last_window_on_top and self._last_window_on_top.panel:layer() + 2 or 3) -- Set the layer above the previous window.

	self._window_on_top = self._windows[#self._windows - 1] or self._windows[app_id]
end

-- ComputerGui:hide -> Turn off the workspace.
function ComputerGui:hide()
	self._ws:hide()
end

-- ComputerGui:show -> Turn on the workspace.
function ComputerGui:show()
	self._ws:show()
end

-- ComputerGui:set_visible -> Set the screen's visibility.
function ComputerGui:set_visible(visible)
	self._visible = visible
	self._gui:set_visible(visible)
end

-- ComputerGui:lock_gui -> Freeze the screen.
function ComputerGui:lock_gui()
	self._ws:set_cull_distance(self._cull_distance)
	self._ws:set_frozen(true)
end

-- // AT EXIT \\

-- ComputerGui:destroy -> Destroy the workspace and all the screen-related information.
function ComputerGui:destroy()
	if alive(self._new_gui) and alive(self._ws) then
		self._new_gui:destroy_workspace(self._ws)

		self._ws = nil
		self._new_gui = nil
	end
end

-- ComputerGui:_close -> Return the camera to the player, remove virtual mouse.
function ComputerGui:_close()
	managers.worldcamera:stop_world_camera()
	self._text_workspace:destroy_workspace(self._hud)
	managers.mouse_pointer:remove_mouse("computer_gui_mouse")
	local state = managers.player:get_current_state()
	state:_toggle_gadget(state._equipped_unit:base())
	self._unit:interaction():set_active(true)
	self._started = false

	self._unit:set_extension_update_enabled(Idstring("computer_gui"), false)
	self._update_enabled = false
end

-- // MISC. \\

-- ComputerGui:game_resolution_changed -> Adjust the mouse's boundaries so they correctly match the new resolution.
function ComputerGui:game_resolution_changed()
	self:add_workspace(self._unit:get_object(Idstring(self._gui_object)))
	self:setup()
end

-- ComputerGui:update -> Runs every frame.
function ComputerGui:update(unit, t, dt)
	if Input:keyboard():down(Idstring("space")) then
		self:_close()
	end
end

-- ComputerGui:save -> Unknown. Better keep it in.
function ComputerGui:save(data)
	local state = {
		started = self._started,
		update_enabled = self._update_enabled,
		visible = self._visible,
	}
	data.ComputerGui = state
end

-- ComputerGui:load -> Unknown. Better keep it in.
function ComputerGui:load(data)
	log("Ran ComputerGui:load()")
	local state = data.ComputerGui

	self:set_visible(state.visible)
	self._unit:set_extension_update_enabled(Idstring("computer_gui"), state.update_enabled and true or false)
end