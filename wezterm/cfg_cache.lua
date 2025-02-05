local wezterm = require "wezterm"
local config = wezterm.config_builder()
local module = {}

-- https://github.com/wez/wezterm/discussions/3664
-- https://github.com/wez/wezterm/blob/d0e9a034406f25af035ecd93f771cc723a2bd704/config/src/config.rs#L748-L757
-- https://github.com/wez/wezterm/blob/d0e9a034406f25af035ecd93f771cc723a2bd704/config/src/config.rs#L1903-L1921

function module.apply_to_config(config)
  config.glyph_cache_image_cache_size = 768
  config.line_quad_cache_size = 3072
  config.line_state_cache_size = 3072
  config.line_to_ele_shape_cache_size = 3072
  config.mux_output_parser_coalesce_delay_ms = 10
  config.periodic_stat_logging = 10
  config.shape_cache_size = 3072
end

return module
