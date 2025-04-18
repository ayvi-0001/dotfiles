local utils = require "utils"
local wezterm = require "wezterm"

local M = {}

COMMON_ACCENT = "#afff00"
COMMON_ACCENT_ALT = "#8a8a8a"
BLACK = "#000000"
UI_PANEL_BG = "#020202"
UI_PANEL_SHADOW = BLACK
UI_FG = "#f0f0ff"

function M.apply_to_config(config)
  config.font = wezterm.font {
    family = "SpaceMono Nerd Font",
    weight = "Medium",
    harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
  }
  config.font_size = 9.0

  config.color_scheme_dirs = { wezterm.config_dir .. "/colors" }
  config.color_scheme = "tokyonight"
  config.colors = {
    background = _G.UI_PANEL_BG,
    foreground = _G.UI_FG,
    split = _G.COMMON_ACCENT,
    tab_bar = {
      background = _G.UI_PANEL_SHADOW,
      inactive_tab_edge = _G.UI_PANEL_SHADOW,
    },
  }
  config.bold_brightens_ansi_colors = "BrightAndBold"

  config.window_padding = {
    top = "0cell",
    left = "0.5cell",
    right = "0.5cell",
    bottom = "0cell",
  }
  config.window_frame = {
    font = wezterm.font { family = "SpaceMono Nerd Font", weight = "Bold" },
    font_size = 9.3,
    active_titlebar_bg = _G.UI_PANEL_BG,
    inactive_titlebar_bg = _G.UI_PANEL_BG,
    border_left_width = "2px",
    border_right_width = "2px",
    border_bottom_height = "0.5px",
    border_top_height = "2px",
    border_left_color = _G.COMMON_ACCENT,
    border_right_color = _G.COMMON_ACCENT,
    border_bottom_color = _G.COMMON_ACCENT,
    border_top_color = _G.COMMON_ACCENT,
  }

  config.adjust_window_size_when_changing_font_size = false
  config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.8 }
  config.window_background_opacity = 0.8
  config.window_close_confirmation = "NeverPrompt"
  config.window_decorations = "RESIZE"

  config.command_palette_bg_color = _G.UI_PANEL_BG
  config.command_palette_font_size = 9.0
  config.command_palette_rows = 20

  config.initial_cols = 280
  config.initial_rows = 60
  config.use_resize_increments = true

  config.enable_scroll_bar = false
  config.scrollback_lines = 100000

  config.hide_tab_bar_if_only_one_tab = false
  config.prefer_to_spawn_tabs = true
  config.prefer_to_spawn_tabs = true
  config.show_close_tab_button_in_tabs = false
  config.show_new_tab_button_in_tab_bar = false
  config.show_tab_index_in_tab_bar = true
  config.switch_to_last_active_tab_when_closing_tab = true
  config.switch_to_last_active_tab_when_closing_tab = true
  config.tab_and_split_indices_are_zero_based = true
  config.tab_bar_at_bottom = false
  config.use_fancy_tab_bar = true
end

-- tabs look like: | > title > |
local INVERSE_SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_left_hard_divider_inverse
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

local function tab_title(tab_info)
  local title = tab_info.tab_title

  if title and #title > 0 then
    return title
  end

  local pane_info = tab_info.active_pane
  title = utils.basename(pane_info.title or pane_info.foreground_process_name)
  if pane_info.domain_name then
    local spacer = #title > 0 and " " or ""
    title = ("(" .. pane_info.domain_name .. ")" .. spacer .. title)
  end

  return title
end

wezterm.on("format-tab-title", function(tab_info, tabs, panes, config, hover, max_width)
  local background = _G.COMMON_ACCENT_ALT
  local foreground = _G.UI_PANEL_SHADOW
  local edge_background = _G.UI_PANEL_SHADOW
  local edge_foreground = background

  if tab_info.is_active then
    foreground = _G.UI_PANEL_SHADOW
    background = _G.COMMON_ACCENT
    edge_foreground = background
  end

  local title = tab_title(tab_info)

  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = INVERSE_SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = " " .. title .. " " },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

return M
