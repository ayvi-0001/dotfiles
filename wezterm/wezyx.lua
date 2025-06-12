local utils = require "utils"
local wezterm = require "wezterm" --[[@as Wezterm]]
local window_space = require "window_space"

--[[ # Module for using Yazi & Helix in Wezterm.
*This is still a work-in-progress and has minimal documentation.*

Requires the Yazi plugin `yazi-rs/plugins:toggle-pane`, plus the following line added
to `$YAZI_CONFIG_HOME/init.lua`

```lua
if os.getenv "YAZI_HIDE_PREVIEW" then require("toggle-pane"):entry("min-preview") end
```

Requires an additional setup in Yazi to subscribe to messages from this module,
it's not currently a standalone plugin, but can be viewed in this same repo
at [`yazi/plugins/wezyx.yazi`](https://github.com/ayvi-0001/dotfiles/tree/main/yazi/plugins/wezyx.yazi).

---

## Callback events

 - yazi-helix-launch-ide
 - yazi-helix-open-new-window
 - trigger-hx-with-scrollback
 - yazi-helix-open-new-right-pane
 - yazi-helix-open-new-right-pane-top-level
 - yazi-helix-open-new-bottom-pane
 - yazi-helix-open-new-bottom-pane-top-level
 - yazi-helix-open-in-left-pane
 - yazi-helix-open-in-pane-below
 - yazi-helix-open-in-pane-above
 - yazi-helix-open-in-right-pane

### Example setting for keybinds:

```lua
config.keys = {
  { key = "p", mods = "CTRL", action = wezterm.action.ActivateKeyTable { name = "pane" } },
}
config.key_tables = {
  pane = {
    { key = "h", mods = "NONE", action = wezterm.action.ActivateKeyTable { name = "yazi_helix" } },
    { key = "Escape", action = "PopKeyTable" },
  },
  yazi_helix = {
    { key = "i", mods = "NONE", action = wezterm.action.EmitEvent "yazi-helix-launch-ide" },
    { key = "w", mods = "NONE", action = wezterm.action.EmitEvent "yazi-helix-open-new-window" },
    { key = "r", mods = "NONE", action = wezterm.action.EmitEvent "yazi-helix-open-new-right-pane" },
    { key = "R", mods = "SHIFT", action = wezterm.action.EmitEvent "yazi-helix-open-new-right-pane-top-level" },
    { key = "d", mods = "NONE", action = wezterm.action.EmitEvent "yazi-helix-open-new-bottom-pane" },
    { key = "D", mods = "SHIFT", action = wezterm.action.EmitEvent "yazi-helix-open-new-bottom-pane-top-level" },
    { key = "h", mods = "NONE", action = wezterm.action.EmitEvent "yazi-helix-open-in-left-pane" },
    { key = "j", mods = "NONE", action = wezterm.action.EmitEvent "yazi-helix-open-in-pane-below" },
    { key = "k", mods = "NONE", action = wezterm.action.EmitEvent "yazi-helix-open-in-pane-above" },
    { key = "l", mods = "NONE", action = wezterm.action.EmitEvent "yazi-helix-open-in-right-pane" },
    { key = "S", mods = "SHIFT", action = wezterm.action.EmitEvent "trigger-hx-with-scrollback" },
    { key = "Escape", mods = "NONE", action = "PopKeyTable" },
  },
}
```
--]]
local M = {}

---Creates a tab with Yazi as the file explorer, Helix as the text editor, and an additional pane for a terminal.
---
---  +-------------------------------------------+
---  |      |                                    |
---  |      |                                    |
---  |      |               helix                |
---  | yazi |                                    |
---  |      |                                    |
---  |      |------------------------------------|
---  |      |              terminal              |
---  +-------------------------------------------+
---
---Moves your active pane to a new tab.
---Send SIGINT to the active pane, then launches Helix.
---Pane split 25% to the left and launches Yazi.
---Pane splits another 30% down from the Helix tab, for terminal commands, clears buffer (ignore any startup messages on a new shell e.g. direnv,etc.).
---Original tab title is preserved and the new tab is moved back to the original index.
---@param window Window
---@param pane Pane
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

  local tab = pane:move_to_new_tab()
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

  -- launch yazi
  -- https://yazi-rs.github.io/docs/quick-start#shell-wrapper
  local yazi_shell_wrapper = [[ function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
  } && y]]
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

---Publish a message to _all_ Yazi instances.
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

---This function first publishes a message to Yazi, only the instance with the
---matching wezterm pane id will execute the callback.
---The target yazi instance will save the hovered url in Yazi's cache dir.
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

