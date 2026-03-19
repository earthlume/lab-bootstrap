#!/usr/bin/env bash
# modules/03-zsh.sh — ZSH + Antidote plugin manager + chsh

log_step "Configuring ZSH + Antidote"

ANTIDOTE_DIR="$TARGET_HOME/.antidote"

# Install antidote via git clone
if [[ -f "$ANTIDOTE_DIR/antidote.zsh" ]]; then
    log_info "Antidote already installed — updating"
    git -C "$ANTIDOTE_DIR" pull --quiet 2>/dev/null || log_warn "Antidote update failed"
else
    log_info "Cloning antidote..."
    rm -rf "$ANTIDOTE_DIR"
    git clone --depth=1 https://github.com/mattmc3/antidote.git "$ANTIDOTE_DIR"
    chown -R "$TARGET_USER:$TARGET_USER" "$ANTIDOTE_DIR"
    log_success "Antidote installed"
fi

# Deploy plugin list
deploy_template "$SCRIPT_DIR/templates/zsh_plugins.txt" "$TARGET_HOME/.zsh_plugins.txt" "$TARGET_USER"

# Change default shell for lume if not already zsh
CURRENT_SHELL="$(getent passwd "$TARGET_USER" | cut -d: -f7)"
if [[ "$CURRENT_SHELL" != */zsh ]]; then
    log_info "Changing default shell to zsh for $TARGET_USER..."
    sudo chsh -s /usr/bin/zsh "$TARGET_USER"
    log_success "Default shell changed to zsh"
else
    log_info "Default shell already zsh"
fi
