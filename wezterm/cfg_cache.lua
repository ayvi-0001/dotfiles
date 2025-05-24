local M = {}

---@param config Config
---@return nil
function M.apply_to_config(config)
  config.glyph_cache_image_cache_size = 512
  config.line_quad_cache_size = 2048
  config.line_state_cache_size = 2048
  config.line_to_ele_shape_cache_size = 2048
  config.mux_output_parser_buffer_size = 1000000
  config.mux_output_parser_coalesce_delay_ms = 3
  config.periodic_stat_logging = 10
  config.shape_cache_size = 2048
end

return M
