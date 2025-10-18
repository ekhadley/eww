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
- `panel/eww.yuck` - A simple centered panel with a clock widget
- `pomo/eww.yuck` - A pomodoro timer widget with dual timers and clock display

Each module has its own `eww.yuck` (widget definitions) and `eww.scss` (styling) files.

### Key Components

**Time Polling**: Main `eww.yuck` defines a `defpoll` named `time` that runs every second, capturing date/time as JSON for use across all widgets.

**Windows**: Two main windows are defined:
- `panel_window` - 40% x 50% centered overlay with clock
- `pomo_window` - 420px x 160px top-center overlay with pomodoro timers

**Pomodoro System**: Dual timer implementation where:
- Each timer has state variables: `pomo{N}_duration`, `pomo{N}_start`, `pomo{N}_state`
- Click to start/pause, scroll to adjust duration
- Visual feedback via circular progress bars that change color when running
- Timers calculate remaining time dynamically based on current time vs start time

### Helper Scripts

**Bash scripts** (in `scripts/bash_scripts/`):
- Window toggle scripts query Hyprland for active screen using `hyprctl -j activeworkspace | jq -r '.monitorID'`
- Then open Eww windows on that specific screen with `eww open [--toggle] <window> --screen $active_screen`

**Zig utilities** (in `scripts/zig/`):
- Built using Zig's build system with `build.zig`
- Includes utilities like network monitor (`network.zig`) and bluetooth status (`bt.zig`)
- Zig binaries are built to `scripts/zig/zig-out/bin/`

### Styling

Main `eww.scss` imports colors from `~/.cache/wal/colors.scss` (pywal integration for system-wide color schemes).

Module-specific SCSS files define widget styling using SCSS variables for colors, with support for hover states and transitions.

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
eww update pomo1_start=<unix_timestamp>
eww update pomo1_state=running
eww update pomo1_duration=3600

# Debug widget values
eww state
eww get <variable_name>
```

### Build Zig Utilities
```bash
cd scripts/zig
zig build
# Outputs to scripts/zig/zig-out/bin/
```

### Toggle Windows (with Hyprland integration)
```bash
./scripts/bash_scripts/pomo_toggle.sh
./scripts/bash_scripts/panel_toggle.sh
```

## Development Workflow

1. Edit `.yuck` files to modify widget structure and behavior
2. Edit `.scss` files to change styling
3. Run `eww reload` to see changes
4. For Zig utilities, rebuild with `zig build` after changes
5. Bash scripts require marking executable with `chmod +x` before use

## Important Notes

- Eww windows use `:stacking "fg"` to appear as overlays
- Window geometry uses `:anchor` for positioning (e.g., "center", "top center")
- All windows are `:focusable false` to avoid interfering with normal workflow
- Color variables from pywal must be available at `~/.cache/wal/colors.scss`
- Hyprland integration requires `hyprctl` and `jq` to be installed

## Eww Gotchas and Learnings

### SCSS Imports
**Critical**: Eww only loads the main `eww.scss` file. Module-specific SCSS files (like `pomo/eww.scss`, `panel/eww.scss`) must be explicitly imported in the main `eww.scss` using `@import` statements. Unlike Yuck files which use `(include)`, SCSS uses standard SASS import syntax:
```scss
@import "./pomo/eww.scss";
@import "./panel/eww.scss";
```
If styles aren't being applied, check that all module SCSS files are imported in the main file.

### Proportional Widget Sizing
**CSS flexbox doesn't work in Eww** - properties like `flex: 1` are not supported. GTK doesn't use flexbox. For proportional sizing of child widgets in a box:

Use `:space-evenly false` on the parent box combined with `:hexpand true` on child widgets:
```lisp
(box :orientation "h"
     :space-evenly false
  (box :hexpand true :width 300)  ; Widget takes 2x space
  (box :hexpand true :width 150)  ; Widget takes 1x space
)
```

Other sizing strategies:
- Explicit pixel widths (fixed, not responsive)
- `:hexpand true` on some children while others use natural size
- Nested boxes with one expanding child and others at fixed widths
