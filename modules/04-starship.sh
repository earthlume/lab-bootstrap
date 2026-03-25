#!/usr/bin/env bash
# modules/04-starship.sh — Starship prompt install + config deployment (or fallback on ARMv6)

log_step "Installing Starship prompt"

if [[ "$IS_ARMV6" == true ]]; then
    log_info "ARMv6 detected — Starship has no ARMv6 build, deploying fallback prompt"
    ensure_dir "$TARGET_HOME/.config/zsh"
    chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config" "$TARGET_HOME/.config/zsh"
    deploy_template "$SCRIPT_DIR/templates/prompt-fallback.zsh" "$TARGET_HOME/.config/zsh/prompt-fallback.zsh" "$TARGET_USER"
    log_success "Fallback prompt deployed"
else
    # Install starship if not present
    if command_exists starship; then
        log_info "Starship already installed — skipping"
    else
        log_info "Installing Starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
        log_success "Starship installed"
    fi

    # Deploy starship config
    ensure_dir "$TARGET_HOME/.config"
    deploy_template "$SCRIPT_DIR/templates/starship.toml" "$TARGET_HOME/.config/starship.toml" "$TARGET_USER"
fi
