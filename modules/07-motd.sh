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
        # Ubuntu: silence default MOTD noise (Canonical ads, ESM, landscape)
        # Uses regular variable (not local) — sourced at top level, not in a function
        motd_entry=""
        for motd_entry in /etc/update-motd.d/*; do
            case "$(basename "$motd_entry")" in
                98-reboot-required|99-lab-motd) continue ;;
                *) sudo chmod -x "$motd_entry" 2>/dev/null || true ;;
            esac
        done
        log_info "Disabled default Ubuntu MOTD scripts (kept 98-reboot-required, 99-lab-motd)"
        sudo install -m 755 "$MOTD_SCRIPT" /etc/update-motd.d/99-lab-motd
        sudo sed -i -e "s|__LAB_DOMAIN__|${LAB_DOMAIN}|g" -e "s|__LAB_SUBNET__|${LAB_SUBNET}|g" /etc/update-motd.d/99-lab-motd
        log_info "MOTD deployed to /etc/update-motd.d/99-lab-motd"
        ;;
    debian|raspbian)
        # Debian / Raspberry Pi OS: replace /etc/motd, deploy via profile.d
        [[ -f /etc/motd ]] && sudo truncate -s 0 /etc/motd
        sudo install -m 755 "$MOTD_SCRIPT" /etc/profile.d/99-lab-motd.sh
        sudo sed -i -e "s|__LAB_DOMAIN__|${LAB_DOMAIN}|g" -e "s|__LAB_SUBNET__|${LAB_SUBNET}|g" /etc/profile.d/99-lab-motd.sh
        log_info "MOTD deployed to /etc/profile.d/99-lab-motd.sh"
        ;;
    *)
        log_warn "Unknown OS_ID '$OS_ID' — deploying MOTD via profile.d as fallback"
        sudo install -m 755 "$MOTD_SCRIPT" /etc/profile.d/99-lab-motd.sh
        sudo sed -i -e "s|__LAB_DOMAIN__|${LAB_DOMAIN}|g" -e "s|__LAB_SUBNET__|${LAB_SUBNET}|g" /etc/profile.d/99-lab-motd.sh
        ;;
esac

log_success "MOTD configured"
