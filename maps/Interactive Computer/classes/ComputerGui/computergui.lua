-- NOTE: ENVIRONMENT BLOOM MUST BE SET TO 0,0,1,0 FOR THE SCREEN TO PROPERLY SHOW UP WITH NO ILLUMINATION ISSUES. 
-- If you desire, you can make a small environment area covering the computer screen with no bloom, so you can apply bloom effects in your map's other areas.

ComputerGui = ComputerGui or class()
ComputerGui.TWEAK_DATA_FILE = "classes/ComputerGui/tweak_data/ComputerGuiTweakData.lua"
ComputerGui.mouse_variants = {
	arrow = {0, 0, 19, 23}, -- Default
	link = {20, 0, 19, 23},
	hand = {40, 0, 19, 23},
	grab = {60, 0, 19, 23}
}

-- // INITIALIZATION \\

function ComputerGui:init(unit)
	if not self.gui_object or not self.tweak_data then
		log("[ComputerGui:init] ERROR: Missing required extension values. Check .unit file!")
		return
	end

	if not tweak_data.computer_gui then
		dofile(BeardLib.current_level._mod.ModPath .. ComputerGui.TWEAK_DATA_FILE)
	end

	self._tweak_data = tweak_data.computer_gui[self.tweak_data]
    self._unit = unit
	self._cull_distance = self._cull_distance or 5000
	self._new_gui = World:newgui()

	self:add_workspace(self._unit:get_object(Idstring(self.gui_object)))
	self:setup()

	self._unit:set_extension_update_enabled(Idstring("computer_gui"), false)
	self._update_enabled = false
end

function ComputerGui:add_workspace(gui_object)
	local gui_width, gui_height = managers.gui_data:get_base_res() -- VERY IMPORTANT. This is so the mouse movement is ALWAYS synced with the user's resolution.
	managers.viewport:add_resolution_changed_func(callback(self, self, "game_resolution_changed"))

	self._ws = self._new_gui:create_object_workspace(gui_width, gui_height, gui_object, Vector3(0, 0, 0))
	self._gui = self._ws:panel():panel({
		name = "panel",
		halign = "grow",
		valign = "grow",
		layer = 0,
	})
	self._gui:bitmap({
		name = "screen_background",
		texture = self._tweak_data.workspace.background_texture,
		w = gui_width,
		h = gui_height,
		layer = 1,
		color = Color(1, 1, 1)
	})
	self._gui:bitmap({
		name = "pointer",
		texture = "guis/textures/mouse_pointer",
		texture_rect = {0, 0, 19, 23},
		layer = 30,
		color = Color(1, 0.7, 0.7, 0.7),
		x = gui_width / 2,
		y = gui_height / 2,
		visible = true
	})

	self._pointer = {
		gui = self._gui:child("pointer")
	}

	self._gui:child("screen_background"):set_w(gui_width)
	self._gui:child("screen_background"):set_h(gui_height)
	self._gui:set_size(self._gui:parent():size())
end

function ComputerGui:setup()
	self._desktop_apps = {}
	self._windows = {}
	self.window_stack = {}

	for app_index, app in pairs(self._tweak_data.applications) do
		self:create_window(app_index, app)

		-- Icons
		self._desktop_apps[app_index] = self._gui:panel({
			name = app_index,
			w = 95,
			h = 95,
			x = 30,
			y = 25 + 100 * (app_index - 1),
			layer = 2
		})
		local icon = self._desktop_apps[app_index]:bitmap({
			texture = app.icon,
			name = "app_bg",
			vertical = "center",
			valign = "center",
			align = "center",
			halign = "center",
			w = 75,
			h = 75,
			layer = 1,
		})
		icon:set_center(self._desktop_apps[app_index]:w() / 2, self._desktop_apps[app_index]:h() / 2)

		local name = self._desktop_apps[app_index]:text({
			text = managers.localization:text(app.name),
			font = tweak_data.menu.pd2_small_font,
			font_size = tweak_data.menu.pd2_small_font_size,
			color = Color.black,
			vertical = "bottom",
			valign = "center",
			align = "center",
			halign = "center",
		})
		name:set_bottom(self._desktop_apps[app_index]:h())
	end
end

function ComputerGui:create_window(app_index, app)
	local app_name = app.name

	local window = ComputerWindow:new(app.window)
	window:create(self._gui, self)

	self._windows[app_name] = window
end

-- // AT ENTER \\

function ComputerGui:start()
	if not self._started then
		self:_start()
		if managers.network:session() then
			managers.network:session():send_to_peers_synched("start_computer_gui", self._unit)
		end
	end
end

