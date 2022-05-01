# Set suggestions strategy
# match_prev_cmd:
#     Chooses the most recent match from history whose preceding item matches
#     the most recently executed command.
#     Won't work as expected with HIST_IGNORE_ALL_DUPS or HIST_EXPIRE_DUPS_FIRST
# completion:
#     Chooses a suggestion based on what tab-completion would suggest.
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)

ZSH_AUTOSUGGEST_MATCH_NUM_PREV_CMDS=2
ZSH_AUTOSUGGEST_MATCH_PREV_MAX_CMDS=-1

# vim: ft=zsh
