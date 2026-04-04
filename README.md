# lab-bootstrap

Universal CLI bootstrapper for ADHD-INTP homelabbers — zsh, modern tools, dopamine-friendly defaults, fleet-wide consistency.

## Quick Start

On a freshly flashed Debian-based host where your provisioning user exists:

```bash
git clone https://github.com/earthlume/lab-bootstrap.git ~/.local/share/lab-bootstrap
bash ~/.local/share/lab-bootstrap/bootstrap.sh
```

Then start a new shell:

```bash
exec zsh
```

That's it. Safe to re-run at any time.

### Work or Fun?

The bootstrap asks one question before it runs: **work or fun?**

- **Work**: Modules 01–08. Pure shell environment + tools. Nothing frivolous.
- **Fun** (default): Modules 01–09. Everything in work, plus the dopamine toolkit — terminal toys, ASCII art, rainbow text, and a more expressive login MOTD.

Default is **fun** — this is a homelab, not a datacenter. Non-interactive runs (`curl | bash`) also default to fun. For scripted deployments:

```bash
./bootstrap.sh --work   # explicit work tier
./bootstrap.sh --fun    # dopamine toolkit included
LAB_MODE=work bash bootstrap.sh  # env var also works
```

The choice is never stored — ask every time. Slash-and-burn means no state.

## What It Does

