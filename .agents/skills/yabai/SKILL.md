---
name: yabai
description: Configure and manage yabai, the macOS tiling window manager. Covers yabairc configuration, window/space/display commands, rules, signals, skhd keybindings, and SIP requirements.
license: MIT
compatibility: opencode
metadata:
  category: system-tools
  audience: macos-users
---

# yabai - macOS Tiling Window Manager

## What I Do

- Help write and debug `yabairc` configuration files
- Provide correct yabai CLI commands for window, space, and display management
- Set up rules for automatic window behavior per application
- Configure signals to react to window management events
- Integrate yabai with skhd for keyboard-driven workflows
- Advise on SIP requirements for advanced features
- Set up status bar integration (sketchybar, spacebar)

## When to Use Me

Use this skill when:
- Creating or editing a `yabairc` configuration
- Writing skhd keybindings that invoke yabai commands
- Troubleshooting yabai window tiling behavior
- Setting up rules for specific applications
- Querying yabai state with `yabai -m query`
- Configuring multi-display or multi-space workflows

## Key Concepts

### Layouts
- **`bsp`** - Binary space partitioning. Windows are automatically tiled by recursively splitting the screen. This is the primary tiling mode.
- **`stack`** - Windows occupy the same region and are stacked. Cycle through them with `--focus stack.next` / `stack.prev`.
- **`float`** - No automatic tiling. Windows are positioned freely.

### SIP (System Integrity Protection)
Features are split by SIP requirement:

**Without SIP changes (works out of the box):**
- BSP/stack/float tiling, focus/swap/warp, window opacity, rules, signals, querying, mouse actions, padding/gaps

**Requires SIP partially disabled + scripting addition:**
- Creating/destroying spaces, moving spaces between displays, `sticky` windows, moving windows to specific spaces, some focus behaviors across spaces

Load the scripting addition in yabairc:
```bash
yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
sudo yabai --load-sa
```

### Command Structure
All commands follow: `yabai -m <domain> <selector> --<command> <value>`

Domains: `config`, `window`, `space`, `display`, `query`, `rule`, `signal`

### Grid System
The grid format for positioning floating windows is `rows:cols:start_x:start_y:width:height`:
- `1:2:0:0:1:1` - left half
- `1:2:1:0:1:1` - right half
- `4:4:1:1:2:2` - centered at half size
- `1:1:0:0:1:1` - fullscreen

### Padding Format
Padding uses `abs:top:bottom:left:right` or `rel:top:bottom:left:right`.

## Instructions

### Writing a yabairc

1. Start with the shebang and scripting addition loading
2. Set global config options (layout, padding, gaps, mouse, opacity, animations)
3. Add space-specific overrides if needed
4. Add rules for apps that should float or go to specific spaces
5. Add signals for status bar integration or custom behaviors
6. End with an echo confirming the config loaded

Always make the file executable: `chmod +x ~/.config/yabai/yabairc`

### Common Patterns

**Float dialog-like apps:**
```bash
yabai -m rule --add app="^System Preferences$" manage=off
yabai -m rule --add app="^Calculator$" manage=off
yabai -m rule --add app="^Finder$" title="^(Copy|Info|Preferences)$" manage=off
```

**Assign apps to spaces:**
```bash
yabai -m rule --add app="^Safari$" space=2
yabai -m rule --add app="^Slack$" space=3
```

**One-shot rules (apply once then auto-remove):**
```bash
yabai -m rule --add --one-shot app="^Safari$" space=1
```

**Query and filter with jq:**
```bash
yabai -m query --spaces | jq '.[] | select(."is-visible" == true) | .index'
yabai -m query --windows | jq '.[] | select(.app == "Safari") | .id'
```

### Debugging

- Check if yabai is running: `pgrep -x yabai`
- Restart yabai: `yabai --restart-service`
- View logs: `tail -f /tmp/yabai_$USER.out.log`
- Error logs: `tail -f /tmp/yabai_$USER.err.log`
- Query current config: `yabai -m config layout`
- List all rules: `yabai -m rule --list`
- List all signals: `yabai -m signal --list`

## Reference Files

- [Full Command Reference](references/commands.md) - All yabai commands organized by domain
- [Sample yabairc](references/sample-yabairc.md) - Complete example configuration
- [skhd Integration](references/skhd-integration.md) - Keybinding examples for skhd
