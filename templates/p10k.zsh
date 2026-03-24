# lab.hoens.fun — Powerlevel10k configuration
# Teal-accented minimal prompt matching fleet visual identity.
# Generated for lab-bootstrap. Edit and re-run bootstrap to restore.

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
    emulate -L zsh -o extended_glob

    # Unset all configuration options
    unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

    # Prompt layout: left only, no right prompt
    typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
        context           # user@hostname (SSH only)
        dir               # current directory
        vcs               # git status
        command_execution_time
        newline
        prompt_char       # prompt symbol
    )
    typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

    # --------------- General ---------------
    typeset -g POWERLEVEL9K_MODE=ascii
    typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
    typeset -g POWERLEVEL9K_ICON_PADDING=none
    typeset -g POWERLEVEL9K_BACKGROUND=                # transparent background
    typeset -g POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE=
    typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=' '
    typeset -g POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
    typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=

    # --------------- Instant Prompt ---------------
    typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

    # --------------- Context (user@host) ---------------
    # Show only on SSH sessions
    typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND=030
    typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%m'
    typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT_EXPANSION,VISUAL_IDENTIFIER_EXPANSION}=
    typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND=030
    typeset -g POWERLEVEL9K_CONTEXT_REMOTE_TEMPLATE='%m'
    typeset -g POWERLEVEL9K_CONTEXT_REMOTE_SUDO_FOREGROUND=030
    typeset -g POWERLEVEL9K_CONTEXT_REMOTE_SUDO_TEMPLATE='%m'
    typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_CONTENT_EXPANSION=

    # --------------- Directory ---------------
    typeset -g POWERLEVEL9K_DIR_FOREGROUND=73
    typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
    typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=3
    typeset -g POWERLEVEL9K_SHORTEN_DELIMITER='…'
    typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=false
    typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=40

    # --------------- VCS (Git) ---------------
    typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND=108
    typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND=173
    typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND=173
    typeset -g POWERLEVEL9K_VCS_LOADING_FOREGROUND=102
    typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=
    typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1
    typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=
    typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter(1)))+${my_git_format}}'
    typeset -g POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION='${$((my_git_formatter(0)))+${my_git_format}}'
    typeset -g POWERLEVEL9K_VCS_{CLEAN,MODIFIED,UNTRACKED}_CONTENT_EXPANSION='${$((my_git_formatter(1)))+${my_git_format}}'

    # Git formatter function
    function my_git_formatter() {
        emulate -L zsh

        if [[ -n $P9K_CONTENT ]]; then
            typeset -g my_git_format=$P9K_CONTENT
            return
        fi

        local res
        local where
        if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
            where=${(V)VCS_STATUS_LOCAL_BRANCH}
        elif [[ -n $VCS_STATUS_TAG ]]; then
            res+='#'
            where=${(V)VCS_STATUS_TAG}
        fi

        (( $1 )) && {
            [[ -n $where ]] && res+="${where//\%/%%}"

            (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ↓${VCS_STATUS_COMMITS_BEHIND}"
            (( VCS_STATUS_COMMITS_AHEAD  )) && res+=" ↑${VCS_STATUS_COMMITS_AHEAD}"
            (( VCS_STATUS_STASHES        )) && res+=" *${VCS_STATUS_STASHES}"
            (( VCS_STATUS_NUM_CONFLICTED )) && res+=" ~${VCS_STATUS_NUM_CONFLICTED}"
            (( VCS_STATUS_NUM_STAGED     )) && res+=" +${VCS_STATUS_NUM_STAGED}"
            (( VCS_STATUS_NUM_UNSTAGED   )) && res+=" !${VCS_STATUS_NUM_UNSTAGED}"
            (( VCS_STATUS_NUM_UNTRACKED  )) && res+=" ?${VCS_STATUS_NUM_UNTRACKED}"
        } || {
            res+="${where//\%/%%}"
        }

        typeset -g my_git_format=$res
    }
    functions -M my_git_formatter 2>/dev/null

    # --------------- Command Execution Time ---------------
    typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=2
    typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
    typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND=102
    typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
    typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_VISUAL_IDENTIFIER_EXPANSION=

    # --------------- Prompt Character ---------------
    typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=030
    typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=167
    typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
    typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
    typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
    typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
    typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
    typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
    typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=

    # --------------- Transient Prompt ---------------
    typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off

    # --------------- Hot Reload ---------------
    (( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
    'builtin' 'unset' 'p10k_config_opts'
}
