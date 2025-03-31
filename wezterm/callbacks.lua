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

return M
