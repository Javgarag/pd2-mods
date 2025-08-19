UnitNetworkHandler = UnitNetworkHandler or class(BaseNetworkHandler)
function UnitNetworkHandler:close_computer_gui(unit, sender)
	if not self:_quick_verification(sender) then
		return
	end

	log("Sync Close")
	unit:computer_gui():sync_close()
end

function UnitNetworkHandler:computer_gui_open_window(unit, app_index, app, sender)
    if not self:_quick_verification(sender) then
		return
	end

	log("Sync Open")
	unit:computer_gui():open_window(app_index, app)
end

function UnitNetworkHandler:computer_gui_mouse(unit, button, x, y, action, sender)
   	if not self:_quick_verification(sender) then
		return
	end
	if action == "moved" then
		log("Sync Mouse Moved")
		unit:computer_gui():mouse_moved(x, y)
	elseif action == "pressed" then
		log("Sync Mouse Pressed")
		unit:computer_gui():mouse_pressed(button, x, y)
	elseif action == "released" then
		log("Sync Mouse Released")
		unit:computer_gui():mouse_released(button, x, y)
	end
end