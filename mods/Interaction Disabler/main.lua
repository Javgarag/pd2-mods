InteractionDisabler = InteractionDisabler or class()
InteractionDisabler.interacts = {}
InteractionDisabler._data_path = SavePath .. "InteractionDisabler_Data.txt"
InteractionDisabler._data = {}
InteractionDisabler._block_interactions_dynamic = false
local menu_id = "interact_disabler_menu"
local params = {}
function params.callback()
    for v in pairs(InteractionDisabler._data) do
        InteractionDisabler._data[tostring(v)] = false
    end
    InteractionDisabler:Save()
    managers.viewport:resolution_changed()
    managers.mission._fading_debug_output:script().log("Restart or enter a mission to apply changes", Color("e82020"))
end

-- Save/Load configuration

function InteractionDisabler:Save()
	local file = io.open( self._data_path, "w+" )
	if file then
		file:write( json.encode( self._data ) )
		file:close()
	end
end

function InteractionDisabler:Load()
	local file = io.open(self._data_path, "r" )
	if file then
		self._data = json.decode( file:read("*all") )
		file:close()
    else
        local file = io.open(self._data_path, "w+" )
        file:write(json.encode({ExampleInteractionID1 = true, ExampleInteractionID2 = false, ExampleInteractionID3 = false}))
        file:close()
	end
end

-- Loc

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_interact_disabler", function(localization_manager)
    localization_manager:add_localized_strings({
      ["interact_disabler_name"] = "Interaction Disabler",
      ["interact_disabler_desc"] = "Configure what interactions to disable here",
    })
end)

-- Populate menu and setup

Hooks:PostHook(InteractionTweakData, "init", "interact_tweak_data_populate_interact_disabler", function (self, tweak_data)
    Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_interact_disabler", function( menu_manager )
        MenuCallbackHandler.callback_interact_disabler_save = function(self, item)
            InteractionDisabler:Save()
        end
        MenuCallbackHandler.callback_interaction_disabler_reset = function(self, item)
            managers.menu:show_default_option_dialog(params)
        end
        for k,v in pairs(tweak_data.interaction) do
            MenuCallbackHandler["callback_disable_interact_".. tostring(k)] = function(self, item)
                InteractionDisabler._data[tostring(k)] = item:value() == "on"
            end
        end
        InteractionDisabler:Load()
    end)
    Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_interact_disabler", function(menu_manager, nodes)
        MenuHelper:NewMenu(menu_id)
    end)

    Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus_interact_disabler", function( menu_manager, nodes )
        MenuHelper:AddButton({
            id = "reset_button",
            title = "Remove all interactions from block list",
            desc = "Make the mod delete all the blocked interactions from its save file so they aren't blocked anymore",
            callback = "callback_interaction_disabler_reset",
            menu_id = menu_id,
            localized = false,
            priority = 99999
        })
        MenuHelper:AddDivider({
            id = "divider",
            menu_id = menu_id,
            size = 16
        })
        for v in pairs(tweak_data.interaction) do
            if type(tweak_data.interaction[v]) ~= "number" then
                MenuHelper:AddToggle({
                    id = tostring(v),
                    menu_id = menu_id,
                    localized = false,
                    title = tweak_data.interaction[v].text_id and managers.localization:text(tweak_data.interaction[v].text_id, {
                        BTN_INTERACT = "[F]",
                        VALUE = "",
                        AMMO_LEFT = "0",
                        INTERACT = "[F]"
                    }) or "No text string available for this interaction",
                    desc = "Tweak data entry: ".. tostring(v),
                    value = InteractionDisabler._data[tostring(v)] or false,
                    callback = "callback_disable_interact_"..tostring(v)
                })
            end
        end
    end)

    Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_interact_disabler", function(menu_manager, nodes)  
        nodes[menu_id] = MenuHelper:BuildMenu(menu_id, {back_callback = "callback_interact_disabler_save"})    
        MenuHelper:AddMenuItem(nodes.blt_options, menu_id, "interact_disabler_name", "interact_disabler_desc")
    end)
end)

-- Interaction blocking

BaseInteractionExt = BaseInteractionExt or class()
IntimitateInteractionExt = IntimitateInteractionExt or class(BaseInteractionExt)
UseInteractionExt = UseInteractionExt or class(BaseInteractionExt)

local old_init = BaseInteractionExt.init
function BaseInteractionExt:init(unit, ...)
    self._unit = unit
	if InteractionDisabler._data[self.tweak_data] then
        self.set_active = function() end
        self.save = function() end
        return 
    end
	return old_init(self, unit, ...)
end

local old_init_intimitate = IntimitateInteractionExt.init
function IntimitateInteractionExt:init(unit, ...)
    self._unit = unit
	if InteractionDisabler._data[self.tweak_data] then
        self.set_active = function() end
        self.save = function() end
        return 
    end
	return old_init_intimitate(self, unit, ...)
end

local old_set_tweakdata = BaseInteractionExt.set_tweak_data
function BaseInteractionExt:set_tweak_data(id, ...)
    if InteractionDisabler._data[id] then return end
    return old_set_tweakdata(self, id, ...)
end

local old_destroy = BaseInteractionExt.destroy
function BaseInteractionExt:destroy(...)
    if self._tweak_data then return old_destroy(self, ...) end
end

local old_sync_interacted = UseInteractionExt.sync_interacted
function UseInteractionExt:sync_interacted(peer, player, ...)
    if InteractionDisabler._data[self.tweak_data] == true then 
        if self._unit then
            self._unit:damage():run_sequence_simple("interact", {
                unit = player
            })
        end
        return 
    end
    return old_sync_interacted(self, peer, player, ...)
end

-- Dynamic block mode

local old_interact = BaseInteractionExt.interact
function BaseInteractionExt:interact(...)
    if InteractionDisabler._block_interactions_dynamic then
        InteractionDisabler._data[self.tweak_data] = true
        InteractionDisabler:Save()
        managers.mission._fading_debug_output:script().log("Added ".. self.tweak_data .. " to block list", Color("e82020"))
    end
    return old_interact(self, ...)
end

local old_interact_intimitate = IntimitateInteractionExt.interact
function IntimitateInteractionExt:interact(...)
    if InteractionDisabler._block_interactions_dynamic then
        InteractionDisabler._data[self.tweak_data] = true
        InteractionDisabler:Save()
        managers.mission._fading_debug_output:script().log("Added ".. self.tweak_data .. " to block list", Color("e82020"))
    end
    return old_interact_intimitate(self, ...)
end