# Copilot Instructions

## Repository Overview

This is a personal dotfiles repository for a Linux desktop/laptop setup centered around **Hyprland** (Wayland) and **i3** (X11 fallback). It uses a **git branch strategy** (not GNU Stow) to manage two distinct machine profiles.

## Branch Strategy & Machine Profiles

Two long-lived branches track separate hardware profiles:

| Branch | User | Machine | Monitors |
|--------|------|---------|----------|
| `main` | `dopeman` | Desktop | `HDMI-A-1`, `DVI-I-1` |
| `laptop` | `Agnosia` | Laptop | `HDMI-A-1`, `eDP-1` |

Branch-specific config blocks are toggled automatically by the **`post-merge` git hook** on every merge. Do not manually remove these markers.

## Branch-Conditional Config Syntax

Many config files contain both desktop and laptop variants gated by section markers:

```ini
### DESKTOP START ###
# monitor = HDMI-A-1, ...
### DESKTOP END ###

### LAPTOP START ###
monitor = eDP-1, ...
### LAPTOP END ###
```

- For `.rasi` / `.kdl` files, the comment char is `//` instead of `#`
- The `post-merge` hook uses `awk` to uncomment the active branch's section and comment out the other
- `noctalia/settings.json` is handled separately via `jq` (no markers — values are rewritten directly)

**Files processed by the hook:**
`.zprofile`, `i3/autostart.i3config`, `i3/audio.i3config`, `i3/gaps.i3config`, `hypr/hyprland.conf`, `hypr/modules/workspaces.conf`, `hypr/modules/looks.conf`, `hypr/modules/audio_controls.conf`, `rofi/config.rasi`, `rofi/applications/spotify-polybar.desktop`, `polybar/modules/tray.ini`, `polybar/modules/volume.ini`, `kitty/kitty.conf`, `noctalia/settings.json`

When editing these files, preserve both `### DESKTOP START/END ###` and `### LAPTOP START/END ###` blocks.

## Directory Structure

Each application gets its own top-level directory mirroring its config destination. Modular configs are split into `modules/` subdirectories and included from a main config file.

```
.dotfiles/
├── hypr/          → ~/.config/hypr/
│   └── modules/   # Sourced from hyprland.conf
├── nvim/          → ~/.config/nvim/
│   └── lua/
│       ├── config/   # Core options, keymaps, LSP
│       └── plugins/  # One file per plugin
├── zsh/           # Sourced wholesale: for file in ~/.dotfiles/zsh/*.zsh; do source "$file"; done
├── polybar/
│   ├── modules/   # One .ini per bar module
│   └── scripts/   # Shell scripts called by modules
├── noctalia/      # Quickshell/QML desktop shell
│   ├── colorschemes/
│   └── plugins/   # kaomoji-provider, screen-recorder
├── rofi/
│   └── applications/
└── post-merge     # Git hook — must be symlinked to .git/hooks/post-merge
```

## Neovim Configuration

- Plugin manager: **lazy.nvim** (bootstrapped in `lua/config/lazy.lua`)
- Lock file: `nvim/lazy-lock.json` — commit changes to this after updating plugins
- Each plugin has its own file under `lua/plugins/`; add new plugins there
- Leader key is `<Space>` (standard lazy.nvim default)
- Indentation: 4 spaces, `expandtab`, no swap/backup files, persistent undo

## Zsh Configuration

Six modular files are all sourced from `.zshrc`:
- `aliases.zsh` — shell aliases (`vim` → `nvim`, `sysup`, `cleanup`, etc.)
- `colorscheme.zsh` — terminal colors
- `envs.zsh` — environment variables and PATH
- `plugins.zsh` — zsh plugin setup
- `prompt.zsh` — PS1 / starship prompt
- `yazi.zsh` — yazi file manager shell integration

Add new shell config to the appropriate existing file rather than creating new ones.

## Theming

**Rose Pine** is the consistent colorscheme across all apps. The GTK theme lives in `rosepine_gtk/gtk/` as a git submodule. Color definitions are duplicated per-app (e.g., `polybar/rosepine.ini`, `noctalia/colors.json`) — update all relevant files when changing theme values.

## Key Conventions

- **No build/test/lint pipeline** — this is a config-only repo with no language runtimes or package managers
- **Hyprland modules** are sourced via `source = ~/.config/hypr/modules/*.conf` — new bindings/rules go in the relevant module file, not `hyprland.conf` directly
- **Polybar modules** are standalone `.ini` files included by the main `config.ini`; scripts live in `polybar/scripts/`
- **Git submodules:** `rosepine_gtk/gtk` — init with `git submodule update --init` after cloning
- The `post-merge` hook must be manually symlinked after cloning: `ln -s ../../post-merge .git/hooks/post-merge`
