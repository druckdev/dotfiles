## Author:  druckdev
## Created  2018-11-23

# echo ${(pl.$LINES..\n.)}

# Enable Powerlevel10k instant prompt. Should stay at the top of ~/.config/zsh/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH_CONF="$ZDOTDIR/plugins"

## set zshoptions
    # setopt AUTO_CD                # cd is not necessary
    setopt AUTO_CONTINUE            # Stopped jobs with 'disown' are automatically sent a CONT signal to make them running.
    setopt AUTO_PARAM_SLASH         # Add a trailing slash when completing directories
    setopt AUTO_PUSHD               # Make cd push the old directory onto the directory stack.
    setopt NO_AUTO_REMOVE_SLASH     # Keeps trailing slash for directories when auto completing.
                                    #   (Beware: commands will act on the target directory not the symlink with the slash)
    setopt NO_BEEP                  # Do not beep on error in ZLE.
    setopt C_BASES                  # Output hexadecimal numbers in the standard C format ('16#FF' -> '0xFF').
    setopt CDABLE_VARS              # Enables changing into hashes without the '~'-prefix
    setopt CHASE_LINKS              # Resolve symbolic links to their true values when changing directory.
    setopt NO_CLOBBER               # '>!' or '>|' must be used to truncate a file, and '>>!' or '>>|' to create a file.
    setopt COMPLETE_IN_WORD         # Complete from the cursor rather than from the end of the word
    setopt CORRECT                  # Try to correct the spelling of a command
    setopt CORRECT_ALL              # Try to correct the spelling of all arguments
    export CORRECT_IGNORE_FILE=".*" # Do not offer hidden files as correction
    setopt EXTENDED_HISTORY         # Saves timedata into the history (:<beginning time>:<elapsed seconds>:<command>).
    setopt EXTENDED_GLOB            # Treat the `#', `~' and `^' characters as part of patterns for filename generation, etc.
    setopt NO_FLOW_CONTROL          # Disables output flow control in the shell's editor via start/stop characters (usually ^S/^Q).
    setopt GLOB_DOTS                # Do not require a leading `.' in a filename to be matched explicitly.
    setopt HIST_IGNORE_DUPS
    setopt HIST_IGNORE_SPACE        # History should ignore commands beginning with a space
    setopt HIST_VERIFY              # perform history expansion and reload line in editing buffer instead of executing it directly
    setopt INC_APPEND_HISTORY_TIME  # enter lines as soon as there ary entered (_time is necessary for <elapsed seconds> of ext_hist)
    setopt INTERACTIVE_COMMENTS     # Allow comments even in interactive shells.
    setopt NO_MENU_COMPLETE         # Do not autoselect the first entry when completing
    # setopt SHARE_HISTORY          # write + read history after every command

    autoload -U select-word-style && select-word-style bash

