local awful = require("awful")
local wibox = require("wibox")
local gshape = require("gears.shape")
local gmatrix = require("gears.matrix")
local ipairs = ipairs
local table = table
local capi = { mouse = mouse }

local _ui = {}

function _ui.colorize_text(text, color)
	return "<span foreground='" .. color .. "'>" .. text .. "</span>"
end

function _ui.add_hover_cursor(w, hover_cursor)
	local original_cursor = "left_ptr"

	w:connect_signal("mouse::enter", function()
		local widget = capi.mouse.current_wibox
		if widget then
			widget.cursor = hover_cursor
		end
	end)

	w:connect_signal("mouse::leave", function()
		local widget = capi.mouse.current_wibox
		if widget then
			widget.cursor = original_cursor
		end
	end)
end

function _ui.vertical_pad(height)
	return wibox.widget({
		forced_height = height,
		layout = wibox.layout.fixed.vertical,
	})
end

-- add a list of buttons using :add_button to `widget`.
function _ui.add_buttons(widget, buttons)
    for _, button in ipairs(buttons) do
        widget:add_button(button)
    end
end

function _ui.horizontal_pad(width)
	return wibox.widget({
		forced_width = width,
		layout = wibox.layout.fixed.horizontal,
	})
end

function _ui.rrect(radius)
	return function(cr, width, height)
		gshape.rounded_rect(cr, width, height, radius)
	end
end

-- trim strings
function _ui.trim(input)
    local result = input:gsub("%s+", "")
    return string.gsub(result, "%s+", "")
end

-- capitalize a string
function _ui.capitalize (txt)
    return string.upper(string.sub(txt, 1, 1))
        .. string.sub(txt, 2, #txt)
end

function _ui.pie(width, height, start_angle, end_angle, radius)
	return function(cr)
		gshape.pie(cr, width, height, start_angle, end_angle, radius)
	end
end

function _ui.prgram(height, base)
	return function(cr, width)
		gshape.parallelogram(cr, width, height, base)
	end
end

function _ui.prrect(radius, tl, tr, br, bl)
	return function(cr, width, height)
		gshape.partially_rounded_rect(cr, width, height, tl, tr, br, bl, radius)
	end
end

function _ui.custom_shape(cr, width, height)
	cr:move_to(0, height / 25)
	cr:line_to(height / 25, 0)
	cr:line_to(width, 0)
	cr:line_to(width, height - height / 25)
	cr:line_to(width - height / 25, height)
	cr:line_to(0, height)
	cr:close_path()
end

-- apply a margin container to a given widget
function _ui.apply_margin(widget, opts)
	return wibox.widget({
		widget,
		margins = opts.margins,
		left = opts.left,
		right = opts.right,
		top = opts.top,
		bottom = opts.bottom,
		widget = wibox.container.margin,
	})
end


local function _get_widget_geometry(_hierarchy, widget)
	local width, height = _hierarchy:get_size()
	if _hierarchy:get_widget() == widget then
		-- Get the extents of this widget in the device space
		local x, y, w, h = gmatrix.transform_rectangle(_hierarchy:get_matrix_to_device(), 0, 0, width, height)
		return { x = x, y = y, width = w, height = h, hierarchy = _hierarchy }
	end

	for _, child in ipairs(_hierarchy:get_children()) do
		local ret = _get_widget_geometry(child, widget)
		if ret then
			return ret
		end
	end
end

function _ui.get_widget_geometry(wibox, widget)
	return _get_widget_geometry(wibox._drawable._widget_hierarchy, widget)
end

function _ui.screen_mask(s, bg)
	local mask = wibox({
		visible = false,
		ontop = true,
		type = "splash",
		screen = s,
	})
	awful.placement.maximize(mask)
	mask.bg = bg
	return mask
end

return _ui
