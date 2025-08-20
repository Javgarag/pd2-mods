local set_position_original = FPCameraPlayerBase.set_position
function FPCameraPlayerBase:set_position(...)
	if self.interacting_with_computer then
		self._unit:set_position(Vector3(0, 0, -100000))
	else
		set_position_original(self, ...)
	end
end