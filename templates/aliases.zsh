# ~/.config/zsh/aliases.zsh — lab.hoens.fun fleet standard
# Managed by lab-bootstrap. Re-run bootstrap to restore.
# Local additions: put them in ~/.zshrc.local

# ----- Modern replacements -----
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first --git'
alias lt='eza -la --icons --tree --level=2'
alias cat='bat'
alias catp='bat -pp'      # plain mode, no paging — use when piping or for cat-like behavior
alias grep='rg'
alias find='fd'
# dust is not available on armhf — use \du to get the real du if this errors
alias du='dust'
alias top='btop'
alias df='duf'

# ----- Navigation -----
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ----- Git shortcuts -----
alias gs='git status'
alias gl='git log --oneline --graph --decorate -20'
alias gd='git diff'
alias ga='git add'
alias gc='git commit'
alias gp='git push'

# ----- Systemd -----
alias sctl='sudo systemctl'
alias jctl='journalctl -xe'

# ----- Network -----
alias ports='ss -tulnp'
alias myip='curl -s ifconfig.me'

# ----- lab.hoens.fun -----
alias labip='ip -4 addr show | grep "inet 10.4.20"'
