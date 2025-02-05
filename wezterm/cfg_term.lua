local wezterm = require "wezterm"
local config = wezterm.config_builder()
local module = {}

-- Run command to install wezterm TERM definition
-- tempfile=$(mktemp) \
--   && curl -o $tempfile https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo \
--   && tic -x -o ~/.terminfo $tempfile \
--   && rm $tempfile

function module.apply_to_config(config)
  config.term = "wezterm"
  config.default_prog = { "c:/program files/git/bin/bash.exe", "-il" }
end

return module
