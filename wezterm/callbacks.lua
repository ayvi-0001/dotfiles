local wezterm = require "wezterm"

local M = {}

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
        action = wezterm.action_callback(function(_window, _pane, line)
          if line then
            active_tab:set_title(line)
          end
        end),
      },
    },
    pane
  )
end

function M.move_pane_to_new_window(window, pane)
  pane:move_to_new_window()
end

function M.scroll_to_bottom(window, pane)
  window:perform_action(
    wezterm.action.Multiple {
      wezterm.action.ScrollToBottom,
      wezterm.action.PopKeyTable,
    },
    pane
  )
end

--- @private
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

function M.move_focus_or_tab_right(window, pane)
  M._move_focus_or_tab(window, pane, "Right")
end

function M.move_focus_or_tab_left(window, pane)
  M._move_focus_or_tab(window, pane, "Left")
end

function M.move_focus_or_tab_up(window, pane)
  M._move_focus_or_tab(window, pane, "Up")
end

function M.move_focus_or_tab_down(window, pane)
  M._move_focus_or_tab(window, pane, "Down")
end

function M.spawn_default_prog_in_new_tab(window, pane)
  window:perform_action(
    wezterm.action.SpawnCommandInNewTab {
      args = window:effective_config()["default_prog"],
    },
    pane
  )
end

function M.launch_workspace(window, pane)
  local home = wezterm.home_dir

  local workspaces = {}
  local workspace_names = wezterm.mux.get_workspace_names()
  for i in pairs(workspace_names) do
    table.insert(workspaces, i, { id = home, label = workspace_names[i] })
  end

  window:perform_action(
    wezterm.action.InputSelector {
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

return M
