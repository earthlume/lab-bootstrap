#!/usr/bin/env bash
# modules/02-binaries.sh — architecture-aware binary downloads from GitHub releases

log_step "Installing prebuilt binaries"

# ARMv6 (Pi Zero/1) cannot execute GitHub-hosted armhf binaries (they target ARMv7+)
if [[ "$IS_ARMV6" == true ]]; then
    log_info "ARMv6 detected — skipping all GitHub binary installs"
    # return works when sourced (normal path); exit covers standalone execution
    return 0 2>/dev/null || exit 0
fi

TMPDIR="$(mktemp -d)"
# shellcheck disable=SC2064 — TMPDIR must expand now (at definition), not at trap time
trap "rm -rf \"$TMPDIR\"" RETURN

# Map ARCH to Rust target triples used in GitHub release asset names
case "$ARCH" in
    x86_64)  RUST_TARGET="x86_64-unknown-linux-gnu"     ; RUST_TARGET_MUSL="x86_64-unknown-linux-musl" ;;
    aarch64) RUST_TARGET="aarch64-unknown-linux-gnu"     ; RUST_TARGET_MUSL="aarch64-unknown-linux-musl" ;;
    armhf)   RUST_TARGET="arm-unknown-linux-gnueabihf"   ; RUST_TARGET_MUSL="arm-unknown-linux-musleabihf" ;;
esac

# --- eza ---
install_eza() {
    if command_exists eza; then
        log_info "eza already installed — skipping"
        return 0
    fi
    log_info "Installing eza ($ARCH)..."
    local url
    url="$(github_asset_url "eza-community/eza" "eza_${RUST_TARGET}\\.tar\\.gz$")" || return 1
    curl -fsSL "$url" -o "$TMPDIR/eza.tar.gz" || { log_warn "Failed to download eza — skipping"; return 1; }
    tar -xzf "$TMPDIR/eza.tar.gz" -C "$TMPDIR"
    sudo install -m 755 "$TMPDIR/eza" /usr/local/bin/eza
    log_success "eza installed"
}

# --- zoxide ---
install_zoxide() {
    if [[ -x "$TARGET_HOME/.local/bin/zoxide" ]]; then
        log_info "zoxide already installed — skipping"
        return 0
    fi
    log_info "Installing zoxide ($ARCH)..."
    # Create target dir with correct ownership BEFORE installer runs (it installs to ~/.local/bin)
    ensure_dir "$TARGET_HOME/.local/bin"
    chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.local" "$TARGET_HOME/.local/bin"
    # Run installer as the target user so paths and ownership are correct
    sudo -u "$TARGET_USER" bash -c 'curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh' || {
        log_warn "Failed to install zoxide — skipping"
        return 1
    }
    log_success "zoxide installed"
}

# --- delta ---
install_delta() {
    if command_exists delta; then
        log_info "delta already installed — skipping"
        return 0
    fi
    log_info "Installing delta ($ARCH)..."
    local url
    # Try gnu first, fall back to musl (delta 0.19.0+ only ships musl for x86_64)
    url="$(github_asset_url "dandavison/delta" "${RUST_TARGET}\\.tar\\.gz$" 2>/dev/null)" \
        || url="$(github_asset_url "dandavison/delta" "${RUST_TARGET_MUSL}\\.tar\\.gz$")" \
        || return 1
    curl -fsSL "$url" -o "$TMPDIR/delta.tar.gz" || { log_warn "Failed to download delta — skipping"; return 1; }
    tar -xzf "$TMPDIR/delta.tar.gz" -C "$TMPDIR"
    # Delta tarball extracts to a directory like delta-X.Y.Z-target/
    local delta_bin
    delta_bin="$(find "$TMPDIR" -name delta -type f -executable 2>/dev/null | head -1)"
    if [[ -z "$delta_bin" ]]; then
        # Try non-executable (some tarballs)
        delta_bin="$(find "$TMPDIR" -name delta -type f 2>/dev/null | head -1)"
    fi
    if [[ -n "$delta_bin" ]]; then
        sudo install -m 755 "$delta_bin" /usr/local/bin/delta
        log_success "delta installed"
    else
        log_warn "Could not find delta binary in archive — skipping"
        return 1
    fi
}

# --- dust (skip on armhf) ---
install_dust() {
    if is_arch armhf; then
        log_info "dust — no armhf build available, skipping"
        return 0
    fi
    if command_exists dust; then
        log_info "dust already installed — skipping"
        return 0
    fi
    log_info "Installing dust ($ARCH)..."
    local url
    url="$(github_asset_url "bootandy/dust" "${RUST_TARGET}\\.tar\\.gz$")" || return 1
    curl -fsSL "$url" -o "$TMPDIR/dust.tar.gz" || { log_warn "Failed to download dust — skipping"; return 1; }
    tar -xzf "$TMPDIR/dust.tar.gz" -C "$TMPDIR"
    local dust_bin
    dust_bin="$(find "$TMPDIR" -name dust -type f -executable 2>/dev/null | head -1)"
    if [[ -z "$dust_bin" ]]; then
        dust_bin="$(find "$TMPDIR" -name dust -type f 2>/dev/null | head -1)"
    fi
    if [[ -n "$dust_bin" ]]; then
        sudo install -m 755 "$dust_bin" /usr/local/bin/dust
        log_success "dust installed"
    else
        log_warn "Could not find dust binary in archive — skipping"
        return 1
    fi
}

# Run all installs — failures are non-fatal
install_eza || true
install_zoxide || true
install_delta || true
install_dust || true
