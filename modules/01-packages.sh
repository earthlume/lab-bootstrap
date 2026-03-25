#!/usr/bin/env bash
# modules/01-packages.sh — apt update + base packages + modern CLI tools

log_step "Installing base packages"

export DEBIAN_FRONTEND=noninteractive

log_info "Updating apt cache..."
sudo apt-get update -qq

log_info "Installing packages..."
sudo apt-get install -y -qq \
    curl wget git jq unzip rsync tmux vim neovim tree ncdu \
    net-tools dnsutils iputils-ping ca-certificates gnupg \
    bat ripgrep fd-find fzf tealdeer duf btop \
    zsh

log_success "Base packages installed"

# Seed tealdeer cache (non-fatal)
if command_exists tldr; then
    log_info "Updating tldr cache..."
    timeout 15 tldr --update 2>/dev/null || log_warn "tldr cache update failed or timed out (network?)"
fi
