local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local helpers = require("helpers")
local widgets = require("ui.widgets")
local wbutton = require("ui.widgets.button")
local animation = require("modules.animation")
local apps = require("configuration.apps")
local separator = wibox.widget.textbox("   ")
local separator2 = wibox.widget.textbox("    ")

local ss_tool = require("ui.screenshot.main")
--- Modern Top Panel
--- ~~~~~~~~~~~~~~~~~~~

return function(s)
    --- Widgets
    --- ~~~~~~~~~~
    s.clock = require("ui.panels.top-panel.clock")(s)
    s.network = require("ui.panels.top-panel.network")()
    local tags = require("ui.panels.top-panel.tag")(s)

    --- Animated tag list
    --- ~~~~~~~~~~~~~~~~~
    local screenshot = wibox.widget {
        {
            {
                markup = helpers.ui.colorize_text("", beautiful.color7),
                align = "center",
                valign = "center",
                font = beautiful.icon_font .. " 14",
                widget = wibox.widget.textbox
            },
            left = dpi(6),
            right = dpi(6),
            top = dpi(6),
            bottom = dpi(6),
            widget = wibox.container.margin
        },
        bg = beautiful.wibar_bg,
        shape = gears.shape.rounded_rect,
        widget = wibox.container.background
    }

    screenshot:connect_signal("button::press", function(_, _, _, button)
        if button == 1 then
            -- awful.spawn.with_shell(
            --   'scrot /tmp/screenshot.png && convert /tmp/screenshot.png -resize 20% /tmp/resized_screenshot.png && dunstify -i /tmp/resized_screenshot.png "Screenshot Captured" && cp /tmp/screenshot.png ~/Pictures/file1_`date +"%Y%m%d_%H%M%S"`.png && rm /tmp/resized_screenshot.png && rm /tmp/screenshot.png'
            -- )
            ss_tool.visible = not ss_tool.visible
        elseif button == 3 then
            awful.spawn.with_shell(
                'scrot /tmp/screenshot.png && convert /tmp/screenshot.png -resize 20% /tmp/resized_screenshot.png && notify-send -a "Screen Captured" -i /tmp/resized_screenshot.png "Screenshot Captured" && cp /tmp/screenshot.png ~/Pictures/file1_`date +"%Y%m%d_%H%M%S"`.png && rm /tmp/resized_screenshot.png && rm /tmp/screenshot.png')
        end
    end)

    --- Taglist buttons
    local modkey = "Mod4"
    local taglist_buttons = gears.table.join(
                                awful.button({}, 1,
                                             function(t) t:view_only() end),
                                awful.button({modkey}, 1, function(t)
            if client.focus then client.focus:move_to_tag(t) end
        end), awful.button({}, 3, awful.tag.viewtoggle),
                                awful.button({modkey}, 3, function(t)
            if client.focus then client.focus:toggle_tag(t) end
        end), awful.button({}, 4, function(t)
            awful.tag.viewnext(t.screen)
        end), awful.button({}, 5, function(t)
            awful.tag.viewprev(t.screen)
        end))

    local function tag_list(s)
        local taglist = awful.widget.taglist({
            screen = s,
            filter = awful.widget.taglist.filter.all,
            layout = {layout = wibox.layout.fixed.horizontal},
            widget_template = {
                widget = wibox.container.margin,
                forced_width = dpi(40),
                forced_height = dpi(40),
                create_callback = function(self, c3, _)
                    local indicator = wibox.widget({
                        widget = wibox.container.place,
                        valign = "center",
                        {
                            widget = wibox.container.background,
                            forced_height = dpi(50),
                            shape = helpers.ui.rrect(dpi(50))
                        }
                    })

                    self.indicator_animation = animation:new({
                        duration = 0.125,
                        easing = animation.easing.linear,
                        update = function(self, pos)
                            indicator.children[1].forced_width = pos
                        end
                    })

                    self:set_widget(indicator)

                    if c3.selected then
                        self.widget.children[1].bg = beautiful.accent
                        self.indicator_animation:set(dpi(32))
                    elseif #c3:clients() == 0 then
                        self.widget.children[1].bg = beautiful.color10
                        self.indicator_animation:set(dpi(8))
                    else
                        self.widget.children[1].bg = beautiful.color11
                        self.indicator_animation:set(dpi(16))
                    end

                    --- Tag preview
                    self:connect_signal("mouse::enter", function()
                        if #c3:clients() > 0 then
                            awesome.emit_signal("bling::tag_preview::update", c3)
                            awesome.emit_signal(
                                "bling::tag_preview::visibility", s, true)
                        end
                    end)

                    self:connect_signal("mouse::leave", function()
                        awesome.emit_signal("bling::tag_preview::visibility", s,
                                            false)
                    end)
                end,
                update_callback = function(self, c3, _)
                    if c3.selected then
                        self.widget.children[1].bg = beautiful.accent
                        self.indicator_animation:set(dpi(32))
                    elseif #c3:clients() == 0 then
                        self.widget.children[1].bg = beautiful.color10
                        self.indicator_animation:set(dpi(8))
                    else
                        self.widget.children[1].bg = beautiful.color11
                        self.indicator_animation:set(dpi(16))
                    end
                end
            },
            buttons = taglist_buttons
        })

        local widget = widgets.button.elevated.state({
            normal_bg = beautiful.widget_bg,
            normal_shape = helpers.ui.rrect(dpi(50)),
            child = {
                taglist,
                margins = {left = dpi(5), right = dpi(5)},
                widget = wibox.container.margin
            }
            -- on_release = function()
            -- awesome.emit_signal("central_panel::toggle", s)
            -- end,
        })

        return wibox.widget({
            widget,
            margins = dpi(5),
            widget = wibox.container.margin
        })
    end

    --- Systray
    --- ~~~~~~~
    local function system_tray()
        local mysystray = wibox.widget.systray()
        mysystray.base_size = beautiful.systray_icon_size

        local widget = wibox.widget({
            widget = wibox.container.constraint,
            strategy = "max",
            width = dpi(0),
            {widget = wibox.container.margin, margins = dpi(10), mysystray}
        })

        local system_tray_animation = animation:new({
            easing = animation.easing.linear,
            duration = 0.125,
            update = function(self, pos) widget.width = pos end
        })

        local arrow = wbutton.text.state({
            text_normal_bg = beautiful.accent,
            normal_shape = gears.shape.circle,
            hover_shape = gears.shape.circle,
            press_shape = gears.shape.circle,
            normal_bg = beautiful.wibar_bg,
            font = beautiful.icon_font .. "Round ",
            size = 18,
            text = "",
            on_turn_on = function(self)
                system_tray_animation:set(400)
                self:set_text("")
            end,
            on_turn_off = function(self)
                system_tray_animation:set(0)
                self:set_text("")
            end
        })

        return wibox.widget({
            layout = wibox.layout.fixed.horizontal,
            arrow,
            widget
        })
    end

    --- Notif panel
    --- ~~~~~~~~~~~
    local function notif_panel()
        local icon = wibox.widget({
            markup = helpers.ui.colorize_text("󰂞", beautiful.fg_normal),
            align = "center",
            valign = "center",
            font = beautiful.material_icons .. " 14",
            widget = wibox.widget.textbox
        })

        local widget = wbutton.elevated.state({
            child = icon,
            normal_shape = gears.shape.circle,
            hover_shape = gears.shape.circle,
            press_shape = gears.shape.circle,
            normal_bg = beautiful.wibar_bg,
            on_release = function()
                awesome.emit_signal("notification_panel::toggle", s)
            end
        })

        return widget
    end

    -- clipboard
    local function clip()
        local clip_icon = wibox.widget({
            markup = helpers.ui.colorize_text("󰅎", beautiful.fg_normal),
            align = "center",
            valign = "center",
            font = beautiful.material_icons .. " 13",
            widget = wibox.widget.textbox
        })

        local widget = wbutton.elevated.state({
            child = clip_icon,
            normal_shape = gears.shape.circle,
            hover_shape = gears.shape.circle,
            press_shape = gears.shape.circle,
            normal_bg = beautiful.wibar_bg,
            on_release = function()
                awful.spawn(apps.default.clip, false)
            end
        })

        return widget
    end

    -- line
    local garis = wibox.widget({
        markup = helpers.ui.colorize_text("", beautiful.color7),
        align = "center",
        valign = "center",
        font = beautiful.icon_font .. " 14",
        widget = wibox.widget.textbox
    })

    -- controlwidget
    local function control()
        local clip_control = wibox.widget({
            markup = helpers.ui.colorize_text("󰒓", beautiful.accent),
            align = "center",
            valign = "center",
            font = beautiful.material_icons .. " 14",
            widget = wibox.widget.textbox
        })

        local widget = wbutton.elevated.state({
            child = clip_control,
            normal_shape = gears.shape.circle,
            hover_shape = gears.shape.circle,
            press_shape = gears.shape.circle,
            normal_bg = beautiful.wibar_bg,
            on_release = function()
                awesome.emit_signal("central_panel::toggle", s)
            end
        })

        return widget
    end

    -- powerbutton
    local function powerbutton()
        local power = wibox.widget({
            markup = helpers.ui.colorize_text("󰐥", beautiful.color1),
            align = "center",
            valign = "center",
            font = beautiful.material_icons .. " 16",
            widget = wibox.widget.textbox
        })

        local widget = wbutton.elevated.state({
            child = power,
            normal_shape = gears.shape.circle,
            hover_shape = gears.shape.circle,
            press_shape = gears.shape.circle,
            normal_bg = beautiful.wibar_bg,
            on_release = function()
                awesome.emit_signal("module::exit_screen:show")
            end
        })

        return widget
    end

    -- launcher
    local function launcher()
        local launc_icon = wibox.widget({
            markup = helpers.ui.colorize_text("󰣚", beautiful.accent),
            align = "center",
            valign = "center",
            font = beautiful.material_icons .. " 14",
            widget = wibox.widget.textbox
        })

        local widget = wbutton.elevated.state({
            child = launc_icon,
            normal_shape = gears.shape.circle,
            hover_shape = gears.shape.circle,
            press_shape = gears.shape.circle,
            normal_bg = beautiful.wibar_bg,
            on_release = function()
                awful.spawn(apps.default.launcher, false)
            end
        })

        return widget
    end

    -- terminal
    local function terminal()
        local term_icon = wibox.widget({
            markup = helpers.ui.colorize_text("󰆍", beautiful.fg_normal),
            align = "center",
            valign = "center",
            font = beautiful.material_icons .. " 14",
            widget = wibox.widget.textbox
        })

        local widget = wbutton.elevated.state({
            child = term_icon,
            normal_shape = gears.shape.circle,
            hover_shape = gears.shape.circle,
            press_shape = gears.shape.circle,
            normal_bg = beautiful.wibar_bg,
            on_release = function()
                awful.spawn(apps.default.terminal, false)
            end
        })

        return widget
    end

    -- neovim
    local function nvim()
        local vim_icon = wibox.widget({
            markup = helpers.ui.colorize_text("", beautiful.fg_normal),
            align = "center",
            valign = "center",
            font = beautiful.ios .. " 14",
            widget = wibox.widget.textbox
        })

        local widget = wbutton.elevated.state({
            child = vim_icon,
            normal_shape = gears.shape.circle,
            hover_shape = gears.shape.circle,
            press_shape = gears.shape.circle,
            normal_bg = beautiful.wibar_bg,
            on_release = function()
                awful.spawn(apps.default.text_editor, false)
            end
        })

        return widget
    end

    -- file browser
    local function files()
        local file_icon = wibox.widget({
            markup = helpers.ui.colorize_text("󰉋", beautiful.fg_normal),
            align = "center",
            valign = "center",
            font = beautiful.material_icons .. " 14",
            widget = wibox.widget.textbox
        })

        local widget = wbutton.elevated.state({
            child = file_icon,
            normal_shape = gears.shape.circle,
            hover_shape = gears.shape.circle,
            press_shape = gears.shape.circle,
            normal_bg = beautiful.wibar_bg,
            on_release = function()
                awful.spawn(apps.default.file_manager, false)
            end
        })

        return widget
    end

    -- vscode
    local function code()
        local code_icon = wibox.widget({
            markup = helpers.ui.colorize_text("󰘐", beautiful.fg_normal),
            align = "center",
            valign = "center",
            font = beautiful.material_icons .. " 14",
            widget = wibox.widget.textbox
        })

        local widget = wbutton.elevated.state({
            child = code_icon,
            normal_shape = gears.shape.circle,
            hover_shape = gears.shape.circle,
            press_shape = gears.shape.circle,
            normal_bg = beautiful.wibar_bg,
            on_release = function()
                awful.spawn(apps.default.code_editor, false)
            end
        })

        return widget
    end

    --- Layoutbox
    --- ~~~~~~~~~
    local function layoutbox()
        local layoutbox_buttons = gears.table.join( --- Left click
        awful.button({}, 1, function(c) awful.layout.inc(1) end),
        --- Right click
        awful.button({}, 3, function(c) awful.layout.inc(-1) end),
        --- Scrolling
        awful.button({}, 4, function() awful.layout.inc(-1) end),
        awful.button({}, 5, function() awful.layout.inc(1) end))

        s.mylayoutbox = awful.widget.layoutbox()
        s.mylayoutbox:buttons(layoutbox_buttons)

        local widget = wbutton.elevated.state({
            child = s.mylayoutbox,
            normal_shape = gears.shape.circle,
            hover_shape = gears.shape.circle,
            press_shape = gears.shape.circle,
            normal_bg = beautiful.wibar_bg
        })

        return widget
    end

    --- Create the top_panel
    --- ~~~~~~~~~~~~~~~~~~~~~~~
    s.top_panel = awful.popup({
        screen = s,
        type = "dock",
        shape = helpers.ui.rrect(beautiful.rounded * 3),
        maximum_height = beautiful.wibar_height,
        -- minimum_width = s.geometry.width,
        minimum_width = s.geometry.width - beautiful.useless_gap * 12,
        -- maximum_width = s.geometry.width,
        placement = function()
            -- awful.placement.top(c)
            awful.placement.top(s.top_panel,
                                {margins = beautiful.useless_gap * 2})
        end,
        bg = beautiful.wibar_bg,
        -- {
        -- {
        -- {
        -- layout = wibox.layout.align.horizontal,
        widget = -- s.clock, -- expand = "none",
        -- tag_list(s),
        -- {
        -- system_tray(),
        -- launcher(),
        -- control(),
        -- clip(),
        -- s.network,
        -- notif_panel(),
        -- layoutbox(),
        -- layout = wibox.layout.fixed.horizontal,
        -- },
        -- },
        -- left = dpi(10),
        -- right = dpi(10),
        -- widget = wibox.container.margin,
        -- },
        -- bg = beautiful.wibar_bg,
        -- widget = wibox.container.background,
        -- },
        {
            {
                layout = wibox.layout.align.horizontal,
                {
                    {
                        {
                            launcher(),
                            garis,
                            files(),
                            terminal(),
                            nvim(),
                            code(),
                            control(),
                            -- spacing = dpi(1),
                            layout = wibox.layout.fixed.horizontal
                        },
                        widget = wibox.container.margin
                    },
                    layout = wibox.layout.fixed.horizontal
                },
                nil,
                {
                    {
                        {
                            system_tray(),
                            right = dpi(4),
                            widget = wibox.container.margin
                        },
                        clip(),
                        s.network,
                        notif_panel(),
                        screenshot,
                        layoutbox(),
                        s.clock,
                        garis,
                        powerbutton(),
                        -- spacing = 0.5,
                        layout = wibox.layout.fixed.horizontal
                    },
                    layout = wibox.layout.fixed.horizontal
                }
            },
            {
                {
                    {
                        {
                            {tags, layout = wibox.layout.fixed.horizontal},
                            left = 10,
                            right = 10,
                            widget = wibox.container.margin
                        },
                        shape = helpers.ui.rrect(dpi(50)),
                        widget = wibox.container.background,
                        bg = beautiful.widget_bg
                    },
                    top = 2,
                    buttom = 2,
                    left = 20,
                    right = 20,
                    widget = wibox.container.margin
                },
                halign = "center",
                widget = wibox.widget.margin,
                layout = wibox.container.place
            },
            layout = wibox.layout.stack
        }
    })

    s.top_panel:struts({
        top = s.top_panel.maximum_height + beautiful.useless_gap * 2
    })

    --- Remove top_panel on full screen
    local function remove_top_panel(c)
        if c.fullscreen or c.maximized then
            c.screen.top_panel.visible = false
        else
            c.screen.top_panel.visible = true
        end
    end

    --- Remove top_panel on full screen
    local function add_top_panel(c)
        if c.fullscreen or c.maximized then
            c.screen.top_panel.visible = true
        end
    end

    --- Hide bar when a splash widget is visible
    awesome.connect_signal("widgets::splash::visibility", function(vis)
        screen.primary.top_panel.visible = not vis
    end)

    client.connect_signal("property::fullscreen", remove_top_panel)
    client.connect_signal("request::unmanage", add_top_panel)
end
