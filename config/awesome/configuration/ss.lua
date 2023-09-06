local awful = require("awful")
local naughty = require("naughty")

-- Function to take a screenshot with a timer (in seconds)
function take_screenshot_with_timer(timer)
    naughty.notify({title = "Screenshot", text = "Taking screenshot in " .. timer .. " seconds"})
    awful.spawn.easy_async_with_shell("sleep " .. timer .. " && scrot -u ~/Pictures/screenshot.png", function()
        naughty.notify({title = "Screenshot", text = "Screenshot saved"})
    end)
end

-- Function to take a fullscreen screenshot
function take_fullscreen_screenshot()
    awful.spawn.easy_async_with_shell("scrot ~/Pictures/screenshot.png", function()
        naughty.notify({title = "Screenshot", text = "Fullscreen screenshot saved"})
    end)
end

-- Function to take a screenshot of a selected area
function take_selected_area_screenshot()
    awful.spawn.easy_async_with_shell("scrot -s ~/Pictures/screenshot.png", function()
        naughty.notify({title = "Screenshot", text = "Selected area screenshot saved"})
    end)
end
