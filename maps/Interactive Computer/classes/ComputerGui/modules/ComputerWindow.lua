function HUDBGBox_create_window(panel, params)
	local box_panel = panel
	local bg_color = params.background_color or Color.black

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

ComputerWindow = ComputerWindow or class(ComputerObjectBase)

function ComputerWindow:init(tweak_data)
    ComputerWindow.super.init(self, tweak_data)

    table.insert(self._tweak_data.children, ComputerRect:new({
        config = {
            name = "drag_hitbox",
            w = self._tweak_data.config.w - 35,
            h = 35,
            alpha = 0
        },
		events = {
			mouse_click = {
				type = "func",
				event = function(window, x, y)
					log("Drag")
				end
			}
		}
	}))

    table.insert(self._tweak_data.children, ComputerBitmap:new({
        config = {
            name = "close_button",
            texture = "guis/textures/pd2/specialization/points_reduce",
            w = 25,
            h = 25,
            x = self._tweak_data.config.w - 30,
            y = 5
        },
		events = {
			mouse_click = {
				type = "func",
				event = function(window, x, y)
					window:trigger_event("close")
				end
			}
		}
    }))
end

function ComputerWindow:create(parent_object, extension)
	ComputerWindow.super.create(self, parent_object, extension)

    self._object = parent_object:panel(self._tweak_data.config)

    -- Creation order matters. Background first, then foreground, so the window is not entirely black.
    HUDBGBox_create_window(self._object, self._tweak_data)

    for _, child in pairs(self._tweak_data.children) do
        child:create(self._object, self._extension, self)
    end

    return self._object
end

function ComputerWindow:trigger_event(event_name, ...)
	ComputerWindow.super.trigger_event(self, event_name, ...)

	local event_filters = {
		mouse_enter = function(child, x, y)
			if child:object():inside(x, y) and child:is_visible(x, y) then
				return true
			end
		end,

		mouse_exit = function(child, x, y)
			if child:object():inside(x, y) and child:is_visible(x, y) then
				return true
			end
		end,

		mouse_click = function(child, x, y)
			if child:object():inside(x, y) and child:is_visible(x, y) then
				return true
			end
		end
	}

	for _, child in pairs(self._tweak_data.children) do
		if event_filters[event_name] and event_filters[event_name](child, ...) == true then
			child:trigger_event(event_name, self, ...)
		elseif not event_filters[event_name] then
			child:trigger_event(event_name, self, ...)
		end
    end
end

function ComputerWindow:is_active_window()
	return self._extension:get_active_window().panel == self._object
end

function ComputerWindow:is_open()
	return self._open
end

function ComputerWindow:is_opening()
	return self._opening
end

function ComputerWindow:clbk_open()
	self._opening = true

	local function open_done() 
		self._opening = false
		self._open = true
	end

	local num_open_windows = #self._extension:get_window_stack()

	self._object:set_x(200 + num_open_windows * 50)
	self._object:set_y(50 + num_open_windows * 50)
    self._object:animate(callback(nil, _G, "HUDBGBox_animate_window"), nil, self._object:w(), 0.1, "open", open_done)
end

function ComputerWindow:clbk_close()
	self._open = false
    self._object:animate(callback(nil, _G, "HUDBGBox_animate_window"), nil, self._object:w(), 0.1, "close")
end

function ComputerWindow:clbk_attention()
	self._object:animate(callback(nil, _G, "HUDBGBox_animate_window_attention"))
end