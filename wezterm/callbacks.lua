local wezterm = require "wezterm"
local M = {}

function M.rename_tab(window, pane)
  window:perform_action(
    wezterm.action.Multiple {
      "PopKeyTable",
      wezterm.action.PromptInputLine {
        description = wezterm.format {
          { Attribute = { Intensity = "Bold" } },
          { Foreground = { AnsiColor = "Fuchsia" } },
          { Text = "Enter new name for tab" },
        },
        initial_value = "",
        action = wezterm.action_callback(function(_window, _pane, line)
          if line then
            window:active_tab():set_title(line)
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

return M
