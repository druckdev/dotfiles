## Author:  druckdev
## Created: 2019-04-17

## Setup keybindings
    bindkey -v
	# no delay when switching into NORMAL
    export KEYTIMEOUT=1

    # Switch cursor style depending on mode
    function zle-line-init zle-keymap-select {
        case $KEYMAP in
            vicmd) echo -ne "\e[1 q";; # block
            viins|main) echo -ne "\e[5 q";; # beam
        esac
    }
    zle -N zle-line-init
    zle -N zle-keymap-select

	bindkey '^[h' run-help
## History
    ## Alternatives to check out: {up,down}-line-or-search
    bindkey '^[[A'  history-substring-search-up
    bindkey "$terminfo[kcuu1]" history-substring-search-up
    bindkey '^[[B'  history-substring-search-down
    bindkey "$terminfo[kcud1]" history-substring-search-down
    bindkey '^R'    history-incremental-search-backward

## Navigation
    bindkey '^[[Z' reverse-menu-complete         # shift-tab
    bindkey '^K' kill-whole-line                 # ctrl-K
    bindkey '^Q' push-input                      # ctrl-Q
    bindkey '\e[H' beginning-of-line             # home
	bindkey "$terminfo[khome]" beginning-of-line # home
    bindkey '\e[F' end-of-line                   # end
    bindkey "$terminfo[kend]" end-of-line        # end
    bindkey -v '^?' backward-delete-char         # normal delete not vim-bac...
    bindkey '^[[P' delete-char                   # delete
    bindkey '^[[3~' delete-char                  # delete
    bindkey '^[[1;5D' backward-word              # ctrl-left
    bindkey '^[[1;5C' forward-word               # ctrl-right
    bindkey '^H' backward-kill-word              # ctrl-backspace
    bindkey '^[[3;5~' kill-word                  # ctrl-delete
    bindkey "$terminfo[kmous]" kill-word         # ctrl-delete

    ## From https://github.com/nicoulaj/dotfiles/blob/1c7dd1b621bc8bae895bafc438562482ea245d7e/.config/zsh/functions/widgets/rationalize-dots
    function _expandDots {
        #[[ $LBUFFER = *.. ]] && LBUFFER+=/.. || LBUFFER+=.
        setopt localoptions nonomatch
        local MATCH dir split
        split=(${(z)LBUFFER})
        (( $#split > 1 )) && dir=$split[-1] || dir=$split
        if [[ $LBUFFER =~ '(^|/| | |'$'\n''|\||;|&)\.\.$' ]]; then
            LBUFFER+=/
            zle self-insert
            zle self-insert
            [[ -e $dir ]] && zle -M ${dir:a:h}
        elif [[ $LBUFFER[-1] == '.' ]]; then
            zle self-insert
            [[ -e $dir ]] && zle -M ${dir:a:h}
        else
            zle self-insert
        fi
    }
    #autoload _expandDots
    zle -N _expandDots
    bindkey . _expandDots

