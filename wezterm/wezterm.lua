local wezterm = require "wezterm"
local config = wezterm.config_builder()

require "events"

local cfg = require "cfg_init"
cfg.apply_to_config(config)

local floating_pane = require "floating_pane"
floating_pane.apply_to_config(config)

return config