function ComputerGui:_start()
	self._started = true
	self._unit:set_extension_update_enabled(Idstring("computer_gui"), true)
	self._update_enabled = true
	--self:post_event(self._start_event)

	self:show()

	if Network:is_client() then
		return
	end

	self._camera_pos = self._unit:get_object(Idstring(self.camera_object or "camera_pos"))
	self._teleport_pos = self._unit:get_object(Idstring("teleport_pos"))
	if not (self._camera_pos or self._teleport_pos) then
		log("[ComputerGui:_start] ERROR: Position object missing. Check model and/or extension configuration!")
		return
	end

	self:create_camera()
	managers.worldcamera:play_world_camera("computer_gui_camera")

	managers.player:warp_to(self._teleport_pos:position(), self._teleport_pos:rotation())
	local state = managers.player:get_current_state()
	state:_toggle_gadget(state._equipped_unit:base())

	self:hud_text()
	self:setup_mouse()
	self:set_visible(true)
end

-- ComputerGui:sync_start -> Network version of ComputerGui:start(), called by UnitNetworkHandler (See /hooks/UnitNetworkHandler.lua)
function ComputerGui:sync_start() 
	self:_start()
end

function ComputerGui:hud_text()
	if self._text_workspace then
		Overlay:newgui():destroy_workspace(self._text_workspace)
		self._text_workspace = nil
	end

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
end

-- ComputerGui:create_camera -> Creates a world camera to run later so the camera can be locked. The model needs to have an object (empty) called "camera_pos".
function ComputerGui:create_camera()
	self._camera = managers.worldcamera:create_world_camera("computer_gui_camera")
	self._camera:set_duration(10000000000)
	self._camera:add_point(self._camera_pos:position(), self._camera_pos:rotation())
end

-- // MOUSE HANDLING \\

function ComputerGui:change_mouse_texture_from_window_position(window, x, y)
	if window then
		local mouse_variant = window:mouse_variant(x, y)
		self._pointer.gui:set_texture_rect(unpack(self.mouse_variants[mouse_variant]))
	end
end

function ComputerGui:mouse_moved(o, x, y)
	if not alive(self._unit) then return end -- Prevent crash on restart

	self._pointer.gui:set_x(x)
	self._pointer.gui:set_y(y)

	local active_window = self:get_active_window()
	local open_windows = self:get_open_windows()

	local changed_texture = false
	for _, window in pairs(open_windows) do
		if window:object():inside(x, y) and window:is_visible(x, y) then
			changed_texture = true
			self:change_mouse_texture_from_window_position(window, x, y)
			window:trigger_event("mouse_enter", x, y)
		end
	end
	if not changed_texture then
		self._pointer.gui:set_texture_rect(unpack(self.mouse_variants.arrow))
	end

	if self._pointer.dragging_offsets and active_window then
		active_window:update_dragging_offset_position({
			x = self._pointer.gui:x() - self._pointer.dragging_offsets.x,
			y = self._pointer.gui:y() - self._pointer.dragging_offsets.y
		})
		self._pointer.gui:set_texture_rect(unpack(self.mouse_variants.grab))
	end
end

function ComputerGui:mouse_pressed(o, button, x, y)
	if button == Idstring("0") then
		for _, window in pairs(self:get_open_windows()) do
			if window:object():inside(x, y) and window:is_visible(x, y) then
				if not window:is_active_window() then
					self:set_active_window(window:object())
					window:trigger_event("gained_focus")
				end
				window:trigger_event("mouse_pressed", button, x, y)
			end
		end

		local inside, app_index, app = self:inside_app_icon(x, y)
		if inside then
			self:open_window(app_index, app)
			self._pointer.gui:set_texture_rect(unpack(self.mouse_variants.arrow))
			return
		end
	end
end

function ComputerGui:mouse_released(o, button, x, y)
	for _, window in pairs(self:get_open_windows()) do
		if window:object():inside(x, y) and window:is_visible(x, y) then
			local click_event = window:trigger_event("mouse_released", button, x, y)
			if click_event then
				if window:is_open() then
					self._pointer.gui:set_texture_rect(unpack(self.mouse_variants[window:mouse_variant(x, y)]))
				else
					self._pointer.gui:set_texture_rect(unpack(self.mouse_variants.arrow))
				end
			end
		end
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

function ComputerGui:start_dragging(window_object)
	self._pointer.dragging_offsets = {
		x = self._pointer.gui:x() - window_object:x(),
		y = self._pointer.gui:y() - window_object:y()
	}
	self._pointer.gui:set_texture_rect(unpack(self.mouse_variants.grab))
end

function ComputerGui:stop_dragging()
	self._pointer.dragging_offsets = nil
end

