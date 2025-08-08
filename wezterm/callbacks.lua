local wezterm = require "wezterm" --[[@as Wezterm]]

local M = {}

---@param window Window
---@param pane Pane
---@returns nil
function M.rename_tab(window, pane)
  local active_tab = window:active_tab()
  window:perform_action(
    wezterm.action.Multiple {
      "PopKeyTable",
      wezterm.action.PromptInputLine {
        description = wezterm.format {
          { Attribute = { Intensity = "Bold" } },
          { Foreground = { AnsiColor = "Fuchsia" } },
          { Text = "Enter new name for tab" },
        },
        initial_value = active_tab:get_title() or "",
        ---@param inner_window Window
        ---@param inner_pane Pane
        ---@param line? string
        ---@return nil
        action = wezterm.action_callback(function(inner_window, inner_pane, line) ---@diagnostic disable-line: unused-local
          if line then
            active_tab:set_title(line)
          end
        end),
      },
    },
    pane
  )
end

---@param window Window
---@param pane Pane
---@returns nil
function M.move_pane_to_new_window(window, pane) ---@diagnostic disable-line: unused-local
  pane:move_to_new_window()
end

---@param window Window
---@param pane Pane
---@returns nil
function M.move_pane_to_new_tab(window, pane) ---@diagnostic disable-line: unused-local
  local active_tab_title = window:active_tab():get_title()

  local active_tab_index ---@type integer
  for _, item in ipairs(window:mux_window():tabs_with_info()) do
    if item.is_active then
      active_tab_index = item.index + 1
    end
  end

  local tab = pane:move_to_new_tab()
  tab:activate()

  if active_tab_title then
    tab:set_title(active_tab_title)
  end

  window:perform_action(wezterm.action.MoveTab(active_tab_index), pane)
end

---@param window Window
---@param pane Pane
function M.zoom_in(window, pane)
  window:perform_action(wezterm.action.IncreaseFontSize, pane)

  local overrides = window:get_config_overrides() or {}

  if not overrides.window_frame then
    local effective_config = window:effective_config()

    if not wezterm.GLOBAL.origin_window_frame_font_size then
      wezterm.GLOBAL.origin_window_frame_font_size = effective_config.window_frame["font_size"]
    end

    overrides.window_frame = effective_config.window_frame or {}
  end

  overrides.window_frame["font_size"] = overrides.window_frame.font_size + 0.5
  window:set_config_overrides(overrides)
end

---@param window Window
---@param pane Pane
function M.zoom_out(window, pane)
  window:perform_action(wezterm.action.DecreaseFontSize, pane)

  local overrides = window:get_config_overrides() or {}

  if not overrides.window_frame then
    local effective_config = window:effective_config()

    if not wezterm.GLOBAL.origin_window_frame_font_size then
      wezterm.GLOBAL.origin_window_frame_font_size = effective_config.window_frame["font_size"]
    end

    overrides.window_frame = effective_config.window_frame or {}
  end

  overrides.window_frame["font_size"] = overrides.window_frame.font_size - 0.5
  window:set_config_overrides(overrides)
end

---@param window Window
---@param pane Pane
function M.zoom_reset(window, pane)
  window:perform_action(wezterm.action.ResetFontSize, pane)

  local overrides = window:get_config_overrides() or {}
  local effective_config = window:effective_config()

  if not overrides.window_frame then
    overrides.window_frame = effective_config.window_frame or {}
  end
  if not wezterm.GLOBAL.origin_window_frame_font_size then
    wezterm.GLOBAL.origin_window_frame_font_size = effective_config.window_frame["font_size"]
  end

  overrides.window_frame["font_size"] = wezterm.GLOBAL.origin_window_frame_font_size
  window:set_config_overrides(overrides)
end

---@param window Window
---@param pane Pane
function M.pane_size_increase_to_top(window, pane)
  local pane_up = pane:tab():get_pane_direction "Up"
  if pane_up ~= nil then
    pane_up:activate()
    window:perform_action(wezterm.action.AdjustPaneSize { "Up", 5 }, window:active_pane())
    pane:activate()
  end
