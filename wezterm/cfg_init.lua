local M = {}

local cache = require "cfg_cache"
local gpu = require "cfg_gpu"
local gui = require "cfg_gui"
local keys = require "cfg_keys"
local term = require "cfg_term"

function M.apply_to_config(config)
  cache.apply_to_config(config)
  gpu.apply_to_config(config)
  gui.apply_to_config(config)
  keys.apply_to_config(config)
  term.apply_to_config(config)
end

return M
