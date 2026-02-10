# skhd + yabai Keybinding Integration

yabai has no built-in keybinding system. Use **skhd** as the hotkey daemon.

## Install skhd

```bash
brew install koekeishiya/formulae/skhd
brew services start skhd
```

Config file: `~/.config/skhd/skhdrc`

## skhd Syntax

```
<modifier> - <key> : <command>
```

Modifiers: `alt`, `shift`, `cmd`, `ctrl`, `fn`, `hyper` (cmd+alt+shift+ctrl), `meh` (alt+shift+ctrl)

Combine with `+`: `shift + alt - h`

## Complete skhdrc Example

```bash
# ========== Window Focus ==========

# Focus window in direction
alt - h : yabai -m window --focus west
alt - j : yabai -m window --focus south
alt - k : yabai -m window --focus north
alt - l : yabai -m window --focus east

# Focus prev/next in stack
alt - n : yabai -m window --focus stack.next || yabai -m window --focus stack.first
alt - p : yabai -m window --focus stack.prev || yabai -m window --focus stack.last

# ========== Window Swap ==========

# Swap window in direction
shift + alt - h : yabai -m window --swap west
shift + alt - j : yabai -m window --swap south
shift + alt - k : yabai -m window --swap north
shift + alt - l : yabai -m window --swap east

# ========== Window Warp ==========

# Warp (re-insert) window in direction
shift + cmd - h : yabai -m window --warp west
shift + cmd - j : yabai -m window --warp south
shift + cmd - k : yabai -m window --warp north
shift + cmd - l : yabai -m window --warp east

# ========== Window Stack ==========

# Stack window onto another
ctrl + alt - h : yabai -m window --stack west
ctrl + alt - j : yabai -m window --stack south
ctrl + alt - k : yabai -m window --stack north
ctrl + alt - l : yabai -m window --stack east

# ========== Window Resize ==========

# Increase/decrease window size
shift + alt - left  : yabai -m window --resize left:-40:0
shift + alt - down  : yabai -m window --resize bottom:0:40
shift + alt - up    : yabai -m window --resize top:0:-40
shift + alt - right : yabai -m window --resize right:40:0

# ========== Window Move to Space ==========

# Move window to space N (requires SIP disabled for some)
shift + alt - 1 : yabai -m window --space 1
shift + alt - 2 : yabai -m window --space 2
shift + alt - 3 : yabai -m window --space 3
shift + alt - 4 : yabai -m window --space 4
shift + alt - 5 : yabai -m window --space 5

# Move window to prev/next space
shift + alt - p : yabai -m window --space prev
shift + alt - n : yabai -m window --space next

# ========== Window Move to Display ==========

# Move window to display
shift + alt - s : yabai -m window --display next
shift + alt - a : yabai -m window --display prev

# ========== Space Focus ==========

# Focus space by number
alt - 1 : yabai -m space --focus 1
alt - 2 : yabai -m space --focus 2
alt - 3 : yabai -m space --focus 3
alt - 4 : yabai -m space --focus 4
alt - 5 : yabai -m space --focus 5

# Focus prev/next space
alt - left  : yabai -m space --focus prev
alt - right : yabai -m space --focus next

# ========== Display Focus ==========

# Focus display
ctrl + alt - left  : yabai -m display --focus prev
ctrl + alt - right : yabai -m display --focus next

# ========== Window Toggles ==========

# Toggle float and center
shift + alt - space : yabai -m window --toggle float --grid 4:4:1:1:2:2

# Toggle fullscreen zoom
alt - f : yabai -m window --toggle zoom-fullscreen

# Toggle parent zoom
shift + alt - f : yabai -m window --toggle zoom-parent

# Toggle native fullscreen
ctrl + alt - f : yabai -m window --toggle native-fullscreen

# Toggle split direction
alt - e : yabai -m window --toggle split

# Toggle sticky (SIP)
shift + alt - s : yabai -m window --toggle sticky

# Toggle picture-in-picture
shift + alt - p : yabai -m window --toggle pip

# ========== Space Layout ==========

# Switch layout
ctrl + alt - b : yabai -m space --layout bsp
ctrl + alt - s : yabai -m space --layout stack
ctrl + alt - d : yabai -m space --layout float

# ========== BSP Tree Operations ==========

# Balance windows
shift + alt - 0 : yabai -m space --balance

# Rotate tree
alt - r : yabai -m space --rotate 90

# Mirror tree
shift + alt - x : yabai -m space --mirror x-axis
shift + alt - y : yabai -m space --mirror y-axis

# ========== Space Management (SIP) ==========

# Create/destroy space
shift + cmd - n : yabai -m space --create
shift + cmd - w : yabai -m space --destroy

# ========== Floating Window Grid ==========

# Left/right half
ctrl + alt - left  : yabai -m window --grid 1:2:0:0:1:1
ctrl + alt - right : yabai -m window --grid 1:2:1:0:1:1

# Top/bottom half
ctrl + alt - up   : yabai -m window --grid 2:1:0:0:1:1
ctrl + alt - down : yabai -m window --grid 2:1:0:1:1:1

# Center (half size)
ctrl + alt - c : yabai -m window --grid 4:4:1:1:2:2

# Fullscreen (floating)
ctrl + alt - return : yabai -m window --grid 1:1:0:0:1:1

# Quarters
ctrl + alt - u : yabai -m window --grid 2:2:0:0:1:1
ctrl + alt - i : yabai -m window --grid 2:2:1:0:1:1
ctrl + alt - j : yabai -m window --grid 2:2:0:1:1:1
ctrl + alt - k : yabai -m window --grid 2:2:1:1:1:1
```

## Tips

- Use `||` to chain fallback commands: `yabai -m window --focus next || yabai -m window --focus first`
- skhd supports modes for modal keybindings (vim-style leader keys)
- Reload skhd config: `skhd --reload`
- Test a command before binding: run it directly in terminal first
