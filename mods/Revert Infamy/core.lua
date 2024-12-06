-- // Made by Javgarag for the MarcMB discord server \\ --

RevertInfamy = RevertInfamy or class()
RevertInfamy._revert_mode = false
RevertInfamy._can_revert_infamy = false

local old_setup_infamytreegui = InfamyTreeGui._setup
local old_mouse_moved_infamytreegui = InfamyTreeGui.mouse_moved

-- GUI Setup: Button creation, localization changes

function InfamyTreeGui:_setup()

    LocalizationManager:add_localized_strings({
	    menu_infamy_go_infamous = string.upper("Infamy options"),
        menu_infamy_go_inf_rep = string.upper("Go infamous with reputation"),
        menu_infamy_go_inf_prestige = string.upper("Go infamous with infamy pool"),
        dialog_revert_infamy = string.upper("You are reverting an infamy!"),
        menu_dialog_revert_infamy = "You are about to revert an infamy level. An infamy level will be substracted.\n\nYour infamy pool will not be altered. Do you want to continue?",
		dialog_yes_revert_inf_01 = string.upper("Yes, and change my normal level to 100"),
		dialog_yes_revert_inf_02 = string.upper("Yes, and change my normal level to 0"),
		menu_infamy_rank_reverted = "Your infamy rank has been reverted to $infamy_rank !",
    })

    old_setup_infamytreegui(self)

    local revert_infamy_error_string = ""
    local infamy_panel_bottom = self.infamous_panel:child("infamy_panel_bottom")
    local go_inf_panel_main = self.infamous_panel:child("infamy_panel_bottom"):child("go_infamous_button")
    local FONT_SIZE = tweak_data.menu.pd2_small_font_size
    local FONT = tweak_data.menu.pd2_small_font
    local BUTTON_COLOR = tweak_data.screen_colors.button_stage_3

    -- Infamy Pool and Rep button adjustment so ours fits in!

    local shift_amount = 15

    infamy_panel_bottom:set_y(infamy_panel_bottom:y() - 10)
    infamy_panel_bottom:set_h(infamy_panel_bottom:h() + 50)

    for i = 1, #infamy_panel_bottom:children() do
        if infamy_panel_bottom:children()[i]:name() == "" then
            infamy_panel_bottom:children()[i]:set_y(infamy_panel_bottom:children()[i]:y() + shift_amount)
        end
    end

    go_inf_panel_main:set_h(go_inf_panel_main:h() + 20)
    go_inf_panel_main:child("go_infamous_prestige_panel"):set_y(go_inf_panel_main:child("go_infamous_prestige_panel"):y() + shift_amount)
    go_inf_panel_main:child("go_infamous_rep_panel"):set_y(go_inf_panel_main:child("go_infamous_rep_panel"):y() + shift_amount)

    -- Creating new "Revert Infamy" button 

	if go_inf_panel_main:child("revert_infamy_panel") ~= nil then 
		return
	end

    if (managers.experience:current_rank() - 1) < 0 then
        RevertInfamy._can_revert_infamy = false
        revert_infamy_error_string = "CAN'T REVERT TO A NEGATIVE INFAMY"
	else
		RevertInfamy._can_revert_infamy = true
    end

    local revert_infamy_panel = go_inf_panel_main:panel({
		name = "revert_infamy_panel",
		y = FONT_SIZE * 1.5,
		h = FONT_SIZE,
	})

    revert_infamy_panel:rect({
		name = "revert_infamy_highlight",   
		visible = false,
		alpha = 0.4,
		layer = 1,
		color = BUTTON_COLOR
	})

	local text_revert_infamy = revert_infamy_panel:text({
		name = "revert_infamy_text",
		align = "right",
		layer = 3,
		text = "REVERT AN INFAMY LEVEL",
		h = FONT_SIZE,
		font = FONT,
		font_size = FONT_SIZE,
		color = RevertInfamy._can_revert_infamy and BUTTON_COLOR or tweak_data.screen_color_grey
	})
	local error_text_revert_infamy = infamy_panel_bottom:text({
		wrap = true,
		align = "right",
		layer = 3,
		text = revert_infamy_error_string,
		font = FONT,
		font_size = FONT_SIZE,
		color = tweak_data.screen_colors.important_1,
		visible = RevertInfamy._can_revert_infamy == false
	})

	ExtendedPanel.make_fine_text(error_text_revert_infamy)
	error_text_revert_infamy:set_righttop(go_inf_panel_main:w() - 5, text_revert_infamy:bottom() - 15)
end

-- Mouse over button detection

