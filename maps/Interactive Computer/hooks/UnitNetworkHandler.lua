UnitNetworkHandler = UnitNetworkHandler or class(BaseNetworkHandler)
function UnitNetworkHandler:start_computer_gui(unit, sender)
    if not alive(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end
	unit:computer_gui():sync_start()
end