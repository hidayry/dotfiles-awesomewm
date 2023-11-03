local awful = require("awful")
local filesystem = require("gears.filesystem")
local config_dir = filesystem.get_configuration_dir()
local helpers = require("helpers")

local function autostart_apps()
    --- Compositor
    helpers.run.check_if_running("picom", nil, function()
        awful.spawn("picom --config " .. config_dir ..
                        "configuration/picom.conf -b", false)
    end)

    --- Music Server
    helpers.run.run_once_grep("mpd")
    helpers.run.run_once_grep("mpDris2")
    --- xrdb
    helpers.run.run_once_pgrep("xrdb merge $HOME/.Xresources")
    --- Polkit Agent
    helpers.run.run_once_pgrep(
        "/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1")
    -- clipboard
    helpers.run.run_once_grep("greenclip daemon")
    -- cursor speed
    helpers.run.run_once_pgrep("xset r rate 200 50")
    -- lockscreen
    helpers.run.run_once_pgrep("xautolock -time 10 -locker '$HOME/.config/awesome/utilities/lock' && echo mem ? /sys/power/state")
    -- helpers.run.run_once_grep("nm-applet")
end

autostart_apps()