## Setup the prompt
    # use bright version of colors when printing bold
    if [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/dircolors/dircolors" ]; then
        eval "$(dircolors -b "${XDG_CONFIG_HOME:-$HOME/.config}/dircolors/dircolors")"
    else
        eval "$(dircolors -b)"
    fi

    if [ -r "$ZSH_CONF/powerlevel10k/powerlevel10k.zsh-theme" ]; then
        source "$ZSH_CONF/powerlevel10k/powerlevel10k.zsh-theme"
        # run `p10k configure` or edit $ZSH_CONF/p10k.zsh-theme to customize
        [ ! -r "$ZSH_CONF/p10k.zsh-theme" ] || source "$ZSH_CONF/p10k.zsh-theme"
    fi

## Setup zsh completion system
    [ ! -d "$ZSH_CONF/completion" ] || fpath=("$ZSH_CONF/completion" $fpath)

    autoload -Uz compinit
    compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"

    zstyle ':completion:*' auto-description 'specify: %d'
    zstyle ':completion:*' completer _expand _complete _correct _approximate
    zstyle ':completion:*' format 'Completing %d'
    zstyle ':completion:*' group-name ''
    zstyle ':completion:*' menu select=2
    zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
    zstyle ':completion:*' list-colors ''
    zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
    zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
    zstyle ':completion:*' menu select=long
    zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
    zstyle ':completion:*' use-compctl false
    zstyle ':completion:*' verbose true

    zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
    zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

    zstyle ':completion:*' menu select

    zstyle -e ':completion:*:users' users 'local user; getent passwd | while IFS=: read -rA user; do (( user[3] >= 1000 || user[3] == 0 )) && reply+=($user[1]); done'
    _comp_options+=(globdots) # Include hidden files


## Load external config files and modules
    autoload edit-command-line; zle -N edit-command-line
    autoload zmv
    # stderred
    if [ -r "$ZSH_CONF/stderred/build/libstderred.so" ]; then
        export LD_PRELOAD="$ZSH_CONF/stderred/build/libstderred.so${LD_PRELOAD:+:$LD_PRELOAD}"
        export STDERRED_ESC_CODE="$(tput bold && tput setaf 1)"
        export STDERRED_BLACKLIST="^(git|curl|wget|swipl)$"
    fi
    [ ! -r "$ZSH_CONF/functionsPre.zsh" ] || source "$ZSH_CONF/functionsPre.zsh"
    [ ! -r "$ZSH_CONF/alias.zsh" ] || source "$ZSH_CONF/alias.zsh"
    [ ! -r "$ZSH_CONF/functionsPost.zsh" ] || source "$ZSH_CONF/functionsPost.zsh"
    [ ! -r  "$ZSH_CONF/transfer.zsh" ] || source "$ZSH_CONF/transfer.zsh"
    [ ! -r "$ZSH_CONF/zsh-autosuggestions/zsh-autosuggestions.zsh" ] || source "$ZSH_CONF/zsh-autosuggestions/zsh-autosuggestions.zsh"
    [ ! -r "$ZSH_CONF/completion.zsh" ] || source "$ZSH_CONF/completion.zsh"
    # [ ! -r "$ZSH_CONF/zsh-async/async.zsh" ] || source "$ZSH_CONF/zsh-async/async.zsh"
    #     async_init
    ### syntax-highlight > history-substring > keys
    # syntax highlighting
    if [ -r "$ZSH_CONF/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
        source $ZSH_CONF/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        source $ZSH_CONF/zsh-syntax-highlighting.zsh-theme
    fi
    # history substr search
    if [ -r "$ZSH_CONF/zsh-history-substring-search/zsh-history-substring-search.zsh" ]; then
        source $ZSH_CONF/zsh-history-substring-search/zsh-history-substring-search.zsh
        HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=true
        HISTORY_SUBSTRING_SEARCH_FUZZY=true
    fi
    [ ! -r "$ZSH_CONF/keys.zsh" ] || source "$ZSH_CONF/keys.zsh"

## Env variables that have nothing to do with zsh
    export EDITOR=nvim

    # `sudo nano` won't work without this (?)
    if [ "$TERM" = "xterm-kitty" ]; then
        export TERM=xterm-256color
    fi

    ## https://www.tecmint.com/view-colored-man-pages-in-linux/
    ## First seen in Fox Kiesters dotfiles
    export LESS_TERMCAP_mb=$'\e[1;32m'
    export LESS_TERMCAP_md=$'\e[1;32m'
    export LESS_TERMCAP_me=$'\e[0m'
    export LESS_TERMCAP_se=$'\e[0m'
    export LESS_TERMCAP_so=$'\E[01;44;33m'
    export LESS_TERMCAP_ue=$'\e[0m'
    export LESS_TERMCAP_us=$'\e[1;4;31m'

    ## Less clutter in $HOME by enforcing the XDG base directory standard
    export ATOM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/atom"
    export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
    export LESSHISTFILE=-
    export SQLITE_HISTORY="${XDG_DATA_HOME:-$HOME/.local/share}/sqlite3/sqlite_history"

    export ANDROID_SDK_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/android"
    export VIMINIT='let $MYVIMRC="/home/user/.config/vim/xdg.vim" | source $MYVIMRC'

## Setup asynchronous jobs
    # async_start_worker msg_completion
    # async_job msg_completion tg-completion

## Setup zle
    zle_highlight=('paste:none')

## History
    HISTSIZE=1000000
    SAVEHIST=1000000
    HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/.zsh_history"

# Finalize Powerlevel10k instant prompt. Should stay at the bottom of ~/.config/zsh/.zshrc.
(( ! ${+functions[p10k-instant-prompt-finalize]} )) || p10k-instant-prompt-finalize
