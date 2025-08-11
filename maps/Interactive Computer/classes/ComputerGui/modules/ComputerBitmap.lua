ComputerBitmap = ComputerBitmap or class(ComputerObjectBase)

function ComputerBitmap:init(tweak_data)
    ComputerBitmap.super.init(self, tweak_data)
end

function ComputerBitmap:create(parent)
    return parent:bitmap(self._tweak_data.config)
end

return ComputerBitmap