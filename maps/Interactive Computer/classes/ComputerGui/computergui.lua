-- NOTE: ENVIRONMENT BLOOM MUST BE SET TO 0,0,1,0 FOR THE SCREEN TO PROPERLY SHOW UP WITH NO ILLUMINATION ISSUES. 
-- If you desire, you can make a small environment area covering the computer screen with no bloom, so you can apply bloom effects in your map's other areas.

ComputerGui = ComputerGui or class()

ComputerGui.modules = {
	ProgressBar = ProgressBar
}

-- // INITIALIZATION \\

function ComputerGui:init(unit)
	if not self.gui_object or not self.tweak_data then
		log("[ComputerGui:init] ERROR: Missing required extension values. Check .unit file!")
		return
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
		gui = self._gui:child("pointer"),
		dragging = false,
		dragging_offsets = {
			x = nil,
			y = nil
		}
	}

	self._gui:child("screen_background"):set_w(gui_width)
	self._gui:child("screen_background"):set_h(gui_height)
	self._gui:set_size(self._gui:parent():size())
end

function ComputerGui:setup()
	self._desktop_apps = {}
	self._windows = {}
	self._window_stack = {}

	for app_index, app in pairs(self._tweak_data.applications) do
		if self:create_window(app_index, app) then
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
end

function ComputerGui:create_window(app_index, app)
	local app_name = app.name

	if not DB:has(Idstring("gui"), Idstring(self._tweak_data.applications[app_index].panel)) then
		log("[ComputerGui:open_window] Couldn't find the .gui window file for app '" .. app_name .. "' in application definition. Check your paths!")
		return false
	end

	self._windows[app_name] = {
		gui = self._gui:gui(Idstring(self._tweak_data.applications[app_index].panel)):script(),
		open = false
	}

	local window = self._windows[app_name].gui
	HUDBGBox_create_window(window.panel, {
		w = window.panel:w(),
		h = window.panel:h()
	})
	
	local drag_hitbox = window.panel:rect({
		name = "drag_hitbox",
		w = window.panel:w() - 35,
		h = 35,
		alpha = 0,
		layer = -1
	})

	local close_button = window.panel:bitmap({
		name = "close_button",
		texture = "guis/textures/pd2/specialization/points_reduce",
		w = 25,
		h = 25,
		x = window.panel:w() - 30,
		y = 5
	})

	--[[local title = window.panel:text({
		name = "title",
		text = managers.localization:text(app_name),
		font = tweak_data.menu.pd2_medium_font,
		font_size = tweak_data.menu.pd2_medium_font_size,
		color = Color.white,
		align = "left",
		x = 5,
		y = 5,
		valign = "center"
	})]]

	return true
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

function ComputerGui:_start()
	self._started = true
	self._unit:set_extension_update_enabled(Idstring("computer_gui"), true)
	self._update_enabled = true
	--self:post_event(self._start_event)

	self:show()

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

function ComputerGui:mouse_pressed(o, button, x, y)
	if button == Idstring("0") then

		local inside, app_index, app = self:inside_app_icon(x, y)
		if inside then
			self:open_window(app_index, app)
			self._pointer.gui:set_texture_rect(0,0,19,23) -- type "arrow"
			return
		end

		-- Close the window if click over the button to close
		local inside, app_index, app = self:inside_app_window_close_button(x, y)
		if inside and app then
			self:close_window(app.name)
			self:set_active_window(self:get_stack_top_app_name())
			self._pointer.gui:set_texture_rect(0,0,19,23) -- type "arrow"
			return
		end

		-- Start dragging
		local inside, app_index, app = self:inside_app_window_drag_hitbox(x, y)
		if inside and app then
			self._pointer.dragging = true
			self._pointer.dragging_offsets.x = self._pointer.gui:x() - self._windows[app.name].gui.panel:x()
			self._pointer.dragging_offsets.y = self._pointer.gui:y() - self._windows[app.name].gui.panel:y()
			
			self:set_active_window(app.name)

			self._pointer.gui:set_texture_rect(60,0,19,23) -- type "grab"
			return
		end

		-- If inside a window, set it as active
		local inside, app_index, app = self:inside_app_window(x, y)
		if inside and app then
			self:set_active_window(app.name)
		end
	end
end

function ComputerGui:mouse_released(button, x, y)
	if self._pointer.dragging then -- Stop dragging
		self._pointer.dragging = false
		self._pointer.dragging_offsets.x = nil
		self._pointer.dragging_offsets.y = nil
		self._pointer.gui:set_texture_rect(40,0,19,23) -- type "hand"
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

function ComputerGui:inside_app_icon(x,y)
	for app_index, app in pairs(self._tweak_data.applications) do
		if self._desktop_apps[app_index]:inside(x,y) and self:item_visible(self._desktop_apps[app_index], x, y) then
			return true, app_index, app
		end
	end
	return false
end

