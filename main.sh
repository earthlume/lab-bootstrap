#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/log.sh
source "$SCRIPT_DIR/lib/log.sh"
# shellcheck source=lib/detect.sh
source "$SCRIPT_DIR/lib/detect.sh"
# shellcheck source=lib/utils.sh
source "$SCRIPT_DIR/lib/utils.sh"

# Validate target user exists before doing anything
if ! id "$TARGET_USER" &>/dev/null; then
    log_error "Target user '$TARGET_USER' does not exist — create it first, then re-run"
    exit 1
fi

# --- Tier selection: work (modules 01-08) or fun (01-09) ---
# Default to fun — this is a homelab, not a datacenter.
TIER="${LAB_MODE:-fun}"

# CLI flags override env var
for arg in "$@"; do
    case "$arg" in
        --work) TIER="work" ;;
        --fun)  TIER="fun"  ;;
    esac
done

# If no explicit choice (env var or flag), ask interactively
EXPLICIT=false
[[ -n "${LAB_MODE:-}" ]] && EXPLICIT=true
[[ " $* " == *" --work "* ]] || [[ " $* " == *" --fun "* ]] && EXPLICIT=true

if [[ "$EXPLICIT" == false ]] && [[ -t 0 ]]; then
    printf "\n  ┌─────────────────────────────────────┐\n"
    printf "  │  Work or fun? [w/F]:                │\n"
    printf "  └─────────────────────────────────────┘\n"
    printf "  > "
    read -r tier_choice
    case "$tier_choice" in
        w|W|work) TIER="work" ;;
        *)        TIER="fun"  ;;
    esac
fi
export TIER

# Error trap — report which module/line failed
trap 'log_error "Bootstrap failed at line $LINENO in ${BASH_SOURCE[0]}"' ERR

log_step "lab-bootstrap — lab.hoens.fun fleet provisioner"
log_info "Host: $HOSTNAME_SHORT | Arch: $ARCH | OS: $OS_ID $OS_VERSION"
log_info "Tier: $TIER"
[[ "$IS_PI" == true ]] && log_info "Pi Model: $PI_MODEL"
[[ -n "$ARM_VERSION" ]] && log_info "ARM version: $ARM_VERSION"
[[ "$IS_ARMV6" == true ]] && log_warn "ARMv6 detected — GitHub-hosted binaries will be skipped"
[[ "$IS_LOW_RAM" == true ]] && log_warn "Low RAM detected (${TOTAL_RAM_MB} MB) — device has ≤512 MB"

# Set timezone (entire fleet is in LA)
log_info "Setting timezone to America/Los_Angeles"
sudo timedatectl set-timezone America/Los_Angeles 2>/dev/null || log_warn "timedatectl not available — timezone not set"

for module in "$SCRIPT_DIR"/modules/[0-9]*.sh; do
    # Skip the dopamine module in work tier
    if [[ "$TIER" == "work" ]] && [[ "$(basename "$module")" == "10-"* ]]; then
        continue
    fi
    # shellcheck disable=SC1090
    source "$module"
done

log_step "Bootstrap complete"
