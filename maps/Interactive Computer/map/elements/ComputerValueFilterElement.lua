core:import("CoreMissionScriptElement")
ComputerValueFilterElement = ComputerValueFilterElement or class(CoreMissionScriptElement.MissionScriptElement)

function ComputerValueFilterElement:init(...)
	ComputerValueFilterElement.super.init(self, ...)
	self._units = {}
end

function ComputerValueFilterElement:client_on_executed(...)
	self:on_executed(...)
end

function ComputerValueFilterElement:on_script_activated()
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

function ComputerValueFilterElement:_load_unit(unit)
	table.insert(self._units, unit)
end

function ComputerValueFilterElement:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if not self._values.key then 
		log("[ComputerValueFilterElement:on_executed] WARN: No key defined. Not executing.")
		return 
	end

	for _, unit in ipairs(self._units) do
		local value = unit:computer_gui():get_value(self._values.key)
		if not (value == self._values.value) then
			return
		end
	end

	self.super.on_executed(self, instigator)
end

-- Editor element integration is broken; the BeardLibAddElement hook is added after BeardLib has finished loading the elements module. Huge thanks to Orez for this workaround:
if BLE then
	Hooks:Add("BeardLibPostInit", "ComputerValueFilterElementEditor", function()
		ComputerValueFilterEditor = ComputerValueFilterEditor or class(MissionScriptEditor)

		function ComputerValueFilterEditor:create_element()
			self.super.create_element(self)
			self._element.class = "ComputerValueFilterElement"
		end

		function ComputerValueFilterEditor:check_unit(unit)
			return unit:computer_gui()
		end

		function ComputerValueFilterEditor:_build_panel()
			self:_create_panel()

			self:BuildUnitsManage("units", nil, nil, {
				check_unit = ClassClbk(self, "check_unit"),
				help = "The units with the ComputerGui extension to check the value for this filter"
			})
			self:StringCtrl("key", {help = "The value's key name"})
			self:StringCtrl("value", {help = "The string value to filter against"})
		end

		table.insert(BLE._config.MissionElements, "ComputerValueFilterElement")
	end)
end