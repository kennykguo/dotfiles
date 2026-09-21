#!/usr/bin/env bash

set -euo pipefail

macos_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
install_packages=true

if [[ "${1:-}" == "--skip-brew" ]]; then
  install_packages=false
elif [[ $# -gt 0 ]]; then
  echo "Usage: $0 [--skip-brew]" >&2
  exit 2
fi

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This installer is intended for macOS." >&2
  exit 1
fi

if $install_packages; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "Install Homebrew first: https://brew.sh" >&2
    exit 1
  fi

  brew bundle --file "$macos_dir/Brewfile"
fi

link_config() {
  local source_path="$1"
  local target_path="$2"

  mkdir -p "$(dirname "$target_path")"

  if [[ -L "$target_path" && "$(readlink "$target_path")" == "$source_path" ]]; then
    return
  fi

  if [[ -e "$target_path" || -L "$target_path" ]]; then
    local relative_target="${target_path#$HOME/}"
    mkdir -p "$backup_dir/$(dirname "$relative_target")"
    if ! mv "$target_path" "$backup_dir/$relative_target"; then
      echo "Skipped $target_path: it could not be moved (check ownership)." >&2
      return
    fi
    echo "Backed up $target_path"
  fi

  ln -s "$source_path" "$target_path"
  echo "Linked $target_path"
}

for app in fish kitty nix nvim omniwm sketchybar; do
  link_config "$macos_dir/.config/$app" "$HOME/.config/$app"
done

for dotfile in .gitconfig .zprofile .zshrc; do
  link_config "$macos_dir/$dotfile" "$HOME/$dotfile"
done

chmod +x "$macos_dir/.config/sketchybar/sketchybarrc" \
  "$macos_dir/.config/sketchybar/plugins/"*.sh

if command -v sketchybar >/dev/null 2>&1; then
  if launchctl print "gui/$(id -u)/homebrew.mxcl.sketchybar" >/dev/null 2>&1; then
    sketchybar --reload
  elif command -v brew >/dev/null 2>&1; then
    brew services start sketchybar
  fi
fi

echo
echo "Configuration installed. Existing files were backed up under:"
echo "  $backup_dir"
echo
echo "Finish the OmniWM permissions and macOS settings listed in macos/README.md."
