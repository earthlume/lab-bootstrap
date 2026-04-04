#!/usr/bin/env bash
# modules/09-dopamine.sh — the dopamine toolkit
# Fun-tier only. Every tool sits inert on disk until explicitly invoked.
# Zero ambient resource usage, zero daemons, zero auto-start.

log_step "Installing the dopamine toolkit — because terminals should spark joy"

# ============================================================================
# APT tools — tiny, architecture-safe, all available in Debian/Ubuntu/Pi OS
# ============================================================================

DOPAMINE_APT_PKGS=(
    cmatrix         # Matrix digital rain
    cbonsai         # animated bonsai tree
    tty-clock       # terminal clock / screensaver
    sl              # steam locomotive (ls typo punishment)
    nyancat         # rainbow cat animation
    figlet          # ASCII text banners
    toilet          # colored ASCII text (libcaca)
    cowsay          # ASCII art speech bubbles
    fortune-mod     # random quotes
)

log_info "Installing apt fun tools..."
# Filter to only packages available in the current repos
AVAILABLE_PKGS=()
for pkg in "${DOPAMINE_APT_PKGS[@]}"; do
    if apt-cache show "$pkg" &>/dev/null; then
        AVAILABLE_PKGS+=("$pkg")
    else
        log_warn "$pkg not in repos — skipping"
    fi
done

if [[ ${#AVAILABLE_PKGS[@]} -gt 0 ]]; then
    sudo apt-get install -y -qq "${AVAILABLE_PKGS[@]}"
    log_success "Apt fun tools installed: ${AVAILABLE_PKGS[*]}"
fi

# pipes.sh — animated pipes screensaver
if ! command_exists pipes.sh; then
    if apt-cache show pipes.sh &>/dev/null; then
        sudo apt-get install -y -qq pipes.sh
        log_success "pipes.sh installed (apt)"
    else
        # Fall back to git clone from pipeseroni
        PIPES_DIR="/opt/pipes.sh"
        if [[ ! -d "$PIPES_DIR" ]]; then
            log_info "pipes.sh not in repos — cloning from pipeseroni/pipes.sh..."
            if git clone --depth=1 https://github.com/pipeseroni/pipes.sh.git "$PIPES_DIR" 2>/dev/null; then
                sudo ln -sf "$PIPES_DIR/pipes.sh" /usr/local/bin/pipes.sh
                log_success "pipes.sh installed (git clone)"
            else
                log_warn "Failed to clone pipes.sh — skipping"
            fi
        else
            log_info "pipes.sh already installed — skipping"
        fi
    fi
else
    log_info "pipes.sh already installed — skipping"
fi

# ============================================================================
# System splash — fastfetch (full systems) or pfetch (ARMv6 / low RAM)
# ============================================================================

install_fastfetch() {
    if command_exists fastfetch; then
        log_info "fastfetch already installed — skipping"
        return 0
    fi

    # Not in Ubuntu 24.04 repos — try PPA first, then GitHub .deb
    if [[ "$OS_ID" == "ubuntu" ]]; then
        log_info "Adding fastfetch PPA for Ubuntu..."
        if sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch 2>/dev/null; then
            sudo apt-get update -qq
            sudo apt-get install -y -qq fastfetch && {
                log_success "fastfetch installed (PPA)"
                return 0
            }
        fi
        log_warn "PPA failed — trying GitHub .deb download..."
    else
        # Debian/Pi OS — try apt first (available in newer repos)
        if apt-cache show fastfetch &>/dev/null; then
            sudo apt-get install -y -qq fastfetch && {
                log_success "fastfetch installed (apt)"
                return 0
            }
        fi
    fi

    # GitHub .deb fallback for x86_64 and aarch64
    local deb_pattern
    case "$ARCH" in
        x86_64)  deb_pattern="linux-amd64\\.deb$" ;;
        aarch64) deb_pattern="linux-aarch64\\.deb$" ;;
        *)       log_warn "No fastfetch binary for $ARCH — will try pfetch"; return 1 ;;
    esac

    local deb_url
    deb_url="$(github_asset_url "fastfetch-cli/fastfetch" "$deb_pattern" 2>/dev/null)" || {
        log_warn "Failed to find fastfetch .deb — will try pfetch"
        return 1
    }

    local tmpfile
    tmpfile="$(mktemp --suffix=.deb)"
    if curl -fsSL "$deb_url" -o "$tmpfile"; then
        sudo dpkg -i "$tmpfile" 2>/dev/null || sudo apt-get install -f -y -qq
        rm -f "$tmpfile"
        log_success "fastfetch installed (GitHub .deb)"
        return 0
    fi

    rm -f "$tmpfile"
    log_warn "Failed to download fastfetch — will try pfetch"
    return 1
}

