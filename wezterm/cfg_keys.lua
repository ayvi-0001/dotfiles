local callbacks = require "callbacks"
local wezterm = require "wezterm" --[[@as Wezterm]]
local window_space = require "window_space"

local M = {}

---@param config Config
---@return nil
function M.apply_to_config(config)
  config.allow_win32_input_mode = true
  config.bypass_mouse_reporting_modifiers = "ALT"
  -- config.debug_key_events = true
  config.disable_default_key_bindings = true
  config.disable_default_quick_select_patterns = true
  config.hide_mouse_cursor_when_typing = false
  config.treat_left_ctrlalt_as_altgr = true

  local key_tables = {
    pane = { name = "pane", timeout_milliseconds = 3000 },
    resize = { name = "resize", one_shot = false, timeout_milliseconds = 3000, until_unknown = true },
    resize_window = { name = "resize_window", one_shot = false, replace_current = true },
    move = { name = "move", one_shot = false, timeout_milliseconds = 1000, replace_current = true },
    tab = { name = "tab", one_shot = false, timeout_milliseconds = 1000, until_unknown = true, replace_current = true },
    scroll = { name = "scroll", one_shot = false, until_unknown = true, replace_current = true },
    session = { name = "session", timeout_milliseconds = 3000, until_unknown = true, replace_current = true },
    disable_one_shot = { name = "disable_key_tables", until_unknown = false },
    disable = { name = "disable_key_tables", one_shot = false, until_unknown = false },
  }

  config.leader = { key = "-", mods = "CMD" }

  config.keys = {
    { key = "p", mods = "CTRL", action = wezterm.action.ActivateKeyTable(key_tables["pane"]) },
    { key = "n", mods = "CTRL", action = wezterm.action.ActivateKeyTable(key_tables["resize"]) },
    { key = "h", mods = "CTRL", action = wezterm.action.ActivateKeyTable(key_tables["move"]) },
    { key = "t", mods = "CTRL", action = wezterm.action.ActivateKeyTable(key_tables["tab"]) },
    { key = "s", mods = "CTRL", action = wezterm.action.ActivateKeyTable(key_tables["scroll"]) },
    { key = "o", mods = "CTRL", action = wezterm.action.ActivateKeyTable(key_tables["session"]) },
    { key = "d", mods = "LEADER", action = wezterm.action.ActivateKeyTable(key_tables["disable_one_shot"]) },
    { key = "D", mods = "LEADER|SHIFT", action = wezterm.action.ActivateKeyTable(key_tables["disable"]) },
    { key = "x", mods = "CTRL|SHIFT", action = wezterm.action.ActivateCopyMode },
    { key = "f", mods = "ALT", action = wezterm.action.EmitEvent "toggle-floating-pane" },
    { key = "h", mods = "ALT", action = wezterm.action_callback(callbacks.move_focus_or_tab_left) },
    { key = "l", mods = "ALT", action = wezterm.action_callback(callbacks.move_focus_or_tab_right) },
    { key = "k", mods = "ALT", action = wezterm.action.ActivatePaneDirection "Up" },
    { key = "j", mods = "ALT", action = wezterm.action.ActivatePaneDirection "Down" },
    { key = "+", mods = "CTRL|SHIFT", action = wezterm.action.IncreaseFontSize },
    { key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
    { key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },
    { key = "H", mods = "ALT", action = wezterm.action.ActivateTabRelative(-1) },
    { key = "L", mods = "ALT", action = wezterm.action.ActivateTabRelative(1) },
    { key = "i", mods = "ALT", action = wezterm.action.MoveTabRelative(-1) },
    { key = "o", mods = "ALT", action = wezterm.action.MoveTabRelative(1) },
    { key = "f", mods = "CTRL|SHIFT", action = wezterm.action.Search "CurrentSelectionOrEmptyString" },
    { key = "C", mods = "CTRL|SHIFT", action = wezterm.action.CopyTo "ClipboardAndPrimarySelection" },
    { key = " ", mods = "SHIFT|CTRL", action = wezterm.action.QuickSelect },
    { key = "V", mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom "Clipboard" },
    { key = "P", mods = "CTRL|SHIFT", action = wezterm.action.ActivateCommandPalette },
  }

  config.key_tables = {
    resize = {
      { key = "h", mods = "NONE", action = wezterm.action.AdjustPaneSize { "Left", 5 } },
      { key = "j", mods = "NONE", action = wezterm.action.AdjustPaneSize { "Down", 5 } },
      { key = "k", mods = "NONE", action = wezterm.action.AdjustPaneSize { "Up", 5 } },
      { key = "l", mods = "NONE", action = wezterm.action.AdjustPaneSize { "Right", 5 } },
      { key = "w", action = wezterm.action.ActivateKeyTable(key_tables["resize_window"]) },
      { key = "Escape", mods = "NONE", action = "PopKeyTable" },
    },

    resize_window = {
      { key = "h", mods = "NONE", action = wezterm.action.EmitEvent "increase-to-left" },
      { key = "H", mods = "SHIFT", action = wezterm.action.EmitEvent "decrease-from-left" },
      { key = "j", mods = "NONE", action = wezterm.action.EmitEvent "increase-to-bottom" },
      { key = "J", mods = "SHIFT", action = wezterm.action.EmitEvent "decrease-from-bottom" },
      { key = "k", mods = "NONE", action = wezterm.action.EmitEvent "increase-to-top" },
      { key = "K", mods = "SHIFT", action = wezterm.action.EmitEvent "decrease-from-top" },
      { key = "l", mods = "NONE", action = wezterm.action.EmitEvent "increase-to-right" },
      { key = "L", mods = "SHIFT", action = wezterm.action.EmitEvent "decrease-from-right" },
      { key = "Escape", mods = "NONE", action = "PopKeyTable" },
    },

    move = {
      { key = "H", mods = "SHIFT", action = wezterm.action_callback(callbacks.rotate_pane_left) },
      { key = "L", mods = "SHIFT", action = wezterm.action_callback(callbacks.rotate_pane_right) },
      { key = "h", mods = "NONE", action = wezterm.action.EmitEvent "move-window-left" },
      { key = "l", mods = "NONE", action = wezterm.action.EmitEvent "move-window-right" },
      { key = "k", mods = "NONE", action = wezterm.action.EmitEvent "move-window-up" },
      { key = "j", mods = "NONE", action = wezterm.action.EmitEvent "move-window-down" },
      { key = "Escape", mods = "NONE", action = "PopKeyTable" },
    },

    tab = {
      { key = "n", mods = "NONE", action = wezterm.action_callback(callbacks.spawn_default_prog_in_new_tab) },
      { key = "z", mods = "NONE", action = wezterm.action_callback(callbacks.spawn_default_prog_in_new_tab_in_home) },
      { key = "x", mods = "NONE", action = wezterm.action.CloseCurrentTab { confirm = false } },
      { key = "h", mods = "NONE", action = wezterm.action.ActivateTabRelative(-1) },
      { key = "l", mods = "NONE", action = wezterm.action.ActivateTabRelative(1) },
      { key = "r", mods = "NONE", action = wezterm.action_callback(callbacks.rename_tab) },
      { key = "`", mods = "NONE", action = wezterm.action.ActivateLastTab },
      { key = "t", mods = "NONE", action = wezterm.action.Multiple { "ShowTabNavigator", "PopKeyTable" } },
      { key = "t", mods = "CTRL", action = wezterm.action.Multiple { "ShowTabNavigator", "PopKeyTable" } },
      { key = "1", mods = "NONE", action = wezterm.action.ActivateTab(0) },
      { key = "2", mods = "NONE", action = wezterm.action.ActivateTab(1) },
      { key = "3", mods = "NONE", action = wezterm.action.ActivateTab(2) },
      { key = "4", mods = "NONE", action = wezterm.action.ActivateTab(3) },
      { key = "5", mods = "NONE", action = wezterm.action.ActivateTab(4) },
      { key = "6", mods = "NONE", action = wezterm.action.ActivateTab(5) },
      { key = "7", mods = "NONE", action = wezterm.action.ActivateTab(6) },
      { key = "8", mods = "NONE", action = wezterm.action.ActivateTab(7) },
      { key = "9", mods = "NONE", action = wezterm.action.ActivateTab(8) },
      { key = "Escape", mods = "NONE", action = "PopKeyTable" },
    },

    session = {
      { key = "d", mods = "NONE", action = wezterm.action.ShowDebugOverlay },
      { key = "h", mods = "NONE", action = wezterm.action.Hide },
      { key = "s", mods = "NONE", action = wezterm.action.Show },
      { key = "l", mods = "NONE", action = wezterm.action.ShowLauncher },
      { key = "q", mods = "NONE", action = wezterm.action.QuitApplication },
      { key = "f", mods = "NONE", action = wezterm.action.ToggleFullScreen },
      { key = "w", mods = "NONE", action = wezterm.action_callback(callbacks.launch_workspace) },
      { key = "n", mods = "NONE", action = wezterm.action_callback(callbacks.create_workspace) },
      { key = "1", mods = "NONE", action = wezterm.action.ActivateWindow(0) },
      { key = "2", mods = "NONE", action = wezterm.action.ActivateWindow(1) },
      { key = "3", mods = "NONE", action = wezterm.action.ActivateWindow(2) },
      { key = "4", mods = "NONE", action = wezterm.action.ActivateWindow(3) },
      { key = "5", mods = "NONE", action = wezterm.action.ActivateWindow(4) },
      { key = "6", mods = "NONE", action = wezterm.action.ActivateWindow(5) },
      { key = "7", mods = "NONE", action = wezterm.action.ActivateWindow(6) },
      { key = "8", mods = "NONE", action = wezterm.action.ActivateWindow(7) },
      { key = "9", mods = "NONE", action = wezterm.action.ActivateWindow(8) },
    },

    yazi_helix = {
      { key = "i", mods = "NONE", action = wezterm.action.EmitEvent "yazi-helix-launch-ide" },
      { key = "w", mods = "NONE", action = wezterm.action.EmitEvent "yazi-helix-open-new-window" },
      { key = "r", mods = "NONE", action = wezterm.action.EmitEvent "yazi-helix-open-new-right-pane" },
      { key = "R", mods = "SHIFT", action = wezterm.action.EmitEvent "yazi-helix-open-new-right-pane-top-level" },
      { key = "d", mods = "NONE", action = wezterm.action.EmitEvent "yazi-helix-open-new-bottom-pane" },
      { key = "D", mods = "SHIFT", action = wezterm.action.EmitEvent "yazi-helix-open-new-bottom-pane-top-level" },
      { key = "h", mods = "NONE", action = wezterm.action.EmitEvent "yazi-helix-open-in-left-pane" },
      { key = "j", mods = "NONE", action = wezterm.action.EmitEvent "yazi-helix-open-in-pane-below" },
      { key = "k", mods = "NONE", action = wezterm.action.EmitEvent "yazi-helix-open-in-pane-above" },
      { key = "l", mods = "NONE", action = wezterm.action.EmitEvent "yazi-helix-open-in-right-pane" },
      { key = "t", mods = "NONE", action = wezterm.action.EmitEvent "yazi-open-new-tab" },
      { key = "S", mods = "SHIFT", action = wezterm.action.EmitEvent "trigger-hx-with-scrollback" },
      { key = "Escape", mods = "NONE", action = "PopKeyTable" },
    },

    pane = {
      { key = "r", mods = "NONE", action = wezterm.action.SplitPane { direction = "Right" } },
      { key = "R", mods = "SHIFT", action = wezterm.action.SplitPane { direction = "Right", top_level = true } },
      { key = "d", mods = "NONE", action = wezterm.action.SplitPane { direction = "Down" } },
      { key = "D", mods = "SHIFT", action = wezterm.action.SplitPane { direction = "Down", top_level = true } },
      { key = "l", mods = "NONE", action = wezterm.action.SplitPane { direction = "Left" } },
      { key = "L", mods = "SHIFT", action = wezterm.action.SplitPane { direction = "Left", top_level = true } },
      { key = "u", mods = "NONE", action = wezterm.action.SplitPane { direction = "Up" } },
      { key = "U", mods = "SHIFT", action = wezterm.action.SplitPane { direction = "Up", top_level = true } },
      { key = "2", mods = "NONE", action = wezterm.action.ActivateKeyTable { name = "pane_25" } },
      { key = "3", mods = "NONE", action = wezterm.action.ActivateKeyTable { name = "pane_33" } },
      { key = "6", mods = "NONE", action = wezterm.action.ActivateKeyTable { name = "pane_66" } },
      { key = "7", mods = "NONE", action = wezterm.action.ActivateKeyTable { name = "pane_75" } },
      { key = "h", mods = "NONE", action = wezterm.action.ActivateKeyTable { name = "yazi_helix" } },
      { key = "i", mods = "NONE", action = wezterm.action.ActivateKeyTable { name = "pane_index" } },
      { key = "s", mods = "CTRL", action = wezterm.action.ActivateKeyTable { name = "pane_select" } },
      { key = "s", mods = "NONE", action = wezterm.action.PaneSelect { show_pane_ids = true } },
      { key = "f", mods = "NONE", action = wezterm.action.TogglePaneZoomState },
      { key = "n", mods = "NONE", action = wezterm.action.EmitEvent "spawn-new-window-80%" },
      { key = "N", mods = "SHIFT", action = wezterm.action.EmitEvent "spawn-new-window-50%" },
      { key = "w", mods = "NONE", action = wezterm.action.EmitEvent "toggle-floating-pane" },
      { key = "e", mods = "NONE", action = wezterm.action_callback(callbacks.move_pane_to_new_tab) },
      { key = "E", mods = "SHIFT", action = wezterm.action_callback(window_space.move_pane_to_new_window) },
      { key = "x", mods = "NONE", action = wezterm.action.CloseCurrentPane { confirm = false } },
      { key = "Escape", mods = "NONE", action = "PopKeyTable" },
    },

    pane_25 = create_sized_pane_key_table(25),
    pane_33 = create_sized_pane_key_table(33),
    pane_66 = create_sized_pane_key_table(66),
    pane_75 = create_sized_pane_key_table(75),

    pane_select = {
      { key = "t", mods = "NONE", action = wezterm.action.PaneSelect { mode = "MoveToNewTab", show_pane_ids = true } },
      { key = "w", mods = "NONE", action = wezterm.action.PaneSelect { mode = "MoveToNewWindow", show_pane_ids = true } },
      { key = "a", mods = "NONE", action = wezterm.action.PaneSelect { mode = "SwapWithActive", show_pane_ids = true } },
      { key = "f", mods = "NONE", action = wezterm.action.PaneSelect { mode = "SwapWithActiveKeepFocus", show_pane_ids = true } },
      { key = "Escape", mods = "NONE", action = "PopKeyTable" },
    },

    pane_index = {
      { key = "1", mods = "NONE", action = wezterm.action.ActivatePaneByIndex(0) },
      { key = "2", mods = "NONE", action = wezterm.action.ActivatePaneByIndex(1) },
      { key = "3", mods = "NONE", action = wezterm.action.ActivatePaneByIndex(2) },
      { key = "4", mods = "NONE", action = wezterm.action.ActivatePaneByIndex(3) },
      { key = "5", mods = "NONE", action = wezterm.action.ActivatePaneByIndex(4) },
      { key = "6", mods = "NONE", action = wezterm.action.ActivatePaneByIndex(5) },
      { key = "7", mods = "NONE", action = wezterm.action.ActivatePaneByIndex(6) },
      { key = "8", mods = "NONE", action = wezterm.action.ActivatePaneByIndex(7) },
      { key = "9", mods = "NONE", action = wezterm.action.ActivatePaneByIndex(8) },
      { key = "Escape", mods = "NONE", action = "PopKeyTable" },
    },

    scroll = {
      { key = "j", mods = "NONE", action = wezterm.action.ScrollByLine(1) },
      { key = "k", mods = "NONE", action = wezterm.action.ScrollByLine(-1) },
      { key = "d", mods = "NONE", action = wezterm.action.ScrollByPage(0.5) },
      { key = "u", mods = "NONE", action = wezterm.action.ScrollByPage(-0.5) },
      { key = "f", mods = "NONE", action = wezterm.action.ScrollByPage(1) },
      { key = "b", mods = "NONE", action = wezterm.action.ScrollByPage(-1) },
      { key = "c", mods = "NONE", action = wezterm.action_callback(callbacks.scroll_to_bottom) },
      { key = "s", mods = "CTRL", action = wezterm.action_callback(callbacks.scroll_to_bottom) },
      { key = "Escape", mods = "NONE", action = "PopKeyTable" },
    },

    copy_mode = {
      { key = "h", mods = "NONE", action = wezterm.action.CopyMode "MoveLeft" },
      { key = "j", mods = "NONE", action = wezterm.action.CopyMode "MoveDown" },
      { key = "k", mods = "NONE", action = wezterm.action.CopyMode "MoveUp" },
      { key = "l", mods = "NONE", action = wezterm.action.CopyMode "MoveRight" },
      { key = "b", mods = "NONE", action = wezterm.action.CopyMode "MoveBackwardWord" },
      { key = "w", mods = "NONE", action = wezterm.action.CopyMode "MoveForwardWord" },
      { key = "e", mods = "NONE", action = wezterm.action.CopyMode "MoveForwardWordEnd" },
      { key = "H", mods = "SHIFT", action = wezterm.action.CopyMode "MoveToStartOfLineContent" },
      { key = "L", mods = "SHIFT", action = wezterm.action.CopyMode "MoveToEndOfLineContent" },
      { key = "f", mods = "NONE", action = wezterm.action.CopyMode { JumpForward = { prev_char = false } } },
      { key = "F", mods = "SHIFT", action = wezterm.action.CopyMode { JumpBackward = { prev_char = false } } },
      { key = "t", mods = "NONE", action = wezterm.action.CopyMode { JumpForward = { prev_char = true } } },
      { key = "T", mods = "SHIFT", action = wezterm.action.CopyMode { JumpBackward = { prev_char = true } } },
      { key = "V", mods = "SHIFT", action = wezterm.action.CopyMode { SetSelectionMode = "Line" } },
      { key = "v", mods = "NONE", action = wezterm.action.CopyMode { SetSelectionMode = "Cell" } },
      { key = "v", mods = "CTRL", action = wezterm.action.CopyMode { SetSelectionMode = "Block" } },
      { key = ",", mods = "NONE", action = wezterm.action.CopyMode "JumpReverse" },
      { key = ";", mods = "NONE", action = wezterm.action.CopyMode "JumpAgain" },
      { key = "g", mods = "NONE", action = wezterm.action.CopyMode "MoveToScrollbackTop" },
      { key = "G", mods = "SHIFT", action = wezterm.action.CopyMode "MoveToScrollbackBottom" },
      { key = "T", mods = "CTRL|SHIFT", action = wezterm.action.CopyMode "MoveToViewportTop" },
      { key = "B", mods = "CTRL|SHIFT", action = wezterm.action.CopyMode "MoveToViewportBottom" },
      { key = "M", mods = "CTRL|SHIFT", action = wezterm.action.CopyMode "MoveToViewportMiddle" },
      { key = "b", mods = "CTRL", action = wezterm.action.CopyMode "PageUp" },
      { key = "f", mods = "CTRL", action = wezterm.action.CopyMode "PageDown" },
      { key = "d", mods = "CTRL", action = wezterm.action.CopyMode { MoveByPage = 0.5 } },
      { key = "u", mods = "CTRL", action = wezterm.action.CopyMode { MoveByPage = -0.5 } },
      { key = ";", mods = "ALT", action = wezterm.action.CopyMode "MoveToSelectionOtherEnd" },
      { key = "q", mods = "NONE", action = wezterm.action.Multiple { "ScrollToBottom", { CopyMode = "Close" } } },
      { key = "c", mods = "CTRL", action = wezterm.action.Multiple { "ScrollToBottom", { CopyMode = "Close" } } },
      { key = "Escape", mods = "NONE", action = wezterm.action.Multiple { "ScrollToBottom", { CopyMode = "Close" } } },
      {
        key = "y",
        mods = "NONE",
        action = wezterm.action.Multiple {
          { CopyTo = "ClipboardAndPrimarySelection" },
          { Multiple = { "ScrollToBottom", { CopyMode = "Close" } } },
        },
      },
    },

    disable_key_tables = {
      { key = "n", mods = "CTRL", action = wezterm.action.SendKey { key = "n", mods = "CTRL" } },
      { key = "p", mods = "CTRL", action = wezterm.action.SendKey { key = "p", mods = "CTRL" } },
      { key = "t", mods = "CTRL", action = wezterm.action.SendKey { key = "t", mods = "CTRL" } },
      { key = "h", mods = "CTRL", action = wezterm.action.SendKey { key = "h", mods = "CTRL" } },
      { key = "o", mods = "CTRL", action = wezterm.action.SendKey { key = "o", mods = "CTRL" } },
      { key = "s", mods = "CTRL", action = wezterm.action.SendKey { key = "s", mods = "CTRL" } },
      { key = "f", mods = "ALT", action = wezterm.action.SendKey { key = "f", mods = "ALT" } },
      { key = "h", mods = "ALT", action = wezterm.action.SendKey { key = "h", mods = "ALT" } },
      { key = "j", mods = "ALT", action = wezterm.action.SendKey { key = "j", mods = "ALT" } },
      { key = "k", mods = "ALT", action = wezterm.action.SendKey { key = "k", mods = "ALT" } },
      { key = "l", mods = "ALT", action = wezterm.action.SendKey { key = "l", mods = "ALT" } },
      { key = "H", mods = "ALT", action = wezterm.action.SendKey { key = "H", mods = "ALT" } },
      { key = "L", mods = "ALT", action = wezterm.action.SendKey { key = "L", mods = "ALT" } },
      { key = "i", mods = "ALT", action = wezterm.action.SendKey { key = "i", mods = "ALT" } },
      { key = "o", mods = "ALT", action = wezterm.action.SendKey { key = "o", mods = "ALT" } },
      { key = "d", mods = "LEADER", action = "PopKeyTable" },
    },
  }

  config.mouse_bindings = {
    -- Disable the default click behavior
    {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "NONE",
      action = wezterm.action.DisableDefaultAssignment,
    },
    -- Ctrl-click will open the link under the mouse cursor
    {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "CTRL",
      action = wezterm.action.OpenLinkAtMouseCursor,
    },
    -- Disable the Ctrl-click down event to stop programs from seeing it when a URL is clicked
    {
      event = { Down = { streak = 1, button = "Left" } },
      mods = "CTRL",
      action = wezterm.action.Nop,
    },
  }
end

---@param percent integer
---@return Key[]
---@diagnostic disable-next-line: lowercase-global
function create_sized_pane_key_table(percent)
  local key_table = {
    { key = "r", mods = "NONE", action = wezterm.action.SplitPane { direction = "Right", size = { Percent = percent } } },
    { key = "R", mods = "NONE", action = wezterm.action.SplitPane { direction = "Right", size = { Percent = percent }, top_level = true } },
    { key = "l", mods = "NONE", action = wezterm.action.SplitPane { direction = "Left", size = { Percent = percent } } },
    { key = "L", mods = "NONE", action = wezterm.action.SplitPane { direction = "Left", size = { Percent = percent }, top_level = true } },
    { key = "u", mods = "NONE", action = wezterm.action.SplitPane { direction = "Up", size = { Percent = percent } } },
    { key = "U", mods = "NONE", action = wezterm.action.SplitPane { direction = "Up", size = { Percent = percent }, top_level = true } },
    { key = "d", mods = "NONE", action = wezterm.action.SplitPane { direction = "Down", size = { Percent = percent } } },
    { key = "D", mods = "NONE", action = wezterm.action.SplitPane { direction = "Down", size = { Percent = percent }, top_level = true } },
  }

  return key_table
end

return M