function ComputerGui:inside_app_icon(x,y)
	for app_index, app in pairs(self._tweak_data.applications) do
		if self._desktop_apps[app_index]:inside(x,y) and self:item_visible(self._desktop_apps[app_index], x, y) then
			return true, app_index, app
		end
	end
	return false
end

function ComputerGui:item_visible(item, x, y) -- Will not work to check if a panel is visible.
	if self:get_active_window() and table.contains(self:get_active_window():object():children(), item) then
		return true
	end

    for _, window in pairs(self:get_open_windows()) do
		if not table.contains(window:object():children(), item) then
			if window:object():layer() > item:parent():layer() and window:object():inside(x, y) then
				return false
			end
		end
    end

    return true
end

-- // SCREEN ACTIONS \\

function ComputerGui:open_window(app_index, app)
	local window = self._windows[app.name]

	if window:is_opening() then 
		return
	end

	if window:is_open() then
		self:set_active_window(window:object())
		window:trigger_event("attention")
		return
	end

	self:set_active_window(window:object())
	window:trigger_event("open")
end

function ComputerGui:set_active_window(window_object)
	if not alive(window_object) then
		log("[ComputerGui:set_active_window] ERROR: Nil window object provided.")
		return
	end

	local inactive_color = Color(1, 50/255, 50/255, 50/255)
	local active_color = Color(1, 0, 0, 0)

	if self.window_stack[#self.window_stack] ~= window_object then
		table.insert(self.window_stack, window_object)
	end

	local new_active_old_index = nil
	for stack_index, stack_object in ipairs(self.window_stack) do -- Iterates in order
		if window_object == stack_object then
			new_active_old_index = stack_index
			break
		end
	end

	if new_active_old_index ~= #self.window_stack then
		table.remove(self.window_stack, new_active_old_index)
	end

	for stack_index, stack_object in ipairs(self.window_stack) do
		stack_object:set_layer(stack_index + 2)
		--[[ Global layer info:
		1 - Desktop background
		2 - Desktop apps
		Rest: windows.
		30 - Mouse pointer
		]]
		
		stack_object:child("bg"):set_color(inactive_color)
	end

	window_object:child("bg"):set_color(active_color)
end

function ComputerGui:remove_from_window_stack(window_object)
	local window_index = nil
	for stack_index, stack_object in ipairs(self.window_stack) do
		if window_object == stack_object then
			window_index = stack_index
			break
		end
	end

	if window_index ~= nil then
		table.remove(self.window_stack, window_index)
	end
end

function ComputerGui:get_window_stack()
	return self.window_stack
end

function ComputerGui:get_open_windows()
	local open_windows = {}

	for _, window in pairs(self._windows) do
		if window:is_open() then
			table.insert(open_windows, window)
		end
	end

	return open_windows
end

function ComputerGui:get_active_window()
	for _, window in pairs(self._windows) do
		if window:object() == self:get_active_window_object() then
			return window
		end
	end
end

function ComputerGui:get_active_window_object()
	return self.window_stack[#self.window_stack]
end

function ComputerGui:get_pointer()
	return self._pointer
end

function ComputerGui:hide()
	self._ws:hide()
end

function ComputerGui:show()
	self._ws:show()
end

function ComputerGui:set_visible(visible)
	self._visible = visible
	self._gui:set_visible(visible)
end

-- // AT EXIT \\

function ComputerGui:destroy()
	if alive(self._new_gui) and alive(self._ws) then
		self._new_gui:destroy_workspace(self._ws)

		self._ws = nil
		self._new_gui = nil
		self._tweak_data = nil
		self._desktop_apps = nil
		self._windows = nil
		self.window_stack = nil
	end
end

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

function ComputerGui:game_resolution_changed()
	local gui_width, gui_height = managers.gui_data:get_base_res()
	self._ws:panel():set_size(gui_width, gui_height)
	self._gui:child("screen_background"):set_w(gui_width)
	self._gui:child("screen_background"):set_h(gui_height)

	self:hud_text()
end

function ComputerGui:update(unit, t, dt)
	if Input:keyboard():down(Idstring("space")) then
		self:_close()
	end
end

-- // DROPIN \\

-- Server
function ComputerGui:save(data)
	log("Ran ComputerGui:save()")
	local state = {
		started = self._started,
		update_enabled = self._update_enabled,
		visible = self._visible,
	}
	data.ComputerGui = state
end

-- Client
function ComputerGui:load(data)
	log("Ran ComputerGui:load()")
	local state = data.ComputerGui

	self:set_visible(state.visible)
	self._unit:set_extension_update_enabled(Idstring("computer_gui"), state.update_enabled and true or false)
end