install_pfetch() {
    if command_exists pfetch; then
        log_info "pfetch already installed — skipping"
        return 0
    fi
    log_info "Installing pfetch (lightweight system info)..."
    local pfetch_url="https://raw.githubusercontent.com/Un1q32/pfetch/master/pfetch"
    ensure_dir "$TARGET_HOME/.local/bin"
    chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.local" "$TARGET_HOME/.local/bin"
    if curl -fsSL "$pfetch_url" -o "$TARGET_HOME/.local/bin/pfetch"; then
        chmod +x "$TARGET_HOME/.local/bin/pfetch"
        chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.local/bin/pfetch"
        log_success "pfetch installed"
        return 0
    fi
    log_warn "Failed to download pfetch — skipping"
    return 1
}

# ARMv6 / low RAM → pfetch only. Others → try fastfetch, fall back to pfetch.
if [[ "$IS_ARMV6" == true ]] || [[ "$IS_LOW_RAM" == true ]]; then
    install_pfetch || true
elif ! install_fastfetch; then
    install_pfetch || true
fi

# ============================================================================
# Compiled tools — skip on ARMv6, warn on failure
# ============================================================================

if [[ "$IS_ARMV6" != true ]]; then

    # lolcat (C version) — rainbow text colorizer
    if [[ ! -x /usr/local/bin/lolcat ]]; then
        if command_exists gcc && command_exists make; then
            log_info "Building lolcat (C version)..."
            LOLCAT_DIR="$(mktemp -d)"
            if git clone --depth=1 https://github.com/jaseg/lolcat.git "$LOLCAT_DIR" 2>/dev/null; then
                if make -C "$LOLCAT_DIR" 2>/dev/null; then
                    sudo install -m 755 "$LOLCAT_DIR/lolcat" /usr/local/bin/lolcat
                    log_success "lolcat installed"
                else
                    log_warn "lolcat build failed (missing gcc?) — skipping"
                fi
            else
                log_warn "Failed to clone lolcat — skipping"
            fi
            rm -rf "$LOLCAT_DIR"
        elif is_arch armhf; then
            # ARMv7 without gcc — skip quietly
            log_info "lolcat — gcc not present on armhf, skipping build"
        else
            log_info "lolcat — gcc/make not found, installing build tools..."
            sudo apt-get install -y -qq gcc make 2>/dev/null || true
            if command_exists gcc && command_exists make; then
                LOLCAT_DIR="$(mktemp -d)"
                if git clone --depth=1 https://github.com/jaseg/lolcat.git "$LOLCAT_DIR" 2>/dev/null; then
                    if make -C "$LOLCAT_DIR" 2>/dev/null; then
                        sudo install -m 755 "$LOLCAT_DIR/lolcat" /usr/local/bin/lolcat
                        log_success "lolcat installed"
                    else
                        log_warn "lolcat build failed — skipping"
                    fi
                fi
                rm -rf "$LOLCAT_DIR"
            fi
        fi
    else
        log_info "lolcat already installed — skipping"
    fi

    # no-more-secrets — decryption effect from the movie Sneakers
    if [[ ! -x /usr/local/bin/nms ]]; then
        if command_exists gcc && command_exists make; then
            log_info "Building no-more-secrets..."
            NMS_DIR="$(mktemp -d)"
            if git clone --depth=1 https://github.com/bartobri/no-more-secrets.git "$NMS_DIR" 2>/dev/null; then
                if make -C "$NMS_DIR" nms 2>/dev/null; then
                    sudo install -m 755 "$NMS_DIR/bin/nms" /usr/local/bin/nms
                    log_success "no-more-secrets installed"
                else
                    log_warn "no-more-secrets build failed — skipping"
                fi
            else
                log_warn "Failed to clone no-more-secrets — skipping"
            fi
            rm -rf "$NMS_DIR"
        else
            log_info "no-more-secrets — gcc/make not available, skipping"
        fi
    else
        log_info "no-more-secrets already installed — skipping"
    fi