function ComputerGui:inside_app_window(x,y)
	for app_index, app in pairs(self._tweak_data.applications) do
		if self._windows[app.name] and self._windows[app.name].open then
			if self._windows[app.name].gui.panel:child("bg"):inside(x,y) and self:item_visible(self._windows[app.name].gui.panel:child("bg"), x, y) then
				return true, app_index, app
			end
		end
	end
	return false
end

function ComputerGui:inside_app_window_close_button(x, y)
	for app_index, app in pairs(self._tweak_data.applications) do
		if self._windows[app.name] and self._windows[app.name].gui.panel:child("close_button"):inside(x,y) and self:item_visible(self._windows[app.name].gui.panel:child("close_button"), x, y) and self._windows[app.name].open then
			return true, app_index, app
		end
	end
	return false
end

function ComputerGui:inside_app_window_drag_hitbox(x, y)
	for app_index, app in pairs(self._tweak_data.applications) do
		if self._windows[app.name] and self._windows[app.name].open then
			if self._windows[app.name].gui.panel:child("drag_hitbox"):inside(x,y) and self:item_visible(self._windows[app.name].gui.panel:child("drag_hitbox"), x, y) then
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

function HUDBGBox_create_window(panel, params, config)
	local box_panel = panel
	local color = config and config.color
	local bg_color = config and config.bg_color or Color(1, 0, 0, 0)

	box_panel:rect({
		name = "bg",
		halign = "grow",
		alpha = 1,
		valign = "grow",
		color = bg_color,
		layer = 0,
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
		texture = "guis/textures/pd2/hud_corner_down_left",
		name = "left_bottom",
		x = 0,
		y = 0,
		halign = "left",
		blend_mode = "normal",
		valign = "bottom"
	})
	left_bottom:set_bottom(box_panel:h())

	local right_top = box_panel:bitmap({
		texture = "guis/textures/pd2/hud_corner_top_right",
		name = "right_top",
		x = 0,
		y = 0,
		halign = "right",
		blend_mode = "normal",
		valign = "top"
	})
	right_top:set_right(box_panel:w())

	local right_bottom = box_panel:bitmap({
		texture = "guis/textures/pd2/hud_corner_down_right",
		name = "right_bottom",
		x = 0,
		y = 0,
		halign = "right",
		blend_mode = "normal",
		valign = "bottom"
	})
	right_bottom:set_right(box_panel:w())
	right_bottom:set_bottom(box_panel:h())

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

function ComputerGui:open_window(app_index, app)
	local window = self._windows[app.name]

	if window.opening then 
		return
	end

	if window.open then 
		self:set_active_window(app.name)
		window.gui.panel:animate(callback(nil, _G, "HUDBGBox_animate_window_attention"))
		return 
	end

	window.opening = true

	local function open_done() 
		window.opening = false
		window.open = true
	end

	self:set_active_window(app.name)
	window.gui.panel:animate(callback(nil, _G, "HUDBGBox_animate_window"), nil, window.gui.panel:w(), 0.1, "open", open_done)
end

function ComputerGui:close_window(app_name)
	local window = self._windows[app_name]
	window.open = false

	local app_index = nil
	for stack_index, stack_name in ipairs(self._window_stack) do
		if app_name == stack_name then
			app_index = stack_index
		end
	end

	if app_index ~= nil then
		table.remove(self._window_stack, app_index)
	end

	window.gui.panel:animate(callback(nil, _G, "HUDBGBox_animate_window"), nil, window.gui.panel:w(), 0.1, "close")
end

function ComputerGui:set_active_window(app_name)
	if not app_name then return end

	local inactive_color = Color(1, 50/255, 50/255, 50/255)
	local active_color = Color(1, 0, 0, 0)

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
		self._windows[stack_name].gui.panel:set_layer(stack_index + 2 + 1) -- Each window is separated by a layer. This is so HudBGBox can have background on -1.
		self._windows[stack_name].gui.panel:child("bg"):set_layer(-1) -- Fix for using :script(). Temporary
		--[[ Global layer info:
		1 - Desktop background
		2 - Desktop apps
		Rest (in pairs): windows.
		30 - Mouse pointer
		]]
		
		self._windows[stack_name].gui.panel:child("bg"):set_color(inactive_color)
	end

	self._windows[app_name].gui.panel:child("bg"):set_color(active_color)
end

function ComputerGui:get_active_window()
	return self._windows[self:get_stack_top_app_name()]
end

function ComputerGui:get_stack_top_app_name()
	return self._window_stack[#self._window_stack]
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

function ComputerGui:lock_gui()
	self._ws:set_cull_distance(self._cull_distance)
	self._ws:set_frozen(true)
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
		self._window_stack = nil
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

-- // MISC. \\

function ComputerGui:game_resolution_changed()
	local gui_width, gui_height = managers.gui_data:get_base_res()
	self._ws:panel():set_size(gui_width, gui_height)
	self._gui:child("screen_background"):set_w(gui_width)
	self._gui:child("screen_background"):set_h(gui_height)
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