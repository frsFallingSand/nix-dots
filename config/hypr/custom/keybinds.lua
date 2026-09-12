hl.bind(
	"CTRL+SUPER+ALT+Slash",
	hl.dsp.exec_cmd("xdg-open ~/.config/hypr/custom/keybinds.lua"),
	{ description = "Edit user keybinds" }
)

local function layout_bind(bind_table)
	return function()
		local workspace = hl.get_active_special_workspace() or hl.get_active_workspace()

		if not workspace then
			return
		end

		local layout = workspace.tiled_layout

		if bind_table[layout] then
			hl.dispatch(bind_table[layout])
		end
	end
end

hl.bind("SUPER+SHIFT+code:10", hl.dsp.focus({ workspace = workspace_in_group(1) }))
hl.bind("SUPER+SHIFT+code:11", hl.dsp.focus({ workspace = workspace_in_group(11) }))
hl.bind("SUPER+SHIFT+code:12", hl.dsp.focus({ workspace = workspace_in_group(21) }))
hl.bind("SUPER+SHIFT+code:13", hl.dsp.focus({ workspace = workspace_in_group(31) }))
hl.bind("SUPER+SHIFT+code:14", hl.dsp.focus({ workspace = workspace_in_group(41) }))
hl.bind("SUPER+SHIFT+code:15", hl.dsp.focus({ workspace = workspace_in_group(51) }))
hl.bind("SUPER+SHIFT+code:16", hl.dsp.focus({ workspace = workspace_in_group(61) }))
hl.bind("SUPER+SHIFT+code:17", hl.dsp.focus({ workspace = workspace_in_group(71) }))
hl.bind("SUPER+SHIFT+code:18", hl.dsp.focus({ workspace = workspace_in_group(81) }))
hl.bind("SUPER+SHIFT+code:19", hl.dsp.focus({ workspace = workspace_in_group(91) }))

hl.bind("SUPER+ALT+SHIFT+code:10", hl.dsp.window.move({ workspace = 1, follow = false }))
hl.bind("SUPER+ALT+SHIFT+code:11", hl.dsp.window.move({ workspace = 11, follow = false }))
hl.bind("SUPER+ALT+SHIFT+code:12", hl.dsp.window.move({ workspace = 21, follow = false }))
hl.bind("SUPER+ALT+SHIFT+code:13", hl.dsp.window.move({ workspace = 31, follow = false }))
hl.bind("SUPER+ALT+SHIFT+code:14", hl.dsp.window.move({ workspace = 41, follow = false }))
hl.bind("SUPER+ALT+SHIFT+code:15", hl.dsp.window.move({ workspace = 51, follow = false }))
hl.bind("SUPER+ALT+SHIFT+code:16", hl.dsp.window.move({ workspace = 61, follow = false }))
hl.bind("SUPER+ALT+SHIFT+code:17", hl.dsp.window.move({ workspace = 71, follow = false }))
hl.bind("SUPER+ALT+SHIFT+code:18", hl.dsp.window.move({ workspace = 81, follow = false }))
hl.bind("SUPER+ALT+SHIFT+code:19", hl.dsp.window.move({ workspace = 91, follow = false }))

hl.bind(
	"SUPER+home",
	layout_bind({
		scrolling = hl.dsp.window.cycle_next(),
		dwindle = hl.dsp.window.cycle_next(),
		monocle = hl.dsp.layout("cyclenext"),
		master = hl.dsp.window.cycle_next(),
	}),
	{ description = "Cycle Next" }
)
hl.bind(
	"SUPER+end",
	layout_bind({
		scrolling = hl.dsp.window.cycle_next({ next = false }),
		dwindle = hl.dsp.window.cycle_next({ next = false }),
		monocle = hl.dsp.layout("cycleprev"),
		master = hl.dsp.window.cycle_next({ next = false }),
	}),
	{ description = "Cycle Prev" }
)

hl.bind("SUPER+SHIFT+G", hl.dsp.group.toggle(), { description = "Toggle Group" })
hl.bind("SUPER+insert", hl.dsp.group.next(), { description = "Active Group Next" })
hl.bind("SUPER+delete", hl.dsp.group.prev(), { description = "Active Group Prev" })

hl.bind("SUPER+CTRL+L", hl.dsp.exec_cmd("swaylock"), { description = "Lock Screen (swaylock)" })
hl.bind("SUPER+ALT+L", hl.dsp.exec_cmd("hyprlock"), { description = "Lock Screen (hyprlock)" })

hl.bind("SUPER+SHIFT+Tab", function()
	local layouts = { "scrolling", "dwindle", "master", "monocle" }
	local workspace = hl.get_active_workspace()
	if hl.get_active_special_workspace() then
		workspace = hl.get_active_special_workspace()
	end

	local next_layout = "dwindle"

	if not workspace then
		return
	end

	for i = 1, #layouts do
		if layouts[i] == workspace.tiled_layout then
			local next_layout_idx = (i % #layouts) + 1
			next_layout = layouts[next_layout_idx]
			break
		end
	end

	if workspace.special then
		hl.workspace_rule({ workspace = tostring(workspace.name), layout = next_layout })
	else
		hl.workspace_rule({ workspace = tostring(workspace.id), layout = next_layout })
	end

	hl.notification.create({
		text = next_layout,
		timeout = 3000,
		icon = "ok",
	})
end)

hl.bind("SUPER+Z", function()
	-- local window = hl.get_window()
	hl.dsp.window.float()
	-- hl.notification({
	-- 	text = window,
	-- 	timeout = 3000,
	-- 	icon = "ok",
	-- })
end)