end

---@param window Window
---@param pane Pane
function M.pane_size_decrease_from_top(window, pane)
  local pane_up = pane:tab():get_pane_direction "Up"
  if pane_up ~= nil then
    pane_up:activate()
    window:perform_action(wezterm.action.AdjustPaneSize { "Down", 5 }, window:active_pane())
    pane:activate()
  end
end

---@param window Window
---@param pane Pane
function M.pane_size_increase_to_bottom(window, pane)
  local pane_down = pane:tab():get_pane_direction "Down"
  if pane_down ~= nil then
    pane_down:activate()
    window:perform_action(wezterm.action.AdjustPaneSize { "Down", 5 }, window:active_pane())
    pane:activate()
  end
end

---@param window Window
---@param pane Pane
function M.pane_size_decrease_from_bottom(window, pane)
  local pane_down = pane:tab():get_pane_direction "Down"
  if pane_down ~= nil then
    pane_down:activate()
    window:perform_action(wezterm.action.AdjustPaneSize { "Up", 5 }, window:active_pane())
    pane:activate()
  end
end

---@param window Window
---@param pane Pane
function M.pane_size_increase_to_right(window, pane)
  local pane_left = pane:tab():get_pane_direction "Left"
  local pane_right = pane:tab():get_pane_direction "Right"
  if pane_right == nil then
    return
  elseif pane_left ~= nil then
    pane_right:activate()
    window:perform_action(wezterm.action.AdjustPaneSize { "Right", 5 }, window:active_pane())
    pane:activate()
  else
    window:perform_action(wezterm.action.AdjustPaneSize { "Right", 5 }, window:active_pane())
  end
end

---@param window Window
---@param pane Pane
function M.pane_size_decrease_from_right(window, pane)
  local pane_left = pane:tab():get_pane_direction "Left"
  local pane_right = pane:tab():get_pane_direction "Right"
  if pane_right == nil then
    return
  elseif pane_left ~= nil then
    pane_right:activate()
    window:perform_action(wezterm.action.AdjustPaneSize { "Left", 5 }, window:active_pane())
    pane:activate()
  else
    window:perform_action(wezterm.action.AdjustPaneSize { "Left", 5 }, window:active_pane())
  end
end

---@param window Window
---@param pane Pane
function M.pane_size_increase_to_left(window, pane)
  if pane:tab():get_pane_direction "Left" then
    window:perform_action(wezterm.action.AdjustPaneSize { "Left", 5 }, window:active_pane())
  end
end

---@param window Window
---@param pane Pane
function M.pane_size_decrease_from_left(window, pane)
  local pane_left = pane:tab():get_pane_direction "Left"
  local pane_right = pane:tab():get_pane_direction "Right"
  if pane_left == nil then
    return
  elseif pane_right ~= nil then
    pane_left:activate()
    window:perform_action(wezterm.action.AdjustPaneSize { "Right", 5 }, window:active_pane())
    pane:activate()
  else
    window:perform_action(wezterm.action.AdjustPaneSize { "Right", 5 }, window:active_pane())
  end
end

---@param window Window
---@param pane Pane
---@returns nil
function M.scroll_to_bottom(window, pane)
  window:perform_action(
    wezterm.action.Multiple {
      wezterm.action.ScrollToBottom,
      wezterm.action.PopKeyTable,
    },
    pane
  )
end

---@enum
local DIRECTION = {
  up = "Up",
  down = "Down",
  left = "Left",
  right = "Right",
}

---@param window Window
---@param pane Pane
---@param direction Direction
---@private
function M._move_focus_or_tab(window, pane, direction)
  local adjacent_pane = window:active_tab():get_pane_direction(direction)
  if adjacent_pane then
    window:perform_action(wezterm.action.ActivatePaneDirection(direction), pane)
  elseif direction == "Right" then
    window:perform_action(wezterm.action.ActivateTabRelative(1), pane)
  elseif direction == "Left" then
    window:perform_action(wezterm.action.ActivateTabRelative(-1), pane)
  end
  -- do nothing on "Up" and "Down"