function InfamyTreeGui:mouse_moved(o, x, y)
    local BUTTON_COLOR = tweak_data.screen_colors.button_stage_3
    local MOUSEOVER_COLOR = tweak_data.screen_colors.button_stage_2
	if managers.menu_scene and managers.menu_scene:input_focus() then
		return false
	end

	local used = false
	local pointer = "arrow"

    if RevertInfamy._can_revert_infamy == true then
        local rev_button = self.infamous_panel:child("infamy_panel_bottom"):child("go_infamous_button"):child("revert_infamy_panel")

		if not self._revert_highlight and rev_button:inside(x, y) then
			used = true
			pointer = "link"
			self._revert_highlight = true

			rev_button:child("revert_infamy_text"):set_color(MOUSEOVER_COLOR)
			rev_button:child("revert_infamy_highlight"):set_visible(true)
			managers.menu_component:post_event("highlight")
		elseif self._revert_highlight and not rev_button:inside(x, y) then
			self._revert_highlight = false

			rev_button:child("revert_infamy_text"):set_color(BUTTON_COLOR)
			rev_button:child("revert_infamy_highlight"):set_visible(false)
		end
    end

    old_mouse_moved_infamytreegui(self, o, x, y)
end

-- Confirmation Prompt

if string.lower(RequiredScript) == "lib/managers/menumanagerdialogs" then
	function MenuManager:show_confirm_revert_infamy(params)

		local dialog_data = {
			title = managers.localization:text("dialog_revert_infamy")
		}
		local no_button = {
			callback_func = params.no_func,
			cancel_button = true,
			text = managers.localization:text("dialog_no")
		}

		local yes_button = {
			text = managers.localization:text("dialog_yes_revert_inf_01"),
			callback_func = params.yes_func
		}

		local yes_button_with_level_reset = {
			text = managers.localization:text("dialog_yes_revert_inf_02"),
			callback_func = params.yes_with_level_reset_func
		}

		dialog_data.text = managers.localization:text("menu_dialog_revert_infamy", {
			level = 100,
			cash = params.cost
		})

		dialog_data.focus_button = 2
		dialog_data.button_list = {
			yes_button,
			yes_button_with_level_reset,
			no_button
		}
		
		dialog_data.w = 620
		dialog_data.h = 500

		managers.system_menu:show_new_unlock(dialog_data)
	end
end
-- MenuCallbackHandler revert_infamy

function MenuCallbackHandler:revert_infamy(params)

    local new_rank = managers.experience:current_rank() - 1
	local yes_clbk = params and params.yes_clbk or false
	local no_clbk = params and params.no_clbk
	local params = {
		cost = managers.experience:cash_string(0),
		free = true
	}

	if 1 == 1 then--managers.experience:current_level() == 0 then
		function params.yes_func()
			RevertInfamy._revert_mode = true
			managers.menu:open_node("blackmarket_preview_node", {
				{
					back_callback = callback(MenuCallbackHandler, MenuCallbackHandler, "_revert_infamy", yes_clbk)
				}
			})
			managers.menu:post_event("infamous_stinger_generic")
			managers.menu_scene:spawn_infamy_card(new_rank)
		end
		function params.yes_with_level_reset_func()
			RevertInfamy._revert_mode = true
			managers.menu:open_node("blackmarket_preview_node", {
				{
					back_callback = callback(MenuCallbackHandler, MenuCallbackHandler, "_revert_infamy_level_reset", yes_clbk)
				}
			})
			managers.menu:post_event("infamous_stinger_generic")
			managers.menu_scene:spawn_infamy_card(new_rank)
		end
	end

	function params.no_func()
		if no_clbk then
			no_clbk()
		end
	end

	managers.menu:show_confirm_revert_infamy(params)
end

-- Mouse clicking button detection

function InfamyTreeGui:mouse_pressed(button, x, y)
	
    self.scroll:mouse_pressed(button, x, y)

	if button == Idstring("0") then
		if self._panel:child("back_button"):inside(x, y) then
			managers.menu:back()

			return
		end

		if RevertInfamy._can_revert_infamy and self.infamous_panel:child("infamy_panel_bottom"):child("go_infamous_button"):child("revert_infamy_panel"):inside(x, y) then
			self.scroll:set_input_focus(false)
			MenuCallbackHandler:revert_infamy({
				no_clbk = function ()
					self.scroll:set_input_focus(true)
				end
			})
			return
		end

		if self._can_go_infamous and self.infamous_panel:child("infamy_panel_bottom"):child("go_infamous_button"):child("go_infamous_rep_panel"):inside(x, y) and MenuCallbackHandler:can_become_infamous() and managers.money:get_infamous_cost(managers.experience:current_rank() + 1) <= managers.money:offshore() then
			self.scroll:set_input_focus(false)
			MenuCallbackHandler:become_infamous({
				no_clbk = function ()
					self.scroll:set_input_focus(true)
				end
			})

			return
		end

		if self._can_go_infamous_prestige and self.infamous_panel:child("infamy_panel_bottom"):child("go_infamous_button"):child("go_infamous_prestige_panel"):inside(x, y) and MenuCallbackHandler:can_become_infamous() and managers.money:get_infamous_cost(managers.experience:current_rank() + 1) <= managers.money:offshore() then
			self.scroll:set_input_focus(false)
			MenuCallbackHandler:become_infamous_with_prestige({
				no_clbk = function ()
					self.scroll:set_input_focus(true)
				end
			})

			return
		end

		if self.scroll:inside(x, y) then
			for index, item in ipairs(self.scroll:items()) do
				if item:inside(x, y) then
					self:unlock_infamy_item(item)

					return
				end
			end
		end
	end

	if button == Idstring("mouse wheel down") and self.scroll:inside(x, y) then
		self.scroll:perform_scroll(-60)
	elseif button == Idstring("mouse wheel up") and self.scroll:inside(x, y) then
		self.scroll:perform_scroll(60)
	end

