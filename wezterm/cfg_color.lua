local wezterm = require "wezterm"
local config = wezterm.config_builder()
local module = {}

function module.apply_to_config(config)
  config.color_scheme = "tokyonight"
  config.colors = {
    foreground = "#f0f0ff",
    background = "#020202",
    split = "#f0f0ff",
    tab_bar = {
       background = "#000000",
       active_tab = {
        bg_color = "#1b1032",
        fg_color = "#89F57C",
      },
       inactive_tab = {
        bg_color = "#1b1032",
        fg_color = "#888888",
      },
    }
  }
end

return module
