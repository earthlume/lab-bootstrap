#!/usr/bin/env bash
# bootstrap.sh — curl-pipe-sh entry point for lab-bootstrap
# Usage: curl -sL https://raw.githubusercontent.com/earthlume/lab-bootstrap/main/bootstrap.sh | bash
set -euo pipefail

REPO_URL="https://github.com/earthlume/lab-bootstrap.git"
INSTALL_DIR="${HOME}/.local/share/lab-bootstrap"

echo "[•] lab-bootstrap — lab.hoens.fun fleet provisioner"

# Ensure git is available
if ! command -v git &>/dev/null; then
    echo "[•] Installing git..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq git
fi

# Clone or pull the repo
if [[ -d "$INSTALL_DIR/.git" ]]; then
    echo "[•] Updating existing installation..."
    git -C "$INSTALL_DIR" pull --quiet
else
    echo "[•] Cloning lab-bootstrap..."
    git clone --depth=1 "$REPO_URL" "$INSTALL_DIR"
fi

# Hand off to main.sh (exec avoids stdin issues from curl pipe)
# Pass CLI flags (--work / --fun) through to main.sh
exec sudo bash "$INSTALL_DIR/main.sh" "$@"
