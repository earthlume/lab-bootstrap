#!/usr/bin/env bash
# lib/detect.sh — OS, architecture, and platform detection

detect_environment() {
    # Architecture (from dpkg which gives the Debian arch name)
    local dpkg_arch
    dpkg_arch="$(dpkg --print-architecture 2>/dev/null || true)"
    case "$dpkg_arch" in
        amd64)  ARCH="x86_64"  ;;
        arm64)  ARCH="aarch64" ;;
        armhf)  ARCH="armhf"   ;;
        *)      ARCH="$(uname -m)"
                log_warn "Unknown dpkg arch '$dpkg_arch', falling back to uname: $ARCH"
                ;;
    esac

    # OS identification from /etc/os-release
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        OS_ID="${ID:-unknown}"
        OS_VERSION="${VERSION_CODENAME:-unknown}"
    else
        OS_ID="unknown"
        OS_VERSION="unknown"
        log_warn "Cannot determine OS — /etc/os-release not found"
    fi

    # Hostname
    HOSTNAME_SHORT="$(hostname -s)"

    # Raspberry Pi detection
    IS_PI=false
    PI_MODEL=""
    if [[ -f /proc/device-tree/model ]]; then
        local model
        model="$(tr -d '\0' < /proc/device-tree/model)"
        if [[ "$model" == *"Raspberry Pi"* ]]; then
            IS_PI=true
            PI_MODEL="$model"
        fi
    fi

    # Export everything
    export ARCH OS_ID OS_VERSION HOSTNAME_SHORT IS_PI PI_MODEL
}

detect_environment
