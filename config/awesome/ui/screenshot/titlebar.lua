local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")

-- Screenshot header
local ss_text = wibox.widget {
    {
        {
            markup = helpers.ui.colorize_text("󰄄  Screenshot",
                                              beautiful.bg_normal),
            font = beautiful.jet .. "16",
            align = "center",
            valign = "center",
            widget = wibox.widget.textbox
        },
        widget = wibox.container.margin,
        top = dpi(5),
        bottom = dpi(5),
        right = dpi(5),
        left = dpi(5)
    },
    widget = wibox.container.background,
    bg = beautiful.accent,
    forced_width = dpi(170),
    forced_height = dpi(36),
    shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, true, true, true,
                                           true, 5)
    end

}

-- Screenreconrd header
local sr_text = wibox.widget {
    {
        {
            -- text = user.name,
            markup = '<span color="' .. beautiful.accent ..
                '" font="JetBrainsMono Nerd Font 15">' .. "  Screen record" ..
                '</span>',
            font = "JetBrainsMono Nerd Font 14",
            widget = wibox.widget.textbox,
            fg = beautiful.fg_normal
        },
        widget = wibox.container.margin,
        top = dpi(5),
        bottom = dpi(5),
        right = dpi(5),
        left = dpi(9)
    },
    widget = wibox.container.background,
    bg = beautiful.widget_bg,
    forced_width = dpi(190),
    forced_height = dpi(36),
    shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, false, true, true,
                                           false, 5)
    end

}

local close = wibox.widget({
    markup = helpers.ui.colorize_text("󰅙", beautiful.color1),
    font = beautiful.material_icons .. " 22",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
})

-- Main titlebar
local titlebar = wibox.widget {
    {
        {
            {
                ss_text,
                -- sr_text,
                layout = wibox.layout.fixed.horizontal
            },
            widget = wibox.container.margin,
            top = dpi(9),
            bottom = dpi(9),
            left = dpi(24),
            right = dpi(3)
        },
        {
            close,
            widget = wibox.container.margin,
            top = dpi(0),
            bottom = dpi(0),
            right = dpi(0),
            left = dpi(100 + 193)
        },
        layout = wibox.layout.fixed.horizontal
    },
    widget = wibox.container.background,
    bg = beautiful.widget_bg,
    --forced_width = dpi(100)
}

-- Hover effects on close button
close:connect_signal("mouse::enter", function()
    close:set_markup_silently(helpers.ui.colorize_text("󰅙", beautiful.color11))
end)

close:connect_signal("mouse::leave", function()
    close:set_markup_silently(helpers.ui.colorize_text("󰅙", beautiful.color1))
end)

close:connect_signal("button::press", function()
    close:set_markup_silently(helpers.ui.colorize_text("󰅙", beautiful.color1))
end)

close:connect_signal("button::release", function()
    close:set_markup_silently(helpers.ui.colorize_text("󰅙", beautiful.color11))
end)

close:connect_signal("button::release", function(_, _, _, button)
    if button == 1 then awesome.emit_signal("ui::screenshot") end
end)

return titlebar
