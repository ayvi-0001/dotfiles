local wezterm = require "wezterm"

--[[
Functions/events for using yazi & helix in wezterm.
This implementation is only an initial attempt, there's still issues with this,
like the shell being hardcoded as bash only,
sending commands to a pane assuming its running helix, even if its not,
relying on wrapper scripts/external plugins (yazi),
and likely many more.
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

local _yazi_copy_path_hovered_file = function(window, pane)
  -- copy the path of the hovered file in yazi
  window:perform_action(
    wezterm.action.Multiple {
      wezterm.action.SendKey { key = "c" },
      wezterm.action.SendKey { key = "c" },
    },
    pane
  )
end

local _helix_open_file_read_from_system_clipboard = function(pane)
  -- send typable command `open`/`edit`
  pane:send_text ":o "
  -- send <C-r> to open registers in typable command
  pane:send_text "\x12"
  -- enter system clipboard register and return
  pane:send_text "+"
  pane:send_text "\r"
end

local yazi_helix_launch_ide = function(window, pane)
  local pid = wezterm.procinfo.pid()
  local cwd = wezterm.procinfo.current_working_dir_for_pid(pid)

  local tab = select(1, pane:move_to_new_tab())
  tab:activate()

  -- split pane for yazi on left-hand side
  local yazi_pane = pane:split {
    args = { "bash", "-il" },
    direction = "Left",
    cwd = cwd,
    size = 0.25,
    -- requires yazi-rs/plugins:toggle-pane
    -- + following setup added to $YAZI_CONFIG_HOME/init.lua
    -- ```lua
    -- local os = require "os"
    -- if os.getenv "YAZI_HIDE_PREVIEW" then require("toggle-pane"):entry("min-preview") end
    --- ```
    set_environment_variables = { YAZI_HIDE_PREVIEW = "1" },
  }

  -- sending commands here instead of in args, so if you exit,
  -- it drops back into the shell, rather than closing the pane.

  -- start yazi, requires yazi shell wrapper
  -- https://yazi-rs.github.io/docs/quick-start#shell-wrapper
  yazi_pane:send_text "y"
  yazi_pane:send_text "\r"

  --start helix
  pane:send_text "hx"
  pane:send_text "\r"

  -- split pane below helix for terminal
  local terminal_pane = pane:split {
    args = { "bash", "-il" },
    direction = "Bottom",
    cwd = cwd,
    size = 0.3,
  }
  terminal_pane:send_text "\x0c" -- clear buffer

  -- start in yazi pane
  yazi_pane:activate()
end

-- Open the hovered path in yazi into an adjacent helix pane.
local yazi_helix_open_in_pane = function(window, pane, direction)
  local _inner = function(_window, _pane)
    local right_pane = _pane:tab():get_pane_direction(direction)
    _yazi_copy_path_hovered_file(_window, _pane)
    right_pane:activate()
    _helix_open_file_read_from_system_clipboard(right_pane)
  end
  return _inner(window, pane)
end

-- Open the hovered path in yazi into a new helix pane.
local yazi_helix_open_new_pane = function(window, pane, direction, top_level)
  local _inner = function(_window, _pane)
    _yazi_copy_path_hovered_file(_window, _pane)
    local new_pane = _pane:split {
      domain = "DefaultDomain",
      direction = direction,
      args = { "hx" },
      size = 0.5,
      top_level = top_level or false,
    }
    _helix_open_file_read_from_system_clipboard(new_pane)
  end
  return _inner(window, pane)
end

-- set callbacks for yazi/helix events.

wezterm.on("yazi-helix-launch-ide", function(window, pane)
  yazi_helix_launch_ide(window, pane)
end)

-- callbacks to open in new panes

wezterm.on("yazi-helix-open-new-right-pane", function(window, pane)
  yazi_helix_open_new_pane(window, pane, "Right", false)
end)

wezterm.on("yazi-helix-open-new-right-pane-top-level", function(window, pane)
  yazi_helix_open_new_pane(window, pane, "Right", true)
end)

wezterm.on("yazi-helix-open-new-bottom-pane", function(window, pane)
  yazi_helix_open_new_pane(window, pane, "Bottom", false)
end)

wezterm.on("yazi-helix-open-new-bottom-pane-top-level", function(window, pane)
  yazi_helix_open_new_pane(window, pane, "Bottom", true)
end)

-- callbacks to open in existing panes

wezterm.on("yazi-helix-open-in-left-pane", function(window, pane)
  yazi_helix_open_in_pane(window, pane, "Left")
end)

wezterm.on("yazi-helix-open-in-pane-below", function(window, pane)
  yazi_helix_open_in_pane(window, pane, "Down")
end)

wezterm.on("yazi-helix-open-in-pane-above", function(window, pane)
  yazi_helix_open_in_pane(window, pane, "Up")
end)

wezterm.on("yazi-helix-open-in-right-pane", function(window, pane)
  yazi_helix_open_in_pane(window, pane, "Right")
end)
