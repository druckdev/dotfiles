[[ ! -d "$ZDOTDIR/completion" ]] || fpath=("$ZDOTDIR/completion" $fpath)

autoload -Uz compinit bashcompinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"
bashcompinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' \
                                    'm:{-_a-zA-Z}={_-A-Za-z}' \
                                    'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

zstyle ':completion:*' menu select

zstyle -e ':completion:*:users' users 'local user; getent passwd | while IFS=: read -rA user; do (( user[3] >= 1000 || user[3] == 0 )) && reply+=($user[1]); done'

# Include hidden files in completion.
_comp_options+=(globdots)

# Don't complete the same argument twice for these programs.
# Taken from http://leahneukirchen.org/dotfiles/.zshrc
zstyle ':completion:*:(diff|meld|trash):*' ignore-line yes

# Use completion of commands for their wrapper functions
compdef ls-show-hidden=ls
compdef nvim-man=man

# Reuse other completion functions
# NOTE: Show completion functions for current context:
#       <C-x>h
#       Generate completion debug trace:
#       <C-x>?

# git
compdef _git-log glog
compdef _git-checkout git-checkout-worktree
compdef _git-commit git-commit-last-msg
compdef _git-rebase git-signoff
# Run git's completion once to avoid a `command not found` error when using the
# completion functions on other programs without having completed something for
# git before in the same session.
_git &>/dev/null || true

# Do not sort completion list
zstyle ":completion:*:git-checkout:*" sort false
zstyle ":completion:*:git-rebase:*" sort false
zstyle ":completion:*:git-show:*" sort false
zstyle ":completion:*:git-signoff:*" sort false
