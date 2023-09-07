local awful = require("awful")
local filesystem = require("gears.filesystem")
local config_dir = filesystem.get_configuration_dir()
local utils_dir = config_dir .. "utilities/"

return {
    --- Default Applications
    default = {
        --- Default terminal emulator
        terminal = "st",
        --- Default music client
        music_player = "alacritty --class music -e ncmpcpp",
        --- Default text editor
        text_editor = "st -e nvim",
        --- Default code editor
        code_editor = "code",
        --- Default web browser
        web_browser = "microsoft-edge-stable",
        --- Default file manager
        file_manager = "thunar",
        --- Default network manager
        network_manager = "networkmanager_dmenu",
        --- Default clipboard
        clip = utils_dir .. "/clip/clip.sh",
        --- Default launcher
        launcher = utils_dir .. "/launcher/launcher.sh",
        --- recorder
        recorder = "SimpleScreenRecorder",
        --- Default rofi global menu
        app_launcher = "rofi -no-lazy-grab -show drun -modi drun -theme " ..
            config_dir .. "configuration/rofi.rasi",
    },

    --- List of binaries/shell scripts that will execute for a certain task
    utils = {
        --- Fullscreen screenshot
        full_screenshot = utils_dir .. "ss.sh -f",
        --- Area screenshot
        area_screenshot = utils_dir .. "ss.sh -s",
        ---10 second
        time_screenshot = utils_dir .. "ss.sh -t 10",
        --- Color Picker
        color_picker = utils_dir .. "colorpicker"
    }
}


