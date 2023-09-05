local awful = require("awful")
local names = {"󰃚", "󰝥", "󰝥", "󰝥", "󰝥", "󰝥", "󰝥", "󰝥"}
--- Tags
--- ~~~~

-- screen.connect_signal("request::desktop_decoration", function(s)
--- Each screen has its own tag table.
-- awful.tag({ "1", "2", "3", "4", "5", "6" }, s, awful.layout.layouts[1])
-- end)

--- set tags
screen.connect_signal("request::desktop_decoration", function(s)
    awful.tag(names, s, awful.layout.layouts[1])
end)
