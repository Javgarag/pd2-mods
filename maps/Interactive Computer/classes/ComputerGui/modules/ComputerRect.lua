ComputerRect = ComputerRect or class(ComputerObjectBase)

function ComputerRect:init(tweak_data)
    ComputerRect.super.init(self, tweak_data)
end

function ComputerRect:create(parent)
    self._object = parent:rect(self._tweak_data.config)
    return self._object
end