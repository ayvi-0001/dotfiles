local utils = require "utils"
local wezterm = require "wezterm" --[[@as Wezterm]]
local window_space = require "window_space"

--[[ Functions/events for using yazi & helix in wezterm.
This is a rough implementation, there's still issues with it,
like the shell being hardcoded as bash only, relying on external plugins (yazi), etc,
I plan to revisit this eventually and make a proper plugin out of it.

The callbacks are set to run on these event names:
  - yazi-helix-launch-ide
  - yazi-helix-open-new-right-pane
  - yazi-helix-open-new-right-pane-top-level
  - yazi-helix-open-new-bottom-pane
  - yazi-helix-open-new-bottom-pane-top-level
  - yazi-helix-open-in-left-pane
  - yazi-helix-open-in-pane-below
  - yazi-helix-open-in-pane-above
  - yazi-helix-open-in-right-pane

Example setting for keybinds:
config.keys = {
  { key = "p", mods = "CTRL", action = wezterm.action.ActivateKeyTable { name = "pane" } },
}
config.key_tables = {
  pane = {
    { key = "h", action = wezterm.action.ActivateKeyTable { name = "yazi_helix" } },
  },
  yazi_helix = {
    { key = "t", action = wezterm.action.EmitEvent "yazi-helix-launch-ide" },
    { key = "r", action = wezterm.action.EmitEvent "yazi-helix-open-new-right-pane" },
    { key = "R", action = wezterm.action.EmitEvent "yazi-helix-open-new-right-pane-top-level" },
    { key = "d", action = wezterm.action.EmitEvent "yazi-helix-open-new-bottom-pane" },
    { key = "D", action = wezterm.action.EmitEvent "yazi-helix-open-new-bottom-pane-top-level" },
    { key = "h", action = wezterm.action.EmitEvent "yazi-helix-open-in-left-pane" },
    { key = "j", action = wezterm.action.EmitEvent "yazi-helix-open-in-pane-below" },
    { key = "k", action = wezterm.action.EmitEvent "yazi-helix-open-in-pane-above" },
    { key = "l", action = wezterm.action.EmitEvent "yazi-helix-open-in-right-pane" },
    { key = "Escape", action = "PopKeyTable" },
  },
}
--]]

---@param _ Window
---@param pane Pane
---@returns nil
local _yazi_copy_path_hovered_file = function(_, pane)
  -- NOTE: expects the default keybindings in yazi for copying
  -- the full path of the hovered file.
  -- TODO: emit data from yazi another way
  pane:send_text "cc"
end

---@param _ Window
---@param pane Pane
---@param file? string
---@return boolean
local _helix_open_file_read_from_system_clipboard = function(_, pane, file)
  ---@param info LocalProcessInfo
  ---@return number
  local function _find_hx_exec(info)
    if not info then
      return -1
    end
    if utils.basename(tostring(info.executable)):find "hx" then
      return info.pid
    else
      local parent_proc = wezterm.procinfo.get_info_for_pid(info.ppid)
      if parent_proc then
        return _find_hx_exec(parent_proc)
      end
    end
    error "pane is not running helix"
  end

  local info = pane:get_foreground_process_info()
  local ok, _ = pcall(_find_hx_exec, info)
  if not ok then
    return false
  end

  if file then
    pane:send_text(":o " .. file .. "\r")
  else
    -- send typable command `open`/`edit` + opening quote surrounding path
    pane:send_text ":o '"
    -- send <C-r> to open registers in typable command
    pane:send_text "\x12"
    -- enter system clipboard register and return + closing quote for path
    pane:send_text "+'"
    pane:send_text "\r"
  end

  return ok
end

---@param _ Window
---@param pane Pane
---@returns nil
local yazi_helix_launch_ide = function(_, pane)
  local pid = wezterm.procinfo.pid()
  local cwd = wezterm.procinfo.current_working_dir_for_pid(pid)

  local tab = select(1, pane:move_to_new_tab())
  tab:activate()

  local default_prog = wezterm.gui.gui_windows()[1]:effective_config()["default_prog"]

  -- split pane for yazi on left-hand side
  local yazi_pane = pane:split {
    args = default_prog,
    direction = "Left",
    cwd = cwd,
    size = 0.25,
    -- requires yazi-rs/plugins:toggle-pane + line below added to $YAZI_CONFIG_HOME/init.lua
    -- if os.getenv "YAZI_HIDE_PREVIEW" then require("toggle-pane"):entry("min-preview") end
    set_environment_variables = { YAZI_HIDE_PREVIEW = "1" },
  }

  -- sending commands here instead of args in pane:split(), so if you exit,
  -- it drops back into the shell, rather than closing the pane.

  --start yazi, https://yazi-rs.github.io/docs/quick-start#shell-wrapper
  yazi_pane:send_text [[ function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
  } && y]]
  yazi_pane:send_text "\r"

  --start helix
  pane:send_text " hx"
  pane:send_text "\r"

  -- split pane below helix for terminal
  local terminal_pane = pane:split {
    args = default_prog,
    direction = "Bottom",
    cwd = cwd,
    size = 0.3,
  }
  terminal_pane:send_text "\x0c" -- clear buffer

  -- activate helix pane first so yazi opens files in the correct pane
  pane:activate()
  wezterm.sleep_ms(100)

  -- start in yazi pane
  yazi_pane:activate()
