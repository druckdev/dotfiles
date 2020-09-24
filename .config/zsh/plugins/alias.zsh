## Author:  druckdev
## Created: 2019-01-16

## Add fslint-directory to PATH
PATH="${PATH:+${PATH}:}/usr/share/fslint/fslint"

## Add flags or shorten commands that I cannot remember
alias getclip="xclip -selection c -o"
alias setclip="perl -pe 'chomp if eof' | xclip -selection c"
alias pdfviewer='evince'
alias pdf='launch evince'
alias darkpdf='launch zathura'
alias geeqie='launch qeeqie'
alias grep='grep --color'
alias igrep='grep -i'
alias emacs-game='emacs -batch -l dunnet'
alias trash-restore='restore-trash'
alias cp='cp -i'
alias mv='mv -i' # --backup=t ??
alias rm='rm -I'
alias less='less -N'
alias lsblk='lsblk -f'
alias rd='rmdir'
alias md='mkdir -p'
alias o='xdg-open'
alias p='pwd'
alias :q='exit'
alias :Q=:q
alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y; [ ! -e /var/run/reboot-required ] || printf "\n\nSystem restart required.\n"'
alias pdf2text='pdftotext'
alias pdf2txt='pdftotext'
alias rm='printf "\033[1;031mUse trash!\n\033[0m"; false'
alias battery='upower -i /org/freedesktop/UPower/devices/battery_BAT0 | grep -E "to full|percentage" | tr -d " " | sed "s/:/: /"'
alias qrdecode='zbarimg'
alias pdfmerge='pdfunite'
alias loadhist='fc -RI'
alias wget='wget --config=${XDG_CONFIG_HOME:-$HOME/.config}/wget/wgetrc --hsts-file="${XDG_DATA_HOME:-$HOME/.local/share}/wget/wget-hsts"'
alias -g G='| grep '
alias -g no2='2>/dev/null'
alias hex=xxd
alias bin='xxd -b -c4 | cut -d" " -f2-5'
if command -v nvim >/dev/null 2>&1; then
	alias vim=nvim
	alias vi=nvim
fi
alias tmux='tmux -f "$HOME/.config/tmux/tmux.conf"'
alias resetCursor='echo -ne "\e[5 q"'
alias makeThisScratchpad='echo -ne "\033]0;scratchpad-terminal\007"'
alias tmsu='tmsu -D "${XDG_DATA_HOME:-$HOME/.local/share}/tmsu/db"'
alias grepdate='grep -E "(={8})|([0-9]{4}([: -_][0-9]{2}){5})|([0-9]{8}[ -_][0-9]{6})"'
alias feh='feh -.'
# 'Temporary' shell in alternate mode that does not mess with the scrollback history
alias tmpshell='tput smcup && zsh && tput rmcup'

## functions
alias trash=_trash_list_default
alias nemo=_nemo_wd_default

## git
alias gs='git status --short' # overrides ghostscript
alias gits='gs'
alias gstat='gs'
alias gitstat='gs'
alias ga='git add'
alias gaa='git add -A'
alias gc="git commit"
alias gpsh='git push'
alias gpush='git push'
alias gpll='git pull'
alias gpull='git pull'
alias gdiff='git diff'
alias gd='git diff'

## Navigation
alias ls='ls --color=auto --group-directories-first -p -v'
alias sl='ls'
alias la='ls -A'
alias l='ls -lh --time-style=long-iso'
alias ll='l -A'
alias cd..='cd ..'
alias cd~='cd ~'

## Hashes for often visited folders
hash -d Desktop=$HOME/Desktop/
hash -d Documents=$HOME/Documents/
hash -d Pictures=$HOME/Pictures/
hash -d Downloads=$HOME/Downloads/
hash -d Projects=$HOME/Projects/
hash -d dot=~Projects/github/dotfiles-github/
hash -d dots=~dot

local UNI="$HOME/Documents/uni"
hash -d cheat=$HOME/Documents/Cheat\ Sheet/
hash -d uni=$UNI/
# hash for current/last wise
local YEAR=$(date +"%y")
if [ -d "$UNI/$YEAR-WiSe" ]; then
	hash -d wise="$UNI/$YEAR-WiSe/"
elif [ -d "$UNI/$(($YEAR - 1))-WiSe" ]; then
	hash -d wise="$UNI/$(($YEAR - 1))-WiSe/"
fi
# hash for current/last sose
if [ -d "$UNI/$YEAR-SoSe" ]; then
	hash -d sose="$UNI/$YEAR-SoSe"/
elif [ -d "$UNI/$(($YEAR - 1))-SoSe" ]; then
	hash -d sose="$UNI/$(($YEAR - 1))-SoSe/"
fi
