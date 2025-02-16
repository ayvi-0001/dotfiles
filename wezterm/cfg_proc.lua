local module = {}

function module.apply_to_config(config)
  config.allow_win32_input_mode = true
  config.audible_bell = "Disabled"
  config.automatically_reload_config = false
  config.bypass_mouse_reporting_modifiers = "ALT"
  config.disable_default_quick_select_patterns = true
  config.hide_mouse_cursor_when_typing = false
  config.log_unknown_escape_sequences = true
  config.prefer_to_spawn_tabs = true
  config.scroll_to_bottom_on_input = true
  config.switch_to_last_active_tab_when_closing_tab = true
  config.treat_left_ctrlalt_as_altgr = true
end

return module
