local wezterm = require "wezterm"

local M = {}

function M.basename(s)
  local name = string.gsub(s, "(.*[/\\])(.*)", "%2")
  if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    return name:gsub(".exe", "")
  end
  return name
end

return M
