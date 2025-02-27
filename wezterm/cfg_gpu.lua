local M = {}

function M.apply_to_config(config)
  config.front_end = "WebGpu"
  config.max_fps = 60
  config.prefer_egl = true
  config.webgpu_power_preference = "HighPerformance"
  config.webgpu_preferred_adapter = {
    backend = "Vulkan",
    device = 10115,
    device_type = "DiscreteGpu",
    driver = "NVIDIA",
    driver_info = "566.36",
    name = "NVIDIA GeForce RTX 4070 SUPER",
    vendor = 4318,
  }
end

return M
