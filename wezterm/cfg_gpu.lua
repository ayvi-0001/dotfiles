local wezterm = require "wezterm"
local M = {}

function M.apply_to_config(config)
  config.front_end = "WebGpu"
  config.max_fps = 60
  config.prefer_egl = true
  config.webgpu_power_preference = "HighPerformance"

  for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
    if gpu.backend == "Dx12" and gpu.device_type == "DiscreteGpu" then
      config.webgpu_preferred_adapter = gpu
      break
    end
  end
end

return M