end

---@param window Window
---@param pane Pane
---@returns nil
function M.move_focus_or_tab_right(window, pane)
  M._move_focus_or_tab(window, pane, DIRECTION.right)
end

---@param window Window
---@param pane Pane
---@returns nil
function M.move_focus_or_tab_left(window, pane)
  M._move_focus_or_tab(window, pane, DIRECTION.left)
end

---@param window Window
---@param pane Pane
---@returns nil
function M.move_focus_or_tab_up(window, pane)
  M._move_focus_or_tab(window, pane, DIRECTION.up)
end

---@param window Window
---@param pane Pane
---@returns nil
function M.move_focus_or_tab_down(window, pane)
  M._move_focus_or_tab(window, pane, DIRECTION.down)
end

---@param window Window
---@param pane Pane
---@returns nil
function M.spawn_default_prog_in_new_tab(window, pane)
  window:perform_action(
    wezterm.action.SpawnCommandInNewTab {
      args = window:effective_config()["default_prog"],
    },
    pane
  )
end

---@param window Window
---@param pane Pane
---@returns nil
function M.spawn_default_prog_in_new_tab_in_home(window, pane)
  window:perform_action(
    wezterm.action.SpawnCommandInNewTab {
      args = window:effective_config()["default_prog"],
      cwd = wezterm.home_dir,
    },
    pane
  )
end

---@param window Window
---@param pane Pane
---@returns nil
function M.rotate_pane_left(window, pane)
  window:perform_action(
    wezterm.action.Multiple {
      wezterm.action.RotatePanes "CounterClockwise",
      wezterm.action.ActivatePaneDirection "Prev",
    },
    pane
  )
end

---@param window Window
---@param pane Pane
---@returns nil
function M.rotate_pane_right(window, pane)
  window:perform_action(
    wezterm.action.Multiple {
      wezterm.action.RotatePanes "Clockwise",
      wezterm.action.ActivatePaneDirection "Next",
    },
    pane
  )
end

---@param window Window
---@param pane Pane
---@returns nil
function M.launch_workspace(window, pane)
  local home = wezterm.home_dir

  local workspaces = {}
  local workspace_names = wezterm.mux.get_workspace_names()
  for i in pairs(workspace_names) do
    table.insert(workspaces, i, { id = home, label = workspace_names[i] })
  end

  window:perform_action(
    wezterm.action.InputSelector {
      ---@param inner_window Window
      ---@param inner_pane Pane
      ---@param id string
      ---@param label string
      ---@return nil
      action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
        if not id and not label then
          wezterm.log_info "cancelled"
        else
          wezterm.log_info("id = " .. id)
          wezterm.log_info("label = " .. label)
          inner_window:perform_action(
            wezterm.action.SwitchToWorkspace {
              name = label,
              spawn = {
                label = "Workspace: " .. label,
                cwd = id,
              },
            },
            inner_pane
          )
        end
      end),
      title = "Choose Workspace",
      choices = workspaces,
      fuzzy = true,
      fuzzy_description = wezterm.format {
        { Attribute = { Intensity = "Bold" } },
        { Foreground = { AnsiColor = "Fuchsia" } },
        { Text = "Fuzzy find and/or make a workspace: " },
      },
    },
    pane
  )
end

---@param window Window
---@param pane Pane
---@returns nil
function M.create_workspace(window, pane)
  window:perform_action(
    wezterm.action.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = "Bold" } },
        { Foreground = { AnsiColor = "Fuchsia" } },
        { Text = "Enter name for new workspace" },
      },
      ---@param inner_window Window
      ---@param inner_pane Pane
      ---@param line string
      ---@return nil
      action = wezterm.action_callback(function(inner_window, inner_pane, line)
        if line then
          inner_window:perform_action(
            wezterm.action.SwitchToWorkspace {
              name = line,
            },
            inner_pane
          )
        end
      end),
    },
    pane
  )
end

return M
