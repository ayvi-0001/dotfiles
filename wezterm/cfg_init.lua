local M = {}

---@param config Config
---@return nil
function M.apply_to_config(config)
  require("cfg_cache").apply_to_config(config)
  require("cfg_gpu").apply_to_config(config)
  require("cfg_gui").apply_to_config(config)
  require("cfg_keys").apply_to_config(config)
  require("cfg_term").apply_to_config(config)
end

return M
