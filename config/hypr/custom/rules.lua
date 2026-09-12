hl.window_rule({ match = { class = ".*" }, opacity = "0.95 0.85" })
hl.window_rule({ match = { class = "Minecraft.*" }, opacity = "1 1" })
hl.window_rule({ match = { class = "Lunar.*" }, opacity = "1 1" })
hl.window_rule({ match = { class = "Axolotl.*" }, opacity = "1 1" })

hl.workspace_rule({ workspace = "1", layout = "scrolling" })
hl.workspace_rule({ workspace = "2", layout = "monocle" })
hl.workspace_rule({ workspace = "7", layout = "master" })

-- hl.window_rule({ match = { class = "Minecraft.*" }, confine_pointer = true })
-- hl.window_rule({ match = { class = "Lunar.*" }, confine_pointer = true })
-- hl.window_rule({ match = { fullscreen = true }, confine_pointer = true })
