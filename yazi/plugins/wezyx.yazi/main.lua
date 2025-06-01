---@class WezyxModule
---@field setup fun(self, opts: { [integer|string]: Sendable }?): nil
local M = {}

---@type string?
WEZTERM_PANE = os.getenv "WEZTERM_PANE"

---@return string?
local get_hovered_url = ya.sync(function()
  local hovered_url = cx.active.current.hovered.url
  if not hovered_url then
    ya.err "error: could not determine hovered url in yazi."
    return
  end
  local hovered_path = tostring(hovered_url):gsub("\\", "/")
  return hovered_path
end)

---Save the current hovered path in yazi's cache_dir.
---Filename template is 'yazi-hovered-wezterm-pane-$WEZTERM_PANE'.
---@param body Sendable
---@async
local cache_hovered_url = function(body) ---@diagnostic disable-line: unused-local
  local cache_dir = rt.preview.cache_dir
  assert(cache_dir, "error: missing preview.cache_dir setting in yazi config.")

  local cache_file = (cache_dir .. "/yazi-hovered-wezterm-pane-" .. WEZTERM_PANE):gsub("\\", "/")
  local file = io.open(cache_file, "w")
  assert(file, "error: could not create/open temp file - " .. cache_file)

  file:write(get_hovered_url())
  file:flush()
  file:close()
end

CALLBACKS = { cache_hovered_url = cache_hovered_url }

local wezyx_remote_callback = function(body)
  if not body then
    ya.err "error: no body sent to remote `wezyx`."
  elseif not body.fn then
    ya.err "error: published message to `wezyx` missing required parameter `fn`."
    -- can't determine YAZI_ID from wezterm, instead message is published
    -- to all instances and only callback on matching wezterm pane.
  elseif tonumber(WEZTERM_PANE) == tonumber(body.wezterm_pane) then
    CALLBACKS[body.fn](body)
  end
end

---@async
function M:setup(_)
  ps.sub_remote("wezyx", wezyx_remote_callback)
end

return M
