local modules = {
    ComputerWindow = { class_name = ComputerWindow, file_name = "ComputerWindow.lua" },
	ComputerBitmap = { class_name = ComputerBitmap, file_name = "ComputerBitmap.lua" },
    ComputerText = { class_name = ComputerText, file_name = "ComputerText.lua" },
    ComputerRect = { class_name = ComputerRect, file_name = "ComputerRect.lua" }
}

dofile(BeardLib.current_level._mod.ModPath .. "classes/ComputerGui/modules/ComputerObjectBase.lua")
for _, module in pairs(modules) do
	dofile(BeardLib.current_level._mod.ModPath .. "classes/ComputerGui/modules/" .. module.file_name)
end

local presets = {
    access_denied = {
        ComputerWindow:new({
            config = {
                halign = "grow",
                valign = "grow",
                w = 340,
                h = 84,
                x = 175,
                y = 75
            },
            background_color = Color.black,
            children = {
                ComputerBitmap:new({
                    config = {
                        name = "icon",
                        texture = "guis/textures/pd2/feature_crimenet_heat",
                        w = 64,
                        h = 64,
                        x = 10,
                        y = 10
                    },
                    events = {}
                }),
                ComputerText:new({
                    config = {
                        name = "text",
                        text = "Access denied.",
                        font = "fonts/font_medium_noshadow_mf",
                        render_template = "Text",
                        font_size = 40,
                        color = Color.white,
                        x = 85,
                        vertical = "center"
                    },
                    events = {}
                })
            }
        })
    }
}

tweak_data.computer_gui = {
    development = {
        workspace = {
            background_texture = "guis/textures/computergui/backgrounds/xp_bg",
        },
        applications = {
            {
                name = "computer_gui_app_trash",
                icon = "guis/textures/computergui/backgrounds/application_icon_trash",
                panel = presets.access_denied
            }
            --[[{
                name = "computer_gui_app_browser",
                icon = "guis/textures/computergui/backgrounds/application_icon_browser",
                panel = "guis/computer_gui/prompt_access_denied"
            },
            {
                name = "computer_gui_app_keygen",
                icon = "guis/textures/computergui/backgrounds/application_icon_keygen",
                panel = "guis/computer_gui/prompt_keygen"
            }]]
        }
    }
}