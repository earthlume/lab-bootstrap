# lab-bootstrap

Universal CLI bootstrapper for [lab.hoens.fun](https://lab.hoens.fun) — one command to set up a consistent, polished shell environment across every node in the fleet.

## Quick Start

On a freshly flashed Debian-based host where user `lume` exists:

```bash
curl -sL https://raw.githubusercontent.com/earthlume/lab-bootstrap/main/bootstrap.sh | bash
```

Then start a new shell:

```bash
exec zsh
```

That's it. Safe to re-run at any time.

## What It Does

Sets up a modern CLI environment — ZSH with plugins, Starship prompt, and a curated set of tools that replace the crusty defaults. This is **general-purpose shell setup only** — no Docker, no application services, no role-specific software.

### Packages (via apt)

`bat` `ripgrep` `fd-find` `fzf` `tealdeer` `duf` `btop` `tmux` `neovim` `ncdu` `jq` `tree` and more

### Prebuilt Binaries (architecture-aware)

| Tool | Purpose | x86_64 | aarch64 | armhf |
|------|---------|:------:|:-------:|:-----:|
| [eza](https://github.com/eza-community/eza) | Modern `ls` | Yes | Yes | Yes |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` | Yes | Yes | Yes |
| [delta](https://github.com/dandavison/delta) | Git pager | Yes | Yes | Yes |
| [dust](https://github.com/bootandy/dust) | Disk usage | Yes | Yes | — |

### Shell Setup

- **ZSH** as default shell with [Antidote](https://github.com/mattmc3/antidote) plugin manager
- **Plugins:** autosuggestions, syntax highlighting, history substring search, sudo (double-ESC), alias reminders
- **[Starship](https://starship.rs)** prompt with teal accent — shows hostname (SSH only), directory, git, command duration
- **Aliases** that map old commands to modern replacements (`ls`→`eza`, `cat`→`bat`, `grep`→`rg`, `find`→`fd`)
- **fzf** keybindings (Ctrl-R for history, Ctrl-T for files)

### System Config

- **SSH:** ed25519 keypair generated (displayed at end for GitHub setup)
- **Git:** identity configured (`earthlume`), delta as pager with side-by-side diffs
- **MOTD:** branded login banner with live system info (hostname, OS, uptime, IP, CPU, memory, disk)

## Architecture Support

Tested across the lab.hoens.fun fleet:

| Architecture | OS | Example Hosts |
|-------------|-----|---------------|
| x86_64 | Ubuntu 24.04 LTS | Workstations, VMs |
| aarch64 | Raspberry Pi OS (Bookworm) | Pi 4, Pi 5 |
| armhf | Raspberry Pi OS (Bookworm) | Pi 2B (1GB) |

## Module Order

| # | Module | What It Does |
|---|--------|-------------|
| 01 | packages | `apt update` + install base packages and modern CLI tools |
| 02 | binaries | Download eza, zoxide, delta, dust from GitHub releases |
| 03 | zsh | Install Antidote, deploy plugins, `chsh` to zsh |
| 04 | starship | Install Starship, deploy prompt config |
| 05 | shell-config | Deploy `.zshrc`, aliases, create `bat`/`fd` symlinks |
| 06 | ssh | Generate ed25519 keypair, configure git identity + delta |
| 07 | motd | Deploy branded MOTD with live system stats |
| 08 | cleanup | `apt autoremove`, print summary, show SSH pubkey |

## Repo Structure

```
lab-bootstrap/
├── bootstrap.sh          # curl target — installs git, clones repo, runs main.sh
├── main.sh               # sources lib/, runs modules in order
├── modules/              # numbered modules, executed sequentially
├── templates/            # config files deployed to the system
├── lib/                  # shared functions (logging, detection, helpers)
├── LICENSE               # MIT
└── README.md
```

## Per-Host Customization

Drop a `~/.zshrc.local` file for host-specific overrides (env vars, project aliases, etc.). It's sourced at the end of `.zshrc` and is not managed by the bootstrap.

## What This Does NOT Do

- Install role-specific software (Ollama, HAILO, Docker, Home Assistant)
- Configure networking, DNS, or firewall
- Set hostname or create users
- Manage systemd services
- Install Nerd Fonts (install those on your SSH client, not the server)

## License

MIT
