ComputerBitmap = ComputerBitmap or class(ComputerObjectBase)

function ComputerBitmap:init(tweak_data)
    ComputerBitmap.super.init(self, tweak_data)
end

function ComputerBitmap:create(parent_object, extension, parent)
    ComputerBitmap.super.create(self, parent_object, extension, parent)

    self._object = parent_object:bitmap(self._tweak_data.config)
end