local wezterm = require "wezterm"
local config = wezterm.config_builder()
local module = {}

function module.apply_to_config(config)
  config.window_padding = {
    left = '1.5cell',
    right = '1.5cell',
    top = '0.5cell',
    bottom = '0cell',
  }
  config.window_frame = {
    font = wezterm.font { family = "SpaceMono Nerd Font", weight = "Bold" },
    font_size = 9.0,
    active_titlebar_bg = "#000000",
    inactive_titlebar_bg = "#000000",
  }
  config.inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 0.8,
  }

  config.adjust_window_size_when_changing_font_size = false
  config.window_background_opacity = 0.8
  config.window_close_confirmation = "NeverPrompt"
  config.window_decorations = "RESIZE"

  config.enable_scroll_bar = false
  config.initial_cols = 280
  config.initial_rows = 60
  config.scrollback_lines = 20000

  config.display_pixel_geometry = "BGR"
  config.freetype_load_target = "Light"

  config.hide_tab_bar_if_only_one_tab = true
  config.prefer_to_spawn_tabs = true
  config.show_new_tab_button_in_tab_bar = false
  config.show_tab_index_in_tab_bar = true
  config.switch_to_last_active_tab_when_closing_tab = true
  config.tab_and_split_indices_are_zero_based = true
  config.tab_bar_at_bottom = false
  config.use_fancy_tab_bar = true

  local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider

  local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider

  -- This function returns the suggested title for a tab.
  -- It prefers the title that was set via `tab:set_title()`
  -- or `wezterm cli set-tab-title`, but falls back to the
  -- title of the active pane in that tab.
  function tab_title(tab_info)
    local title = tab_info.tab_title
    -- if the tab title is explicitly set, take that
    if title and #title > 0 then
      return title
    end
    -- Otherwise, use the title from the active pane
    -- in that tab
    return tab_info.active_pane.title
  end

  wezterm.on(
    'format-tab-title',
    function(tab, tabs, panes, config, hover, max_width)
      local edge_background = '#0b0022'
      local background = '#1b1032'
      local foreground = '#808080'

      if tab.is_active then
        background = '#2b2042'
        foreground = '#89F57C'
      elseif hover then
        background = '#3b3052'
        foreground = '#909090'
      end

      local edge_foreground = background

      local title = tab_title(tab)

      return {
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = SOLID_LEFT_ARROW },
        { Background = { Color = background } },
        { Foreground = { Color = foreground } },
        { Text = title },
        { Background = { Color = edge_background } },
        { Foreground = { Color = edge_foreground } },
        { Text = SOLID_RIGHT_ARROW },
      }
    end
  )
end

return module
