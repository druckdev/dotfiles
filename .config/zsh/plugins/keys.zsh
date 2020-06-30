## Author:  druckdev
## Created: 2019-04-17

## Setup keybindings
    bindkey -v
	# no delay when switching into NORMAL
    export KEYTIMEOUT=1

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

## Support selecting with shift and the keyboard
## Does not quite work yet
    shift-arrow() {
      ((REGION_ACTIVE)) || zle set-mark-command
      zle $1
    }
    shift-left() shift-arrow backward-char
    shift-right() shift-arrow forward-char
    shift-left-word() shift-arrow backward-word
    shift-right-word() shift-arrow forward-word
    toggle-select() zle set-mark-command
    #select-all()
    zle -N shift-left
    zle -N shift-right
    zle -N shift-left-word
    zle -N shift-right-word
    zle -N toggle-select 

    bindkey '^[[1;2D' shift-left
    bindkey '^[[1;2C' shift-right
    bindkey '^[[1;6D' shift-left-word
    bindkey '^[[1;6C' shift-right-word

    # bindkey '^S' toggle-select
    # bindkey '^A' select-all
