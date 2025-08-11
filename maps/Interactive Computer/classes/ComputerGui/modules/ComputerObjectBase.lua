ComputerObjectBase = ComputerObjectBase or class()

function ComputerObjectBase:init(tweak_data)
    self._tweak_data = tweak_data
end

function ComputerObjectBase:create()
    log("[ComputerObjectBase:create] ERROR: No specific create() method defined for object.")
end

function ComputerObjectBase:children()
    return self._tweak_data.children
end

return ComputerObjectBase