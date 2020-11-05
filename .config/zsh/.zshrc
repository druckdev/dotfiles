## Author:  druckdev
## Created: 2018-11-23

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH_CONF="$ZDOTDIR/plugins"

# https://github.com/romkatv/dotfiles-public/blob/7e49fc4fb71d/.zshrc#L35
comp-conf() {
	emulate -L zsh
	[[ ! "$1.zwc" -nt "$1" && -w "${1:h}" ]] || return 0
	zmodload -F zsh/files b:zf_mv b:zf_rm
	local tmp="$1.tmp.$$.zwc"
	{
		zcompile -R -- "$tmp" "$1" && zf_mv -f -- "$tmp" "$1.zwc" || return 1
	} always {
		(( ! $? )) || zf_rm -f -- "$tmp"
	}
}

# https://github.com/romkatv/dotfiles-public/blob/7e49fc4fb71d/.zshrc#L47
comp-source() {
	emulate -L zsh
	[[ -e "$1" ]] && comp-conf "$1" && source -- "$1"
}

## set zshoptions
setopt AUTO_CONTINUE            # Stopped jobs with 'disown' are automatically sent a CONT signal to make them running.
setopt AUTO_LIST                # Automatically list choices on an ambiguous completion.
setopt AUTO_PARAM_SLASH         # Add a trailing slash when completing directories
setopt AUTO_PUSHD               # Make cd push the old directory onto the directory stack.
setopt NO_AUTO_REMOVE_SLASH     # Keeps trailing slash for directories when auto completing.
                                #   (Beware: commands will act on the target directory not the symlink with the slash)
setopt NO_BEEP                  # Do not beep on error in ZLE.
setopt CDABLE_VARS              # Expand named directories without leading '~'.
setopt C_BASES                  # Output hexadecimal numbers in the standard C format ('16#FF' -> '0xFF').
setopt CHASE_LINKS              # Resolve symbolic links to their true values when changing directory.
setopt NO_CLOBBER               # '>!' or '>|' must be used to truncate a file, and '>>!' or '>>|' to create a file.
setopt NO_COMPLETE_ALIASES      # Substitute internally before completion.
setopt COMPLETE_IN_WORD         # Complete from the cursor rather than from the end of the word
setopt CORRECT                  # Try to correct the spelling of a command
setopt CORRECT_ALL              # Try to correct the spelling of all arguments
CORRECT_IGNORE_FILE=".*"        # Do not offer hidden files as correction
setopt EXTENDED_HISTORY         # Save in format : <beginning time>:<elapsed seconds>;<command>
setopt EXTENDED_GLOB            # Treat the `#', `~' and `^' characters as part of patterns for filename generation, etc.
setopt NO_FLOW_CONTROL          # Disables output flow control in the shell's editor via start/stop characters (usually ^S/^Q).
setopt GLOB_DOTS                # Do not require a leading `.' in a filename to be matched explicitly.
setopt HIST_IGNORE_DUPS         # Do not enter command lines into the history list if they are duplicates of the previous event.
setopt HIST_IGNORE_SPACE        # History should ignore commands beginning with a space
setopt HIST_VERIFY              # perform history expansion and reload line in editing buffer instead of executing it directly
setopt NO_INC_APPEND_HISTORY    # Do not write lines as soon as they are entered (breaks exec time otherwise)
setopt INC_APPEND_HISTORY_TIME  # Write lines after they are finished
setopt INTERACTIVE_COMMENTS     # Allow comments even in interactive shells.
setopt LIST_AMBIGUOUS           # Insert unambiguous prefix without completion list (auto_list set)
setopt LIST_PACKED              # Make completion list smaller by printing matches in columns with different widths.
setopt NO_MENU_COMPLETE         # Do not autoselect the first entry when completing
setopt PUSHD_IGNORE_DUPS        # Don't push multiple copies of the same directory onto the directory stack.
setopt NO_SHARE_HISTORY         # Do not write + read history after every command (messes up exec time otherwise)
setopt SH_WORD_SPLIT            # Causes field splitting to be performed on unquoted parameter expansions

autoload -U select-word-style && select-word-style bash

## Setup the prompt
# use bright version of colors when printing bold
if command -v dircolors &>/dev/null; then
	if [[ -e "${XDG_CONFIG_HOME:-$HOME/.config}/dircolors/dircolors" ]]; then
		eval "$(dircolors -b "${XDG_CONFIG_HOME:-$HOME/.config}/dircolors/dircolors")"
	else
		eval "$(dircolors -b)"
	fi
fi

if [[ -e "$ZSH_CONF/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
	comp-source "$ZSH_CONF/powerlevel10k/powerlevel10k.zsh-theme"
	# To customize prompt, run `p10k configure` or edit $ZSH_CONF/p10k.zsh-theme.
	comp-source "$ZSH_CONF/p10k.zsh-theme"
fi

## Setup zsh completion system
[[ ! -d "$ZSH_CONF/completion" ]] || fpath=("$ZSH_CONF/completion" $fpath)

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

# Include hidden files in completion.
_comp_options+=(globdots)

# Don't complete the same argument twice for these programs.
# Taken from http://leahneukirchen.org/dotfiles/.zshrc
zstyle ':completion:*:(diff|meld|trash):*' ignore-line yes

comp-source "$ZSH_CONF/fzf-tab/fzf-tab.plugin.zsh"

## Load external config files and modules
autoload edit-command-line; zle -N edit-command-line
(( ! $+aliases[run-help] )) || unalias run-help
autoload -Uz run-help run-help-git zmv
if [[ -d "$ZDOTDIR/autoload" ]]; then
	fpath=("$ZDOTDIR/autoload" $fpath)
	autoload -Uz -- "" "${fpath[1]}"/[^_.]*(.xN:t)
fi
! command -v direnv &>/dev/null || eval "$(direnv hook zsh)"
# stderred
if [[ -e "$ZSH_CONF/stderred/usr/share/stderred/stderred.sh" ]]; then
	comp-source "$ZSH_CONF/stderred/usr/share/stderred/stderred.sh"
	export STDERRED_ESC_CODE="$(tput bold && tput setaf 1)" # bold red
	export STDERRED_BLACKLIST="^(git|curl|wget|swipl)$"
fi
comp-source "$ZSH_CONF/alias.zsh"
comp-source "$ZSH_CONF/functions.zsh"
comp-source "$ZSH_CONF/zsh-autosuggestions/zsh-autosuggestions.zsh"
### syntax-highlight > keys
# syntax highlighting
if [[ -e "$ZSH_CONF/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
	comp-source "$ZSH_CONF/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
	comp-source "$ZSH_CONF/zsh-syntax-highlighting.zsh-theme"
fi
comp-source "$ZSH_CONF/keys.zsh"
# Reenable fzf-tab since `bindkey -v` seems to deactivate it
enable-fzf-tab

## Setup zle
zle_highlight=('paste:none')

## History
HISTSIZE=1000000
SAVEHIST=1000000
[[ -d "${XDG_DATA_HOME:-$HOME/.local/share}/zsh" ]] || mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/zsh"
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/.zsh_history"
