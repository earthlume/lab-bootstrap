#!/usr/bin/env bash
# bootstrap.sh — curl-pipe-sh entry point for lab-bootstrap
# Usage: curl -fsSL <raw-url>/bootstrap.sh | bash
#   or:  git clone https://github.com/earthlume/lab-bootstrap.git ~/.local/share/lab-bootstrap && bash ~/.local/share/lab-bootstrap/bootstrap.sh
# Clone auto-detects SSH vs HTTPS — SSH is used when GitHub SSH auth is available.
set -euo pipefail

HTTPS_URL="https://github.com/earthlume/lab-bootstrap.git"
SSH_URL="git@github.com:earthlume/lab-bootstrap.git"
INSTALL_DIR="${HOME}/.local/share/lab-bootstrap"

echo "[•] lab-bootstrap — fleet provisioner"

# Ensure git is available
if ! command -v git &>/dev/null; then
    echo "[•] Installing git..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq git
fi

# Detect whether SSH authentication to GitHub is available
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    REPO_URL="$SSH_URL"
    echo "[•] GitHub SSH access detected — using SSH clone URL"
else
    REPO_URL="$HTTPS_URL"
    echo "[•] No GitHub SSH access — using HTTPS clone URL"
fi

# Clone or pull the repo
if [[ -d "$INSTALL_DIR/.git" ]]; then
    echo "[•] Updating existing installation..."
    git -C "$INSTALL_DIR" pull --quiet
else
    echo "[•] Cloning lab-bootstrap..."
    git clone --depth=1 "$REPO_URL" "$INSTALL_DIR"
fi

# Ask work/fun BEFORE sudo so the user doesn't burn sudo attempts
# before even starting. main.sh will see the explicit flag and skip its prompt.
TIER_FLAG=""
if [[ -z "${LAB_MODE:-}" ]] && [[ " $* " != *" --work "* ]] && [[ " $* " != *" --fun "* ]] && [[ -t 0 ]]; then
    printf "\n  ┌─────────────────────────────────────┐\n"
    printf "  │  Work or fun? [w/F]:                │\n"
    printf "  └─────────────────────────────────────┘\n"
    printf "  > "
    read -r tier_choice
    case "$tier_choice" in
        w|W|work) TIER_FLAG="--work" ;;
        *)        TIER_FLAG="--fun"  ;;
    esac
fi

# Hand off to main.sh (exec avoids stdin issues from curl pipe)
# Pass CLI flags (--work / --fun) through to main.sh
exec sudo bash "$INSTALL_DIR/main.sh" "$@" $TIER_FLAG
