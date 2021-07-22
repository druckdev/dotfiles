## Author:  druckdev
## Created: 2021-07-21

# Children of HOME
for dir in "$HOME"/[^.]*(/); do
	[[ ! ${dir:t} =~ " " ]] || continue
	hash -d ${dir:t}="$dir"
done

# Children of documents
hash="$(xdg-user-dir DOCUMENTS 2>/dev/null || echo docs)"
hash="$(basename "$hash")"
if (( $+nameddirs[$hash] )); then
	hash -d cheat=~$hash/cheat_sheets
	hash -d uni=~$hash/uni
	hash -d work=~$hash/work
fi
unset hash

# Dotfiles
if (( $+nameddirs[projs] )); then
	hash -d dot{,s}=~projs/dotfiles
fi

# Most recent semester folder
if (( $+nameddirs[uni] )); then
	# Use the first match in ~uni/[0-9][0-9]-{So,Wi}Se sorted in descending
	# numeric order (most recent semester). The echo is necessary as else
	# filename generation will include the wise= and nothing is matched.
	# TODO!
	hash -d sose="$(echo ~uni/[0-9][0-9]-SoSe(NnOn[1]))"
	hash -d wise="$(echo ~uni/[0-9][0-9]-WiSe(NnOn[1]))"
fi