---@param _ Window
---@param pane Pane
---@param file? string
---@return boolean
local open_with_helix = function(_, pane, file)
  local ok = pcall(utils.find_parent_executable, pane:get_foreground_process_info(), "hx")
  if not ok then
    return ok
  end

  if file ~= nil and file ~= "" then
    pane:send_paste(":o " .. file .. "\r")
  end

  return ok
end

---Open the selected/hovered url(s) in Yazi into an adjacent Helix pane.
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

---Open the selected/hovered url(s) in Yazi into a new Helix pane.
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

---Open the selected/hovered url(s) in Yazi into a new Helix window.
---@param _ Window
---@param pane Pane
local yazi_helix_open_new_window = function(_, pane)
  window_space.spawn_window_and_set_dimensions {
    ratio = 0.5,
    domain = "local",
    args = { "hx", yazi_read_target_paths(pane:pane_id()) },
  }
end

-------------------------------------- CALLBACKS ---------------------------------------

---@see wezyx.lua:97
---@overload fun(window: Window, pane: Pane)
wezterm.on("yazi-helix-launch-ide", function(window, pane)
  yazi_helix_launch_ide(window, pane)
end)

---Open the selected/hovered url(s) from Yazi in Helix into a new window.
---@overload fun(window: Window, pane: Pane)
wezterm.on("yazi-helix-open-new-window", function(window, pane)
  yazi_helix_open_new_window(window, pane)
end)

---Capture the entire scrollback and visible area of the active pane, write it to a file and then open that file in the Helix editor.
---@overload fun(window: Window, pane: Pane)
wezterm.on("trigger-hx-with-scrollback", function(window, pane) ---@diagnostic disable-line: unused-local
  local text = pane:get_lines_as_text(pane:get_dimensions().scrollback_rows)
  local filename = utils.write(nil, text)
  window_space.spawn_window_and_set_dimensions {
    ratio = 0.5,
    domain = "local",
    args = { "hx", filename },
  }
end)

---Open the selected/hovered url(s) from Yazi in Helix, split horizontally, with the new pane on the right.
---@overload fun(window: Window, pane: Pane)
wezterm.on("yazi-helix-open-new-right-pane", function(window, pane)
  yazi_helix_open_new_pane(window, pane, "Right", false)
end)

---Open the selected/hovered url(s) from Yazi in Helix, split horizontally, with the new pane on the right.
---Rather than splitting the active pane, split the entire window.
---@overload fun(window: Window, pane: Pane)
wezterm.on("yazi-helix-open-new-right-pane-top-level", function(window, pane)
  yazi_helix_open_new_pane(window, pane, "Right", true)
end)

---Open the selected/hovered url(s) from Yazi in Helix, split horizontally, with the new pane on the bottom.
---@overload fun(window: Window, pane: Pane)
wezterm.on("yazi-helix-open-new-bottom-pane", function(window, pane)
  yazi_helix_open_new_pane(window, pane, "Bottom", false)
end)

---Open the selected/hovered url(s) from Yazi in Helix, split horizontally, with the new pane on the bottom.
---Rather than splitting the active pane, split the entire window.
---@overload fun(window: Window, pane: Pane)
wezterm.on("yazi-helix-open-new-bottom-pane-top-level", function(window, pane)
  yazi_helix_open_new_pane(window, pane, "Bottom", true)
end)

---Open the selected/hovered url(s) from Yazi into an _existing_ pane on the left running Helix.
---@overload fun(window: Window, pane: Pane)
wezterm.on("yazi-helix-open-in-left-pane", function(window, pane)
  yazi_helix_open_in_pane(window, pane, "Left")
end)

---Open the selected/hovered url(s) from Yazi into an _existing_ pane on the bottom running Helix.
---@overload fun(window: Window, pane: Pane)
wezterm.on("yazi-helix-open-in-pane-below", function(window, pane)
  yazi_helix_open_in_pane(window, pane, "Down")
end)

---Open the selected/hovered url(s) from Yazi into an _existing_ pane on the top running Helix.
---@overload fun(window: Window, pane: Pane)
wezterm.on("yazi-helix-open-in-pane-above", function(window, pane)
  yazi_helix_open_in_pane(window, pane, "Up")
end)

---Open the selected/hovered url(s) from Yazi into an _existing_ pane on the right running Helix.
---@overload fun(window: Window, pane: Pane)
wezterm.on("yazi-helix-open-in-right-pane", function(window, pane)
  yazi_helix_open_in_pane(window, pane, "Right")
end)

return M -- NOTE: currently unused, for future setup function.
