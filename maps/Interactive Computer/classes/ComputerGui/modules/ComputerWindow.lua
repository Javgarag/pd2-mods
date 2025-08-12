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

ComputerWindow = ComputerWindow or class(ComputerObjectBase)

function ComputerWindow:init(tweak_data)
    ComputerWindow.super.init(self, tweak_data)

    table.insert(self._tweak_data.children, ComputerRect:new({
        config = {
            name = "drag_hitbox",
            w = self._tweak_data.config.w - 35,
            h = 35,
            alpha = 0
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
        }
    }))

    for _, child in pairs(self._tweak_data.children) do
        child:set_parent(self)
        child:compute_properties()
    end
end

function ComputerWindow:create(parent)
    self._object = parent:panel(self._tweak_data.config)

    -- Creation order matters. Background first, then foreground, so the window is not entirely black.
    HUDBGBox_create_window(self._object, self._tweak_data)

    for _, child in pairs(self._tweak_data.children) do
        child:create(self._object)
    end

    return self._object
end