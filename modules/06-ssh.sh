#!/usr/bin/env bash
# modules/06-ssh.sh — SSH key generation + git identity + delta pager config

log_step "Configuring SSH + Git identity"

SSH_DIR="$TARGET_HOME/.ssh"
SSH_KEY="$SSH_DIR/id_ed25519"

# Generate ed25519 keypair if it doesn't exist
if [[ -f "$SSH_KEY" ]]; then
    log_info "SSH key already exists — skipping"
else
    log_info "Generating ed25519 SSH keypair..."
    ensure_dir "$SSH_DIR"
    ssh-keygen -t ed25519 -C "$TARGET_USER@$(hostname -s).${LAB_DOMAIN}" -f "$SSH_KEY" -N ""
    log_success "SSH keypair generated"
fi

# Set correct permissions
chmod 700 "$SSH_DIR"
chmod 600 "$SSH_KEY"
chmod 644 "$SSH_KEY.pub"
chown -R "$TARGET_USER:$TARGET_USER" "$SSH_DIR"

# Configure git identity (as the target user)
sudo -u "$TARGET_USER" git config --global user.name "earthlume"
sudo -u "$TARGET_USER" git config --global user.email "earthlume@users.noreply.github.com"
log_info "Git identity configured"

# Configure delta as git pager (if installed)
if command_exists delta; then
    sudo -u "$TARGET_USER" git config --global core.pager delta
    sudo -u "$TARGET_USER" git config --global interactive.diffFilter "delta --color-only"
    sudo -u "$TARGET_USER" git config --global delta.navigate true
    sudo -u "$TARGET_USER" git config --global delta.side-by-side true
    sudo -u "$TARGET_USER" git config --global merge.conflictstyle diff3
    sudo -u "$TARGET_USER" git config --global diff.colorMoved default
    log_info "Git configured to use delta as pager"
fi
