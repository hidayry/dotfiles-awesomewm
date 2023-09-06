local awful = require("awful")
local naughty = require("naughty")
local beautiful = require("beautiful")

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

-- Function to take a screenshot with a timer (in seconds)
function take_screenshot_with_timer(timer)
    naughty.notify({title = "Screenshot", text = "Taking screenshot in " .. timer .. " seconds"})
    awful.spawn.easy_async_with_shell("sleep " .. timer .. " && scrot -u ~/Pictures/screenshot.png", function()
        naughty.notify({
            text = "Screenshot Captured!",
            title = "   Screenshot Tool",
            font = beautiful.jet .. "14",
            timeout = 5,
            actions = { open_pictures }
          })
    end)
end

-- Function to take a fullscreen screenshot
function take_fullscreen_screenshot()
    awful.spawn.easy_async_with_shell("scrot ~/Pictures/screenshot.png", function()
        naughty.notify({
            text = "Fullscreen Screenshot Captured!",
            title = "   Screenshot Tool",
            font = beautiful.jet .. "14",
            timeout = 5,
            actions = { open_pictures }
          })
    end)
end

-- Function to take a screenshot of a selected area
function take_selected_area_screenshot()
    awful.spawn.easy_async_with_shell("scrot -s ~/Pictures/screenshot.png", function()
        naughty.notify({
            text = "Selected Screenshot Captured!",
            title = "   Screenshot Tool",
            font = beautiful.jet .. "14",
            timeout = 5,
            actions = { open_pictures }
          })
    end)
end
