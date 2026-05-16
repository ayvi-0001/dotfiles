require("relative-motions"):setup { show_numbers = "none" }

require("git"):setup { order = 1500 }

require("full-border"):setup()

require("fg"):setup()

local bookmarks = os.getenv "YAZI_CONFIG_HOME" .. "/state/bookmark"
require("yamb"):setup { jump_notify = true, cli = "fzf", path = bookmarks }

local projects = os.getenv "YAZI_CONFIG_HOME" .. "/state/projects.json"
require("projects"):setup {
  save = { method = "lua", lua_save_path = projects },
  last = {
    update_after_save = true,
    update_after_load = true,
    update_before_quit = true,
    load_after_start = false,
  },
}

require("copy-file-contents"):setup {}

require("session"):setup { sync_yanked = true }

require("wezyx"):setup {}

require("starship"):setup()

require("zoxide"):setup { update_db = true }

require("bunny"):setup {
  hops = require("hops")["keys"],
}

if os.getenv "YAZI_HIDE_PREVIEW" then
  require("toggle-pane"):entry "min-preview"
end
