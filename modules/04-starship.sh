#!/usr/bin/env bash
# modules/04-starship.sh — Starship prompt install + config deployment

log_step "Installing Starship prompt"

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
