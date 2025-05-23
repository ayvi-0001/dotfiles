require("relative-motions"):setup { show_numbers = "relative" }

require("git"):setup()

require("full-border"):setup()

require("fg"):setup()

local bookmarks = os.getenv "HOME" .. "/.config/yazi/state/bookmark"
require("yamb"):setup { jump_notify = true, cli = "fzf", path = bookmarks }

local projects = os.getenv "HOME" .. "/.config/yazi/state/projects.json"
require("projects"):setup { save = { method = "lua", lua_save_path = projects } }

require("copy-file-contents"):setup {}

require("session"):setup { sync_yanked = true }

require("starship"):setup()

require("zoxide"):setup { update_db = true }

if os.getenv "YAZI_HIDE_PREVIEW" then
  require("toggle-pane"):entry "min-preview"
end
