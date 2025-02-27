local wezterm = require "wezterm"
local config = wezterm.config_builder()

local init = require "init"

init.cache.apply_to_config(config)
init.gpu.apply_to_config(config)
init.keys.apply_to_config(config)
init.term.apply_to_config(config)
init.gui.apply_to_config(config)

local floating_pane = require "floating_pane"
floating_pane.apply_to_config(config)

require "events"

return config
