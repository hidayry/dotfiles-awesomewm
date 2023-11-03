local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local naughty = require("naughty")
local helpers = require("helpers")
local titlebar = require("ui.screenshot.titlebar")

local timer_button = require("ui.screenshot.buttons.timed_ss")
local fullscreen = require("ui.screenshot.buttons.fullscreen")
local selection = require("ui.screenshot.buttons.selection")

local Separator = wibox.widget.textbox("    ")
Separator.forced_height = 330
Separator.forced_width = 540

----------------------------------------------
--Text Boxes----------------------------------
----------------------------------------------


--Delay time----------------------------------

local delay_time = 10

local function timer_value(num)
  if (num > 0) then
    Value = num;
  else
    Value = 0;
  end
  return Value
end

local delay_text = wibox.widget {
  -- text = user.name,
  markup = helpers.ui.colorize_text("Delay in seconds", beautiful.color2),
  font = beautiful.font_name .. "14",
  widget = wibox.widget.textbox,
}

local timer = wibox.widget {
  markup = helpers.ui.colorize_text("󱎫 ".. timer_value(delay_time) .. " ", beautiful.color4),
  font = beautiful.jet .. " 14",
  widget = wibox.widget.textbox,
}

local increase_timer = wibox.widget {
  markup = helpers.ui.colorize_text("   ", beautiful.color2),
  font = beautiful.icon_font .. " 14",
  widget = wibox.widget.textbox,
}

increase_timer:connect_signal("button::press", function(_, _, _, button)
  if button == 1 then
    delay_time = delay_time + 1
    timer:set_markup_silently(helpers.ui.colorize_text("󱎫 ".. timer_value(delay_time) .. " ", beautiful.accent))
  end
end)


local decrease_timer = wibox.widget {
  markup = helpers.ui.colorize_text("   ", beautiful.color2),
  font = beautiful.icon_font .. " 14",
  widget = wibox.widget.textbox,
}

decrease_timer:connect_signal("button::press", function(_, _, _, button)
  if button == 1 then
    if delay_time > 0 then
      delay_time = delay_time - 1
    else
      delay_time = delay_time
    end
    timer:set_markup_silently(helpers.ui.colorize_text("󱎫 ".. timer_value(delay_time) .. " ", beautiful.accent))
  end
end)

local vertical_separator = wibox.widget {
  orientation = 'vertical',
  forced_height = dpi(1.5),
  forced_width = dpi(1.5),
  span_ratio = 0.75,
  widget = wibox.widget.separator,
  color = "#a9b1d6",
  border_color = "#a9b1d6",
  opacity = 0.75
}

local delay_control = wibox.widget {
  {
    {
      increase_timer,
      vertical_separator,
      decrease_timer,
      layout = wibox.layout.fixed.horizontal
    },
    widget = wibox.container.margin,
    left = dpi(5),
    right = dpi(5)
  },
  widget = wibox.container.background,
  bg = beautiful.wibar_bg,
  shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, 16)
  end,
}

local delay = wibox.widget {
  {
    {
      delay_text,
      widget = wibox.container.margin,
      left = dpi(15),
      top = dpi(12),
      bottom = dpi(12),
      right = dpi(168),
    },
    {
      timer,
      widget = wibox.container.margin,
      left = dpi(10),
      top = dpi(12),
      bottom = dpi(12),
      --right = dpi(2),
    },
    {
      delay_control,
      widget = wibox.container.margin,
      left = dpi(8),
      top = dpi(7),
      bottom = dpi(7),
      --right = dpi(5),
    },
    layout = wibox.layout.fixed.horizontal,
    forced_width = dpi(490)

  },
  widget = wibox.container.background,
  bg = beautiful.widget_bg,
  shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, 5)
  end,

}

--Toggle Mouse cursor-------------------------

local pointer_visible = true

local pointer_text = wibox.widget {
  markup = helpers.ui.colorize_text("Show mouse cursor", beautiful.color2),
  font = beautiful.font_name .. " 14",
  widget = wibox.widget.textbox,
}

local toggle_button = wibox.widget {
  markup = helpers.ui.colorize_text("   ", beautiful.color2),
  font = beautiful.jet .. " 20",
  widget = wibox.widget.textbox,
}

local toggle_cursor = wibox.widget {
  {
    {
      pointer_text,
      widget = wibox.container.margin,
      left = dpi(15),
      top = dpi(12),
      bottom = dpi(12),
      right = dpi(220),
    },
    {
      toggle_button,
      widget = wibox.container.margin,
      left = dpi(15),
      top = dpi(0),
      bottom = dpi(0),
      right = dpi(5),
    },
    layout = wibox.layout.fixed.horizontal,
    forced_width = dpi(490)

  },
  widget = wibox.container.background,
  bg = beautiful.widget_bg,
  shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, 5)
  end,

}

