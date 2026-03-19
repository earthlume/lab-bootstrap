#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/log.sh"
source "$SCRIPT_DIR/lib/detect.sh"
source "$SCRIPT_DIR/lib/utils.sh"

# Error trap — report which module/line failed
trap 'log_error "Bootstrap failed at line $LINENO in ${BASH_SOURCE[0]}"' ERR

log_step "lab-bootstrap — lab.hoens.fun fleet provisioner"
log_info "Host: $HOSTNAME_SHORT | Arch: $ARCH | OS: $OS_ID $OS_VERSION"
[[ "$IS_PI" == true ]] && log_info "Pi Model: $PI_MODEL"

for module in "$SCRIPT_DIR"/modules/[0-9]*.sh; do
    source "$module"
done

log_step "Bootstrap complete"
