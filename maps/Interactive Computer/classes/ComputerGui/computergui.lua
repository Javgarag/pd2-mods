-- NOTE: ENVIRONMENT BLOOM MUST BE SET TO 0,0,1,0 FOR THE SCREEN TO PROPERLY SHOW UP WITH NO ILLUMINATION ISSUES. 
-- If you desire, you can make a small environment area covering the computer screen with no bloom, so you can apply bloom effects in your map's other areas.

ComputerGui = ComputerGui or class()
ComputerGui.BASE_ASSET_PATH = "guis/textures/computergui/"

-- // INITIALIZATION \\

-- ComputerGui:init -> Initial extension setup, when the mission starts up.
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
	managers.viewport:add_resolution_changed_func(callback(self, self, "game_resolution_changed"))

	self._ws = self._new_gui:create_object_workspace(gui_width, gui_height, gui_object, Vector3(0, 0, 0))
	self._gui = self._ws:panel():gui(Idstring("guis/computer_gui/base"))
	self._gui_script = self._gui:script()
	self._pointer = {
		gui = self._gui_script.pointer,
		dragging = false,
		dragging_offsets = {
			x = nil,
			y = nil
		}
	}
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
	self._desktop_apps = {}
	self._windows = {}
	self._window_stack = {}

	for app_index, app in pairs(self._applications) do
		-- Icon setup
		self._desktop_apps[app_index] = self._gui_script.panel:panel({
			name = app_index,
			w = 75,
			h = 95,
			x = 30 ,
			y = 30 + 95 * (app_index - 1),
			layer = 2
		})
		self._desktop_apps[app_index]:bitmap({
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

	if Network:is_client() then
		return
	end

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

	self:setup_mouse()
	self:set_visible(true)
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

	self._pointer.gui:set_x(x)
	self._pointer.gui:set_y(y)

	if  self:inside_app_window_drag_hitbox(x, y) and not self._pointer.dragging then
		self._pointer.gui:set_texture_rect(40,0,19,23) -- type "hand"
	elseif self:inside_app_icon(x, y) or self:inside_app_window_close_button(x, y) then
		self._pointer.gui:set_texture_rect(20,0,19,23) -- type "link"
	else
		self._pointer.gui:set_texture_rect(0,0,19,23) -- type "arrow"
	end

	if self._pointer.dragging then -- Window dragging
		local active_window = self:get_active_window()

		active_window.gui.panel:set_x(self._pointer.gui:x() - self._pointer.dragging_offsets.x)
		active_window.gui.panel:set_y(self._pointer.gui:y() - self._pointer.dragging_offsets.y)
		self._pointer.gui:set_texture_rect(60,0,19,23) -- type "grab"
	end
end

-- ComputerGui:mouse_pressed -> Triggers when the mouse is pressed.
function ComputerGui:mouse_pressed(o, button, x, y)
	if button == Idstring("0") then

		local inside, app_index, app = self:inside_app_icon(x, y)
		if inside then
			self:open_window(app_index, app)
			self._pointer.gui:set_texture_rect(0,0,19,23) -- type "arrow"
		end

		-- Close the window if click over the button to close
		local inside, app_index, app = self:inside_app_window_close_button(x, y)
		if inside and app then
			self:close_window(app.name)
			self:set_active_window(self:get_stack_top_app_name())
			self._pointer.gui:set_texture_rect(0,0,19,23) -- type "arrow"
		end

		-- Start dragging
		local inside, app_index, app = self:inside_app_window_drag_hitbox(x, y)
		if inside and app then
			self._pointer.dragging = true
			self._pointer.dragging_offsets.x = self._pointer.gui:x() - self._windows[app.name].gui.panel:x()
			self._pointer.dragging_offsets.y = self._pointer.gui:y() - self._windows[app.name].gui.panel:y()
			
			self:set_active_window(app.name)

			self._pointer.gui:set_texture_rect(60,0,19,23) -- type "grab"
		end

		-- If inside a window, set it as active
		local inside, app_index, app = self:inside_app_window(x, y)
		if inside and app then
			self:set_active_window(app.name)
		end
	end
end

-- ComputerGui:mouse_released -> Triggers when the mouse, which was previously pressed, is released.
function ComputerGui:mouse_released()
	if self._pointer.dragging then -- Stop dragging
		self._pointer.dragging = false
		self._pointer.dragging_offsets.x = nil
		self._pointer.dragging_offsets.y = nil
		self._pointer.gui:set_texture_rect(0,0,19,23) -- type "arrow"
	end
end

function ComputerGui:setup_mouse()
	local data = {
		mouse_move = callback(self, self, "mouse_moved"),
		mouse_press = callback(self, self, "mouse_pressed"),
		mouse_release = callback(self, self, "mouse_released"),
		id = "computer_gui_mouse"
	}

	managers.mouse_pointer:use_mouse(data)
	managers.mouse_pointer:disable()
end

function ComputerGui:remove_mouse()
	managers.mouse_pointer:remove_mouse("computer_gui_mouse")
end

-- ComputerGui:inside_app_icon -> Check if the pointer is currently inside a clickable application button.
function ComputerGui:inside_app_icon(x,y)
	for app_index, app in pairs(self._applications) do
		if self._desktop_apps[app_index]:inside(x,y) and self:item_visible(self._desktop_apps[app_index], x, y) then
			return true, app_index, app
		end
	end
	return false
end

-- ComputerGui:inside_app_window -> Check if the pointer is currently inside a window.
function ComputerGui:inside_app_window(x,y)
	for app_index, app in pairs(self._applications) do
		if self._windows[app.name] and self._windows[app.name].open then
			if self._windows[app.name].gui.panel:child("bg"):inside(x,y) and self:item_visible(self._windows[app.name].gui.panel:child("bg"), x, y) then
				return true, app_index, app
			end
		end
	end
	return false
end

-- ComputerGui:inside_app_window_close_button -> Check if the pointer is currently inside a clickable window close button.
function ComputerGui:inside_app_window_close_button(x, y)
	for app_index, app in pairs(self._applications) do
		if self._windows[app.name] and self._windows[app.name].gui.close_button:inside(x,y) and self:item_visible(self._windows[app.name].gui.close_button, x, y) and self._windows[app.name].open then
			return true, app_index, app
		end
	end
	return false
end

-- ComputerGui:inside_app_window_drag_hitbox -> Check if the pointer is currently inside a clickable window drag button hitbox.
function ComputerGui:inside_app_window_drag_hitbox(x, y)
	for app_index, app in pairs(self._applications) do
		if self._windows[app.name] and self._windows[app.name].open then
			if self._windows[app.name].gui.drag_hitbox:inside(x,y) and self:item_visible(self._windows[app.name].gui.drag_hitbox, x, y) then
				return true, app_index, app
			end
		end
	end
	return false
end

function ComputerGui:item_visible(item, x, y) -- Will not work to check if a panel is visible.
	if self:get_active_window() and table.contains(self:get_active_window().gui.panel:children(), item) then
		return true
	end

    for _, window in pairs(self._windows) do
		if window.open then
			if not table.contains(window.gui.panel:children(), item) then
				if window.gui.panel:layer() > item:parent():layer() and window.gui.panel:inside(x, y) then
					return false
				end
			end
		end
    end

    return true
end

-- // SCREEN ACTIONS \\

local function HUDBGBox_create_window(panel, params, config)
	local box_panel = panel
	local color = config and config.color
	local bg_color = config and config.bg_color or Color(1, 0, 0, 0)

	box_panel:rect({
		name = "bg",
		halign = "grow",
		alpha = 1,
		valign = "grow",
		color = bg_color
	})

	local left_top = box_panel:bitmap({
		texture = "guis/textures/pd2/hud_corner",
		name = "left_top",
		y = 0,
		halign = "left",
		x = 0,
		valign = "top"
	})

	local left_bottom = box_panel:bitmap({
		texture = "guis/textures/pd2/hud_corner",
		name = "left_bottom",
		x = 0,
		y = 0,
		halign = "left",
		rotation = -90,
		blend_mode = "normal",
		valign = "bottom"
	})
	left_bottom:set_bottom(box_panel:h())
	left_bottom:set_render_template(Idstring("VertexColorTextured"))

	local right_top = box_panel:bitmap({
		texture = "guis/textures/pd2/hud_corner",
		name = "right_top",
		x = 0,
		y = 0,
		halign = "right",
		rotation = 90,
		blend_mode = "normal",
		valign = "top"
	})
	right_top:set_right(box_panel:w())
	right_top:set_render_template(Idstring("VertexColorTextured"))

	local right_bottom = box_panel:bitmap({
		texture = "guis/textures/pd2/hud_corner",
		name = "right_bottom",
		x = 0,
		y = 0,
		halign = "right",
		rotation = 180,
		blend_mode = "normal",
		valign = "bottom"
	})
	right_bottom:set_right(box_panel:w())
	right_bottom:set_bottom(box_panel:h())
	right_bottom:set_render_template(Idstring("VertexColorTextured"))

	return box_panel
end

function HUDBGBox_animate_window(panel, wait_t, target_w, speed, anim, done_cb)
	local center_x = panel:center_x()

	if anim == "open" then
		panel:set_w(0)
		panel:set_visible(true)
	end

	local TOTAL_T = speed
	local t = TOTAL_T

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt

		panel:set_w(anim == "open" and ((1 - t / TOTAL_T) * target_w) or ((t / TOTAL_T) * target_w))
		panel:set_center_x(center_x)
	end

	panel:set_w(target_w)
	panel:set_center_x(center_x)

	if anim == "close" then
		panel:set_visible(false)
	end

	if done_cb then
		done_cb()
	end
end

function HUDBGBox_animate_window_attention(panel)
	local TOTAL_T = 1
	local t = TOTAL_T

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local var = math.abs(math.cos(t * 180))

		panel:set_alpha(1 * var)
	end

	panel:set_alpha(1)
end

-- ComputerGui:open_window -> Open the panel specified in the application configuration of id app_id
function ComputerGui:open_window(app_index, app)
	local app_name = app.name

	if not DB:has(Idstring("gui"), Idstring(self._applications[app_index].panel)) then
		log("[ComputerGui:open_window] Couldn't find the .gui window file for app '" .. app_name .. "' in application definition. Check your paths!")
		return
	end

	if self._windows[app_name] and self._windows[app_name].open then 
		self:set_active_window(app_name)
		self._windows[app_name].gui.panel:animate(callback(nil, _G, "HUDBGBox_animate_window_attention"))
		return 
	end

	if not self._windows[app_name] then -- Only create it if it doesn't exist already
		self._windows[app_name] = {
			gui = self._gui_script.panel:gui(Idstring(self._applications[app_index].panel)):script(),
			open = true
		}

		local window = self._windows[app_name].gui
		HUDBGBox_create_window(window.panel, {
			w = window.panel:w(),
			h = window.panel:h()
		})
	end

	local function open_done() 
		self._windows[app_name].open = true
		self:set_active_window(app_name)
	end

	self._windows[app_name].gui.panel:animate(callback(nil, _G, "HUDBGBox_animate_window"), nil, self._windows[app_name].gui.panel:w(), 0.1, "open", open_done)
end

function ComputerGui:close_window(app_name)
	local function close_done()
		self._windows[app_name].open = false

		local app_index = nil
		for stack_index, stack_name in ipairs(self._window_stack) do
			if app_name == stack_name then
				app_index = stack_index
			end
		end

		if app_index ~= nil then
			table.remove(self._window_stack, app_index)
		end
	end

	self._windows[app_name].gui.panel:animate(callback(nil, _G, "HUDBGBox_animate_window"), nil, self._windows[app_name].gui.panel:w(), 0.1, "close", close_done)
end

function ComputerGui:set_active_window(app_name)
	if not app_name then return end

	if self._window_stack[#self._window_stack] ~= app_name then
		table.insert(self._window_stack, app_name)
	end

	local new_active_old_index = nil
	for stack_index, stack_name in ipairs(self._window_stack) do -- Iterates in order
		if app_name == stack_name then
			new_active_old_index = stack_index
			break
		end
	end

	if new_active_old_index ~= #self._window_stack then
		table.remove(self._window_stack, new_active_old_index)
	end

	for stack_index, stack_name in ipairs(self._window_stack) do
		if stack_name ~= app_name then
			self._windows[stack_name].gui.panel:set_layer(stack_index + 2)
		end
	end

	self._windows[app_name].gui.panel:set_layer(#self._window_stack + 2) -- New active
end

function ComputerGui:get_active_window()
	return self._windows[self:get_stack_top_app_name()]
end

function ComputerGui:get_stack_top_app_name()
	return self._window_stack[#self._window_stack]
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
		self._applications = nil
		self._desktop_apps = nil
		self._windows = nil
		self._window_stack = nil
	end
end

-- ComputerGui:_close -> Return the camera to the player, remove virtual mouse.
function ComputerGui:_close()
	managers.worldcamera:stop_world_camera()
	self._text_workspace:destroy_workspace(self._hud)
	self:remove_mouse()
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
	local gui_width, gui_height = managers.gui_data:get_base_res()
	self._ws:panel():set_size(gui_width, gui_height)
end

-- ComputerGui:update -> Runs every frame.
function ComputerGui:update(unit, t, dt)
	if Input:keyboard():down(Idstring("space")) then
		self:_close()
	end
end

-- ComputerGui:save -> Unknown. Better keep it in.
function ComputerGui:save(data)
	log("Ran ComputerGui:save()")
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