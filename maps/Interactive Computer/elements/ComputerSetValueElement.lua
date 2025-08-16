core:import("CoreMissionScriptElement")
ComputerSetValueElement = ComputerSetValueElement or class(CoreMissionScriptElement.MissionScriptElement)

function ComputerSetValueElement:init(...)
	ComputerSetValueElement.super.init(self, ...)
	self._units = {}
end

function ComputerSetValueElement:client_on_executed(...)
	self:on_executed(...)
end

function ComputerSetValueElement:on_script_activated()
	if not Network:is_server() then
		return
	end

	if self._values.units then
		for _, id in ipairs(self._values.units) do
			local unit = managers.worlddefinition:get_unit_on_load(id, callback(self, self, "_load_unit"))

			if unit then
				table.insert(self._units, unit)
			end
		end
	end
end

function ComputerSetValueElement:_load_unit(unit)
	table.insert(self._units, unit)
end

function ComputerSetValueElement:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if not self._values.key then 
		log("[ComputerSetValueElement:on_executed] WARN: No key defined. Not executing.")
		return 
	end

	for _, unit in ipairs(self._units) do
		unit:computer_gui():set_value(self._values.key, self._values.value)
	end

	self.super.on_executed(self, instigator)
end

-- Editor element integration is broken; the BeardLibAddElement hook is added after BeardLib has finished loading the elements module. Huge thanks to Orez for this workaround:
if BLE then
	Hooks:Add("BeardLibPostInit", "ComputerSetValueElementEditor", function()
		ComputerSetValueEditor = ComputerSetValueEditor or class(MissionScriptEditor)

		function ComputerSetValueEditor:create_element()
			self.super.create_element(self)
			self._element.class = "ComputerSetValueElement"
		end

		function ComputerSetValueEditor:check_unit(unit)
			return unit:computer_gui()
		end

		function ComputerSetValueEditor:_build_panel()
			self:_create_panel()

			self:BuildUnitsManage("units", nil, nil, {
				check_unit = ClassClbk(self, "check_unit"),
				help = "The units with the ComputerGui extension to set values to"
			})
			self:StringCtrl("key", {help = "The value's key name"})
			self:StringCtrl("value", {help = "The string value to set for the key"})
		end

		table.insert(BLE._config.MissionElements, "ComputerSetValueElement")
	end)
end