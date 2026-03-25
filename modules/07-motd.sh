#!/usr/bin/env bash
# modules/07-motd.sh — deploy custom branded MOTD (OS-aware strategy)

log_step "Deploying MOTD"

# Fun tier gets the enhanced MOTD with figlet/lolcat/fortune/cowsay
if [[ "${TIER:-work}" == "fun" ]]; then
    MOTD_SCRIPT="$SCRIPT_DIR/templates/motd-fun"
else
    MOTD_SCRIPT="$SCRIPT_DIR/templates/motd"
fi

case "$OS_ID" in
    ubuntu)
        # Ubuntu: append our MOTD to the pipeline, keep existing scripts
        sudo install -m 755 "$MOTD_SCRIPT" /etc/update-motd.d/99-lab-motd
        log_info "MOTD deployed to /etc/update-motd.d/99-lab-motd"
        ;;
    debian|raspbian)
        # Debian / Raspberry Pi OS: replace /etc/motd, deploy via profile.d
        [[ -f /etc/motd ]] && sudo truncate -s 0 /etc/motd
        sudo install -m 755 "$MOTD_SCRIPT" /etc/profile.d/99-lab-motd.sh
        log_info "MOTD deployed to /etc/profile.d/99-lab-motd.sh"
        ;;
    *)
        log_warn "Unknown OS_ID '$OS_ID' — deploying MOTD via profile.d as fallback"
        sudo install -m 755 "$MOTD_SCRIPT" /etc/profile.d/99-lab-motd.sh
        ;;
esac

log_success "MOTD configured"
