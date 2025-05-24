local wezterm = require "wezterm" --[[@as Wezterm]]

local config = wezterm.config_builder()

require "window_space"
require "events"
require "wezyx"

require("cfg_init").apply_to_config(config)
require("floating_pane").apply_to_config(config)

return config
