#!/usr/bin/env bash
# modules/08-cleanup.sh — apt cleanup, summary, and SSH pubkey display

log_step "Cleanup"

log_info "Running apt autoremove..."
sudo apt-get autoremove -y -qq
sudo apt-get clean -qq
log_success "Apt cleanup done"

# Summary
log_step "Summary"

log_success "Base packages installed (bat, ripgrep, fd, fzf, btop, duf, tealdeer, ...)"
command_exists eza && log_success "eza installed" || log_warn "eza not installed"
command_exists zoxide && log_success "zoxide installed" || log_warn "zoxide not installed"
command_exists delta && log_success "delta installed" || log_warn "delta not installed"
if ! is_arch armhf; then
    command_exists dust && log_success "dust installed" || log_warn "dust not installed"
fi
command_exists starship && log_success "Starship prompt installed" || log_warn "Starship not installed"
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
