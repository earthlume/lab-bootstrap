#!/usr/bin/env bash
# modules/07-motd.sh — deploy custom branded MOTD

log_step "Deploying MOTD"

MOTD_SCRIPT="$SCRIPT_DIR/templates/motd"

if [[ -d /etc/update-motd.d ]]; then
    # Ubuntu: deploy as update-motd.d script (runs last)
    sudo install -m 755 "$MOTD_SCRIPT" /etc/update-motd.d/99-lab-motd
    log_info "MOTD deployed to /etc/update-motd.d/99-lab-motd"
else
    # Debian / Pi OS: clear static motd, deploy via profile.d
    [[ -f /etc/motd ]] && sudo truncate -s 0 /etc/motd
    sudo install -m 755 "$MOTD_SCRIPT" /etc/profile.d/99-lab-motd.sh
    log_info "MOTD deployed to /etc/profile.d/99-lab-motd.sh"
fi

log_success "MOTD configured"