end

-- Resetting the menu

function MenuCallbackHandler:_revert_infamy(yes_clbk)
	RevertInfamy._revert_mode = false

    managers.menu_scene:destroy_infamy_card()

	local rank = managers.experience:current_rank() - 1

    if rank > managers.experience:current_rank() then
        return
    end

	managers.experience:reset()
	managers.experience:set_current_rank(rank)
	managers.experience:give_experience(23336413, true)	

	managers.skilltree:next_specialization()
	managers.skilltree:previous_specialization()

	managers.skilltree:switch_skills_to_next() 
	managers.skilltree:switch_skills_to_previous() 

	if managers.menu_component then
		managers.menu_component:refresh_player_profile_gui()
	end

	local logic = managers.menu:active_menu().logic

	if logic then
		logic:refresh_node()
		logic:select_item("crimenet")
	end

	managers.savefile:save_progress("steam_cloud")
	managers.savefile:save_progress("local_hdd")
	managers.savefile:save_setting(true)
	managers.menu:post_event("infamous_player_join_stinger")

	if yes_clbk then
		yes_clbk()
	end

	if SystemInfo:distribution() == Idstring("STEAM") then
		managers.statistics:publish_level_to_steam()
	end
end

function MenuCallbackHandler:_revert_infamy_level_reset(yes_clbk)
	RevertInfamy._revert_mode = false

	managers.menu_scene:destroy_infamy_card()

	local max_rank = tweak_data.infamy.ranks

	if max_rank <= managers.experience:current_rank() then
		return
	end

	local rank = managers.experience:current_rank() - 1

    if rank > managers.experience:current_rank() then
        return
    end

	managers.experience:reset()
	managers.experience:set_current_rank(rank)

	managers.skilltree:infamy_reset()
	managers.multi_profile:infamy_reset()
	managers.blackmarket:reset_equipped()

	if managers.menu_component then
		managers.menu_component:refresh_player_profile_gui()
	end

	local logic = managers.menu:active_menu().logic

	if logic then
		logic:refresh_node()
		logic:select_item("crimenet")
	end

	managers.savefile:save_progress("steam_cloud")
	managers.savefile:save_progress("local_hdd")
	managers.savefile:save_setting(true)
	managers.menu:post_event("infamous_player_join_stinger")

	if yes_clbk then
		yes_clbk()
	end

	if SystemInfo:distribution() == Idstring("STEAM") then
		managers.statistics:publish_level_to_steam()
	end
end

-- Correction for infamy text
MenuSceneGui = MenuSceneGui or class()
function MenuSceneGui:update(t, dt)
    if self._shown_infamy_text_t then
		if self._shown_infamy_text_t <= t then
			self._shown_infamy_text_t = nil
			local current_rank = managers.experience:current_rank()
			if RevertInfamy._revert_mode == true then
				local infamous_string = managers.localization:to_upper_text("menu_infamy_rank_reverted", {
					infamy_rank = tostring(current_rank - 1)
				})
				self._infamy_increased_text = self._panel:text({
					vertical = "top",
					align = "center",
					layer = 1,
					text = infamous_string,
					font = tweak_data.menu.pd2_large_font,
					font_size = tweak_data.menu.pd2_large_font_size
				})
	
				self._infamy_increased_text:move(0, self._panel:h() * 0.1)
			else
				local infamous_string = managers.localization:to_upper_text(current_rank == 0 and "menu_infamy_rank_reached" or "menu_infamy_rank_increased", {
					infamy_rank = tostring(current_rank + 1)
				})
				self._infamy_increased_text = self._panel:text({
					vertical = "top",
					align = "center",
					layer = 1,
					text = infamous_string,
					font = tweak_data.menu.pd2_large_font,
					font_size = tweak_data.menu.pd2_large_font_size
				})
	
				self._infamy_increased_text:move(0, self._panel:h() * 0.1)
			end

		end
	elseif managers.menu_scene:infamy_card_shown() and not alive(self._infamy_increased_text) then
		self._shown_infamy_text_t = t + 4
	end

	if alive(self._infamy_increased_text) then
		-- Nothing
	end

	if managers.menu:is_pc_controller() then
		return
	end

	if mvector3.is_zero(self._left_axis_vector) then
		managers.menu_scene:stop_controller_move()
	else
		local x = mvector3.x(self._left_axis_vector)
		local y = mvector3.y(self._left_axis_vector)

		managers.menu_scene:controller_move(x * dt, y * dt)
	end

	if mvector3.is_zero(self._right_axis_vector) then
		managers.menu_scene:stop_controller_zoom()
	else
		local x = mvector3.x(self._right_axis_vector)
		local y = mvector3.y(self._right_axis_vector)

		managers.menu_scene:controller_zoom(x * dt, y * dt)
	end
end