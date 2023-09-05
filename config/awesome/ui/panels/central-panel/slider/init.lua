local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local brightness = require(... .. "./brightness")
local volume = require(... .. "./volume")
local mic = require(... .. "./mic")

return wibox.widget({
	{
		{
			{
				brightness,
				volume,
				mic,
				--spacing = dpi(5),
				layout = wibox.layout.fixed.vertical,
			},
			margins = { top = dpi(7), bottom = dpi(7), left = dpi(12), right = dpi(10) },
			widget = wibox.container.margin,
		},
		widget = wibox.container.background,
		forced_height = dpi(150),
		forced_width = dpi(320),
		bg = beautiful.widget_bg,
		shape = helpers.ui.rrect(beautiful.border_radius),
	},
	margins = dpi(6),
	color = "#FF000000",
	widget = wibox.container.margin,
})
