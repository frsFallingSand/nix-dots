local M = {}

-- 配置参数
local TARGET_MAX_RR = 144.0 -- 目标最高刷新率
local RR_EPSILON = 0.5 -- 浮点容差：用于包容 144.001Hz 等硬件微小偏差

---格式化刷新率（剔除末尾无效的 0 和多余小数点，如 144.000 -> 144, 143.910 -> 143.91）
local function format_rr(rr)
	local str = string.format("%.3f", rr)
	str = str:gsub("%.?0+$", "")
	return str
end

---获取显示器的所有可用模式（兼容性封装）
local function get_available_modes(mon)
	-- 1. 优先使用 Hyprland 新版 Lua 原生属性 available_modes
	if mon.available_modes and #mon.available_modes > 0 then
		return mon.available_modes
	end

	-- 2. 兼容回退：若当前版本的 Lua 接口未直接挂载 available_modes，通过 hyprctl 纯文本解析
	local modes = {}
	local handle = io.popen("hyprctl monitors all")
	if handle then
		local content = handle:read("*a")
		handle:close()

		local in_target_mon = false
		for line in content:gmatch("[^\r\n]+") do
			local mon_name = line:match("^Monitor%s+([^%s%(]+)")
			if mon_name then
				in_target_mon = (mon_name == mon.name)
			elseif in_target_mon and line:match("availableModes:") then
				local modes_str = line:match("availableModes:%s*(.*)")
				for w, h, rr in modes_str:gmatch("(%d+)x(%d+)@([%d%.]+)Hz") do
					table.insert(modes, {
						width = tonumber(w),
						height = tonumber(h),
						refresh_rate = tonumber(rr),
					})
				end
				break
			end
		end
	end
	return modes
end

---核心逻辑：选出最高分辨率下符合刷新率要求的最佳模式
local function select_best_mode(modes)
	if not modes or #modes == 0 then
		return nil
	end

	-- 规则 1：能用高的分辨率就用高的分辨率（以像素总面积为准，面积相同按宽度优先）
	local best_w, best_h = 0, 0
	for _, m in ipairs(modes) do
		local area = m.width * m.height
		local best_area = best_w * best_h
		if area > best_area or (area == best_area and m.width > best_w) then
			best_w = m.width
			best_h = m.height
		end
	end

	-- 提取所有处于该最高分辨率下的模式
	local candidates = {}
	for _, m in ipairs(modes) do
		if m.width == best_w and m.height == best_h then
			table.insert(candidates, m)
		end
	end

	if #candidates == 0 then
		return nil
	end

	-- 规则 2：能用高的刷新率就用高的刷新率；如果超过 144，使用 <= 144 的最大值
	-- 判断是否在 <= 144Hz 范围内（加入 RR_EPSILON 容忍 144.001 等小数）
	local function is_within_limit(rr)
		return rr <= (TARGET_MAX_RR + RR_EPSILON)
	end

	local best_mode = nil
	for _, m in ipairs(candidates) do
		if is_within_limit(m.refresh_rate) then
			if not best_mode or m.refresh_rate > best_mode.refresh_rate then
				best_mode = m
			end
		end
	end

	-- 兜底逻辑：若该屏幕只支持高于 144Hz 的模式（无低档刷新率），退而取候选里的最低刷新率
	if not best_mode then
		for _, m in ipairs(candidates) do
			if not best_mode or m.refresh_rate < best_mode.refresh_rate then
				best_mode = m
			end
		end
	end

	return best_mode
end

---应用显示器设置
local function apply_monitor_config()
	local monitors = hl.get_monitors() or {}

	for _, mon in ipairs(monitors) do
		local modes = get_available_modes(mon)
		local best = select_best_mode(modes)

		if best then
			-- 检查当前是否已经是目标模式，避免重复应用导致屏幕闪烁或死循环
			local cur_rr = mon.refresh_rate or 0
			local rr_diff = math.abs(cur_rr - best.refresh_rate)

			if mon.width ~= best.width or mon.height ~= best.height or rr_diff >= 0.1 then
				local mode_str = string.format("%dx%d@%s", best.width, best.height, format_rr(best.refresh_rate))

				-- 调用 Hyprland Lua 原生监视器配置接口
				hl.monitor({
					output = mon.name,
					mode = mode_str,
					position = "auto", -- 可根据需要改为 "0x0" 等固定坐标
					scale = 1, -- 可根据需要改为 "auto" 或指定浮点缩放比例
				})
			end
		end
	end
end

-- 1. 启动/加载时立即应用配置
apply_monitor_config()

-- 2. 监听热插拔与配置重载事件，动态自动配置新接入的显示器
hl.on("monitor.added", apply_monitor_config)
hl.on("config.reloaded", apply_monitor_config)

return M
