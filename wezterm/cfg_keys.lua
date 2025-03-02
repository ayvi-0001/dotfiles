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

  config.leader = { key = "Space", mods = "CTRL|SHIFT" }
  config.keys = {
    {
      key = "p",
      mods = "CTRL",
      action = wezterm.action.ActivateKeyTable {
        name = "pane",
        timeout_milliseconds = 3000,
        until_unknown = true,
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
      key = "h",
      mods = "CTRL",
      action = wezterm.action.ActivateKeyTable {
        name = "move",
        one_shot = false,
        timeout_milliseconds = 3000,
      },
    },
    {
      key = "t",
      mods = "CTRL",
      action = wezterm.action.ActivateKeyTable {
        name = "tab",
        one_shot = false,
        timeout_milliseconds = 3000,
        until_unknown = true,
      },
    },
    {
      key = "s",
      mods = "CTRL",
      action = wezterm.action.ActivateKeyTable {
        name = "scroll",
        one_shot = false,
        timeout_milliseconds = 3000,
        until_unknown = true,
      },
    },
    {
      key = "o",
      mods = "CTRL",
      action = wezterm.action.ActivateKeyTable {
        name = "session",
        timeout_milliseconds = 3000,
        until_unknown = true,
      },
    },
    { key = "LeftArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection "Left" },
    { key = "h", mods = "ALT", action = wezterm.action.ActivatePaneDirection "Left" },
    { key = "RightArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection "Right" },
    { key = "l", mods = "ALT", action = wezterm.action.ActivatePaneDirection "Right" },
    { key = "UpArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection "Up" },
    { key = "k", mods = "ALT", action = wezterm.action.ActivatePaneDirection "Up" },
    { key = "DownArrow", mods = "ALT", action = wezterm.action.ActivatePaneDirection "Down" },
    { key = "j", mods = "ALT", action = wezterm.action.ActivatePaneDirection "Down" },
    { key = "+", mods = "CTRL|SHIFT", action = wezterm.action.IncreaseFontSize },
    { key = "-", mods = "CTRL|SHIFT", action = wezterm.action.DecreaseFontSize },
    { key = "0", mods = "CTRL", action = wezterm.action.ResetFontSize },
    { key = "H", mods = "ALT", action = wezterm.action.ActivateTabRelative(-1) },
    { key = "L", mods = "ALT", action = wezterm.action.ActivateTabRelative(1) },
    { key = "i", mods = "ALT", action = wezterm.action.MoveTabRelative(-1) },
    { key = "o", mods = "ALT", action = wezterm.action.MoveTabRelative(1) },
    {
      key = "C",
      mods = "CTRL|SHIFT",
      action = wezterm.action.CopyTo "ClipboardAndPrimarySelection",
    },
    { key = "V", mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom "Clipboard" },
    { key = "P", mods = "CTRL|SHIFT", action = wezterm.action.ActivateCommandPalette },
    { key = "t", mods = "CTRL|ALT", action = wezterm.action.ReloadConfiguration },
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
          until_unknown = true,
          replace_current = true,
        },
      },
      { key = "Escape", action = "PopKeyTable" },
    },

    resize_window = {
      { key = "l", action = wezterm.action.EmitEvent "increase-window-width" },
      { key = "h", action = wezterm.action.EmitEvent "decrease-window-width" },
      { key = "j", action = wezterm.action.EmitEvent "increase-window-height" },
      { key = "k", action = wezterm.action.EmitEvent "decrease-window-height" },
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
      { key = "n", action = wezterm.action.SpawnTab "CurrentPaneDomain" },
      { key = "x", action = wezterm.action.CloseCurrentTab { confirm = false } },
      { key = "h", action = wezterm.action.ActivateTabRelative(-1) },
      { key = "l", action = wezterm.action.ActivateTabRelative(1) },
      { key = "r", action = wezterm.action_callback(C.rename_tab) },
      { key = "`", action = wezterm.action.ActivateLastTab },
      { key = "t", action = wezterm.action.ShowTabNavigator },
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

    pane = {
      { key = "r", action = wezterm.action.SplitPane { direction = "Right" } },
      { key = "R", action = wezterm.action.SplitPane { direction = "Right", top_level = true } },
      { key = "d", action = wezterm.action.SplitPane { direction = "Down" } },
      { key = "D", action = wezterm.action.SplitPane { direction = "Down", top_level = true } },
      { key = "x", action = wezterm.action.CloseCurrentPane { confirm = false } },
      { key = "f", action = wezterm.action.TogglePaneZoomState },
      { key = "n", action = wezterm.action.EmitEvent "spawn-new-window" },
      { key = "w", action = wezterm.action.EmitEvent "toggle-floating-pane" },
      { key = "e", action = wezterm.action_callback(C.move_pane_to_new_window) },
      { key = "Escape", action = "PopKeyTable" },
    },

    scroll = {
      { key = "k", mods = "", action = wezterm.action.ScrollByLine(-1) },
      { key = "j", mods = "", action = wezterm.action.ScrollByLine(1) },
      { key = "b", mods = "", action = wezterm.action.ScrollByPage(-1) },
      { key = "f", mods = "", action = wezterm.action.ScrollByPage(1) },
      { key = "u", mods = "", action = wezterm.action.ScrollByPage(-0.5) },
      { key = "d", mods = "", action = wezterm.action.ScrollByPage(0.5) },
      { key = "s", mods = "CTRL", action = wezterm.action.PopKeyTable },
      {
        key = "c",
        mods = "CTRL",
        action = wezterm.action.Multiple {
          wezterm.action.ScrollToBottom,
          wezterm.action.PopKeyTable,
        },
      },
      { key = "Escape", action = "PopKeyTable" },
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
