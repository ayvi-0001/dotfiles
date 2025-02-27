local module = {}

-- Run command to install wezterm TERM definition
-- tempfile=$(mktemp) \
--   && curl -o $tempfile https://raw.githubusercontent.com/wez/wezterm/main/termwiz/data/wezterm.terminfo \
--   && tic -x -o ~/.terminfo $tempfile \
--   && rm $tempfile

function module.apply_to_config(config)
  config.audible_bell = "Disabled"
  config.automatically_reload_config = false
  config.default_prog = { "c:/program files/git/bin/bash.exe", "-il" }
  config.detect_password_input = false
  config.mux_enable_ssh_agent = true
  config.mux_env_remove = { "SSH_AUTH_SOCK", "SSH_CLIENT", "SSH_CONNECTION" }
  config.term = "wezterm"
end

return module
