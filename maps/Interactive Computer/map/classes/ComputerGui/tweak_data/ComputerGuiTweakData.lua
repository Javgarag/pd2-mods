local MODULE_DIRECTORY = BeardLib.current_level._mod.ModPath .. "classes/ComputerGui/modules/"
local REQUIRED_MODULES = {
    "base/ComputerObjectBase.lua",
    "base/ComputerWindow.lua"
}
local modules = {
    "base/ComputerBitmap.lua",
    "base/ComputerText.lua",
    "base/ComputerRect.lua",

    -- Add any additional modules here
    "slow/ComputerProgressBar.lua"
}

for _, module in pairs(REQUIRED_MODULES) do
	dofile(MODULE_DIRECTORY .. module)
end
for _, module in pairs(modules) do
	dofile(MODULE_DIRECTORY .. module)
end

local presets = {
    access_denied = {
        config = {
            halign = "grow",
            valign = "grow",
            w = 340,
            h = 84
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
    },
    keygen = {
        config = {
            halign = "grow",
            valign = "grow",
            w = 600,
            h = 200
        },
        children = {
            ComputerProgressBar:new({
                config = {
                    name = "progress_bar",
                    w = 600,
                    h = 200
                },
                events = {
                    open = {
                        type = "callback",
                        enabled = true,
                        event = "clbk_start",
                        post_event = {
                            sound_event_id = "bar_train_panel_hacking"
                        }
                    }
                }
            })
        },
        background_color = Color.black
    }
}

tweak_data.computer_gui = {
    development = {
        workspace = {
            background_texture = "guis/textures/computergui/backgrounds/xp_bg",
        },
        applications = {

            {
                name = "computer_gui_app_browser",
                icon = "guis/textures/computergui/backgrounds/application_icon_browser",
                window = deep_clone(presets.access_denied)
            },
        }
    }
}