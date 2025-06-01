local wezterm = require "wezterm" --[[@as Wezterm]]

local config = wezterm.config_builder()

require("window_space").setup {
  enable_window_resize_events = true,
  enable_window_move_events = true,
}

require "events"
require "wezyx"

require("cfg_init").apply_to_config(config)
require("floating_pane").apply_to_config(config)

return config
