local wezterm = require "wezterm"
local config = wezterm.config_builder()
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

  local act = wezterm.action

  local function hURI_editLnCn(win, pane, uri)
    local prefix	= 'file-line-column://' -- 'file-line-column:///path/to/file.txt:ln:col'
    -- the exact scheme of the URL depends on the editor, so ↑ and editor arguments ↓ need to be adjusted to reflect that
    -- https://github.com/dandavison/open-in-editor/blob/master/open-in-editor
    local prefix_re	= prefix:escmagic() -- escape -:/
    local prefix_beg, prefix_end = uri:find('^'..prefix_re)
    if prefix_beg == 1 then
      local editor_cli = 'C:/Users/Alan_/.cargo/bin/hx.exe'
      local uri_target = uri:sub(prefix_end + 1)
      win:perform_action(act.SpawnCommandInNewTab {args={editor_cli,uri_target}},pane)
      return false -- prevent the default action from opening in a browser
    end
    -- no return value → allow later handlers and ultimately the default action to run
  end
  wezterm.on('open-uri', hURI_editLnCn) -- open file-line-column URIs in a terminal text editor  
end

return module
