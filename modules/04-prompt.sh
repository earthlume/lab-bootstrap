#!/usr/bin/env bash
# modules/04-prompt.sh — Powerlevel10k config deployment (or fallback on ARMv6)

log_step "Configuring prompt (Powerlevel10k)"

if [[ "$IS_ARMV6" == true ]]; then
    log_info "ARMv6 detected — Powerlevel10k is too heavy, deploying fallback prompt"
    ensure_dir "$TARGET_HOME/.config/zsh"
    chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config" "$TARGET_HOME/.config/zsh"
    deploy_template "$SCRIPT_DIR/templates/prompt-fallback.zsh" "$TARGET_HOME/.config/zsh/prompt-fallback.zsh" "$TARGET_USER"
    log_success "Fallback prompt deployed"
else
    # p10k theme is loaded via Antidote (zsh_plugins.txt) — just deploy the config
    deploy_template "$SCRIPT_DIR/templates/p10k.zsh" "$TARGET_HOME/.p10k.zsh" "$TARGET_USER"
    log_success "Powerlevel10k config deployed"
fi
