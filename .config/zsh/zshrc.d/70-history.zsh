HISTSIZE=1000000
SAVEHIST=1000000
# Keep bash from truncating zsh's history if there is no bashrc
export HISTFILESIZE=1000000

if [[ ! -d "${XDG_DATA_HOME:-$HOME/.local/share}"/zsh ]]; then
	mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}"/zsh
fi
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}"/zsh/zsh_history
