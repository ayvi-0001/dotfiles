local utils = require "utils"
local wezterm = require "wezterm" --[[@as Wezterm]]
local window_space = require "window_space"

--[[
Functions/events for using yazi & helix in wezterm.
*This is still a work-in-progress and has minimal documentation.*

Requires the Yazi plugin `yazi-rs/plugins:toggle-pane`, plus the following line added
to $YAZI_CONFIG_HOME/init.lua

```lua
if os.getenv "YAZI_HIDE_PREVIEW" then require("toggle-pane"):entry("min-preview") end
```

Requires an additional setup in Yazi to subscribe to messages from this module,
it's not currently a standalone plugin, but can be viewed in this same repo
at [`wezyx.yazi`](https://github.com/ayvi-0001/dotfiles/tree/main/yazi/plugins/wezyx.yazi).

---

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
  - yazi-helix-open-new-window
  - trigger-hx-with-scrollback

Example setting for keybinds:
config.keys = {
  { key = "p", mods = "CTRL", action = wezterm.action.ActivateKeyTable { name = "pane" } },
}
config.key_tables = {
  pane = {
    { key = "h", action = wezterm.action.ActivateKeyTable { name = "yazi_helix" } },
    { key = "Escape", action = "PopKeyTable" },
  },
  yazi_helix = {
    { key = "i", action = wezterm.action.EmitEvent "yazi-helix-launch-ide" },
    { key = "r", action = wezterm.action.EmitEvent "yazi-helix-open-new-right-pane" },
    { key = "R", action = wezterm.action.EmitEvent "yazi-helix-open-new-right-pane-top-level" },
    { key = "d", action = wezterm.action.EmitEvent "yazi-helix-open-new-bottom-pane" },
    { key = "D", action = wezterm.action.EmitEvent "yazi-helix-open-new-bottom-pane-top-level" },
    { key = "h", action = wezterm.action.EmitEvent "yazi-helix-open-in-left-pane" },
    { key = "j", action = wezterm.action.EmitEvent "yazi-helix-open-in-pane-below" },
    { key = "k", action = wezterm.action.EmitEvent "yazi-helix-open-in-pane-above" },
    { key = "l", action = wezterm.action.EmitEvent "yazi-helix-open-in-right-pane" },
    { key = "w", action = wezterm.action.EmitEvent "yazi-helix-open-new-window" },
    { key = "Escape", action = "PopKeyTable" },
  },
}
--]]

---@param _ Window
---@param pane Pane
---@param file? string
---@return boolean
local open_with_helix = function(_, pane, file)
  local ok = pcall(utils.find_parent_executable, pane:get_foreground_process_info(), "hx")
  if not ok then
    return false
  end

  if file then
    pane:send_paste(":o " .. file .. "\r")
    -- the case below is from a previous version where the file would be opened in helix
    -- by reading the system clipboard register. it's no longer used.
    --
    -- else
    --   -- send typable command `open`/`edit` + opening quote surrounding path
    --   pane:send_text ":o '"
    --   -- send <C-r> to open registers in typable command
    --   pane:send_text "\x12"
    --   -- enter system clipboard register and return + closing quote for path
    --   pane:send_text "+'"
    --   pane:send_text "\r"
  end

  return ok
end

-- moves your active pane to a new tab
-- send a SIGINT to the active pane incase any program is currently running, then launches helix
-- pane split 25% to the left and launches yazi
-- pane splits another 30% down from the helix tab, for terminal commands, clears buffer (ignore any startup messages on a new shell e.g. direnv,etc.)
-- the new tab is then moved back to the index of the original active tab
-- if the original tab had a title, it's set on the new tab
---@param window Window
---@param pane Pane
---@returns nil
local yazi_helix_launch_ide = function(window, pane)
  local pid = wezterm.procinfo.pid()
  local cwd = wezterm.procinfo.current_working_dir_for_pid(pid) or pane:get_current_working_dir()
  local active_tab_title = window:active_tab():get_title()

  window:perform_action(wezterm.action.SendKey { key = "c", mods = "CTRL" }, pane)

  local default_prog = window:effective_config()["default_prog"]

  local active_tab_index ---@type integer
  for _, item in ipairs(window:mux_window():tabs_with_info()) do
    if item.is_active then
      active_tab_index = item.index
    end
  end

  local tab = select(1, pane:move_to_new_tab())
  tab:activate()

  if active_tab_title then
    tab:set_title(active_tab_title)
  end

  window:perform_action(wezterm.action.MoveTab(active_tab_index), pane)

  -- split pane for yazi on left-hand side
  local yazi_pane = pane:split {
    args = default_prog,
    direction = "Left",
    cwd = cwd,
    size = 0.25,
    set_environment_variables = { YAZI_HIDE_PREVIEW = "1" },
  }

  -- sending commands here instead of args in pane:split(), so if you exit,
  -- it drops back into the shell, rather than closing the pane.

  -- https://yazi-rs.github.io/docs/quick-start#shell-wrapper
  local yazi_shell_wrapper = [[ function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
  } && y]]
  -- launch yazi
  yazi_pane:send_text(yazi_shell_wrapper .. "\r")
  -- launch helix
  pane:send_text " hx\r"
  -- split pane below helix for terminal
  local terminal_pane = pane:split {
    args = default_prog,
    direction = "Bottom",
    cwd = cwd,
    size = 0.3,
  }
  -- clear buffer
  terminal_pane:send_text "\x0c"
  -- activate helix pane first so yazi opens files in the correct pane
  pane:activate()
  wezterm.sleep_ms(100)
  -- start in yazi pane
  yazi_pane:activate()
