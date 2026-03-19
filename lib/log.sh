#!/usr/bin/env bash
# lib/log.sh — colored logging for lab-bootstrap
# Petrol/teal (#008080) as primary accent

# ANSI color codes (256-color for true teal)
readonly _TEAL='\033[38;5;30m'
readonly _GREEN='\033[38;5;34m'
readonly _YELLOW='\033[38;5;178m'
readonly _RED='\033[38;5;160m'
readonly _BOLD='\033[1m'
readonly _DIM='\033[2m'
readonly _RESET='\033[0m'

log_info() {
    printf "${_TEAL}[•]${_RESET} %s\n" "$*"
}

log_success() {
    printf "${_GREEN}[✓]${_RESET} %s\n" "$*"
}

log_warn() {
    printf "${_YELLOW}[!]${_RESET} %s\n" "$*" >&2
}

log_error() {
    printf "${_RED}[✗]${_RESET} %s\n" "$*" >&2
}

log_step() {
    printf "\n${_BOLD}${_TEAL}═══ %s ═══${_RESET}\n\n" "$*"
}
