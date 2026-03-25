#!/usr/bin/env bash
# modules/05-shell-config.sh — deploy .zshrc, aliases, and create symlinks for renamed Debian binaries

log_step "Deploying shell configuration"

# Deploy .zshrc
deploy_template "$SCRIPT_DIR/templates/zshrc" "$TARGET_HOME/.zshrc" "$TARGET_USER"

# Deploy aliases
ensure_dir "$TARGET_HOME/.config/zsh"
chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config" "$TARGET_HOME/.config/zsh"
deploy_template "$SCRIPT_DIR/templates/aliases.zsh" "$TARGET_HOME/.config/zsh/aliases.zsh" "$TARGET_USER"

# Create symlinks for Debian-renamed binaries
# batcat → bat
if command_exists batcat && ! [[ -e /usr/local/bin/bat ]]; then
    ensure_symlink "$(command -v batcat)" /usr/local/bin/bat
fi

# fdfind → fd
if command_exists fdfind && ! [[ -e /usr/local/bin/fd ]]; then
    ensure_symlink "$(command -v fdfind)" /usr/local/bin/fd
fi

log_success "Shell configuration deployed"
