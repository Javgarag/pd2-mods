ContractBoxGui = ContractBoxGui or class()

if not managers.network then return end
local session = managers.network:session()
if not session then return end
local in_lobby = game_state_machine:verify_game_state(GameStateFilters.lobby) and session:local_peer():in_lobby()
if not in_lobby then return end

local menu = managers.menu:get_menu("menu_main")
if not menu then return end
local node = menu.data._nodes["lobby"]

if node:item("leave_lobby"):visible() then
    -- Hide components
    managers.menu_component:close_contract_gui()
    managers.menu_component:hide_lobby_chat_gui()
    managers.menu_component:close_lobby_code_gui()

    -- Hide the items
    for _, item in pairs(node:items()) do
        item:set_visible(false)
        log(item:name())
    end

    managers.menu:active_menu().logic:refresh_node("lobby", true)
else
    -- Show components
    managers.menu_component:create_contract_gui()
    managers.menu_component:_create_lobby_chat_gui()
    managers.menu_component:create_lobby_code_gui(node)

    -- Show the items
    for _, item in pairs(node:items()) do
        item:set_visible(true)
    end

    managers.menu:active_menu().logic:refresh_node("lobby", true)
end
