ComputerRect = ComputerRect or class(ComputerObjectBase)

function ComputerRect:init(tweak_data)
    ComputerRect.super.init(self, tweak_data)
end

function ComputerRect:create(parent_object, extension, parent)
    ComputerRect.super.create(self, parent_object, extension, parent)

    self._object = parent_object:rect(self._tweak_data.config)
end