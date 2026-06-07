local wezterm = require "wezterm" --[[@as Wezterm]]

local M = {}

---@param s string
---@return string
function M.basename(s)
  local name = string.gsub(s, "(.*[/\\])(.*)", "%2")
  if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    name = name:gsub(".[eE][xX][eE]", "")
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

---@param url Url
function M.get_url_file_path(url)
  local file_path = url.file_path
  -- issue with Windows where when accessing the attribute file_path on the Url object,
  -- it adds a forward slash at the start of the path.
  -- e.g. if the path is A:/, it returns /A:/
  if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    file_path = file_path:gsub("^/", "")
  end
  return file_path
end

---@param info LocalProcessInfo?
---@param name string
---@return LocalProcessInfo?
function M.find_parent_executable(info, name)
  if not info then
    wezterm.log_error "find_parent_executable: no info passed."
    return
  end
  if info.name:find(name) then
    return info
  else
    local parent_proc = wezterm.procinfo.get_info_for_pid(info.ppid)
    if parent_proc then
      return M.find_parent_executable(parent_proc, name)
    end
  end

  local err_msg = "find_parent_executable: parent process `" .. name .. "` not found in adjacent pane."
  local windows = wezterm.gui.gui_windows()
  windows[1]:toast_notification("Wezterm", err_msg, nil, 4000)
  error(err_msg)
end

---@param pane Pane
---@return string
function M.get_pane_working_dir(pane)
  local cwd = pane:get_current_working_dir() ---@type string|Url

  if type(cwd) == "string" then
    ---@diagnostic disable-next-line: undefined-field
    cwd = wezterm.url.parse(cwd) ---@type Url
  end

  ---@generic T
  ---@param str T
  ---@param prefix string
  ---@return string
  local function remove_prefix(str, prefix)
    if type(str) ~= "string" then
      str = tostring(str)
    end
    if str:sub(1, #prefix) == prefix then
      return str:sub(#prefix + 1)
    else
      return str
    end
  end

  if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    cwd = remove_prefix(cwd.path, "/")
  else
    cwd = tostring(cwd.path)
  end

  return cwd
end

return M
