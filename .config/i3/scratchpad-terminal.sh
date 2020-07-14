#!/bin/sh

exec >/dev/null

while getopts "c:e:hn:s" FLAGS; do
    case "$FLAGS" in
        c)  W_CLASS="$OPTARG";;
        e)  COMMAND="$OPTARG";;
        h)  HIDE=1;;
        n)  W_NAME="$OPTARG";;
        s)  SHOW=1;;
        *)  exit 1;;
    esac
done
shift $(($OPTIND - 1))

[ -n "$W_CLASS" ] || return 1
[ -n "$W_NAME" ] || return 1
[ -z "$SHOW" ] || [ -n "$COMMAND" ] || return 1

TREE="$(i3-msg -t get_tree)"
if ! (echo "$TREE"  | grep -Po "\"name\":\"${W_NAME}\".*?class\":\"$W_CLASS\".*?floating\":\"[^\"]*\"" \
                    | grep -q '"floating":"user_on"')
then
    EXIST_NOT=1
elif (echo "$TREE"  | grep -Po '"focused":true.*?name":"[^"]*"' \
                    | grep -q "\"name\":\"${W_NAME}\"")
then
    FOCUS_ON_PAD=1
elif [ ! $EXIST_NOT ] && (echo "$TREE"  | grep -Po '"output":"__i3".*?"name":"[^"]*"' \
                                        | grep -q "\"name\":\"${W_NAME}\"")
then
    HIDDEN=1
fi

if [ $HIDE ] && [ ! $EXIST_NOT ] && [ ! $HIDDEN ]; then
    # There is a visible scratchpad-terminal that shall be hidden
    i3-msg "[class=\"$W_CLASS\" title=\"^${W_NAME}$\"] scratchpad show"
    exit 0
fi

if [ $SHOW ]; then
    if [ $EXIST_NOT ]; then
        # terminal does not exist yet
        WORKSPACE="$(i3-msg -t get_workspaces | jq '.[] | select(.focused==true).name' | tr -d '"')"
        i3-msg "workspace $W_NAME"
        eval env SCRATCHPAD_TERMINAL=1 $COMMAND &
        # Sleep for a very short time until the window is ready (floating, etc.)
        # TODO: Dirty hack! Find something better.
        sleep 0.1
        i3-msg "workspace $WORKSPACE"
    elif [ $HIDDEN ]; then
        # terminal is "hidden" in scratchpad
        i3-msg "[class=\"$W_CLASS\" title=\"^${W_NAME}$\"] scratchpad show"
    elif [ ! $FOCUS_ON_PAD ]; then
        # terminal is visible but focus lays somewhere else
        i3-msg "[class=\"$W_CLASS\" title=\"^${W_NAME}$\"] scratchpad show, scratchpad show"
    fi
    exit 0
fi
