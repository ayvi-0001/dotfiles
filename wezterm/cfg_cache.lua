local M = {}

function M.apply_to_config(config)
  config.glyph_cache_image_cache_size = 768
  config.line_quad_cache_size = 3072
  config.line_state_cache_size = 3072
  config.line_to_ele_shape_cache_size = 3072
  config.mux_output_parser_buffer_size = 1000000
  config.mux_output_parser_coalesce_delay_ms = 10
  config.periodic_stat_logging = 10
  config.shape_cache_size = 3072
end

return M
