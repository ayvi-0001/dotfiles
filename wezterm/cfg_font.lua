local wezterm = require "wezterm"
local config = wezterm.config_builder()
local module = {}

function module.apply_to_config(config)
  config.font = wezterm.font {
    family = 'SpaceMono Nerd Font',
    weight = "Medium"
  }
  config.bold_brightens_ansi_colors  = "BrightAndBold"
  config.cursor_thickness = "0.1cell"
  config.font_size = 9.0
  config.line_height = 1
end

return module
