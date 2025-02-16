require("relative-motions"):setup {
  show_numbers = "relative",
  show_motion = true,
  only_motions = false,
}

require("git"):setup()

require("custom-shell"):setup {
  history_path = "~/.config/yazi/state/yazi_cmd_history",
  save_history = true,
}

require("full-border"):setup { type = ui.Border.ROUNDED }

require("current-size"):setup {}

-- start: yamb.yazi
local bookmarks = {}
local path_sep = package.config:sub(1, 1)
local home_path = ya.target_family() == "windows" and os.getenv "USERPROFILE" or os.getenv "HOME"

require("yamb"):setup {
  bookmarks = bookmarks,
  jump_notify = true,
  cli = "fzf",
  keys = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
  path = os.getenv "HOME" .. "/.config/yazi/state/bookmark",
}
-- end: yamb.yazi

-- to enable linemode, add to ~/.config/yazi/yazi.toml
-- [manager]
-- linemode = "size_and_mtime"
function Linemode:size_and_mtime(job)
  local time = math.floor(self._file.cha.mtime or 0)
  if time == 0 then
    time = ""
  else
    time = os.date("%Y-%m-%d %H:%M", time)
  end
  local size = self._file:size()
  if size then
    return ui.Line(string.format("%s %s", size and ya.readable_size(size) or "-", time))
  else
    local folder = cx.active:history(self._file.url)
    return ui.Line(string.format("%s %s", folder and tostring(#folder.files) or "-", time))
  end
end

require("projects"):setup {
  save = {
    method = "lua",
  },
  last = {
    update_after_save = true,
    update_after_load = true,
    load_after_start = false,
  },
  merge = {
    quit_after_merge = false,
  },
  notify = {
    enable = true,
    title = "Projects",
    timeout = 3,
    level = "info",
  },
}

require("session"):setup { sync_yanked = true }

require("starship"):setup()

if os.getenv "YAZI_HIDE_PREVIEW" then
  require("hide-preview"):entry()
end
