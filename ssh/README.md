# SSH configuration

For a step-by-step walkthrough, see
[Passwordless UG SSH access from Arch Linux](../docs/setup/arch-ug-ssh.md).

`config` is a copy of Kenny's SSH config, including `ecf`, `ug177`, `ug178`,
`wsl`, `frenchables`, and `jetson`. The UG aliases connect through ECF using
`ProxyJump`, so `ssh ug177` works from off campus without a separate manual
login to ECF.

## Set up another computer

On macOS, Linux, or Windows with WSL, install OpenSSH (including `ssh-copy-id`)
and run:

```sh
git clone https://github.com/kennykguo/dotfiles.git ~/dotfiles
bash ~/dotfiles/ssh/setup.sh
ssh ug177
```

If the repository is already cloned, pull its latest changes and run the setup
script. HTTPS cloning avoids requiring a GitHub SSH key on the new computer.

On Arch Linux, install the prerequisites with
`sudo pacman -Syu --needed git openssh`, then run the commands above. Arch's
[`openssh` package](https://archlinux.org/packages/core/x86_64/openssh/files/)
includes `ssh-copy-id`. This uses the SSH client; no local `sshd` service needs
to be enabled. Run the setup script as your regular user, without `sudo`.

The script backs up an existing `~/.ssh/config` inside a private directory
under `~/.ssh/`, then symlinks the tracked config. Keep the repository in place.
It creates `~/.ssh/id_ed25519` locally with no passphrase if that key does not
exist, and enrolls its public key on ECF and both UG hosts. Existing private
keys are preserved. Only public keys are sent to the servers; passwords and
private keys are never stored in this repository.

Enter the ECF password and the UG password when prompted during enrollment.
These are separate accounts, so setup may need more than one password entry.
You may also see first-connection host-key confirmation prompts; verify the
fingerprints through a trusted university source. Already enrolled keys are
skipped; if the UG hosts share a home directory, one UG enrollment may cover
both. The final checks establish fresh connections on both hops with password
prompts disabled, rather than relying on cached sessions.

After successful enrollment, use `ssh ug177` or `ssh ug178` without the account
password. Account password changes normally do not invalidate an authorized
SSH key; removing the key or server policy changes can require setup again.
Each new computer runs setup with its own local key.

New keys have no passphrase to meet the no-prompt login preference, so protect
the computer and its private key. If reusing an existing encrypted key, keep its
passphrase and use an SSH agent to unlock it. On macOS, run
`ssh-add --apple-use-keychain ~/.ssh/id_ed25519` and configure `UseKeychain yes`
and `AddKeysToAgent yes` for the ECF and UG hosts to reuse the saved passphrase.
On Linux/WSL, unlock the key with the desktop/session SSH agent. Passphrase
caching follows that agent's lifetime.

To install only the config without generating or enrolling keys:

```sh
bash ~/dotfiles/ssh/setup.sh --config-only
```

The macOS dotfiles installer also links this config. Keys for `wsl` and
`frenchables` (`~/.ssh/id_rsa`) are managed separately; this setup enrolls only
ECF and UG access.

References: [OpenSSH key generation](https://man.openbsd.org/ssh-keygen) and
[SSH jump hosts and connection reuse](https://man.openbsd.org/ssh_config).
