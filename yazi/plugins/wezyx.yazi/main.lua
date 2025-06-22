---@class WezyxModule
---@field setup fun(self, opts: { [integer|string]: Sendable }?): nil
local M = {}

---@type string?
WEZTERM_PANE = os.getenv "WEZTERM_PANE"

---@overload fun(): fs__File
local get_active_hovered = ya.sync(function()
  return cx.active.current.hovered
end)

---@overload fun(): tab__Selected
local get_active_selected = ya.sync(function()
  return cx.active.selected
end)

local get_target_paths = function()
  local target_paths ---@type string

  local selected = get_active_selected()
  if #selected > 0 then
    local selected_paths = ""
    for _, p in pairs(selected) do
      if ya.target_family() == "windows" then
        selected_paths = selected_paths .. ya.quote(tostring(p)) .. " "
      else
        selected_paths = selected_paths .. tostring(p) .. " "
      end
    end

    target_paths = tostring(selected_paths)
  else
    local hovered_url = get_active_hovered().url
    if not hovered_url then
      ya.err "error: could not determine selected/hovered url(s) in yazi."
      return
    end

    target_paths = tostring(hovered_url)
  end

  if ya.target_family() == "windows" then
    target_paths = target_paths:gsub("\\", "/")
  end

  return target_paths
end

---@generic T
---@param v? T
---@param msg? any
---@param level? integer
---@return T
local ya_assert = function(v, msg, level)
  if not v then
    ya.err(msg)
    error(msg, level)
  end
  return v
end

---Save target urls in a file in yazi's cache_dir.
---If any files are selected, those will be the targeted paths.
---If no files are selected, then it will default to the hovered url.
---Filename template is 'yazi-target-paths-wezterm-pane-$WEZTERM_PANE'.
---@param body Sendable
---@async
local cache_target_paths = function(body) ---@diagnostic disable-line: unused-local
  local cache_dir = rt.preview.cache_dir ---@type string?
  cache_dir = ya_assert(cache_dir, "error: missing preview.cache_dir setting in yazi config.", 2)

  local cache_file = (cache_dir .. "/yazi-target-paths-wezterm-pane-" .. WEZTERM_PANE):gsub("\\", "/")
  local file = io.open(cache_file, "w")
  file = ya_assert(file, "error: could not create/open temp file - " .. cache_file, 2)

  file:write(get_target_paths())
  file:flush()
  file:close()
end

CALLBACKS = { cache_target_paths = cache_target_paths }

local wezyx_remote_callback = function(body)
  -- can't determine YAZI_ID from wezterm, instead message is published
  -- to all instances and only calls back on matching wezterm pane.
  if body.wezterm_pane and tonumber(WEZTERM_PANE) == tonumber(body.wezterm_pane) then
    ya_assert(body.fn, "error: published message to `wezyx` missing required parameter `fn`.", 2)
    CALLBACKS[body.fn](body)
  end
end

---@async
function M:setup(_)
  ps.sub_remote("wezyx", wezyx_remote_callback)
end

return M
