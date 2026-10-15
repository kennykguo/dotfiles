#!/usr/bin/env bash

set -euo pipefail
umask 077

ssh_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_only=false
if [[ "${1:-}" == "--config-only" && $# -eq 1 ]]; then
  config_only=true
elif [[ $# -gt 0 ]]; then
  echo "Usage: $0 [--config-only]" >&2
  exit 2
fi

if ! $config_only; then
  for command_name in ssh ssh-keygen ssh-copy-id; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
      echo "Install $command_name first, then rerun this script." >&2
      exit 1
    fi
  done
fi

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
config_path="$HOME/.ssh/config"
if [[ ! -L "$config_path" || "$(readlink "$config_path")" != "$ssh_dir/config" ]]; then
  if [[ -e "$config_path" || -L "$config_path" ]]; then
    backup_dir="$(mktemp -d "$HOME/.ssh/config-backup.XXXXXXXX")"
    mv "$config_path" "$backup_dir/config"
    echo "Backed up the existing SSH config to $backup_dir/config"
  fi
  ln -s "$ssh_dir/config" "$config_path"
fi
echo "Linked $config_path"

if $config_only; then
  exit 0
fi

key_path="$HOME/.ssh/id_ed25519"
if [[ ! -e "$key_path" && ! -L "$key_path" ]]; then
  if [[ -e "$key_path.pub" || -L "$key_path.pub" ]]; then
    echo "Found $key_path.pub without its private key; restore the key or move the public file first." >&2
    exit 1
  fi
  echo "Creating a local SSH key without a passphrase for passwordless login."
  ssh-keygen -q -t ed25519 -N '' -f "$key_path" -C "$(id -un)@$(hostname)-utoronto"
elif [[ ! -f "$key_path" ]]; then
  echo "Cannot read the existing private key at $key_path; it was left unchanged." >&2
  exit 1
fi

# Derive the public key from the private key, so a stale .pub cannot enroll
# the wrong key. An existing encrypted key may prompt for its passphrase.
public_key="$(ssh-keygen -y -f "$key_path")"
if [[ -L "$key_path.pub" ]]; then
  echo "Refusing to replace the public-key symlink at $key_path.pub." >&2
  exit 1
fi
printf '%s\n' "$public_key" > "$key_path.pub"
chmod 600 "$key_path" "$key_path.pub"

# ECF is a separate login from UG. Enroll the jump host first so subsequent
# UG connections can use this key for the jump, too. ssh-copy-id skips keys
# already accepted, including when UG machines share an authorized_keys file.
for host in ecf ug177 ug178; do
  echo "Setting up key login for $host (enter that account's password if asked)."
  ssh-copy-id -i "$key_path.pub" -o IdentitiesOnly=yes "$host"
done

# Disable connection reuse on both hops: a cached password login must not
# make verification appear to pass. BatchMode also forbids password prompts.
fresh_options=(-o BatchMode=yes -o ControlMaster=no -o ControlPath=none -o ConnectTimeout=15)
ssh "${fresh_options[@]}" ecf true
for host in ug177 ug178; do
  ssh "${fresh_options[@]}" \
    -o 'ProxyCommand=ssh -o BatchMode=yes -o ControlMaster=no -o ControlPath=none -o ConnectTimeout=15 -W %h:%p ecf' \
    "$host" true
done

echo "Verified fresh passwordless logins. Connect with: ssh ug177 (or ssh ug178)"
