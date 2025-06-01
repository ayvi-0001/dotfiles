local wezterm = require "wezterm" --[[@as Wezterm]]

local M = {}

---@param s string
---@return string
function M.basename(s)
  local name = string.gsub(s, "(.*[/\\])(.*)", "%2")
  if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    name = name:gsub(".exe", "")
    return name
  end
  return name
end

---@param filename string?
---@param text string
---@return string
function M.write(filename, text)
  if not filename then
    filename = os.tmpname()
  end

  local f = io.open(filename, "w+")
  if not f then
    error("failed to write file: " .. filename)
  end

  f:write(text or "")
  f:flush()
  f:close()

  return filename
end

return M
