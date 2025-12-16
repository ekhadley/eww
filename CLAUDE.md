# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Eww (ElKowar's Wacky Widgets) configuration for creating custom widgets on a Linux desktop, specifically integrated with Hyprland window manager. Eww is a widget system that uses a declarative Yuck language for UI definitions and SCSS for styling.

**Documentation**: Official Eww documentation is available locally in the `.docs/` directory, including:
- `widgets.md` - Widget reference
- `configuration.md` - Configuration guide
- `working_with_gtk.md` - GTK theming info
- `expression_language.md` - Expression syntax
- Other reference files

## IMPORTANT: Maintain This Documentation

**Eww has limited documentation available.** As you work with this codebase, debug issues, and discover useful patterns or gotchas, **you must update this CLAUDE.md file** with your learnings. Add new sections, examples, and insights that will help future instances work more effectively with Eww. This includes:
- Yuck language syntax patterns that work well
- Common errors and their solutions
- Widget interaction patterns
- State management gotchas
- Debugging techniques
- System-specific details (monitor setups, keybindings, window manager configurations, etc.)
- Any other useful discoveries

## Architecture

### Module Structure

The configuration uses a modular approach with the main `eww.yuck` including two sub-modules:
- `panel/eww.yuck` - Main dashboard panel with clock, date, pomodoro timers, colorscheme display, and audio controls
- `pomo/eww.yuck` - Standalone pomodoro timer widget with dual timers and clock display

Each module has its own `eww.yuck` (widget definitions) and `eww.scss` (styling) files.

### Key Components

**Time Polling**: Main `eww.yuck` defines a `defpoll` named `time` that runs every second, capturing date/time as JSON for use across all widgets. Available fields:
- `time.hr` - Hour (12-hour, no leading zero)
- `time.hour` - Hour (24-hour, no leading zero)
- `time.min` - Minutes
- `time.sec` - Seconds
- `time.s` - Unix timestamp (for timer calculations)
- `time.month` - Full month name (e.g., "December")
- `time.mon` - Abbreviated month (e.g., "Dec")
- `time.day` - Day of month
- `time.year` - Year
- `time.dow` - Abbreviated day of week (e.g., "Tue")
- `time.weekday` - Full day of week (e.g., "Tuesday")

**Windows**:
- `panel_window` - Centered overlay with clock, date, pomodoro timers, colorscheme dots, and audio controls
- `pomo_window` - 420px x 160px top-center overlay with standalone pomodoro timers

**Panel Components**:
- **Clock/Date**: Time display with date underneath, vertically centered
- **Pomodoro Timers**: Dual circular progress timers (click to start/pause, scroll to adjust duration)
- **Colorscheme Display**: 8 colored dots showing pywal colors (color1-color8)
- **Audio Toggle**: Switches between headphones and speaker Bluetooth devices
- **Mute Toggle**: Toggles audio mute on default sink

**Pomodoro System**: Dual timer implementation where:
- Each timer has state variables: `panel_pomo{N}_duration`, `panel_pomo{N}_start`, `panel_pomo{N}_state`
- Standalone pomo uses: `pomo{N}_duration`, `pomo{N}_start`, `pomo{N}_state`
- Click to start/pause, scroll to adjust duration (±60 seconds)
- Visual feedback via circular progress bars that change color when running
- Timers calculate remaining time dynamically based on current time vs start time

**Audio System**:
- `audio_is_headphones` poll - Checks if headphones are the default sink
- `audio_muted` poll - Checks if default sink is muted
- Bluetooth device MAC addresses hardcoded for headphones (AC:BF:71:08:A1:D6) and speaker (EC:81:93:AC:8B:60)

### Helper Scripts

**Bash scripts** (in `scripts/`):
- `pomo_toggle.sh` / `panel_toggle.sh` - Toggle windows on active monitor
- Uses Hyprland integration: `hyprctl -j activeworkspace | jq -r '.monitorID'`
- Opens windows on correct screen: `eww open --toggle <window> --screen $active_screen`
- `panel_toggle.sh` also populates `system_info_str` from fastfetch before opening

**External script** (`~/wgmn/scripts/select_bt_audio_sink`):
- Switches Bluetooth audio devices
- Checks if device is already connected before attempting connection
- Uses 5-second timeout to avoid hanging on unreachable devices
- Shows hyprctl notifications for success/failure

### Styling

Main `eww.scss` imports colors from `~/.cache/wal/colors-eww.yuck` (pywal integration for system-wide color schemes).

Module-specific SCSS files define widget styling using SCSS variables for colors, with support for hover states and transitions.

**Color Usage**:
- `$color4` - Clock and date text
- `$color5` - Pomodoro timers, audio toggle icon
- `$color6` - Mute toggle icon
- `$background` / `color0` - Background (avoid using for visible elements)
- `color1-color8` - Colorscheme display dots

