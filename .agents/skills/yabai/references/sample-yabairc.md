# Sample yabairc Configuration

A complete, well-commented yabairc ready to use or adapt.

```bash
#!/usr/bin/env sh

# ====== Scripting Addition ======
# Requires SIP partially disabled. Remove these two lines if SIP is enabled.
yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
sudo yabai --load-sa

# ====== Global Settings ======

yabai -m config \
    layout                       bsp \
    window_placement             second_child \
    split_ratio                  0.50 \
    auto_balance                 off \
    \
    top_padding                  10 \
    bottom_padding               10 \
    left_padding                 10 \
    right_padding                10 \
    window_gap                   8 \
    \
    mouse_follows_focus          off \
    focus_follows_mouse          off \
    \
    window_shadow                on \
    window_opacity               on \
    active_window_opacity        1.0 \
    normal_window_opacity        0.92 \
    \
    window_animation_duration    0.25 \
    window_animation_easing      ease_out_circ \
    \
    insert_feedback_color        0xffd75f5f \
    \
    mouse_modifier               fn \
    mouse_action1                move \
    mouse_action2                resize \
    mouse_drop_action            swap

# ====== External Bar ======
# Uncomment if using sketchybar or another bar
# yabai -m config external_bar all:32:0

# ====== Space-Specific Settings ======

# Space 1: stack layout for a "main" workspace
# yabai -m config --space 1 layout stack

# Space 4: floating layout for creative tools
# yabai -m config --space 4 layout float

# ====== Space Labels ======
# Labels make it easier to reference spaces in skhd bindings
yabai -m space 1 --label code
yabai -m space 2 --label web
yabai -m space 3 --label chat
yabai -m space 4 --label media

# ====== Rules ======

# System apps that should float
yabai -m rule --add app="^System Preferences$" manage=off
yabai -m rule --add app="^System Settings$" manage=off
yabai -m rule --add app="^Calculator$" manage=off
yabai -m rule --add app="^Karabiner" manage=off
yabai -m rule --add app="^Archive Utility$" manage=off
yabai -m rule --add app="^Logi Options" manage=off
yabai -m rule --add app="^Alfred Preferences$" manage=off

# Finder dialogs float, main windows tile
yabai -m rule --add app="^Finder$" title="^(Copy|Connect|Move|Info|Preferences)$" manage=off

# Activity Monitor floats
yabai -m rule --add app="^Activity Monitor$" manage=off

# Picture-in-Picture stays on top and floats
yabai -m rule --add title="^Picture.in.Picture$" sticky=on manage=off layer=above

# Assign apps to specific spaces
yabai -m rule --add app="^Safari$" space=web
yabai -m rule --add app="^Firefox$" space=web
yabai -m rule --add app="^Google Chrome$" space=web
yabai -m rule --add app="^Slack$" space=chat
yabai -m rule --add app="^Discord$" space=chat
yabai -m rule --add app="^Spotify$" space=media
yabai -m rule --add app="^Music$" space=media

# ====== Signals ======

# Refresh sketchybar on workspace/window events
# yabai -m signal --add event=window_focused action="sketchybar --trigger window_focus"
# yabai -m signal --add event=window_created action="sketchybar --trigger windows_on_spaces"
# yabai -m signal --add event=window_destroyed action="sketchybar --trigger windows_on_spaces"
# yabai -m signal --add event=space_changed action="sketchybar --trigger space_change"

# Auto-float newly created Finder windows (except main windows)
yabai -m signal --add event=window_created app="^Finder$" title!="^$" \
    action="yabai -m window \$YABAI_WINDOW_ID --toggle float"

echo "yabai configuration loaded"
```

## Minimal Configuration

A stripped-down config for getting started quickly:

```bash
#!/usr/bin/env sh

yabai -m config layout bsp
yabai -m config window_gap 8
yabai -m config top_padding 8
yabai -m config bottom_padding 8
yabai -m config left_padding 8
yabai -m config right_padding 8

yabai -m rule --add app="^System Settings$" manage=off
yabai -m rule --add app="^Calculator$" manage=off

echo "yabai configuration loaded"
```
