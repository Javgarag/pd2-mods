local modules = {
	ComputerBitmapObject = { class_name = ComputerBitmapObject, file_name = "ComputerBitmapObject.lua" }
}

dofile(BeardLib.current_level._mod.ModPath .. "classes/ComputerGui/modules/ComputerObjectBase.lua")
for _, module in pairs(modules) do
	dofile(BeardLib.current_level._mod.ModPath .. "classes/ComputerGui/modules/" .. module.file_name)
end

tweak_data.computer_gui = {
    development = {
        workspace = {
            background_texture = "guis/textures/computergui/backgrounds/xp_bg",
        },
        test = ComputerBitmapObject:new(),
        applications = {
            {
                name = "computer_gui_app_trash",
                icon = "guis/textures/computergui/backgrounds/application_icon_trash",
                panel = "guis/computer_gui/prompt_access_denied"
            },
            {
                name = "computer_gui_app_browser",
                icon = "guis/textures/computergui/backgrounds/application_icon_browser",
                panel = "guis/computer_gui/prompt_access_denied"
            },
            {
                name = "computer_gui_app_keygen",
                icon = "guis/textures/computergui/backgrounds/application_icon_keygen",
                panel = "guis/computer_gui/prompt_keygen"
            }
        }
    }
}