end

---Open the hovered path in yazi into an adjacent helix pane.
---@param window Window
---@param pane Pane
---@param direction string
---@param file? string
---@return nil
local yazi_helix_open_in_pane = function(window, pane, direction, file)
  ---@param _window Window
  ---@param _pane Pane
  ---@return nil
  local _inner = function(_window, _pane)
    local right_pane = _pane:tab():get_pane_direction(direction)
    if not file then
      _yazi_copy_path_hovered_file(_window, _pane)
      local ok = _helix_open_file_read_from_system_clipboard(window, right_pane)
      if ok then
        right_pane:activate()
      end
    else
      _helix_open_file_read_from_system_clipboard(window, right_pane, file)
    end
  end
  return _inner(window, pane)
end

---Open the hovered path in yazi into a new helix pane.
---@param window Window
---@param pane Pane
---@param direction string
---@param top_level boolean
---@return nil
local yazi_helix_open_new_pane = function(window, pane, direction, top_level)
  ---@param _window Window
  ---@param _pane Pane
  ---@return nil
  local _inner = function(_window, _pane)
    _yazi_copy_path_hovered_file(_window, _pane)
    local new_pane = _pane:split {
      domain = "DefaultDomain",
      direction = direction,
      args = { "hx" },
      size = 0.5,
      top_level = top_level or false,
    }
    _helix_open_file_read_from_system_clipboard(window, new_pane)
  end
  return _inner(window, pane)
end

---Open the hovered path in yazi into a new helix window.
---@param window Window
---@param pane Pane
---@returns nil
local yazi_helix_open_new_window = function(window, pane)
  _yazi_copy_path_hovered_file(window, pane)
  local _, new_pane, new_window = window_space.spawn_window_and_set_dimensions { ratio = 0.5, domain = "local", args = { "hx" } }
  _helix_open_file_read_from_system_clipboard(new_window, new_pane)
end

-- set callbacks for yazi/helix events.

---@param window Window
---@param pane Pane
wezterm.on("yazi-helix-launch-ide", function(window, pane)
  yazi_helix_launch_ide(window, pane)
end)

---@param window Window
---@param pane Pane
wezterm.on("yazi-helix-open-new-window", function(window, pane)
  yazi_helix_open_new_window(window, pane)
end)

---@param window Window
---@param pane Pane
wezterm.on("trigger-hx-with-scrollback", function(window, pane) ---@diagnostic disable-line: unused-local
  local text = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)
  local filename = utils.write(nil, text)
  window_space.spawn_window_and_set_dimensions {
    ratio = 0.5,
    domain = "local",
    args = { "hx", filename },
  }
end)

-- callbacks to open in new panes

---@param window Window
---@param pane Pane
wezterm.on("yazi-helix-open-new-right-pane", function(window, pane)
  yazi_helix_open_new_pane(window, pane, "Right", false)
end)

---@param window Window
---@param pane Pane
wezterm.on("yazi-helix-open-new-right-pane-top-level", function(window, pane)
  yazi_helix_open_new_pane(window, pane, "Right", true)
end)

---@param window Window
---@param pane Pane
wezterm.on("yazi-helix-open-new-bottom-pane", function(window, pane)
  yazi_helix_open_new_pane(window, pane, "Bottom", false)
end)

---@param window Window
---@param pane Pane
wezterm.on("yazi-helix-open-new-bottom-pane-top-level", function(window, pane)
  yazi_helix_open_new_pane(window, pane, "Bottom", true)
end)

-- callbacks to open in existing panes

---@param window Window
---@param pane Pane
wezterm.on("yazi-helix-open-in-left-pane", function(window, pane)
  yazi_helix_open_in_pane(window, pane, "Left")
end)

---@param window Window
---@param pane Pane
wezterm.on("yazi-helix-open-in-pane-below", function(window, pane)
  yazi_helix_open_in_pane(window, pane, "Down")
end)

---@param window Window
---@param pane Pane
wezterm.on("yazi-helix-open-in-pane-above", function(window, pane)
  yazi_helix_open_in_pane(window, pane, "Up")
end)

---@param window Window
---@param pane Pane
wezterm.on("yazi-helix-open-in-right-pane", function(window, pane)
  yazi_helix_open_in_pane(window, pane, "Right")
end)