fi  # end IS_ARMV6 != true

# ============================================================================
# Python tools — only if python3 is present
# ============================================================================

if command_exists python3; then
    # terminaltexteffects (TTE) — 37 visual text effects, zero deps beyond stdlib
    if ! command_exists tte; then
        # Skip on ARMv6 — too slow to be fun
        if [[ "$IS_ARMV6" != true ]]; then
            log_info "Installing terminaltexteffects..."
            if command_exists pipx; then
                if pipx install terminaltexteffects 2>/dev/null; then
                    log_success "TTE installed (pipx)"
                else
                    log_warn "TTE install via pipx failed — skipping"
                fi
            else
                # Find a working pip command
                PIP_CMD="$(command -v pip3 2>/dev/null || command -v pip 2>/dev/null || true)"
                if [[ -z "$PIP_CMD" ]]; then
                    log_info "pip not found — installing python3-pip..."
                    sudo apt-get install -y -qq python3-pip 2>/dev/null || true
                    PIP_CMD="$(command -v pip3 2>/dev/null || command -v pip 2>/dev/null || true)"
                fi
                if [[ -n "$PIP_CMD" ]]; then
                    # Try --break-system-packages first (required on Debian 12+ / Ubuntu 23.04+)
                    # Fall back without it for older pip versions
                    if sudo "$PIP_CMD" install --break-system-packages terminaltexteffects 2>/dev/null; then
                        log_success "TTE installed (pip)"
                    elif sudo "$PIP_CMD" install terminaltexteffects 2>/dev/null; then
                        log_success "TTE installed (pip, legacy mode)"
                    else
                        log_warn "TTE install via pip failed — skipping"
                    fi
                else
                    log_warn "No pip available — TTE skipped"
                fi
            fi
        fi
    else
        log_info "TTE already installed — skipping"
    fi
fi

# ============================================================================
# Theme: btop Catppuccin Mocha
# ============================================================================

if command_exists btop; then
    BTOP_THEME_DIR="$TARGET_HOME/.config/btop/themes"
    ensure_dir "$BTOP_THEME_DIR"
    chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config/btop"
    if curl -sL -o "$BTOP_THEME_DIR/catppuccin_mocha.theme" \
        "https://raw.githubusercontent.com/catppuccin/btop/main/themes/catppuccin_mocha.theme" 2>/dev/null; then
        chown "$TARGET_USER:$TARGET_USER" "$BTOP_THEME_DIR/catppuccin_mocha.theme"
        log_success "btop Catppuccin Mocha theme installed"
    else
        log_warn "Failed to download btop theme — skipping"
    fi
else
    log_info "btop not installed — skipping theme"
fi

# ============================================================================
# Theme: Catppuccin Mocha for bat + delta
# ============================================================================

if command_exists bat; then
    BAT_THEME_DIR="$TARGET_HOME/.config/bat/themes"
    ensure_dir "$BAT_THEME_DIR"
    chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config/bat"
    if curl -sL -o "$BAT_THEME_DIR/Catppuccin Mocha.tmTheme" \
        "https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Mocha.tmTheme" 2>/dev/null; then
        chown "$TARGET_USER:$TARGET_USER" "$BAT_THEME_DIR/Catppuccin Mocha.tmTheme"
        sudo -u "$TARGET_USER" bat cache --build 2>/dev/null || true
        log_success "bat Catppuccin Mocha theme installed"
    else
        log_warn "Failed to download bat theme — skipping"
    fi
fi

# delta uses bat's theme engine — just set the syntax-theme in git config
if command_exists delta; then
    sudo -u "$TARGET_USER" git config --global delta.syntax-theme "Catppuccin Mocha"
    log_info "delta syntax theme set to Catppuccin Mocha"
fi

log_success "Dopamine toolkit complete"
