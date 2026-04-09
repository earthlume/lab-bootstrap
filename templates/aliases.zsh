# ~/.config/zsh/aliases.zsh — fleet standard
# Managed by lab-bootstrap. Re-run bootstrap to restore.
# Local additions: put them in ~/.zshrc.local

# ----- Modern replacements -----
# Guarded aliases for tools that may not exist on ARMv6 (no GitHub binaries)
if command -v eza &>/dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -la --icons --group-directories-first --git'
    alias lt='eza -la --icons --tree --level=2'
fi

alias cat='bat'
alias catp='bat -pp'      # plain + no paging — pipe-friendly, true cat replacement
alias grep='rg'
alias find='fd'

if command -v dust &>/dev/null; then
    alias du='dust'
fi

alias top='btop'

# ----- Speed aliases -----
alias c='clear'
alias q='exit'
alias h='history | tail -30'
alias hg='history | grep'
alias path='echo $PATH | tr ":" "\n"'
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias reload='exec zsh'
if command -v curl &>/dev/null; then
    alias weather='curl -s wttr.in/?format=3'
fi

# ----- Navigation -----
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# ----- Files -----
alias mk='mkdir -p'
alias cx='chmod +x'
alias own='sudo chown -R $(whoami):$(whoami)'

# ----- Git -----
alias gs='git status -sb'
alias ga='git add -A'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline -15'
alias gd='git diff'
alias gb='git branch -a'
alias git-hierarchal='git log --graph --oneline --all'
alias git-save='git add -A && git commit -m'

# ----- System -----
alias sctl='sudo systemctl'
alias jctl='journalctl -xe'
alias ports='sudo ss -tulnp'
alias mem='free -h'
alias disk='df -h | grep -v tmpfs'
alias temp='sensors 2>/dev/null || cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | awk "{print \$1/1000\"°C\"}"'
if command -v curl &>/dev/null; then
    alias myip='curl -s ifconfig.me'
fi

# ----- Network -----
alias ping3='ping -c 3'
if command -v dig &>/dev/null; then
    alias dns='dig +short'
fi
alias listening='sudo lsof -iTCP -sTCP:LISTEN -P -n'

# ----- Apt -----
alias apt-up='sudo apt update && sudo apt upgrade -y'
alias apt-clean='sudo apt autoremove -y && sudo apt autoclean'
alias apt-search='apt-cache search'

# ----- Tool inventory -----
_check() { command -v "$1" &>/dev/null && printf ' \033[32m✓\033[0m %-12s' "$1" || printf ' \033[31m✗\033[0m %-12s' "$1"; }
work() {
    echo "Work tier:"
    _check eza;    _check bat;    _check rg;     _check fd;   echo
    _check fzf;    _check zoxide; _check delta;  _check dust; echo
    _check btop;   _check duf;    _check tldr;   _check tmux; echo
    _check nvim;   _check jq;     _check tree;                echo
}
fun() {
    echo "Fun tier:"
    _check figlet;    _check lolcat;    _check cowsay;   _check fortune; echo
    _check cmatrix;   _check cbonsai;   _check tty-clock; _check sl;     echo
    _check nyancat;   _check pipes.sh;  _check toilet;   _check nms;     echo
    _check tte;       _check fastfetch; _check pfetch;                    echo
}
alias tools='work; echo; fun'

# ----- Lab network -----
LAB_NET="__LAB_SUBNET__"
if [[ -n "$LAB_NET" ]]; then
    alias labip='ip -4 addr show | grep "inet '"$LAB_NET"'"'
else
    alias labip='ip -4 addr show | grep "inet " | grep -v 127.0.0.1'
fi
