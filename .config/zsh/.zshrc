## Author:  druckdev
## Created: 2018-11-23

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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
	[[ -e "$1" ]] && comp-conf "$1" && source -- "$1"
}

folder-source() {
	[[ -d "$1" ]] || return 1

	for f in "$1"/[^._]*(N); do
		if [[ -d "$f" ]]; then
			folder-source "$f"
		elif [[ -n "${f##*.zwc}" ]]; then
			comp-source "$f"
		fi
	done
}

folder-source "$ZDOTDIR"/zshrc.d
