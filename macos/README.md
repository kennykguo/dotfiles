# macOS dotfiles

This folder contains the shared macOS configuration for:

- OmniWM (Niri layout, two 50% columns, momentum trackpad scrolling)
- SketchyBar with clickable OmniWM workspaces
- Kitty
- Neovim
- Fish and Zsh
- Nix client settings
- Git

The existing Linux/Hyprland configuration remains at the repository root.

## Install

Homebrew must already be installed. Then run:

```sh
git clone git@github.com:kennykguo/dotfiles.git ~/dotfiles
cd ~/dotfiles
./macos/install.sh
```

On a machine where the applications are already installed, use
`./macos/install.sh --skip-brew` to link configs without changing packages.

SketchyBar is distributed through the `FelixKratz/formulae` Homebrew tap. If a
recent Homebrew release asks whether to trust that tap, review it and run
`brew trust FelixKratz/formulae` explicitly before rerunning the installer.

The installer uses symlinks so repository changes apply immediately. Existing
targets are moved to a timestamped directory under `~/.dotfiles-backup` before
links are created.

## Required macOS setup

1. Open **System Settings → Desktop & Dock**.
2. Turn **Stage Manager** off.
3. Under Mission Control, turn **Displays have separate Spaces** on.
4. Log out and back in if that Spaces setting changed.
5. Launch OmniWM and grant Accessibility and Input Monitoring. Screen Recording
   is optional but enables thumbnails and captured visuals.
6. Enable **Start at Login** in OmniWM.
7. Keep one native macOS Space per display and use OmniWM workspaces instead.

The included OmniWM configuration enables local IPC because SketchyBar uses
`omniwmctl` to display and switch workspaces. OmniWM's own workspace bar is
disabled to prevent it from overlapping SketchyBar.

For the 13-inch MacBook display, the **More Space** 1710-point scaled resolution
allows two 831-point Niri columns. This is wide enough for Discord's 800-point
native minimum window width.

## Niri behavior

- At most two columns are visible at once.
- New columns default to 50% width.
- Additional apps remain in the scrolling strip outside the viewport.
- Three-finger column scrolling uses Momentum mode.

Useful shortcuts:

| Shortcut | Action |
| --- | --- |
| `Option + Arrow` | Focus a neighboring window |
| `Option + Shift + Arrow` | Move a window |
| `Option + Comma/Period` | Cycle column width presets |
| `Option + 1–9` | Switch workspace |
| `Option + Return` | Toggle OmniWM fullscreen |

## Updating the tracked config

Because the installed files are symlinked, changes made by OmniWM or edits made
under `~/.config` appear directly in this repository. Review changes before
committing, especially after OmniWM schema upgrades.

Runtime state is intentionally excluded. Clipboard history, cached window
placements, logs, application databases, credentials, and macOS permissions are
not portable configuration and are not tracked here.
