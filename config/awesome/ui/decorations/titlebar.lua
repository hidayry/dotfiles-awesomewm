local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")
local decorations = require("ui.decorations")

--- MacOS like window decorations
--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

--- Disable this if using `picom` to round your corners
--- decorations.enable_rounding()

--- Tabbed
local bling = require("modules.bling")
local tabbed_misc = bling.widget.tabbed_misc

--- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    if c.requests_no_titlebar then return end
    -- buttons for the titlebar
    local buttons = gears.table.join(awful.button({}, 1, function()
        c:emit_signal("request::activate", "titlebar", {raise = true})
        awful.mouse.client.move(c)
    end), awful.button({}, 3, function()
        c:emit_signal("request::activate", "titlebar", {raise = true})
        awful.mouse.client.resize(c)
    end))
    local top_titlebar = awful.titlebar(c, {
        position = "left",
        size = 36,
        font = beautiful.font_name .. "Medium 12",
        bg = beautiful.titlebar_bg
    })

    -- buttons for the titlebar
    local buttons = gears.table.join(awful.button({}, 1, function()
        client.focus = c
        c:raise()
        awful.mouse.client.move(c)
    end), awful.button({}, 3, function()
        client.focus = c
        c:raise()
        awful.mouse.client.resize(c)
    end))

    top_titlebar:setup({
        {
            {
                -- Left
                helpers.ui.apply_margin(awful.titlebar.widget.closebutton(c), {
                    left = 7,
                    right = 7,
                    top = 10,
                    bottom = 5
                }),
                helpers.ui.apply_margin(
                    awful.titlebar.widget.maximizedbutton(c),
                    {left = 7, right = 7, top = 4, bottom = 5}),
                helpers.ui.apply_margin(awful.titlebar.widget.minimizebutton(c),
                                        {
                    left = 7,
                    right = 7,
                    top = 4,
                    bottom = 5
                }),
                spacing = 0,
                layout = wibox.layout.fixed.vertical()
            },
            widget = wibox.container.margin,
            top = 1,
            bottom = 0,
            right = 5,
            left = 2
        },
        {
            -- Middle
            --     {
            --     -- Title
            --         align  = 'center',
            --         widget = awful.titlebar.widget.titlewidget(c)
            --     },
            buttons = buttons,
            layout = wibox.layout.flex.horizontal
        },
        {
            -- Right
            {
                helpers.ui.apply_margin(awful.titlebar.widget.stickybutton(c), {
                    left = 7,
                    right = 7,
                    top = 4,
                    bottom = 5,
                }),
                helpers.ui.apply_margin(awful.titlebar.widget.ontopbutton(c), {
                    left = 7,
                    right = 7,
                    top = 4,
                    bottom = 10
                }),
                layout = wibox.layout.fixed.vertical()
            },
            widget = wibox.container.margin,
            top = 0,
            bottom = 1,
            right = 5,
            left = 2
        },
        layout = wibox.layout.align.vertical
        -- },
        -- bg = beautiful.color20,
        -- shape = helpers.ui.rrect(dpi(30)),
        -- widget = wibox.container.background,
    })

    -- awful
    ---	.titlebar(c, {
    --		position = "bottom",
    --		size = dpi(18),
    --		bg = beautiful.transparent,
    --	})
    --	:setup({
    --		bg = beautiful.titlebar_bg,
    --		shape = helpers.ui.prrect(beautiful.border_radius, false, false, true, true),
    --		widget = wibox.container.background,
    --	})
end)
