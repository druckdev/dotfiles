#!/bin/sh

exec >/dev/null

CLASS="Gnome-terminal"
NAME="scratchpad-terminal"

while getopts "hn:s" FLAGS; do
    case "$FLAGS" in
        h)  HIDE=1;;
        n)  NAME="$OPTARG";;
        s)  SHOW=1;;
        *)  exit 1;;
    esac
done
shift $(($OPTIND - 1 ))

TREE="$(i3-msg -t get_tree)"
if ! (echo "$TREE"  | grep -Po "\"name\":\"${NAME}\".*?floating\":\"[^\"]*\"" \
                    | grep -q '"floating":"user_on"')
then
    EXIST_NOT=1
elif (echo "$TREE"  | grep -Po '"focused":true.*?name":"[^"]*"' \
                    | grep -q "\"name\":\"${NAME}\"")
then
    FOCUS_ON_PAD=1
elif [ ! $EXIST_NOT ] && (echo "$TREE"  | grep -Po '"output":"__i3".*?"name":"[^"]*"' \
                                        | grep -q "\"name\":\"${NAME}\"")
then
    HIDDEN=1
fi

if [ $HIDE ] && [ ! $EXIST_NOT ] && [ ! $HIDDEN ]; then
    # There is a visible scratchpad-terminal that shall be hidden
    i3-msg "[class=\"$CLASS\" title=\"^${NAME}$\"] scratchpad show"
    exit 0
fi

if [ $SHOW ]; then
    if [ $EXIST_NOT ]; then
        # terminal does not exist yet
        gnome-terminal --window-with-profile="$NAME" --hide-menubar
    elif [ $HIDDEN ]; then
        # terminal is "hidden" in scratchpad
        i3-msg "[class=\"$CLASS\" title=\"^${NAME}$\"] scratchpad show"
    elif [ ! $FOCUS_ON_PAD ]; then
        # terminal is visible but focus lays somewhere else
        i3-msg "[class=\"$CLASS\" title=\"^${NAME}$\"] scratchpad show, scratchpad show"
    fi
    exit 0
fi
