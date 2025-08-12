ComputerText = ComputerText or class(ComputerObjectBase)

function ComputerText:init(tweak_data)
    ComputerText.super.init(self, tweak_data)
end

function ComputerText:create(parent)
    self._object = parent:text(self._tweak_data.config)
    return self._object
end