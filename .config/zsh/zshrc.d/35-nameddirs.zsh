## Author:  druckdev
## Created: 2021-07-21

# Children of HOME
# for dir in "$HOME"/[^.]*(/); do
# 	[[ ! ${dir:t} =~ " " ]] || continue
# 	hash -d -- ${dir:t}="$dir"
# done

# Children of documents
docs="$(xdg-user-dir DOCUMENTS 2>/dev/null)"
if [[ -e $docs ]]; then
	hash -d cheat="$docs"/cheat_sheets
	hash -d uni="$docs"/uni
	hash -d work="$docs"/work
fi
unset hash

# Dotfiles
if [[ -e ~/projs ]]; then
	hash -d dot{,s}=~/projs/dotfiles
fi

# Most recent semester folder
if (( $+nameddirs[uni] )); then
	# Use the first match in ~uni/[0-9][0-9]-{s,w}s sorted in descending
	# numeric order (most recent semester). The echo is necessary as else
	# filename generation will include the wise= and nothing is matched.
	# TODO!
	dir="$(echo ~uni/[0-9][0-9]ss(NnOn[1]))"
	if [[ $dir ]]; then
		hash -d sose="$dir"
		hash -d ss="$nameddirs[sose]"
	fi
	dir="$(echo ~uni/[0-9][0-9]ws(NnOn[1]))"
	if [[ $dir ]]; then
		hash -d wise="$dir"
		hash -d ws="$nameddirs[wise]"
	fi
	unset dir
fi
