#!/usr/bin/env bash
# modules/09-docker-prep.sh — create /opt/stacks for Docker stack repos

if ! command_exists docker; then
    log_info "Docker not detected — skipping /opt/stacks setup"
    return 0 2>/dev/null || exit 0
fi

STACKS_DIR="/opt/stacks"

if [[ -d "$STACKS_DIR" ]]; then
    # Fix ownership if needed
    CURRENT_OWNER="$(stat -c '%U' "$STACKS_DIR")"
    if [[ "$CURRENT_OWNER" != "$TARGET_USER" ]]; then
        chown "$TARGET_USER:$TARGET_USER" "$STACKS_DIR"
        log_info "Fixed ownership of $STACKS_DIR to $TARGET_USER"
    else
        log_info "$STACKS_DIR already exists with correct ownership — skipping"
    fi
else
    mkdir -p "$STACKS_DIR"
    chown "$TARGET_USER:$TARGET_USER" "$STACKS_DIR"
    log_success "Created $STACKS_DIR — clone your stack repo here"
fi
