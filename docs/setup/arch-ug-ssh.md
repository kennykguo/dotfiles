# Passwordless UG SSH access from Arch Linux

This setup lets you run `ssh ug177` or `ssh ug178` from your Arch computer.
SSH connects through ECF automatically using the aliases in
[`ssh/config`](../../ssh/config).

## 1. Install Git and OpenSSH

```bash
sudo pacman -Syu --needed git openssh
```

Arch's [OpenSSH package](https://archlinux.org/packages/core/x86_64/openssh/files/)
includes `ssh`, `ssh-keygen`, and `ssh-copy-id`. You only need the SSH client
for this setup; there is no need to enable a local `sshd` service.

## 2. Get the dotfiles

On a computer where the repository has not been cloned yet:

```bash
git clone https://github.com/kennykguo/dotfiles.git ~/dotfiles
```

If you already have it at `~/dotfiles`, update it instead:

```bash
git -C ~/dotfiles pull --ff-only
```

The HTTPS clone URL works without first setting up a GitHub SSH key.

## 3. Run the SSH setup

Run this as your regular user, without `sudo`:

```bash
bash ~/dotfiles/ssh/setup.sh
```

The script:

1. Backs up any existing `~/.ssh/config` under `~/.ssh/config-backup.*/config`
   and links the repository's SSH config into place.
2. Creates a local `~/.ssh/id_ed25519` key without a passphrase if that key
   does not already exist. An existing private key is preserved.
3. Registers its public key with ECF, UG177, and UG178, skipping keys that
   are already accepted.
4. Checks fresh logins to all three hosts with password prompts and connection
   reuse disabled.

Enter your ECF password and UG password when prompted. They are separate
accounts, so there may be more than one password entry during setup. If the
UG machines share your home directory, one UG enrollment may cover both.
First connections can also ask you to confirm host fingerprints; verify them
using a trusted university source.

Wait for this success message:

```text
Verified fresh passwordless logins. Connect with: ssh ug177 (or ssh ug178)
```

## 4. Connect

```bash
ssh ug177
# Or:
ssh ug178
```

Both aliases use the username `guokenny` and jump through
`remote.ecf.utoronto.ca`. You do not need to log into ECF manually first.
Keep `~/dotfiles` in place because `~/.ssh/config` is a symlink into it.

## What gets remembered

The servers authorize your computer's public key. The script does not save
your account passwords. Newly generated keys have no passphrase so later
connections do not need an unlock prompt; protect the computer and its private
key. Private keys remain on the computer and are not committed to GitHub.

The config also reuses connections for up to 10 minutes of idle time, but key
authentication is what lets a new connection work without the account
password. Changing an account password normally does not invalidate an
authorized key. Removing the key, changing server policy, or losing the local
private key can require setup again.

Run setup separately on each new computer so it has its own local key.

## If setup or login needs attention

- **An existing key asks for a passphrase:** the script preserves encrypted
  keys. Unlock yours with `ssh-add ~/.ssh/id_ed25519` in a session with an SSH
  agent, then rerun setup. If you have no agent, start one for the current
  shell with `eval "$(ssh-agent -s)"` first. Unlock caching lasts for that
  agent's lifetime.
- **An account password is still requested:** rerun setup and check which
  host fails. ECF and UG must both accept the local key. You can test them
  separately with `ssh ecf`, `ssh ug177`, and `ssh ug178`.
- **A machine times out:** check connectivity and retry when that machine is
  reachable. The script reports success only after all three hosts pass.
- **You only want the aliases:** run
  `bash ~/dotfiles/ssh/setup.sh --config-only`. This installs the config
  without generating or registering a key.

For the shared configuration and macOS notes, see
[`ssh/README.md`](../../ssh/README.md). OpenSSH documents
[key generation](https://man.openbsd.org/ssh-keygen) and
[jump hosts and connection reuse](https://man.openbsd.org/ssh_config).
