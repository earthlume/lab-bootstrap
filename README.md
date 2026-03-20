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

| Tool | Purpose | x86_64 | aarch64 | armhf v7 (Pi 3) | armhf v6 (Pi Zero) |
|------|---------|:------:|:-------:|:----------------:|:------------------:|
| [eza](https://github.com/eza-community/eza) | Modern `ls` | ✅ | ✅ | ✅ | ❌ |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` | ✅ | ✅ | ✅ | ❌ |
| [delta](https://github.com/dandavison/delta) | Git pager | ✅ | ✅ | ✅ | ❌ |
| [dust](https://github.com/bootandy/dust) | Disk usage | ✅ | ✅ | — | ❌ |

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

## Design Philosophy

Every default in this setup externalizes something — a decision, a command you'd have to remember, a sequence you'd have to repeat. The shell remembers so you don't have to. Roughly one in ten professional developers report ADHD or concentration difficulties, and those developers build compensatory systems instinctively: automated tests, linters, aliases, scripts that eliminate repetition. This bootstrapper is that instinct made explicit. But like curb cuts on sidewalks — designed for wheelchairs, used by everyone — these patterns just produce better developer experience regardless of how your brain works.

| Pattern | What it looks like here |
|---------|------------------------|
| External memory | Aliases (`gs`, `ll`, `..`), shared history across terminals, git shortcuts |
| Reduced activation energy | One-command install, `AUTO_CD`, zoxide frecency, `catp` plain mode |
| Recognition over recall | Autosuggestions, history substring search (arrow keys) |
| Fuzzy over exact | fzf Ctrl-R / Ctrl-T — partial recall beats perfect recall |
| Visual anchoring | eza `--icons`, bat syntax highlighting, Starship color-coded prompt |
| Fast feedback | Instant prompt (cached compinit <50ms), async autosuggestions |
| Graceful degradation | ARMv6 fallback prompt, guarded aliases, idempotent re-runs |

None of this requires opt-in. It's the default — because good defaults are the whole point.

## Architecture & Platform Support

The bootstrapper auto-detects CPU architecture (including ARM sub-version via `/proc/cpuinfo`) and available RAM. ARMv6 devices like the Pi Zero and Pi 1 are first-class targets with a gracefully reduced feature set.

### Compatibility Matrix

| Feature | x86_64 | aarch64 (Pi 4/5) | armhf v7 (Pi 3) | armhf v6 (Pi Zero/1) |
|---------|:------:|:-----------------:|:----------------:|:--------------------:|
| Apt tools (bat, rg, fd, fzf, btop, duf) | ✅ | ✅ | ✅ | ✅ |
| GitHub binaries (eza, zoxide, delta) | ✅ | ✅ | ✅ | ❌ |
| dust | ✅ | ✅ | ❌ | ❌ |
| Starship prompt | ✅ | ✅ | ✅ | ❌ (fallback) |
| ZSH + Antidote plugins | ✅ | ✅ | ✅ | ✅ |

### ARMv6 Behavior (Pi Zero / Pi 1)

On ARMv6 devices, the bootstrapper automatically:

- **Skips all GitHub-hosted binaries** — the `armhf` builds published on GitHub target ARMv7 minimum and will not execute on ARMv6
- **Skips Starship** — no ARMv6 build exists. A **pure Zsh fallback prompt** is deployed instead, with teal accents, `vcs_info` git branch display, and SSH-only hostname — same look, zero dependencies
- **Guards aliases** — `ls`→`eza` and `du`→`dust` aliases are wrapped in `command -v` checks so they silently degrade to system defaults when the tools aren't present

All apt-installed tools (bat, ripgrep, fd, fzf, btop, duf, tealdeer) work on ARMv6.

### Low RAM Detection (≤512 MB)

The bootstrapper detects total system RAM from `/proc/meminfo` and sets an `IS_LOW_RAM` flag when the device has 512 MB or less. A warning is emitted at startup for operator visibility.

### Tested Platforms

| Architecture | OS | Example Hosts |
|-------------|-----|---------------|
| x86_64 | Ubuntu 24.04 LTS | Workstations, VMs |
| aarch64 | Raspberry Pi OS (Bookworm) | Pi 4, Pi 5 |
| armhf v7 | Raspberry Pi OS (Bookworm) | Pi 3 |
| armhf v6 | Raspberry Pi OS (Bookworm) | Pi Zero, Pi 1 |

## Module Order

| # | Module | What It Does |
|---|--------|-------------|
| 01 | packages | `apt update` + install base packages and modern CLI tools |
| 02 | binaries | Download eza, zoxide, delta, dust from GitHub releases (skipped on ARMv6) |
| 03 | zsh | Install Antidote, deploy plugins, `chsh` to zsh |
| 04 | starship | Install Starship + config, or deploy fallback prompt on ARMv6 |
| 05 | shell-config | Deploy `.zshrc`, aliases, create `bat`/`fd` symlinks |
| 06 | ssh | Generate ed25519 keypair, configure git identity + delta |
| 07 | motd | Deploy branded MOTD with live system stats (OS-aware strategy) |
| 08 | cleanup | `apt autoremove`, print summary, show SSH pubkey |

## Repo Structure

```
lab-bootstrap/
├── bootstrap.sh          # curl target — installs git, clones repo, runs main.sh
├── main.sh               # sources lib/, runs modules in order
├── modules/              # numbered modules, executed sequentially
├── templates/            # config files deployed to the system
│   ├── prompt-fallback.zsh   # pure Zsh prompt for ARMv6 (no Starship)
│   └── ...
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
