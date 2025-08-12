ComputerObjectBase = ComputerObjectBase or class()

function ComputerObjectBase:init(tweak_data)
    self._tweak_data = tweak_data
end

function ComputerObjectBase:compute_properties()
    for name, property in pairs(self._tweak_data.config) do
        if type(property) == "function" then
            self._tweak_data.config[name] = property(self)
        end
    end

    -- Example of a computed property:
    --[[
    w = function(self)
        return self._parent._tweak_data.config.w - 35
    end
    ]]
end

function ComputerObjectBase:set_parent(parent)
    self._parent = parent
end

function ComputerObjectBase:create()
    log("[ComputerObjectBase:create] ERROR: No specific create() method defined for object.")
end

function ComputerObjectBase:children()
    return self._tweak_data.children
end