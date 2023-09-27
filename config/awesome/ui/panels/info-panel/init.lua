local awful = require("awful")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local wibox = require("wibox")
local helpers = require("helpers")
local gears = require("gears")

--- Information Panel
--- ~~~~~~~~~~~~~~~~~

return function(s)
    --- Date
    local hours = wibox.widget.textclock("%H")
    local minutes = wibox.widget.textclock("%M")

    local date = {
        font = beautiful.font_name .. "Bold 12",
        align = "center",
        valign = "center",
        widget = wibox.widget.textclock("%A, %d %b %Y")
    }

    local make_little_dot = function()
        return wibox.widget({
            bg = beautiful.accent,
            forced_width = dpi(10),
            forced_height = dpi(10),
            shape = gears.shape.circle,
            widget = wibox.container.background
        })
    end

    local time = {
        {
            font = beautiful.font_name .. "Bold 40",
            align = "right",
            valign = "top",
            widget = hours
        },
        {
            nil,
            {
                make_little_dot(),
                make_little_dot(),
                spacing = dpi(10),
                widget = wibox.layout.fixed.vertical
            },
            expand = "none",
            widget = wibox.layout.align.vertical
        },
        {
            font = beautiful.font_name .. "Bold 40",
            align = "left",
            valign = "top",
            widget = minutes
        },
        spacing = dpi(20),
        layout = wibox.layout.fixed.horizontal
    }

    --- Calendar
    s.calendar = require("ui.panels.info-panel.calendar")()
    s.stats = require("ui.panels.info-panel.stats")

    local calendar = wibox.widget({
        {s.calendar, margins = dpi(16), widget = wibox.container.margin},
        bg = beautiful.widget_bg,
        shape = helpers.ui.rrect(beautiful.border_radius),
        widget = wibox.container.background
    })

    --- Weather
    -- s.weather = require("ui.panels.info-panel.weather")
    -- local weather = wibox.widget({
    -- {
    -- s.weather,
    -- margins = dpi(16),
    -- widget = wibox.container.margin,
    -- },
    -- bg = beautiful.one_bg3,
    -- shape = helpers.ui.rrect(beautiful.border_radius),
    -- widget = wibox.container.background,
    -- })

    s.info_panel = awful.popup({
        type = "dock",
        screen = s,
        -- minimum_height = s.geometry.height - (beautiful.wibar_height + dpi(10)),
        -- maximum_height = s.geometry.height - (beautiful.wibar_height + dpi(10)),
        minimum_height = dpi(670),
        maximum_height = dpi(670),
        minimum_width = dpi(310),
        maximum_width = dpi(310),
        bg = beautiful.transparent,
        ontop = true,
        visible = false,
        placement = function(w)
            awful.placement.top_right(w, {
                honor_workarea = true,
                margins = {top = beautiful.useless_gap * 2, right = dpi(5)}
            })
        end,
        widget = {
            {
                { ----------- TOP GROUP -----------
                    {
                        helpers.ui.vertical_pad(dpi(5)),
                        {
                            nil,
                            time,
                            expand = "none",
                            layout = wibox.layout.align.horizontal
                        },
                        helpers.ui.vertical_pad(dpi(5)),
                        date,
                        helpers.ui.vertical_pad(dpi(10)),
                        layout = wibox.layout.fixed.vertical
                    },
                    layout = wibox.layout.fixed.vertical
                },
                { ----------- MIDDLE GROUP -----------
                    {
                        nil,
                        {
                            helpers.ui.vertical_pad(dpi(5)),
                            {
                                nil,
                                calendar,
                                expand = "none",
                                forced_height = dpi(290),
                                layout = wibox.layout.align.horizontal
                            },
                            layout = wibox.layout.fixed.vertical
                        },
                        nil,
                        expand = "none",
                        layout = wibox.layout.align.vertical
                    },
                    shape = helpers.ui.prrect(beautiful.border_radius * 2, true,
                                              true, true, true),
                    bg = beautiful.wibar_bg,
                    widget = wibox.container.background
                },
                { ----------- BOTTOM GROUP -----------
                    {
                        helpers.ui.vertical_pad(dpi(2)),
                        {
                            nil,
                            s.stats,
                            expand = "none",
                            layout = wibox.layout.align.horizontal
                        },
                        helpers.ui.vertical_pad(dpi(5)),
                        layout = wibox.layout.fixed.vertical
                    },
                    bg = beautiful.wibar_bg,
                    widget = wibox.container.background
                },
                layout = wibox.layout.align.vertical
            },
            shape = helpers.ui.prrect(beautiful.border_radius * 2, true, true,
                                      true, true),
            bg = beautiful.wibar_bg,
            widget = wibox.container.background
        }
    })

    --- Toggle container visibility
    awesome.connect_signal("info_panel::toggle", function(scr)
        if scr == s then s.info_panel.visible = not s.info_panel.visible end
    end)
end
