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
end

function ComputerObjectBase:setup_events()
    for event_name, event_data in pairs(self._tweak_data.events or {}) do
        if event_data.type == "callback" then
            if not self[event_data.event] then
                log("[ComputerObjectBase:setup_events] ERROR: No method defined for callback type event '" .. event_name .. "'.")
            end

            function self.event_callback_func()
                return callback(self, self, event_data.event)
            end

            self._tweak_data.events[event_name].event = self:event_callback_func()
        end
    end
end

function ComputerObjectBase:trigger_event(event_name, ...)
    local event_table = self._tweak_data.events[event_name]
    if event_table and event_table.event and event_table.enabled then
        event_table.event(self, ...)
        if event_table.post_event then
            self.extension:post_event(event_table.post_event.sound_event_id, event_table.post_event.clbk, event_table.post_event.flags)
        end
        return true
    end
    return false
end

function ComputerObjectBase:create(parent_object, extension, parent)
    self.extension = extension
    self._parent = parent

    self:compute_properties()
    self:setup_events()
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

    if not self._object:visible() then
        return false
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

function ComputerObjectBase:update(t, dt)
end