local MODULE_DIRECTORY = BeardLib.current_level._mod.ModPath .. "classes/ComputerGui/modules/"
local REQUIRED_MODULES = {
    "base/ComputerObjectBase.lua",
    "base/ComputerWindow.lua"
}
local modules = {
    -- Add any additional modules here
    "base/ComputerBitmap.lua",
    "base/ComputerText.lua",
    "base/ComputerRect.lua",
    "base/ComputerVideo.lua",
    "example/ComputerProgressBar.lua"
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
                        event = "clbk_start"
                    }
                },
                update_enabled = true
            })
        },
        events = {
            prompt_insert_drive = {
                type = "spawn",
                enabled = true,
                event = ComputerWindow:new({
                    config = {
                        halign = "grow",
                        valign = "grow",
                        w = 340,
                        h = 84
                    },
                    background_color = Color.red,
                    can_user_close = false,
                    children = {
                        ComputerText:new({
                            config = {
                                name = "insert_drive_text",
                                text = "ERROR: Insert drive.",
                                font = "fonts/font_medium_noshadow_mf",
                                render_template = "Text",
                                font_size = 40,
                                color = Color.white,
                                y = function(self) 
                                    return self._parent:object():y() / 2 
                                end,
                                x = function(self) 
                                    return self._parent:object():x() / 2 + 10
                                end,
                                vertical = "center"
                            }
                        })
                    }
                })
            },
            play_video = {
                type = "spawn",
                enabled = true,
                event = ComputerWindow:new({
                    config = {
                        halign = "grow",
                        valign = "grow",
                        w = 660,
                        h = 380
                    },
                    background_color = Color.black,
                    can_user_close = false,
                    children = {
                        ComputerVideo:new({
                            config = {
                                video = "movies/attract",
                                width = 640,
                                height = 360,
                                x = 10,
                                y = 10
                            },
                            events = {
                                open = {
                                    type = "callback",
                                    enabled = true,
                                    event = "play_video"
                                }
                            }
                        })
                    }
                })
            }
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
            {
                name = "computer_gui_app_keygen",
                icon = "guis/textures/computergui/backgrounds/application_icon_keygen",
                window = deep_clone(presets.keygen)
            },
        }
    }
}