## Commands

### Eww Operations
```bash
# Reload Eww after making changes
eww reload

# Open/close specific windows
eww open pomo_window
eww close pomo_window
eww open --toggle panel_window

# Update widget variables
eww update panel_pomo1_start=<unix_timestamp>
eww update panel_pomo1_state=running
eww update panel_pomo1_duration=3600

# Debug widget values
eww state
eww get <variable_name>

# View logs for debugging
eww logs
```

### Toggle Windows (with Hyprland integration)
```bash
./scripts/pomo_toggle.sh
./scripts/panel_toggle.sh
```

## Development Workflow

1. Edit `.yuck` files to modify widget structure and behavior
2. Edit `.scss` files to change styling
3. Run `eww reload` to see changes
4. Check `eww logs` if widgets don't appear or behave unexpectedly
5. Bash scripts require `chmod +x` before first use

## Important Notes

- Eww windows use `:stacking "fg"` to appear as overlays
- Window geometry uses `:anchor` for positioning (e.g., "center", "top center")
- All windows are `:focusable false` to avoid interfering with normal workflow
- Color variables from pywal must be available at `~/.cache/wal/colors-eww.yuck`
- Hyprland integration requires `hyprctl` and `jq` to be installed

## Eww Gotchas and Learnings

### Variable Namespace is Global
All variables across all included yuck files share the same namespace. If you have a standalone widget and want to integrate it into another widget, you must rename variables to avoid conflicts. Example:
- Standalone pomo uses: `pomo1_state`, `pomo1_duration`, `pomo1_start`
- Panel pomo uses: `panel_pomo1_state`, `panel_pomo1_duration`, `panel_pomo1_start`

### No `strmatch` Function
Eww does NOT have a `strmatch` or regex matching function. For string comparisons:
- Use simple equality: `variable == "value"`
- For pattern matching, use a poll that returns a simple boolean:
```lisp
(defpoll is_headphones :interval "1s"
    `some_command | grep -q "pattern" && echo "true" || echo "false"`)

; Then use simple comparison
:text {is_headphones == "true" ? "yes" : "no"}
```

### Font Awesome Icons
Font Awesome icons require specific font family and weight:
```scss
.icon {
    font-family: "Font Awesome 7 Free";  // or "Font Awesome 6 Free"
    font-weight: 900;  // Required for solid icons
}
```
Icon unicode values (e.g., `\uf025` for headphones) must be inserted as actual UTF-8 characters in yuck files, not escape sequences.

### SCSS Imports
**Critical**: Eww only loads the main `eww.scss` file. Module-specific SCSS files (like `pomo/eww.scss`, `panel/eww.scss`) must be explicitly imported in the main `eww.scss` using `@import` statements. Unlike Yuck files which use `(include)`, SCSS uses standard SASS import syntax:
```scss
@import "./pomo/eww.scss";
@import "./panel/eww.scss";
```
If styles aren't being applied, check that all module SCSS files are imported in the main file.

### Pywal Color Variables
- `color0` is typically the background color - avoid using it for visible elements as it will be invisible
- Use `color1` through `color8` (or higher) for visible elements
- Colors are imported from `~/.cache/wal/colors-eww.yuck`

### Proportional Widget Sizing
**CSS flexbox doesn't work in Eww** - properties like `flex: 1` are not supported. GTK doesn't use flexbox. For proportional sizing of child widgets in a box:

Use `:space-evenly false` on the parent box combined with `:vexpand true` or `:hexpand true` on child widgets:
```lisp
(box :orientation "v"
     :space-evenly false
  (box :height 150)           ; Fixed height
  (box :vexpand true          ; Fills remaining space
       :valign "center")      ; Content centered within
)
```

For equal distribution, use `:space-evenly true` on the parent.

### Vertical Alignment in Expanding Containers
To center content within an expanding container:
```lisp
(box :vexpand true           ; Outer box expands
  (box :valign "center"      ; Inner content centered
       :space-evenly false
    ; content here
  )
)
```

### Circular Progress Widgets
The `circular-progress` widget is great for timers. Key properties:
- `:width` - Overall size
- `:thickness` - Line thickness
- `:value` - Progress 0-100
- `:start-at` - Starting position (75 = top)

For a timer with background ring, use overlay:
```lisp
(overlay
  (circular-progress :class "progress" :value calculated_progress)
  (circular-progress :class "progress-bg" :value 100)
  (label :text "time")
)
```

### Hyprctl Notifications
For user feedback from scripts:
```bash
# Success (type 1, blue)
hyprctl notify 1 3000 "rgb(89b4fa)" "Message"

# Error (type 3, red)
hyprctl notify 3 3000 "rgb(f38ba8)" "Error message"

# Warning (type 2, yellow)
hyprctl notify 2 3000 "rgb(f9e2af)" "Warning"
```
Arguments: type, duration_ms, color, message
