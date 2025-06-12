local M = {}

---@param config Config
---@return nil
function M.apply_to_config(config)
  -- default: 256
  config.glyph_cache_image_cache_size = 512
  -- This should be set to at least the sum of the number of lines in the panes in a tab.
  -- eg: if you have an 80x24 terminal split left/right then you should set this to at least 2x24 = 48
  -- Setting it smaller than that will harm performance
  -- default: 1024
  config.line_quad_cache_size = 2048
  -- Should also be set >= number of lines as above.
  -- Values are relatively small, may not need adjustment.
  -- default: 1024
  config.line_state_cache_size = 2048
  -- Should also be set >= number of lines as above.
  -- Values are relatively small, may not need adjustment.
  -- default: 1024
  config.line_to_ele_shape_cache_size = 2048
  -- The buffer size used by parse_buffered_data in the mux module.
  -- This should not be too large, otherwise the processing cost
  -- of applying a batch of actions to the terminal will be too
  -- high and the user experience will be laggy and less responsive.
  config.mux_output_parser_buffer_size = 1000000
  -- How many ms to delay after reading a chunk of output
  -- in order to try to coalesce fragmented writes into
  -- a single bigger chunk of output and reduce the chances
  -- observing "screen tearing" with un-synchronized output
  -- default: 3
  config.mux_output_parser_coalesce_delay_ms = 3
  -- If non-zero, specifies the period (in seconds) at which various
  -- statistics are logged.  Note that there is a minimum period of 10 seconds.
  config.periodic_stat_logging = 10
  -- should be >= the number of different attributed runs on the screen.
  -- hard to suggest a min size: try reducing until you notice performance getting bad.
  -- default: 1024
  config.shape_cache_size = 2048
end

return M
