ComputerPanel = ComputerPanel or class(ComputerObjectBase)

function ComputerPanel:init(tweak_data)
    ComputerPanel.super.init(self, tweak_data)
end

function ComputerPanel:create(parent)
    return parent:panel(self._tweak_data.config)
end

return ComputerPanel