end

---Publish a message to _all_ yazi instances.
---Payload is encoded as json before being sent to receivers.
---@param payload { [string]: string|number }
local ya_pub_wezyx = function(payload)
  wezterm.run_child_process {
    "ya",
    "pub-to",
    "0",
    "wezyx",
    "--json",
    wezterm.json_encode(payload),
  }
end

---This function first publishes a message to yazi, only the instance with the
---matching wezterm pane id will execute the callback.
---The target yazi instance will save the hovered url in yazi's cache dir.
---The hovered url will be saved in a file named `yazi-target-paths-wezterm-pane-$WEZTERM_PANE`,
---and this function will read and return the contents.
---@param pane_id number
---@return string
local yazi_read_target_paths = function(pane_id)
  ya_pub_wezyx { fn = "cache_target_paths", wezterm_pane = pane_id }

  local yazi_cache_dir = wezterm.home_dir .. "/.cache/yazi"
  local file_template = "yazi-target-paths-wezterm-pane-"
  local filename = yazi_cache_dir .. "/" .. file_template .. tostring(pane_id)
  filename = filename:gsub("\\", "/")

  local file = io.open(filename, "rb")
  assert(file, "error: failed to open file " .. filename)
  local path = file:read "*a" --[[@as string]]
  file:close()

  return path
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
      local ok = open_with_helix(_window, right_pane, yazi_read_target_paths(_pane:pane_id()))
      if ok then
        right_pane:activate()
      end
    else
      open_with_helix(window, right_pane, file)
    end
  end
  return _inner(window, pane)
end

---Open the hovered path in yazi into a new helix pane.
---@param window Window
---@param pane Pane
---@param direction "Right" | "Left" | "Top" | "Bottom"
---@param top_level boolean?
---@return nil
local yazi_helix_open_new_pane = function(window, pane, direction, top_level)
  ---@param _ Window
  ---@param _pane Pane
  ---@return nil
  local _inner = function(_, _pane)
    _pane:split {
      direction = direction,
      args = { "hx", yazi_read_target_paths(_pane:pane_id()) },
      size = 0.5,
      top_level = top_level or false,
    }
  end
  return _inner(window, pane)
end

---Open the hovered path in yazi into a new helix window.
---@param _ Window
---@param pane Pane
---@returns nil
local yazi_helix_open_new_window = function(_, pane)
  window_space.spawn_window_and_set_dimensions {
    ratio = 0.5,
    domain = "local",
    args = { "hx", yazi_read_target_paths(pane:pane_id()) },
  }
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
