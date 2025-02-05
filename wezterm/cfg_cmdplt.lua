local wezterm = require "wezterm"
local config = wezterm.config_builder()
local module = {}

function module.apply_to_config(config)
  config.command_palette_bg_color = "#020202"
  config.command_palette_font_size = 9.0
  config.command_palette_rows = 20
end

return module
