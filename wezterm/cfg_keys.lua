local C = require "callbacks"
local wezterm = require "wezterm"

local M = {}

function M.apply_to_config(config)
  config.allow_win32_input_mode = true
  config.bypass_mouse_reporting_modifiers = "ALT"
  -- config.debug_key_events = true
  config.disable_default_key_bindings = true
  config.disable_default_quick_select_patterns = true
  config.hide_mouse_cursor_when_typing = false
  config.treat_left_ctrlalt_as_altgr = true

  config.keys = {
    {
      key = "p",
      mods = "CTRL",
      action = wezterm.action.ActivateKeyTable {
        name = "pane",
        timeout_milliseconds = 3000,
      },
    },
    {
      key = "n",
      mods = "CTRL",
      action = wezterm.action.ActivateKeyTable {
        name = "resize",
        one_shot = false,
        timeout_milliseconds = 3000,
        until_unknown = true,
      },
    },
    {
      key = "`",
      mods = "CTRL",
      action = wezterm.action.ActivateKeyTable {
        name = "disable_wezterm_key_tables",
        one_shot = false,
        until_unknown = false,
      },
    },
    {
      key = "h",
      mods = "CTRL",
      action = wezterm.action.ActivateKeyTable {
        name = "move",
        one_shot = false,
        timeout_milliseconds = 1000,
        replace_current = true,
      },
    },
    {
      key = "t",
      mods = "CTRL",
      action = wezterm.action.ActivateKeyTable {
        name = "tab",
        one_shot = false,
        timeout_milliseconds = 1000,
        until_unknown = true,
        replace_current = true,
      },
    },
    {
      key = "s",
      mods = "CTRL",
      action = wezterm.action.ActivateKeyTable {
        name = "scroll",
        one_shot = false,
        until_unknown = true,
        replace_current = true,
      },
    },
    {
      key = "o",
      mods = "CTRL",
      action = wezterm.action.ActivateKeyTable {
        name = "session",
        timeout_milliseconds = 3000,
        until_unknown = true,
        replace_current = true,
      },
    },
    { key = "f", mods = "ALT", action = wezterm.action.EmitEvent "toggle-floating-pane" },
    { key = "h", mods = "ALT", action = wezterm.action_callback(C.move_focus_or_tab_left) },
    { key = "l", mods = "ALT", action = wezterm.action_callback(C.move_focus_or_tab_right) },
    { key = "k", mods = "ALT", action = wezterm.action.ActivatePaneDirection "Up" },
    { key = "j", mods = "ALT", action = wezterm.action.ActivatePaneDirection "Down" },
    { key = "+", mods = "CTRL|SHIFT", action = wezterm.action.IncreaseFontSize },
    { key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
    { key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },
    { key = "H", mods = "ALT", action = wezterm.action.ActivateTabRelative(-1) },
    { key = "L", mods = "ALT", action = wezterm.action.ActivateTabRelative(1) },
    { key = "i", mods = "ALT", action = wezterm.action.MoveTabRelative(-1) },
    { key = "o", mods = "ALT", action = wezterm.action.MoveTabRelative(1) },
    { key = "x", mods = "CTRL|SHIFT", action = wezterm.action.ActivateCopyMode },
    { key = "f", mods = "CTRL|SHIFT", action = wezterm.action.Search "CurrentSelectionOrEmptyString" },
    { key = "C", mods = "CTRL|SHIFT", action = wezterm.action.CopyTo "ClipboardAndPrimarySelection" },
    { key = " ", mods = "SHIFT|CTRL", action = wezterm.action.QuickSelect },
    { key = "V", mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom "Clipboard" },
    { key = "P", mods = "CTRL|SHIFT", action = wezterm.action.ActivateCommandPalette },
  }

  config.key_tables = {
    resize = {
      { key = "h", action = wezterm.action.AdjustPaneSize { "Left", 5 } },
      { key = "j", action = wezterm.action.AdjustPaneSize { "Down", 5 } },
      { key = "k", action = wezterm.action.AdjustPaneSize { "Up", 5 } },
      { key = "l", action = wezterm.action.AdjustPaneSize { "Right", 5 } },
      {
        key = "w",
        action = wezterm.action.ActivateKeyTable {
          name = "resize_window",
          one_shot = false,
          replace_current = true,
        },
      },
      { key = "Escape", action = "PopKeyTable" },
    },

    resize_window = {
      { key = "h", action = wezterm.action.EmitEvent "increase-to-left" },
      { key = "H", action = wezterm.action.EmitEvent "decrease-from-left" },
      { key = "j", action = wezterm.action.EmitEvent "increase-to-bottom" },
      { key = "J", action = wezterm.action.EmitEvent "decrease-from-bottom" },
      { key = "k", action = wezterm.action.EmitEvent "increase-to-top" },
      { key = "K", action = wezterm.action.EmitEvent "decrease-from-top" },
      { key = "l", action = wezterm.action.EmitEvent "increase-to-right" },
      { key = "L", action = wezterm.action.EmitEvent "decrease-from-right" },
      { key = "Escape", action = "PopKeyTable" },
    },

    move = {
      {
        key = "h",
        action = wezterm.action.Multiple {
          wezterm.action.RotatePanes "CounterClockwise",
          wezterm.action.ActivatePaneDirection "Prev",
        },
      },
      {
        key = "l",
        action = wezterm.action.Multiple {
          wezterm.action.RotatePanes "Clockwise",
          wezterm.action.ActivatePaneDirection "Next",
        },
      },
      { key = "H", action = wezterm.action.EmitEvent "move-window-left" },
      { key = "L", action = wezterm.action.EmitEvent "move-window-right" },
      { key = "K", action = wezterm.action.EmitEvent "move-window-up" },
      { key = "J", action = wezterm.action.EmitEvent "move-window-down" },
      { key = "Escape", action = "PopKeyTable" },
    },

    tab = {
      { key = "n", action = wezterm.action_callback(C.spawn_default_prog_in_new_tab) },
      { key = "x", action = wezterm.action.CloseCurrentTab { confirm = false } },
      { key = "h", action = wezterm.action.ActivateTabRelative(-1) },
      { key = "l", action = wezterm.action.ActivateTabRelative(1) },
      { key = "r", action = wezterm.action_callback(C.rename_tab) },
      { key = "`", action = wezterm.action.ActivateLastTab },
      { key = "t", action = wezterm.action.Multiple { "ShowTabNavigator", "PopKeyTable" } },
      { key = "t", mods = "CTRL", action = wezterm.action.Multiple { "ShowTabNavigator", "PopKeyTable" } },
      { key = "1", action = wezterm.action.ActivateTab(0) },
      { key = "2", action = wezterm.action.ActivateTab(1) },
      { key = "3", action = wezterm.action.ActivateTab(2) },
      { key = "4", action = wezterm.action.ActivateTab(3) },
      { key = "5", action = wezterm.action.ActivateTab(4) },
      { key = "6", action = wezterm.action.ActivateTab(5) },
      { key = "7", action = wezterm.action.ActivateTab(6) },
      { key = "8", action = wezterm.action.ActivateTab(7) },
      { key = "9", action = wezterm.action.ActivateTab(8) },
      { key = "Escape", action = "PopKeyTable" },
    },

    session = {
      { key = "d", action = wezterm.action.ShowDebugOverlay },
      { key = "h", action = wezterm.action.Hide },
      { key = "s", action = wezterm.action.Show },
      { key = "l", action = wezterm.action.ShowLauncher },
      { key = "q", action = wezterm.action.QuitApplication },
      { key = "w", action = wezterm.action_callback(C.launch_workspace) },
      { key = "1", action = wezterm.action.ActivateWindow(0) },
      { key = "2", action = wezterm.action.ActivateWindow(1) },
      { key = "3", action = wezterm.action.ActivateWindow(2) },
      { key = "4", action = wezterm.action.ActivateWindow(3) },
      { key = "5", action = wezterm.action.ActivateWindow(4) },
      { key = "6", action = wezterm.action.ActivateWindow(5) },
      { key = "7", action = wezterm.action.ActivateWindow(6) },
      { key = "8", action = wezterm.action.ActivateWindow(7) },
      { key = "9", action = wezterm.action.ActivateWindow(8) },
    },

    yazi_helix = {
      { key = "t", action = wezterm.action.EmitEvent "yazi-helix-launch-ide" },
      { key = "w", action = wezterm.action.EmitEvent "yazi-helix-open-new-window" },
      { key = "r", action = wezterm.action.EmitEvent "yazi-helix-open-new-right-pane" },
      { key = "R", action = wezterm.action.EmitEvent "yazi-helix-open-new-right-pane-top-level" },
      { key = "d", action = wezterm.action.EmitEvent "yazi-helix-open-new-bottom-pane" },
      { key = "D", action = wezterm.action.EmitEvent "yazi-helix-open-new-bottom-pane-top-level" },
      { key = "h", action = wezterm.action.EmitEvent "yazi-helix-open-in-left-pane" },
      { key = "j", action = wezterm.action.EmitEvent "yazi-helix-open-in-pane-below" },
      { key = "k", action = wezterm.action.EmitEvent "yazi-helix-open-in-pane-above" },
      { key = "l", action = wezterm.action.EmitEvent "yazi-helix-open-in-right-pane" },
      { key = "S", action = wezterm.action.EmitEvent "trigger-hx-with-scrollback" },
      { key = "Escape", action = "PopKeyTable" },
    },

    pane = {
      { key = "r", action = wezterm.action.SplitPane { direction = "Right" } },
      { key = "R", action = wezterm.action.SplitPane { direction = "Right", top_level = true } },
      { key = "d", action = wezterm.action.SplitPane { direction = "Down" } },
      { key = "D", action = wezterm.action.SplitPane { direction = "Down", top_level = true } },
      { key = "l", action = wezterm.action.SplitPane { direction = "Left" } },
      { key = "L", action = wezterm.action.SplitPane { direction = "Left", top_level = true } },
      { key = "u", action = wezterm.action.SplitPane { direction = "Up" } },
      { key = "U", action = wezterm.action.SplitPane { direction = "Up", top_level = true } },
      { key = "3", action = wezterm.action.ActivateKeyTable { name = "pane_33" } },
      { key = "6", action = wezterm.action.ActivateKeyTable { name = "pane_66" } },
      { key = "h", action = wezterm.action.ActivateKeyTable { name = "yazi_helix" } },
      { key = "i", action = wezterm.action.ActivateKeyTable { name = "pane_index" } },
      { key = "s", mods = "CTRL", action = wezterm.action.ActivateKeyTable { name = "pane_select" } },
      { key = "s", action = wezterm.action.PaneSelect { show_pane_ids = true } },
      { key = "f", action = wezterm.action.TogglePaneZoomState },
      { key = "n", action = wezterm.action.EmitEvent "spawn-new-window" },
      { key = "w", action = wezterm.action.EmitEvent "toggle-floating-pane" },
      { key = "e", action = wezterm.action_callback(C.move_pane_to_new_window) },
      { key = "x", action = wezterm.action.CloseCurrentPane { confirm = false } },
      { key = "Escape", action = "PopKeyTable" },
    },

    pane_select = {
      { key = "t", action = wezterm.action.PaneSelect { mode = "MoveToNewTab", show_pane_ids = true } },
      { key = "w", action = wezterm.action.PaneSelect { mode = "MoveToNewWindow", show_pane_ids = true } },
      { key = "a", action = wezterm.action.PaneSelect { mode = "SwapWithActive", show_pane_ids = true } },
      { key = "f", action = wezterm.action.PaneSelect { mode = "SwapWithActiveKeepFocus", show_pane_ids = true } },
      { key = "Escape", action = "PopKeyTable" },
    },

    pane_index = {
      { key = "1", action = wezterm.action.ActivatePaneByIndex(0) },
      { key = "2", action = wezterm.action.ActivatePaneByIndex(1) },
      { key = "3", action = wezterm.action.ActivatePaneByIndex(2) },
      { key = "4", action = wezterm.action.ActivatePaneByIndex(3) },
      { key = "5", action = wezterm.action.ActivatePaneByIndex(4) },
      { key = "6", action = wezterm.action.ActivatePaneByIndex(5) },
      { key = "7", action = wezterm.action.ActivatePaneByIndex(6) },
      { key = "8", action = wezterm.action.ActivatePaneByIndex(7) },
      { key = "9", action = wezterm.action.ActivatePaneByIndex(8) },
      { key = "Escape", action = "PopKeyTable" },
    },

    pane_33 = {
      { key = "r", action = wezterm.action.SplitPane { direction = "Right", size = { Percent = 33 } } },
      { key = "R", action = wezterm.action.SplitPane { direction = "Right", size = { Percent = 33 }, top_level = true } },
      { key = "l", action = wezterm.action.SplitPane { direction = "Left", size = { Percent = 33 } } },
      { key = "L", action = wezterm.action.SplitPane { direction = "Left", size = { Percent = 33 }, top_level = true } },
      { key = "u", action = wezterm.action.SplitPane { direction = "Up", size = { Percent = 33 } } },
      { key = "U", action = wezterm.action.SplitPane { direction = "Up", size = { Percent = 33 }, top_level = true } },
      { key = "d", action = wezterm.action.SplitPane { direction = "Down", size = { Percent = 33 } } },
      { key = "D", action = wezterm.action.SplitPane { direction = "Down", size = { Percent = 33 }, top_level = true } },
    },

    pane_66 = {
      { key = "r", action = wezterm.action.SplitPane { direction = "Right", size = { Percent = 66 } } },
      { key = "R", action = wezterm.action.SplitPane { direction = "Right", size = { Percent = 66 }, top_level = true } },
      { key = "l", action = wezterm.action.SplitPane { direction = "Left", size = { Percent = 66 } } },
      { key = "L", action = wezterm.action.SplitPane { direction = "Left", size = { Percent = 66 }, top_level = true } },
      { key = "u", action = wezterm.action.SplitPane { direction = "Up", size = { Percent = 66 } } },
      { key = "U", action = wezterm.action.SplitPane { direction = "Up", size = { Percent = 66 }, top_level = true } },
      { key = "d", action = wezterm.action.SplitPane { direction = "Down", size = { Percent = 66 } } },
      { key = "D", action = wezterm.action.SplitPane { direction = "Down", size = { Percent = 66 }, top_level = true } },
    },

    scroll = {
      { key = "j", action = wezterm.action.ScrollByLine(1) },
      { key = "k", action = wezterm.action.ScrollByLine(-1) },
      { key = "d", action = wezterm.action.ScrollByPage(0.5) },
      { key = "u", action = wezterm.action.ScrollByPage(-0.5) },
      { key = "f", action = wezterm.action.ScrollByPage(1) },
      { key = "b", action = wezterm.action.ScrollByPage(-1) },
      { key = "c", action = wezterm.action_callback(C.scroll_to_bottom) },
      { key = "s", mods = "CTRL", action = wezterm.action.PopKeyTable },
      { key = "Escape", action = "PopKeyTable" },
    },

    disable_wezterm_key_tables = {
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
      { key = "`", mods = "CTRL", action = "PopKeyTable" },
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

return M
