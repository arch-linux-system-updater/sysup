<div align="center">

# sysup

**One command to update and tidy up your whole Arch Linux system.**

[![AUR version](https://img.shields.io/aur/version/sysup?logo=archlinux&label=AUR)](https://aur.archlinux.org/packages/sysup)
[![CI](https://github.com/arch-linux-system-updater/sysup/actions/workflows/ci.yml/badge.svg)](https://github.com/arch-linux-system-updater/sysup/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

</div>

```bash
paru -S sysup
sysup
```

sysup (system-updater) finds what's on your machine and updates **all of it**: repo and AUR packages, Flatpaks, firmware, toolchains, shell plugins and dotfiles. Then it clears out junk and tells you if anything needs your attention.

It needs no setup or config. It works out of the box on Arch, EndeavourOS, CachyOS and other Arch-based distros, and skips anything you don't have installed. If you don't use Snap, you'll never hear about Snap.

An example run (shortened):

```
 sysup 1.0.0  Arch Linux · 7.2.14-arch1-1 · paru
────────────────────────────────────────────────────
  -> Updates available: 42 repo · 3 AUR · 2 Flatpak

==> Arch news  archlinux.org/news
  ✓ No news since your last upgrade.

==> System packages  paru
  $ paru -Syu
  ...

==> Cleanup
  • package cache (keep 2)
  $ sudo paccache -rk2
  • AUR build cache
  • systemd journal
  ✓ Freed 2.3 GiB

==> Health checks
  ✓ Everything looks healthy.

────────────────────────────────────────────────────
 Summary
  ✓ Arch news                nothing new
  ✓ System packages          42 upgraded, 1 installed
  ✓ Flatpak                  system apps, unused system runtimes
  ✓ Dotfiles & desktop       Caelestia dotfiles
  ✓ Cleanup                  freed 2.3 GiB
  ✓ Health checks            all good

  ✓ Done in 1m 52s
```

## Features

### Updates everything

| | |
|---|---|
| **Arch news** | Shows [news](https://archlinux.org/news/) posted since your last upgrade and asks before continuing, so manual interventions never catch you off guard |
| **Mirrors** | Refreshes the mirrorlist with `reflector` or `rate-mirrors` when it's more than 14 days old |
| **Keyring** | Updates `archlinux-keyring` first when a new one is out, so signature errors don't break the upgrade |
| **Packages** | Full upgrade with your AUR helper (**paru**, **yay**, pikaur or trizen, auto-detected), or `pacman -Syu` |
| **Flatpak & Snap** | Updates system and user Flatpaks, removes unused runtimes, runs `snap refresh` |
| **Firmware** | Checks `fwupd` for BIOS/device firmware updates and offers to install them |
| **Dev tools** | `rustup`, `cargo install-update`, `pipx`, `uv tool`, npm globals, `bun`, `deno`, `gh` extensions, `tldr` pages |
| **Plugins** | oh-my-zsh, fisher, tmux tpm, lazy.nvim |
| **Dotfiles** | Dotfile frameworks such as [Caelestia](https://github.com/caelestia-dots) (`caelestia update`) |
| **Your stuff** | Any commands you add, plus scripts in `~/.config/sysup/hooks.d/` |

### Cleans up

- Orphaned packages (asks first)
- pacman package cache: keeps the last 2 versions and drops uninstalled ones
- paru/yay build caches: old builds, leftover build trees, packages you removed
- systemd journal, trimmed to 500 MB / 4 weeks
- Thumbnails you haven't looked at in 30 days
- **Deep clean** (`sysup -d`) also covers:
  - pip, uv, npm, yarn, pnpm, go and cargo caches
  - dangling docker/podman images
  - old coredumps
  - trash items older than 30 days

### Checks your system afterwards

- `.pacnew` / `.pacsave` config files waiting to be merged
- Failed systemd services (system and user)
- AUR packages that need a rebuild after a library update (with `rebuild-detector`)
- Whether you should reboot: new kernel, microcode, glibc, systemd, nvidia, mesa or firmware
- Tips, such as enabling parallel downloads or SSD TRIM

## Safe by design

- **One password prompt.** Run it as your normal user. It asks for sudo once and keeps it alive for the whole run, even through long AUR builds.
- **No partial upgrades.** The keyring is only touched right before a full `-Syu`.
- **Won't break your boot.** It refuses to run if `/boot` is in fstab but not mounted.
- **Handles a stuck pacman lock.** It removes a stale `db.lck`, but never while a package manager is running.
- **Nothing hidden.** Every command is printed before it runs, and `sysup -n` shows them all without changing anything.
- **Asks before risky steps.** That covers orphan removal and firmware installs. Firmware is never installed unattended unless you set `FIRMWARE=yes`.
- **Leaves pacman-owned files alone.** It skips global npm packages in `/usr` and anything else pacman manages.

## Installation

From the AUR:

```bash
paru -S sysup      # or: yay -S sysup
```

Without an AUR helper:

```bash
git clone https://aur.archlinux.org/sysup.git
cd sysup && makepkg -si
```

From source:

```bash
git clone https://github.com/arch-linux-system-updater/sysup.git
cd sysup && sudo make install
```

**Optional extras** that sysup uses when they're installed:

```bash
sudo pacman -S reflector rebuild-detector fwupd flatpak
```

## Usage

```
sysup                      update + clean everything
sysup -y                   fully unattended, never asks
sysup -yd                  unattended, with deep clean
sysup -n                   dry run: show what would happen
sysup -c                   just list available updates
sysup --devel              also rebuild -git AUR packages
sysup --only clean -d      just free up disk space
sysup --skip devtools,plugins
sysup -l                   list all steps
sysup --edit-config        open your config in $EDITOR
sysup -h                   all options
```

**Steps:** `news` `mirrors` `keyring` `packages` `flatpak` `snap` `firmware` `devtools` `plugins` `dotfiles` `extra` `clean` `checks`

**Exit codes:** `0` everything worked, `1` a step failed, `130` interrupted.

## Configuration

You don't need a config file. All options and their defaults are documented in `/etc/sysup.conf`. To change something, run:

```bash
sysup --edit-config
```

This copies the file to `~/.config/sysup/sysup.conf` and opens it. Uncomment the lines you want to change:

```bash
AUR_HELPER=paru           # auto | paru | yay | pikaur | trizen | pacman
DEVEL=yes                 # always rebuild -git packages
ORPHANS=yes               # remove orphans without asking
PKG_CACHE_KEEP=1          # keep only the latest cached version
JOURNAL_MAX_SIZE=200M
SKIP_STEPS=(snap firmware)
EXTRA_COMMANDS=(
    "hyprpm update"
)
```

### Hooks

Executable scripts in `~/.config/sysup/hooks.d/` run during the `extra` step, in alphabetical order. They get `SYSUP_HELPER`, `SYSUP_NOCONFIRM` and `SYSUP_DRY_RUN` in their environment:

```bash
#!/bin/sh
# ~/.config/sysup/hooks.d/10-backup-dotfiles
[ "$SYSUP_DRY_RUN" = 1 ] && exit 0
cd ~/dotfiles && git add -A && git commit -qm "auto: $(date -I)" || true
```

## FAQ

**Do I still need paru/yay?**
For AUR packages, yes. sysup drives your AUR helper rather than replacing it. Without one, it updates repo packages with pacman.

**Is it safe to run with `-y`?**
It's built for that. `-y` answers yes to sysup's own questions and passes `--noconfirm` to the tools it runs. Read the Arch news anyway: sysup shows it, but it can't do manual interventions for you.

**Can I run it from a cron job or timer?**
Running unattended full upgrades on Arch is discouraged. Reading the news and merging `.pacnew` files needs a human. Use `sysup -c` in a timer if you want notifications instead.

**How do I add support for another tool?**
Each step is a small, readable bash function in [`sysup`](sysup). Add a `task "<label>" run <command>` line behind a check that the tool is installed, then open a PR.

## Uninstall

```bash
sudo pacman -Rns sysup
rm -rf ~/.config/sysup ~/.local/state/sysup     # optional: your config and run history
```

## Contributing

Issues and pull requests are welcome. Before opening a PR:

```bash
make check        # bash -n + shellcheck
./sysup -n        # dry run on your machine
```

## License

[MIT](LICENSE)
