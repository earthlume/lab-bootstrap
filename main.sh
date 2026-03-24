#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/detect.sh"
source "$SCRIPT_DIR/lib/utils.sh"

# Validate target user exists before doing anything
if ! id "$TARGET_USER" &>/dev/null; then
    log_error "Target user '$TARGET_USER' does not exist — create it first, then re-run"
    exit 1
fi

# Error trap — report which module/line failed
trap 'log_error "Bootstrap failed at line $LINENO in ${BASH_SOURCE[0]}"' ERR

log_step "lab-bootstrap — lab.hoens.fun fleet provisioner"
log_info "Host: $HOSTNAME_SHORT | Arch: $ARCH | OS: $OS_ID $OS_VERSION"
[[ "$IS_PI" == true ]] && log_info "Pi Model: $PI_MODEL"
[[ -n "$ARM_VERSION" ]] && log_info "ARM version: $ARM_VERSION"
[[ "$IS_ARMV6" == true ]] && log_warn "ARMv6 detected — GitHub-hosted binaries and Powerlevel10k will be skipped"
[[ "$IS_LOW_RAM" == true ]] && log_warn "Low RAM detected (${TOTAL_RAM_MB} MB) — device has ≤512 MB"

for module in "$SCRIPT_DIR"/modules/[0-9]*.sh; do
    source "$module"
done

log_step "Bootstrap complete"
