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
log_success "Powerlevel10k prompt configured"
log_success "ZSH configured with Antidote plugins"
log_success "Shell aliases and config deployed"
log_success "Git identity configured (earthlume)"
log_success "MOTD deployed"

# Display SSH public key
SSH_PUB="$TARGET_HOME/.ssh/id_ed25519.pub"
if [[ -f "$SSH_PUB" ]]; then
    log_step "SSH public key (add to GitHub → Settings → SSH Keys)"
    cat "$SSH_PUB"
    echo ""
fi

log_info "Start a new shell or run 'exec zsh' to activate changes"
