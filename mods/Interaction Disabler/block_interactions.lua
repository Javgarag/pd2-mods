InteractionDisabler = InteractionDisabler or class()
InteractionDisabler._block_interactions_dynamic = true
managers.mission._fading_debug_output:script().log("Active until mission restart/end/leave", tweak_data.system_chat_color)
managers.mission._fading_debug_output:script().log("Activated dynamic block mode; completed interactions from now on will be blocked starting next map load", tweak_data.system_chat_color)
managers.mission._fading_debug_output:script().log("Interaction Disabler", Color("a7ddf4"))