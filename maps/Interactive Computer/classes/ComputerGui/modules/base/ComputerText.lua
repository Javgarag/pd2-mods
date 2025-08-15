ComputerText = ComputerText or class(ComputerObjectBase)

function ComputerText:init(tweak_data)
    ComputerText.super.init(self, tweak_data)
end

function ComputerText:create(parent_object, extension, parent)
    ComputerText.super.create(self, parent_object, extension, parent)

    self._object = parent_object:text(self._tweak_data.config)
end