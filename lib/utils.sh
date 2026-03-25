#!/usr/bin/env bash
# lib/utils.sh — idempotency helpers, download helpers, symlink helpers

# User that the bootstrap targets
readonly TARGET_USER="lume"
readonly TARGET_HOME="/home/$TARGET_USER"

command_exists() {
    command -v "$1" &>/dev/null
}

is_arch() {
    [[ "$ARCH" == "$1" ]]
}

ensure_symlink() {
    local source="$1" target="$2"
    if [[ ! -L "$target" ]] || [[ "$(readlink -f "$target")" != "$(readlink -f "$source")" ]]; then
        ln -sf "$source" "$target"
        log_info "Symlinked $target → $source"
    fi
}

ensure_line() {
    local file="$1" line="$2"
    if ! grep -qF "$line" "$file" 2>/dev/null; then
        echo "$line" >> "$file"
    fi
}

ensure_dir() {
    mkdir -p "$1"
}

# Download a file and make it executable
download_binary() {
    local url="$1" dest="$2"
    log_info "Downloading $(basename "$dest") from $url"
    if curl -fsSL "$url" -o "$dest"; then
        chmod +x "$dest"
        log_success "Installed $(basename "$dest")"
        return 0
    else
        log_warn "Failed to download $(basename "$dest") — skipping"
        return 1
    fi
}

# Deploy a template file to a target path, creating parent dirs and setting ownership
deploy_template() {
    local src="$1" dest="$2"
    local owner="${3:-}"
    ensure_dir "$(dirname "$dest")"
    cp -f "$src" "$dest"
    if [[ -n "$owner" ]]; then
        chown "$owner:$owner" "$dest"
    fi
    log_info "Deployed $(basename "$dest")"
}

# Fetch latest GitHub release tag for a repo
# Usage: github_latest_tag "owner/repo"
github_latest_tag() {
    local repo="$1"
    local tag
    tag="$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null | jq -r '.tag_name // empty')"
    if [[ -z "$tag" ]]; then
        log_warn "Failed to fetch latest release for $repo (GitHub API rate limit?)"
        return 1
    fi
    echo "$tag"
}

# Fetch a specific asset URL from the latest GitHub release
# Usage: github_asset_url "owner/repo" "pattern"
github_asset_url() {
    local repo="$1" pattern="$2"
    local url
    url="$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null \
        | jq -r --arg pat "$pattern" '.assets[] | select(.name | test($pat)) | .browser_download_url' \
        | head -1)"
    if [[ -z "$url" ]]; then
        log_warn "No asset matching '$pattern' found for $repo"
        return 1
    fi
    echo "$url"
}
