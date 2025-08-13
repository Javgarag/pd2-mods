local MODULE_DIRECTORY = BeardLib.current_level._mod.ModPath .. "classes/ComputerGui/modules/"
local modules = {
    "ComputerWindow.lua",
	"ComputerBitmap.lua",
    "ComputerText.lua",
    "ComputerRect.lua"
}

dofile(MODULE_DIRECTORY .. "ComputerObjectBase.lua")
for _, module in pairs(modules) do
	dofile(MODULE_DIRECTORY .. module)
end

tweak_data.computer_gui = {
    development = {
        workspace = {
            background_texture = "guis/textures/computergui/backgrounds/xp_bg",
        },
        applications = {
            {
                name = "computer_gui_app_trash",
                icon = "guis/textures/computergui/backgrounds/application_icon_trash",
                window = {
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
                    },
                    events = {
                        open = {
                            type = "callback",
                            event = "clbk_open"
                        },
                        close = {
                            type = "callback",
                            event = "clbk_close"
                        },
                        attention = {
                            type = "callback",
                            event = "clbk_attention"
                        }
                    }
                }
            },
            {
                name = "computer_gui_app_browser",
                icon = "guis/textures/computergui/backgrounds/application_icon_browser",
                window = {
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
                    },
                    events = {
                        open = {
                            type = "callback",
                            event = "clbk_open"
                        },
                        close = {
                            type = "callback",
                            event = "clbk_close"
                        },
                        attention = {
                            type = "callback",
                            event = "clbk_attention"
                        }
                    }
                }
            }
            --[[{
                name = "computer_gui_app_keygen",
                icon = "guis/textures/computergui/backgrounds/application_icon_keygen",
                panel = "guis/computer_gui/prompt_keygen"
            }]]
        }
    }
}