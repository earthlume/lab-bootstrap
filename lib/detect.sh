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

    # ARM sub-version detection from /proc/cpuinfo (not dpkg)
    ARM_VERSION=""
    IS_ARMV6=false
    if [[ -f /proc/cpuinfo ]]; then
        local cpu_arch
        cpu_arch="$(awk '/^CPU architecture/ {print $NF; exit}' /proc/cpuinfo)"
        case "$cpu_arch" in
            6) ARM_VERSION="6" ;;
            7)
                # ARMv6 devices (Pi Zero/1) sometimes report CPU architecture 7
                # but the Hardware line disambiguates. BCM2835 is the SoC used in
                # Pi Zero, Zero W, Pi 1 Model A/B, and Compute Module 1 — all ARMv6.
                local hardware
                hardware="$(awk '/^Hardware/ {print $NF; exit}' /proc/cpuinfo)"
                if [[ "$hardware" == "BCM2835" ]]; then
                    ARM_VERSION="6"
                else
                    ARM_VERSION="7"
                fi
                ;;
            8) ARM_VERSION="8" ;;
        esac
        [[ "$ARM_VERSION" == "6" ]] && IS_ARMV6=true
    fi

    # RAM detection from /proc/meminfo
    TOTAL_RAM_MB=0
    IS_LOW_RAM=false
    if [[ -f /proc/meminfo ]]; then
        local mem_kb
        mem_kb="$(awk '/^MemTotal:/ {print $2; exit}' /proc/meminfo)"
        TOTAL_RAM_MB=$(( mem_kb / 1024 ))
        (( TOTAL_RAM_MB <= 512 )) && IS_LOW_RAM=true
    fi

    # Export everything
    export ARCH OS_ID OS_VERSION HOSTNAME_SHORT IS_PI PI_MODEL
    export ARM_VERSION IS_ARMV6 TOTAL_RAM_MB IS_LOW_RAM
}

detect_environment
