# yabai Command Reference

## Config Commands

Set global or space-specific settings.

```bash
# Set a global config value
yabai -m config <key> <value>

# Set a space-specific config value
yabai -m config --space <space_index> <key> <value>

# Read a config value
yabai -m config <key>
```

### Config Keys

| Key | Values | Description |
|-----|--------|-------------|
| `layout` | `bsp`, `stack`, `float` | Window layout mode |
| `top_padding` | integer | Top padding in pixels |
| `bottom_padding` | integer | Bottom padding in pixels |
| `left_padding` | integer | Left padding in pixels |
| `right_padding` | integer | Right padding in pixels |
| `window_gap` | integer | Gap between windows in pixels |
| `split_ratio` | float (0.0-1.0) | Default split ratio |
| `auto_balance` | `on`, `off` | Auto-balance BSP tree on window events |
| `window_placement` | `first_child`, `second_child` | Where new windows appear in BSP |
| `window_shadow` | `on`, `off`, `float` | Show window shadows |
| `window_opacity` | `on`, `off` | Enable window opacity |
| `active_window_opacity` | float (0.0-1.0) | Opacity of focused window |
| `normal_window_opacity` | float (0.0-1.0) | Opacity of unfocused windows |
| `window_animation_duration` | float (seconds) | Animation duration (0 = disabled) |
| `window_animation_easing` | `ease_in_sine`, `ease_out_sine`, `ease_in_out_sine`, `ease_in_quad`, `ease_out_quad`, `ease_in_out_quad`, `ease_in_cubic`, `ease_out_cubic`, `ease_in_out_cubic`, `ease_in_expo`, `ease_out_expo`, `ease_in_out_expo`, `ease_in_circ`, `ease_out_circ`, `ease_in_out_circ` | Animation easing function |
| `window_origin_display` | `default`, `focused`, `cursor` | Which display new windows appear on |
| `insert_feedback_color` | hex color `0xAARRGGBB` | Color of insertion feedback |
| `mouse_follows_focus` | `off`, `autoraise`, `autofocus` | Move mouse when focus changes |
| `focus_follows_mouse` | `off`, `autoraise`, `autofocus` | Focus window under mouse |
| `mouse_modifier` | `cmd`, `alt`, `shift`, `ctrl`, `fn` | Key for mouse actions |
| `mouse_action1` | `move`, `resize` | Action for modifier + left click |
| `mouse_action2` | `move`, `resize` | Action for modifier + right click |
| `mouse_drop_action` | `swap`, `stack` | Action when dropping a window on another |
| `external_bar` | `off` or `<position>:<top_offset>:<bottom_offset>` | Reserve space for external bar. Position: `main`, `all` |

---

## Window Commands

```bash
yabai -m window [<window_sel>] --<command> <value>
```

### Window Selectors

| Selector | Description |
|----------|-------------|
| `north`, `east`, `south`, `west` | Direction relative to focused window |
| `prev`, `next` | Previous/next in window tree |
| `first`, `last` | First/last in window tree |
| `recent` | Most recently focused |
| `largest`, `smallest` | By area |
| `mouse` | Window under cursor |
| `stack.prev`, `stack.next`, `stack.first`, `stack.last`, `stack.recent` | Stack navigation |
| `sibling` | Sibling in BSP tree |
| `<window_id>` | Specific window ID |

### Window Actions

```bash
# Focus
yabai -m window --focus <sel>

# Swap position and size with another window
yabai -m window --swap <sel>

# Warp (re-insert) at another window's position
yabai -m window --warp <sel>

# Stack window on top of another
yabai -m window --stack <sel>

# Insert direction feedback (sets where next window will split)
yabai -m window --insert <dir>    # north, east, south, west, stack

# Grid placement (floating windows)
yabai -m window --grid <rows>:<cols>:<x>:<y>:<w>:<h>

# Move window (floating only)
yabai -m window --move abs:<x>:<y>
yabai -m window --move rel:<dx>:<dy>

# Resize window
yabai -m window --resize <handle>:<dx>:<dy>
# Handles: top, left, bottom, right, top_left, top_right, bottom_left, bottom_right, abs

# Set split ratio for this window's parent
yabai -m window --ratio abs:<ratio>
yabai -m window --ratio rel:<delta>

# Toggle properties
yabai -m window --toggle float
yabai -m window --toggle sticky          # show on all spaces (SIP)
yabai -m window --toggle pip              # picture-in-picture
yabai -m window --toggle shadow
yabai -m window --toggle split            # toggle split direction
yabai -m window --toggle zoom-parent      # zoom to parent node size
yabai -m window --toggle zoom-fullscreen  # zoom to fullscreen
yabai -m window --toggle native-fullscreen

# Move to space or display
yabai -m window --space <space_sel>       # (SIP for some)
yabai -m window --display <display_sel>

# Minimize / deminimize
yabai -m window --minimize
yabai -m window --deminimize <window_id>

# Close
yabai -m window --close

# Set layer
yabai -m window --layer <below|normal|above>

# Set opacity
yabai -m window --opacity <0.0-1.0>
```

---

## Space Commands

```bash
yabai -m space [<space_sel>] --<command> <value>
```

### Space Selectors

| Selector | Description |
|----------|-------------|
| `prev`, `next` | Adjacent spaces |
| `first`, `last` | First/last space |
| `recent` | Most recently focused |
| `<index>` | Space index number |
| `<label>` | Space label string |

### Space Actions

