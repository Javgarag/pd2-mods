ComputerObjectBase = ComputerObjectBase or class()

function ComputerObjectBase:init(tweak_data)
    self._tweak_data = tweak_data
    self:setup_events()
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

function ComputerObjectBase:setup_events()
    for event_name, event_data in pairs(self._tweak_data.events or {}) do
        if event_data.type == "callback" then
            if not self[event_data.event] then
                log("[ComputerObjectBase:setup_events] ERROR: No method defined for callback type event '" .. event_name .. "'.")
            end

            self._tweak_data.events[event_name].event = callback(self, self, event_data.event)
        end
    end
end

function ComputerObjectBase:trigger_event(event_name, ...)
    local event = self._tweak_data.events[event_name] and self._tweak_data.events[event_name].event
    if event then
        event(...)
        return true
    end
    return false
end

function ComputerObjectBase:create(parent_object, extension, parent)
    self.extension = extension
    self._parent = parent

    self:compute_properties()
end

function ComputerObjectBase:is_visible(x, y)
    if self._parent and self._parent:is_active_window() then
        return true
    end

    for _, window in pairs(self.extension:get_open_windows()) do
        if not table.contains(window:children(), self) then
            if window:object():layer() > self._parent:object():layer() and window:object():inside(x, y) then
                return false
            end
        end
    end

    return true
end

function ComputerObjectBase:mouse_variant()
    return self._tweak_data.mouse_variant
end

function ComputerObjectBase:object()
    return self._object
end

function ComputerObjectBase:children()
    return self._tweak_data.children
end