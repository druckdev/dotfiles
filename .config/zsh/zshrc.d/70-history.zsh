# SPDX-License-Identifier: MIT
# Copyright (c) 2020 - 2022 Julian Prein

HISTSIZE=999999999
SAVEHIST="$HISTSIZE"

# Keep bash from truncating zsh's history if there is no bashrc
export HISTFILESIZE="$HISTSIZE"

if [[ ! -d "${XDG_DATA_HOME:-$HOME/.local/share}"/zsh ]]; then
	mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}"/zsh
fi
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}"/zsh/zsh_history