toggle_button:connect_signal("button::press", function(_, _, _, button)
  if button == 1 then
    pointer_visible = not pointer_visible
    if pointer_visible then
      toggle_button:set_markup_silently(helpers.ui.colorize_text("   ", beautiful.color2))
    else
      toggle_button:set_markup_silently(helpers.ui.colorize_text("   ", beautiful.color2))
    end
  end
end)



----------------------------------------------
--Main Popup----------------------------------
----------------------------------------------
local ss_tool = awful.popup {
  screen = s,
  widget = wibox.container.background,
  ontop = true,
  bg = "#00000000",
  visible = false,
  -- maximum_width = 200,
  placement = function(c)
    awful.placement.centered(c,
      { margins = { top = dpi(0), bottom = dpi(0), left = dpi(0), right = dpi(0) } })
  end,
  shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, 0)
  end,
  opacity = 1,
  forced_height = dpi(330),
  forced_width = dpi(200),
  border_color = beautiful.wibar_bg,
  border_width = dpi(4)
}

ss_tool:setup {
  titlebar,
  {
    {
      Separator,
      widget = wibox.container.background,
      bg = beautiful.wibar_bg
    },
    {
      {
        {
          {
            fullscreen,
            widget = wibox.container.margin,
            left = dpi(10),
            right = dpi(10)
          },
          {
            selection,
            widget = wibox.container.margin,
            left = dpi(10),
            right = dpi(10)
          },
          {
            timer_button,
            widget = wibox.container.margin,
            left = dpi(10),
            right = dpi(10)
          },
          layout = wibox.layout.fixed.horizontal
        },
        widget = wibox.container.margin,
        top = dpi(20),
        bottom = dpi(20),
        left = dpi(15),
        right = dpi(15),
      },
      {
        delay,
        widget = wibox.container.margin,
        top = dpi(10),
        bottom = dpi(0),
        left = dpi(25),
        right = dpi(25)
      },
      {
        toggle_cursor,
        widget = wibox.container.margin,
        top = dpi(15),
        bottom = dpi(28),
        left = dpi(25),
        right = dpi(25)
      },

      layout = wibox.layout.fixed.vertical
    },
    layout = wibox.layout.stack
  },

  layout = wibox.layout.fixed.vertical
}

awesome.connect_signal("ui::screenshot", function()
  ss_tool.visible = false
end)

--Screenshot Functionalities-----------------
---------------------------------------------

local open_pictures = naughty.action {
  name = 'Open Pictures',
  icon_only = false,
}

open_pictures:connect_signal(
  'invoked',
  function()
    awful.spawn('thunar ' .. 'Pictures', false)
  end
)

fullscreen:connect_signal("button::release", function(_, _, _, button)
  if button == 1 then
    ss_tool.visible = false
    local screenshot_name = "screenshot_" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".png"
    awful.spawn.easy_async_with_shell("sleep 0.3 && scrot ~/Pictures/" .. screenshot_name,
      function()
        naughty.notify
        (
          {
            text = "Fullscreen Screenshot Captured!",
            title = "   Screenshot Tool",
            font = beautiful.jet .. "14",
            timeout = 5,
            actions = { open_pictures }
          }
        )
      end)
  end
end)

timer_button:connect_signal("button::release", function(_, _, _, button)
  if button == 1 then
    ss_tool.visible = false
    local screenshot_name = "screenshot_" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".png"
    awful.spawn.easy_async_with_shell("sleep 0.3 && scrot -d " .. delay_time .. " ~/Pictures/" .. screenshot_name,
      function()
        naughty.notify
        (
          {
            text = "Screenshot Captured!",
            title = "   Screenshot Tool",
            font = beautiful.jet .. "14",
            timeout = 5,
            actions = { open_pictures }
          }
        )
      end)
  end
end)

selection:connect_signal("button::release", function(_, _, _, button)
  if button == 1 then
    ss_tool.visible = false
    local screenshot_name = "screenshot_" .. os.date("%Y-%m-%d_%H-%M-%S") .. ".png"
    awful.spawn.easy_async_with_shell("sleep 0.3 && scrot -s ~/Pictures/" .. screenshot_name, function()
        naughty.notify
        (
          {
            text = "Selected Screenshot Captured!",
            title = "   Screenshot Tool",
            font = beautiful.jet .. "14",
            timeout = 5,
            actions = { open_pictures }
          }
        )
      end)
  end
end)


return ss_tool
