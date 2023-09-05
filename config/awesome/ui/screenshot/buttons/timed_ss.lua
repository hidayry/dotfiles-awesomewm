local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local helpers = require("helpers")

--Image widget
local image = wibox.widget {
  widget = wibox.widget.imagebox,
  image = os.getenv("HOME") .. "/.config/awesome/ui/screenshot/assets/clock.png",
  resize = true,
  opacity = 1,

}

local text = {
  markup = helpers.ui.colorize_text("Timer", beautiful.fg_normal),
  font = beautiful.font_name .. " 12",-- text = user.name,
  widget = wibox.widget.textbox,
  align = "center"}

local container = wibox.widget {
  {
    image,
    text,
    layout = wibox.layout.fixed.vertical
  },
  widget = wibox.container.margin,
  left = dpi(30),
  right = dpi(30),
  top = dpi(10),
  bottom = dpi(25)

}

--Main Widget
local button = wibox.widget {
  {
    {
      {
        image,
        layout = wibox.layout.fixed.vertical
      },
      left   = dpi(25),
      right  = dpi(25),
      top    = dpi(25),
      bottom = dpi(25),
      widget = wibox.container.margin
    },
    layout = wibox.container.place
  },
  bg = beautiful.widget_bg,
  shape = gears.shape.rounded_rect,
  widget = wibox.container.background,
  forced_height = dpi(140),
  forced_width = dpi(150),
  -- border_width = dpi(1.5),
  -- border_color = color.white
}

button:connect_signal("mouse::enter", function()
  button.bg = beautiful.accent
  image.image = os.getenv("HOME") .. "/.config/awesome/ui/screenshot/assets/clock-hover.png"
end)

button:connect_signal("mouse::leave", function()
  image.image = os.getenv("HOME") .. "/.config/awesome/ui/screenshot/assets/clock.png"
  button.bg = beautiful.widget_bg
end)

button:connect_signal("button::press", function()
  button.bg = beautiful.accent
end)

button:connect_signal("button::release", function()
  button.bg = beautiful.widget_bg
end)


return button
