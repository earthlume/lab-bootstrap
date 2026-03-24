# Pure Zsh fallback prompt — used on ARMv6 devices where Powerlevel10k is unavailable
# Teal accent to match lab.hoens.fun visual identity

autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' %F{030}(%b)%f'
zstyle ':vcs_info:git:*' actionformats ' %F{030}(%b|%a)%f'
setopt PROMPT_SUBST

# Show hostname only over SSH
[[ -n "$SSH_CONNECTION" ]] && _host="%F{030}%m%f:" || _host=""

PROMPT='${_host}%F{030}%~%f${vcs_info_msg_0_} %F{030}❯%f '
