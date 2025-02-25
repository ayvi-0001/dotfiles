local wezterm = require "wezterm"
local config = wezterm.config_builder()

local init = require "init"

init.cache.apply_to_config(config)
init.cmdplt.apply_to_config(config)
init.color.apply_to_config(config)
init.font.apply_to_config(config)
init.gpu.apply_to_config(config)
init.keys.apply_to_config(config)
init.proc.apply_to_config(config)
init.term.apply_to_config(config)
init.window.apply_to_config(config)

require "events"

return config