```bash
# Focus
yabai -m space --focus <sel>

# Create / destroy (SIP)
yabai -m space --create
yabai -m space --destroy

# Move space
yabai -m space --move <sel>           # reorder space
yabai -m space --display <display>    # move to display (SIP)

# Label
yabai -m space <index> --label <name>

# Layout
yabai -m space --layout bsp|stack|float

# BSP tree operations
yabai -m space --balance              # equalize all windows
yabai -m space --mirror x-axis        # mirror horizontally
yabai -m space --mirror y-axis        # mirror vertically
yabai -m space --rotate 90|180|270    # rotate tree

# Padding and gaps
yabai -m space --padding abs:<t>:<b>:<l>:<r>
yabai -m space --padding rel:<t>:<b>:<l>:<r>
yabai -m space --gap abs:<gap>
yabai -m space --gap rel:<delta>
yabai -m space --toggle padding
yabai -m space --toggle gap
```

---

## Display Commands

```bash
yabai -m display [<display_sel>] --<command> <value>
```

### Display Selectors

`prev`, `next`, `first`, `last`, `recent`, `mouse`, `<arrangement_index>`

### Display Actions

```bash
# Focus display
yabai -m display --focus <sel>

# Label display
yabai -m display <index> --label <name>
```

---

## Query Commands

```bash
# Query all windows / spaces / displays
yabai -m query --windows
yabai -m query --spaces
yabai -m query --displays

# Query current / specific
yabai -m query --windows --window
yabai -m query --windows --window <window_id>
yabai -m query --spaces --space
yabai -m query --spaces --space <index>
yabai -m query --displays --display

# Query filtered by parent
yabai -m query --windows --space <index>
yabai -m query --windows --display <index>
yabai -m query --spaces --display <index>
```

Output is JSON. Pipe to `jq` for filtering:

```bash
# Get focused window app name
yabai -m query --windows --window | jq '.app'

# Get IDs of all visible windows
yabai -m query --windows | jq '[.[] | select(."is-visible" == true)] | .[].id'

# Get visible space indices
yabai -m query --spaces | jq '[.[] | select(."is-visible" == true)] | .[].index'

# Count windows on current space
yabai -m query --windows --space | jq 'length'
```

---

## Rule Commands

Rules automatically apply behaviors to windows matching criteria.

```bash
# Add a rule
yabai -m rule --add [<criteria>...] [<properties>...]

# List all rules
yabai -m rule --list

# Remove rule by index or label
yabai -m rule --remove <index>
yabai -m rule --remove <label>

# Apply rules to existing windows
yabai -m rule --apply
```

### Rule Criteria

| Key | Description |
|-----|-------------|
| `app` | Regex matching application name |
| `title` | Regex matching window title |
| `role` | Window role |
| `subrole` | Window subrole |
| `label` | Label for the rule (for removal) |

Prefix regex with `!` to negate: `title!="^Copy$"`

### Rule Properties

| Key | Values | Description |
|-----|--------|-------------|
| `manage` | `on`, `off` | Whether yabai manages the window |
| `sticky` | `on`, `off` | Show on all spaces (SIP) |
| `layer` | `below`, `normal`, `above` | Window layer |
| `opacity` | float | Window opacity |
| `space` | index/label | Send to specific space |
| `display` | index | Send to specific display |
| `grid` | `r:c:x:y:w:h` | Grid position (floating) |
| `native-fullscreen` | `on`, `off` | Enter native fullscreen |
| `--one-shot` | flag | Remove rule after first match |

---

## Signal Commands

Signals execute actions in response to events.

```bash
# Add a signal
yabai -m signal --add event=<event> [app=<regex>] [title=<regex>] [label=<label>] action=<command>

# List all signals
yabai -m signal --list

# Remove signal
yabai -m signal --remove <index>
yabai -m signal --remove <label>
```

### Events

| Event | Description | Environment Variables |
|-------|-------------|----------------------|
| `application_launched` | App launched | `YABAI_PROCESS_ID` |
| `application_terminated` | App terminated | `YABAI_PROCESS_ID` |
| `application_front_switched` | App activated | `YABAI_PROCESS_ID`, `YABAI_RECENT_PROCESS_ID` |
| `application_activated` | App activated | `YABAI_PROCESS_ID` |
| `application_deactivated` | App deactivated | `YABAI_PROCESS_ID` |
| `application_visible` | App unhidden | `YABAI_PROCESS_ID` |
| `application_hidden` | App hidden | `YABAI_PROCESS_ID` |
| `window_created` | Window created | `YABAI_WINDOW_ID` |
| `window_destroyed` | Window destroyed | `YABAI_WINDOW_ID` |
| `window_focused` | Window focused | `YABAI_WINDOW_ID` |
| `window_moved` | Window moved | `YABAI_WINDOW_ID` |
| `window_resized` | Window resized | `YABAI_WINDOW_ID` |
| `window_minimized` | Window minimized | `YABAI_WINDOW_ID` |
| `window_deminimized` | Window deminimized | `YABAI_WINDOW_ID` |
| `window_title_changed` | Title changed | `YABAI_WINDOW_ID` |
| `space_created` | Space created (SIP) | `YABAI_SPACE_ID` |
| `space_destroyed` | Space destroyed (SIP) | `YABAI_SPACE_ID` |
| `space_changed` | Space focused | `YABAI_SPACE_ID`, `YABAI_RECENT_SPACE_ID` |
| `display_added` | Display connected | `YABAI_DISPLAY_ID` |
| `display_removed` | Display disconnected | `YABAI_DISPLAY_ID` |
| `display_moved` | Display rearranged | `YABAI_DISPLAY_ID` |
| `display_resized` | Display resolution changed | `YABAI_DISPLAY_ID` |
| `display_changed` | Display focused | `YABAI_DISPLAY_ID`, `YABAI_RECENT_DISPLAY_ID` |
| `mission_control_enter` | MC opened | - |
| `mission_control_exit` | MC closed | - |
| `dock_did_restart` | Dock restarted | - |
| `system_woke` | System woke from sleep | - |