Sets up a modern CLI environment — ZSH with plugins, Powerlevel10k prompt, and a curated set of tools that replace the crusty defaults. This is **general-purpose shell setup only** — no Docker, no application services, no role-specific software.

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
- **[Powerlevel10k](https://github.com/romkatv/powerlevel10k)** prompt with teal accent, instant prompt, transient prompt — shows hostname (SSH only), directory, git, command duration. Works on all architectures including ARMv6.
- **Aliases** that map old commands to modern replacements (`ls`→`eza`, `cat`→`bat`, `grep`→`rg`, `find`→`fd`)
- **fzf** keybindings (Ctrl-R for history, Ctrl-T for files)

### System Config

- **SSH:** ed25519 keypair generated (displayed at end for GitHub setup)
- **Git:** identity configured (`earthlume`), delta as pager with side-by-side diffs
- **MOTD:** branded login banner with live system info (hostname, OS, uptime, IP, CPU, memory, disk)
- **Timezone:** configurable via `LAB_TIMEZONE` env var (default: UTC)

## The Dopamine Toolkit (Fun Tier)

Module 10 installs terminal toys and visual tools. Every single one sits inert on disk until you type its name — zero daemons, zero auto-start, zero ambient resource usage.

### What Gets Installed

**Terminal toys** (all via apt, all <100KB, all ARM-safe):
`cmatrix` `cbonsai` `tty-clock` `sl` `nyancat` `pipes.sh` `figlet` `toilet` `cowsay` `fortune-mod`

**System splash:**
- `fastfetch` on x86_64 and aarch64 (via PPA on Ubuntu, apt or GitHub .deb elsewhere)
- `pfetch` on armhf and low-RAM devices (single-script download)

**Compiled tools** (skipped on ARMv6):
- `lolcat` — C version from [jaseg/lolcat](https://github.com/jaseg/lolcat), not the Ruby gem
- `no-more-secrets` — the Sneakers decryption effect from [bartobri/no-more-secrets](https://github.com/bartobri/no-more-secrets)

**Python tools** (only if Python 3 is present, skipped on ARMv6):
- `terminaltexteffects` (TTE) — 37 visual text effects, ~207 KB, zero dependencies

**Theme:**
- btop Catppuccin Mocha theme

### Fun-Tier MOTD

When installed with `--fun`, the login MOTD gets enhanced:
- Figlet hostname banner piped through lolcat (if both available)
- fastfetch or pfetch system info
- fortune piped through cowsay (if both available)

Every element is guarded with `command -v` — the MOTD never errors if a tool is missing.

### Architecture Scaling

| Feature | x86_64 | aarch64 (Pi 4/5) | armhf v7 (Pi 3) | armhf v6 (Pi Zero/1) |
|---------|:------:|:-----------------:|:----------------:|:--------------------:|
| Apt fun tools | ✅ | ✅ | ✅ | ✅ |
| fastfetch | ✅ | ✅ | ❌ (pfetch) | ❌ (pfetch) |
| lolcat (C) | ✅ | ✅ | if gcc present | ❌ |
| no-more-secrets | ✅ | ✅ | if gcc present | ❌ |
| TTE | ✅ | ✅ | if pip present | ❌ |
| btop theme | ✅ | ✅ | ✅ | if btop installed |

### What the Dopamine Toolkit Does NOT Install

- `hollywood` — 50+ MB dependency chain, unmaintained, kills low-RAM Pis
- `asciiquarium` — Perl CPAN module hassle
- Ruby `lolcat` gem — pulls entire Ruby runtime
- `genact` — no armhf binary, novelty only

## Design Philosophy

Every default in this setup externalizes something — a decision, a command you'd have to remember, a sequence you'd have to repeat. The shell remembers so you don't have to. Roughly one in ten professional developers report ADHD or concentration difficulties, and those developers build compensatory systems instinctively: automated tests, linters, aliases, scripts that eliminate repetition. This bootstrapper is that instinct made explicit. But like curb cuts on sidewalks — designed for wheelchairs, used by everyone — these patterns just produce better developer experience regardless of how your brain works.

| Pattern | What it looks like here |
|---------|------------------------|
| External memory | Aliases (`gs`, `ll`, `..`), shared history across terminals, git shortcuts |
| Reduced activation energy | One-command install, `AUTO_CD`, zoxide frecency, `catp` plain mode |
| Recognition over recall | Autosuggestions, history substring search (arrow keys) |
| Fuzzy over exact | fzf Ctrl-R / Ctrl-T — partial recall beats perfect recall |
| Visual anchoring | eza `--icons`, bat syntax highlighting, p10k color-coded prompt |
| Fast feedback | Instant prompt (<50ms), transient prompt, async autosuggestions |
| Graceful degradation | p10k works on ARMv6, guarded aliases, idempotent re-runs |
| Dopamine on demand | Fun tier tools spark joy when you need a break — and stay silent when you don't |

None of this requires opt-in. It's the default — because good defaults are the whole point.

## Architecture & Platform Support

The bootstrapper auto-detects CPU architecture (including ARM sub-version via `/proc/cpuinfo`) and available RAM. ARMv6 devices like the Pi Zero and Pi 1 are first-class targets with a gracefully reduced feature set.

### Compatibility Matrix

| Feature | x86_64 | aarch64 (Pi 4/5) | armhf v7 (Pi 3) | armhf v6 (Pi Zero/1) |
|---------|:------:|:-----------------:|:----------------:|:--------------------:|
| Apt tools (bat, rg, fd, fzf, btop, duf) | ✅ | ✅ | ✅ | ✅ |
| GitHub binaries (eza, zoxide, delta) | ✅ | ✅ | ✅ | ❌ |
| dust | ✅ | ✅ | ❌ | ❌ |
| Powerlevel10k prompt | ✅ | ✅ | ✅ | ✅ |
| ZSH + Antidote plugins | ✅ | ✅ | ✅ | ✅ |
| Dopamine toolkit (fun tier) | ✅ (full) | ✅ (full) | ✅ (apt + conditional) | ✅ (apt only) |

### ARMv6 Behavior (Pi Zero / Pi 1)

On ARMv6 devices, the bootstrapper automatically:

- **Skips all GitHub-hosted binaries** — the `armhf` builds published on GitHub target ARMv7 minimum and will not execute on ARMv6
- **Guards aliases** — `ls`→`eza` and `du`→`dust` aliases are wrapped in `command -v` checks so they silently degrade to system defaults when the tools aren't present
- **Scales the dopamine toolkit** — apt tools install fine, compiled tools and TTE are skipped, pfetch replaces fastfetch

Powerlevel10k works on ARMv6 with no degradation — it's pure Zsh, no binary required. All apt-installed tools (bat, ripgrep, fd, fzf, btop, duf, tealdeer) work on ARMv6.

### Low RAM Detection (≤512 MB)

The bootstrapper detects total system RAM from `/proc/meminfo` and sets an `IS_LOW_RAM` flag when the device has 512 MB or less. A warning is emitted at startup for operator visibility. Low-RAM devices get pfetch instead of fastfetch in the fun tier.

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
| 04 | prompt | Deploy Powerlevel10k config (loaded via Antidote, works on all architectures) |
| 05 | shell-config | Deploy `.zshrc`, aliases, create `bat`/`fd` symlinks |
| 06 | ssh | Generate ed25519 keypair, configure git identity + delta |
| 07 | motd | Deploy branded MOTD with live system stats (OS-aware, fun-tier enhanced) |
| 08 | cleanup | `apt autoremove`, print summary, show SSH pubkey |
| 09 | docker-prep | Create `/opt/stacks`, Docker readiness check |
| 10 | dopamine | Terminal toys, system splash, visual tools (**fun tier only**) |

## Repo Structure

```
lab-bootstrap/
├── bootstrap.sh          # curl target — installs git, clones repo, runs main.sh
├── main.sh               # sources lib/, runs modules in order, handles tier selection
├── modules/              # numbered modules, executed sequentially
│   ├── 04-prompt.sh     # deploys Powerlevel10k config
│   ├── 09-docker-prep.sh # /opt/stacks setup when Docker is present
│   └── 10-dopamine.sh   # fun-tier terminal toys and visual tools
├── templates/            # config files deployed to the system
│   ├── p10k.zsh              # Powerlevel10k config (lean style, teal accent)
│   ├── motd-fun              # enhanced MOTD for fun tier
│   └── ...
├── lib/                  # shared functions (logging, detection, helpers)
├── LICENSE               # MIT
└── README.md
```

## Configuration

The bootstrapper uses environment variables for fleet-specific settings. All have sensible defaults.

| Variable | Default | Purpose |
|----------|---------|---------|
| `LAB_DOMAIN` | `lab.example` | Domain suffix for SSH key comments and MOTD hostname display |
| `LAB_SUBNET` | *(empty)* | Preferred IP subnet for MOTD and `labip` alias (e.g. `10.4.20`). If unset, shows first non-loopback IP |
| `LAB_TIMEZONE` | `UTC` | Timezone set during bootstrap (e.g. `America/Los_Angeles`) |
| `LAB_MODE` | `fun` | Tier selection: `work` or `fun`. CLI flags `--work`/`--fun` override this |
| `TARGET_USER` | `lume` | User account the bootstrap configures (set in `lib/utils.sh`) |

Example: customize for your fleet:

```bash
LAB_DOMAIN=mylab.local LAB_SUBNET=192.168.1 LAB_TIMEZONE=Europe/London bash bootstrap.sh --work
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
