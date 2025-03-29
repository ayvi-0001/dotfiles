require("relative-motions"):setup {
  show_numbers = "relative",
  show_motion = true,
  only_motions = false,
}

require("git"):setup()

require("full-border"):setup { type = ui.Border.ROUNDED }

require("fg"):setup { default_action = "jump" }

-- start: yamb.yazi
require("yamb"):setup {
  bookmarks = {},
  jump_notify = true,
  cli = "fzf",
  keys = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
  path = os.getenv "HOME" .. "/.config/yazi/state/bookmark",
}
-- end: yamb.yazi

require("projects"):setup {
  save = {
    method = "lua",
    lua_save_path = os.getenv "HOME" .. "/.config/yazi/state/projects.json",
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
    timeout = 2,
    level = "info",
  },
}

require("copy-file-contents"):setup {
  append_char = "\n",
  notification = true,
}

require("session"):setup { sync_yanked = true }

require("starship"):setup()

if os.getenv "YAZI_HIDE_PREVIEW" then
  require("toggle-pane"):entry "min-preview"
end
