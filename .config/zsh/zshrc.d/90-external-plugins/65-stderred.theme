# Bold red

if (( $+commands[tput] )); then
	STDERRED_ESC_CODE="$(tput bold && tput setaf 1)"
else
	STDERRED_ESC_CODE="\e[1m\e31m"
fi
export STDERRED_ESC_CODE

export STDERRED_BLACKLIST="^(git|curl|wget|swipl)$"
