#!/usr/bin/env bash
# modules/08-cleanup.sh — apt cleanup, summary, and SSH pubkey display

log_step "Cleanup"

# Disable unnecessary services on non-Pi headless servers
if [[ "$IS_PI" != true ]] && systemctl is-active --quiet ModemManager 2>/dev/null; then
    log_info "Disabling ModemManager (no modem on headless server)..."
    sudo systemctl disable --now ModemManager
    log_success "ModemManager disabled"
fi

log_info "Running apt autoremove..."
sudo apt-get autoremove -y -qq
sudo apt-get clean -qq
log_success "Apt cleanup done"

# Summary
log_step "Summary"

log_success "Base packages installed (bat, ripgrep, fd, fzf, btop, duf, tealdeer, ...)"
# Helper: check if a command exists in root's PATH or the target user's ~/.local/bin
check_installed() {
    command -v "$1" &>/dev/null || [[ -x "$TARGET_HOME/.local/bin/$1" ]]
}

check_installed eza && log_success "eza installed" || log_warn "eza not installed"
check_installed zoxide && log_success "zoxide installed" || log_warn "zoxide not installed"
check_installed delta && log_success "delta installed" || log_warn "delta not installed"
if ! is_arch armhf; then
    check_installed dust && log_success "dust installed" || log_warn "dust not installed"
fi
log_success "Powerlevel10k prompt configured (via Antidote)"
log_success "ZSH configured with Antidote plugins"
log_success "Shell aliases and config deployed"
log_success "MOTD deployed"

# --- System overview ---
log_step "System overview"

# Docker
if command_exists docker; then
    DOCKER_VER="$(docker --version 2>/dev/null | head -1)"
    log_info "Docker: $DOCKER_VER"
    if id -nG "$TARGET_USER" 2>/dev/null | grep -qw docker; then
        log_success "$TARGET_USER is in the docker group"
    else
        log_warn "$TARGET_USER is NOT in the docker group — run: sudo usermod -aG docker $TARGET_USER"
    fi
else
    log_info "Docker: not installed"
fi

# zsh
if command_exists zsh; then
    log_info "zsh: $(zsh --version 2>/dev/null | head -1)"
else
    log_warn "zsh: not installed"
fi

# git identity
GIT_NAME="$(sudo -u "$TARGET_USER" git config --global user.name 2>/dev/null || true)"
GIT_EMAIL="$(sudo -u "$TARGET_USER" git config --global user.email 2>/dev/null || true)"
if [[ -n "$GIT_NAME" ]]; then
    log_info "git: $GIT_NAME <$GIT_EMAIL>"
else
    log_warn "git: no identity configured"
fi

# SSH key fingerprint
SSH_PUB="$TARGET_HOME/.ssh/id_ed25519.pub"
if [[ -f "$SSH_PUB" ]]; then
    SSH_FP="$(ssh-keygen -lf "$SSH_PUB" 2>/dev/null | awk '{print $2}')"
    log_info "SSH pubkey: $SSH_FP"
else
    log_warn "SSH pubkey: not found"
fi

# /opt/stacks
if [[ -d /opt/stacks ]]; then
    log_info "/opt/stacks: exists (owned by $(stat -c '%U' /opt/stacks))"
else
    log_info "/opt/stacks: not created"
fi

# Display SSH public key for easy copy
if [[ -f "$SSH_PUB" ]]; then
    log_step "SSH public key (add to GitHub → Settings → SSH Keys)"
    cat "$SSH_PUB"
    echo ""
fi

log_info "Start a new shell or run 'exec zsh' to activate changes"
