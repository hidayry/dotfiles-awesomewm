#!/bin/bash

rofi -modi "clipboard:greenclip print" -theme "$HOME/.config/awesome/utilities/clip/clipboard.rasi" -show clipboard -run-command '{cmd}'
