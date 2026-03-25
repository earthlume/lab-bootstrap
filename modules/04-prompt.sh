#!/usr/bin/env bash
# modules/04-prompt.sh — deploy Powerlevel10k config
# p10k itself is installed as a zsh plugin via Antidote (in zsh_plugins.txt).
# This module just deploys the pre-built config so the prompt looks right
# on first login without running `p10k configure`.

log_step "Deploying Powerlevel10k config"

deploy_template "$SCRIPT_DIR/templates/p10k.zsh" "$TARGET_HOME/.p10k.zsh" "$TARGET_USER"
log_success "Powerlevel10k config deployed"
