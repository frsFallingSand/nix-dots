local GPU_PCI = "0000:01:00.0"

local DEDICATED_MONITOR = "DP-3"
local FALLBACK_MONITOR = "HDMI-A-1"

local current_mode = nil
local pending = false

-- GPU STATE

local function read_driver_name()
	local p = io.popen("readlink -f /sys/bus/pci/devices/" .. GPU_PCI .. "/driver")

	if not p then
		return nil
	end

	local output = p:read("*a")
	p:close()

	if not output then
		return nil
	end

	output = output:gsub("%s+", "")

	return output:match("([^/]+)$")
end

local function vfio_active()
	return read_driver_name() == "vfio-pci"
end

-- WORKSPACE

local function goto_workspace_1()
	hl.dispatch(hl.dsp.focus({
		workspace = 1,
	}))
end

-- MODES

local function apply_host_mode()
	if current_mode == "host" then
		return
	end

	current_mode = "host"

	print("[VFIO] host mode")

	hl.monitor({
		output = FALLBACK_MONITOR,
		disabled = true,
	})

	hl.workspace_rule({
		workspace = "1",
		monitor = DEDICATED_MONITOR,
		default = true,
	})

	hl.workspace_rule({
		workspace = "2",
		monitor = DEDICATED_MONITOR,
	})

	hl.workspace_rule({
		workspace = "3",
		monitor = DEDICATED_MONITOR,
	})

	goto_workspace_1()

	hl.notification.create({
		text = "Host mode",
		timeout = 3000,
		icon = "ok",
	})
end

local function apply_guest_mode()
	if current_mode == "guest" then
		return
	end

	current_mode = "guest"

	print("[VFIO] guest mode")

	hl.monitor({
		output = FALLBACK_MONITOR,
		mode = "preferred",
		position = "auto",
		scale = 1,
	})

	hl.workspace_rule({
		workspace = "1",
		monitor = FALLBACK_MONITOR,
		default = true,
	})

	hl.workspace_rule({
		workspace = "2",
		monitor = FALLBACK_MONITOR,
	})

	hl.workspace_rule({
		workspace = "3",
		monitor = FALLBACK_MONITOR,
	})

	goto_workspace_1()

	hl.notification.create({
		text = "Guest mode",
		timeout = 3000,
		icon = "ok",
	})
end

-- MAIN

local function reconfigure()
	if vfio_active() then
		apply_guest_mode()
	else
		apply_host_mode()
	end
end

local function schedule_reconfigure()
	if pending then
		return
	end

	pending = true

	hl.timer(1000, function()
		pending = false
		reconfigure()
	end)
end

-- EVENTS

reconfigure()

hl.on("monitor.added", schedule_reconfigure)
hl.on("monitor.removed", schedule_reconfigure)

hl.bind("SUPER+SHIFT+F12", function()
	hl.notification.create({
		text = "Manually Triggered Detect",
		timeout = 3000,
		icon = "ok",
	})
	reconfigure()
end)
