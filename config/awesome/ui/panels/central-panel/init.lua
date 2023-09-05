local awful = require("awful")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local wibox = require("wibox")
local helpers = require("helpers")
local gears = require("gears")
local icons = require("icons")
local widgets = require("ui.widgets")
local focused = awful.screen.focused()

--- AWESOME Central panel
--- ~~~~~~~~~~~~~~~~~~~~~

return function(s)
    --- Header
    local function header()
        --- username
        local profile_name = wibox.widget({
            widget = wibox.widget.textbox,
            markup = "Ryan Hidayat",
            font = beautiful.font_name .. "Bold 13",
            valign = "center"
        })

        awful.spawn.easy_async_with_shell([[
		sh -c '
		fullname="$(getent passwd `whoami` | cut -d ':' -f 5 | cut -d ',' -f 1 | tr -d "\n")"
		if [ -z "$fullname" ];
		then
			printf "$(whoami)@$(hostname)"
		else
			printf "$fullname"
		fi
		'
		]], function(stdout)
            local stdout = stdout:gsub("%\n", "")
            profile_name:set_markup(stdout)
        end)

        --- uptime
        local uptime_time = wibox.widget({
            widget = wibox.widget.textbox,
            markup = "up 3 hours, 33 minutes",
            font = beautiful.font_name .. "Medium 10",
            valign = "center"
        })

        local update_uptime = function()
            awful.spawn.easy_async_with_shell("uptime -p", function(stdout)
                local uptime = stdout:gsub("%\n", "")
                uptime_time:set_markup(uptime)
            end)
        end

        gears.timer({
            timeout = 60,
            autostart = true,
            call_now = true,
            callback = function() update_uptime() end
        })

        local dashboard_text = wibox.widget({
            {
                {
                    image = beautiful.pfp,
                    resize = true,
                    halign = "center",
                    clip_shape = gears.shape.circle,
                    valign = "center",
                    widget = wibox.widget.imagebox
                },
                shape = gears.shape.circle,
                widget = wibox.container.background
            },
            strategy = "exact",
            height = dpi(46),
            width = dpi(46),
            widget = wibox.container.constraint
        })

        local widget = wibox.widget({
            -- {
            -- dashboard_text,
            -- nil,
            -- search_box(),
            -- layout = wibox.layout.align.horizontal,
            -- },
            -- margins = dpi(10),
            -- widget = wibox.container.margin,
            -- })
            {
                layout = wibox.layout.align.horizontal,
                { --- Left
                    dashboard_text,
                    spacing = dpi(8),
                    widget = wibox.container.margin
                },
                { --- Middle
                    {
                        {
                            widget = wibox.container.scroll.horizontal,
                            step_function = wibox.container.scroll
                                .step_functions.waiting_nonlinear_back_and_forth,
                            fps = 60,
                            speed = 75,
                            profile_name
                        },
                        {
                            widget = wibox.container.scroll.horizontal,
                            step_function = wibox.container.scroll
                                .step_functions.waiting_nonlinear_back_and_forth,
                            fps = 60,
                            speed = 75,
                            uptime_time
                        },
                        forced_width = dpi(30),
                        layout = wibox.layout.fixed.vertical,
                        spacing = dpi(2)
                    },

                    layout = wibox.layout.flex.horizontal
                },
                {
                    {
                        widgets.button.text.normal({
                            forced_width = dpi(40),
                            forced_height = dpi(40),
                            font = "icomoon bold ",
                            shape = gears.shape.circle,
                            text_normal_bg = beautiful.accent,
                            normal_bg = beautiful.one_bg3,
                            normal_shape = gears.shape.circle,
                            text = "",
                            size = 15,
                            on_release = function()
                                lock_screen_show()
                                awesome.emit_signal("central_panel::toggle",
                                                    focused)
                            end
                        }),
                        widgets.button.text.normal({
                            forced_width = dpi(40),
                            forced_height = dpi(40),
                            font = "icomoon bold ",
                            text_normal_bg = beautiful.color1,
                            normal_bg = beautiful.one_bg3,
                            normal_shape = gears.shape.circle,
                            text = "",
                            size = 15,
                            on_release = function()
                                awesome.emit_signal("module::exit_screen:show")
                                awesome.emit_signal("central_panel::toggle",
                                                    focused)
                            end
                        }),
                        spacing = dpi(10),
                        layout = wibox.layout.fixed.horizontal
                    },
                    widget = wibox.container.background
                },
                top = dpi(6),
                bottom = dpi(6),
                right = dpi(12),
                widget = wibox.container.margin
            },
            bg = beautiful.widget_bg,
            shape = helpers.ui.prrect(beautiful.border_radius, true, true,
                                      false, false),
            widget = wibox.container.background
        })

        return widget
    end

    local function search_box()
        local search_icon = wibox.widget({
            font = "icomoon bold 12",
            align = "center",
            valign = "center",
            widget = wibox.widget.textbox()
        })

        local reset_search_icon = function()
            search_icon.markup = helpers.ui.colorize_text("",
                                                          beautiful.accent)
        end
        reset_search_icon()

        local search_text = wibox.widget({
            --- markup = helpers.ui.colorize_text("Search", beautiful.color8),
            align = "center",
            valign = "center",
            font = beautiful.font,
            widget = wibox.widget.textbox()
        })

        local search = wibox.widget({
            {
                {
                    {
                        search_icon,
                        {
                            search_text,
                            top = dpi(2),
                            bottom = dpi(2),
                            widget = wibox.container.margin
                        },
                        layout = wibox.layout.fixed.horizontal
                    },
                    left = dpi(5),
                    widget = wibox.container.margin
                },
                forced_height = dpi(30),
                forced_width = dpi(30),
                shape = gears.shape.rounded_bar,
                bg = beautiful.widget_bg,
                widget = wibox.container.background()
            },
            margins = dpi(6),
            color = "#FF000000",
            widget = wibox.container.margin
        })

        local function generate_prompt_icon(icon, color)
            return "<span font='icomoon 12' foreground='" .. color .. "'>" ..
                       icon .. "</span> "
        end

        local function activate_prompt(action)
            search_icon.visible = false
            local prompt
            if action == "run" then
                prompt = generate_prompt_icon("", beautiful.accent)
            elseif action == "web_search" then
                prompt = generate_prompt_icon("", beautiful.accent)
            end
            helpers.misc.prompt(action, search_text, prompt,
                                function() search_icon.visible = true end)
        end

        search:buttons(gears.table.join(awful.button({}, 1, function()
            activate_prompt("run")
        end), awful.button({}, 3, function()
            activate_prompt("web_search")
        end)))

        return search
    end

    s.awesomewm = wibox.widget({
        {
            {
                image = gears.color.recolor_image(icons.debian_logo,
                                                  beautiful.accent),
                resize = true,
                halign = "center",
                valign = "center",
                forced_height = dpi(80),
                widget = wibox.widget.imagebox
            },
            strategy = "exact",
            widget = wibox.container.constraint
        },
        -- margins = dpi(10),
        widget = wibox.container.margin
    })

    --- Widgets
    -- s.stats = require("ui.panels.central-panel.stats")
    -- s.user_profile = require("ui.panels.central-panel.user-profile")
    s.quick_settings = require("ui.panels.central-panel.quick-settings")
    s.slider = require("ui.panels.central-panel.slider")
    s.music_player = require("ui.panels.central-panel.music-player")

    s.central_panel = awful.popup({
        type = "dock",
        screen = s,
        minimum_height = dpi(670),
        maximum_height = dpi(670),
        minimum_width = dpi(340),
        maximum_width = dpi(340),
        bg = beautiful.transparent,
        ontop = true,
        visible = false,
        placement = function(w)
            awful.placement.top_left(w, {
                margins = {
                    top = beautiful.wibar_height + dpi(7),
                    bottom = dpi(5),
                    left = dpi(5),
                    right = dpi(5)
                }
            })
        end,
        widget = {
            {
                {
                    header(),
                    margins = {
                        top = dpi(5),
                        bottom = dpi(5),
                        right = dpi(10),
                        left = dpi(10)
                    },
                    widget = wibox.container.margin
                },
                {
                    {
                        {
                            nil,
                            {
                                {
                                    -- s.user_profile,
                                    search_box(),
                                    s.quick_settings,
                                    s.slider,
                                    -- s.stats,
                                    s.music_player,
                                    s.awesomewm,
                                    layout = wibox.layout.fixed.vertical
                                },
                                -- {
                                -- s.stats,
                                -- s.music_player,
                                -- s.awesomewm,
                                -- layout = wibox.layout.fixed.vertical
                                -- },
                                layout = wibox.layout.align.horizontal
                            },
                            layout = wibox.layout.align.vertical
                        },
                        margins = dpi(10),
                        widget = wibox.container.margin
                    },
                    shape = helpers.ui.prrect(beautiful.border_radius * 2, true,
                                              true, false, false),
                    bg = beautiful.wibar_bg,
                    widget = wibox.container.background
                },
                layout = wibox.layout.align.vertical
            },
            bg = beautiful.widget_bg,
            shape = helpers.ui.rrect(beautiful.border_radius),
            widget = wibox.container.background
        }
    })

    --- Toggle container visibility
    awesome.connect_signal("central_panel::toggle", function(scr)
        if scr == s then
            s.central_panel.visible = not s.central_panel.visible
        end
    end)
end
