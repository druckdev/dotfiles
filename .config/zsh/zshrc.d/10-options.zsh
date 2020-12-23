# Vim macro that pulls the description from zshoptions(1) for the next option:
# `/setopt:s/\m \(NO_\)\?\([^ ]*\)/ \2/^wyEu:vert Man zshoptions/\m^ \+"j^y$ho# pddkPgqqj`
# Load for example into `q` by: `"qyi``
# NOTE: Only copies first line. If there are multiple lines (as with
# SHARE_HISTORY) the other lines have to be copied manually.

# Changing Directories
	# Make cd push the old directory onto the directory stack.
	setopt AUTO_PUSHD

	# If the argument to a cd command (or an implied cd with the AUTO_CD option
	# set) is not a directory, and does not begin with a slash, try to expand
	# the expression as if it were preceded by a `~' (see the section `Filename
	# Expansion').
	setopt CDABLE_VARS

	# Resolve symbolic links to their true values when changing directory.  This
	# also has the effect of CHASE_DOTS, i.e. a `..' path segment will be
	# treated as referring to the physical parent, even if the preceding path
	# segment is a symbolic link.
	setopt CHASE_LINKS

	# Don't push multiple copies of the same directory onto the directory stack.
	setopt PUSHD_IGNORE_DUPS

# Completion
	# Automatically list choices on an ambiguous completion.
	setopt AUTO_LIST

	# If a parameter is completed whose content is the name of a directory, then
	# add a trailing slash instead of a space.
	setopt AUTO_PARAM_SLASH

	# When the last character resulting from a completion is a slash and the
	# next character typed is a word delimiter, a slash, or a character that
	# ends a command (such as a semicolon or an ampersand), remove the slash.
	setopt NO_AUTO_REMOVE_SLASH

	# Prevents aliases on the command line from being internally substituted
	# before completion is attempted.  The effect is to make the alias a
	# distinct command for completion purposes.
	setopt NO_COMPLETE_ALIASES

	# If unset, the cursor is set to the end of the word if completion is
	# started. Otherwise it stays there and completion is done from both ends.
	setopt COMPLETE_IN_WORD

	# This option works when AUTO_LIST or BASH_AUTO_LIST is also set.  If there
	# is an unambiguous prefix to insert on the command line, that is done
	# without a completion list being displayed; in other words, auto-listing
	# behaviour only takes place when nothing would be inserted.  In the case of
	# BASH_AUTO_LIST, this means that the list will be delayed to the third call
	# of the function.
	setopt LIST_AMBIGUOUS

	# Try to make the completion list smaller (occupying less lines) by printing
	# the matches in columns with different widths.
	setopt LIST_PACKED

	# On an ambiguous completion, instead of listing possibilities or beeping,
	# insert the first match immediately.  Then when completion is requested
	# again, remove the first match and insert the second match, etc.  When
	# there are no more matches, go back to the first one again.
	# reverse-menu-complete may be used to loop through the list in the other
	# direction. This option overrides AUTO_MENU.
	setopt NO_MENU_COMPLETE

# Expansion and Globbing
	# Treat the `#', `~' and `^' characters as part of patterns for filename
	# generation, etc.  (An initial unquoted `~' always produces named directory
	# expansion.)
	setopt EXTENDED_GLOB

	# Do not require a leading `.' in a filename to be matched explicitly.
	setopt GLOB_DOTS

# History
	# Save each command's beginning timestamp (in seconds since the epoch) and
	# the duration (in seconds) to the history file.  The format of this
	# prefixed data is:
	# `: <beginning time>:<elapsed seconds>;<command>'.
	setopt EXTENDED_HISTORY

	# Do not enter command lines into the history list if they are duplicates of
	# the previous event.
	setopt HIST_IGNORE_DUPS

	# Remove command lines from the history list when the first character on the
	# line is a space, or when one of the expanded aliases contains a leading
	# space.  Only normal aliases (not global or suffix aliases) have this
	# behaviour.  Note that the command lingers in the internal history until
	# the next command is entered before it vanishes, allowing you to briefly
	# reuse or edit the line.  If you want to make it vanish right away without
	# entering another command, type a space and press return.
	setopt HIST_IGNORE_SPACE

	# Remove function definitions from the history list.  Note that the function
	# lingers in the internal history until the next command is entered before
	# it vanishes, allowing you to briefly reuse or edit the definition.
	setopt HIST_NO_FUNCTIONS

	# Whenever the user enters a line with history expansion, don't execute the
	# line directly; instead, perform history expansion and reload the line into
	# the editing buffer.
	setopt HIST_VERIFY

	# This option works like APPEND_HISTORY except that new history lines are
	# added to the $HISTFILE incrementally (as soon as they are entered), rather
	# than waiting until the shell exits.  The file will still be periodically
	# re-written to trim it when the number of lines grows 20% beyond the value
	# specified by $SAVEHIST (see also the HIST_SAVE_BY_COPY option).
	setopt NO_INC_APPEND_HISTORY

	# This option is a variant of INC_APPEND_HISTORY in which, where possible,
	# the history entry is written out to the file after the command is
	# finished, so that the time taken by the command is recorded correctly in
	# the history file in EXTENDED_HISTORY format.  This means that the history
	# entry will not be available immediately from other instances of the shell
	# that are using the same history file.
	setopt INC_APPEND_HISTORY_TIME

	# Allow comments even in interactive shells.
	setopt INTERACTIVE_COMMENTS

	# This option both imports new commands from the history file, and also
	# causes your typed commands to be appended to the history file (the latter
	# is like specifying INC_APPEND_HISTORY, which should be turned off if this
	# option is in effect).  The history lines are also output with timestamps
	# ala EXTENDED_HISTORY (which makes it easier to find the spot where we left
	# off reading the file after it gets re-written).
	#
	# By default, history movement commands visit the imported lines as well as
	# the local lines, but you can toggle this on and off with the
	# set-local-history zle binding.  It is also possible to create a zle widget
	# that will make some commands ignore imported commands, and some include
	# them.
	#
	# If you find that you want more control over when commands get imported,
	# you may wish to turn SHARE_HISTORY off, INC_APPEND_HISTORY or
	# INC_APPEND_HISTORY_TIME (see above) on, and then manually import commands
	# whenever you need them using `fc -RI'.
	setopt NO_SHARE_HISTORY

# Input/Output
	# Allows `>' redirection to truncate existing files.  Otherwise `>!' or `>|'
	# must be used to truncate a file.
	#
	# If the option is not set, and the option APPEND_CREATE is also not set,
	#`>>!' or `>>|' must be used to create a file.  If either option is set,
	#`>>' may be used.
	setopt NO_CLOBBER

	# Try to correct the spelling of commands.  Note that, when the
	# HASH_LIST_ALL option is not set or when some directories in the path are
	# not readable, this may falsely report spelling errors the first time some
	# commands are used.
	#
	# The shell variable CORRECT_IGNORE may be set to a pattern to match words
	# that will never be offered as corrections.
	setopt CORRECT

	# Try to correct the spelling of all arguments in a line.
	#
	# The shell variable CORRECT_IGNORE_FILE may be set to a pattern to match
	# file names that will never be offered as corrections.
	setopt CORRECT_ALL
	CORRECT_IGNORE_FILE=".*"

	# If this option is unset, output flow control via start/stop characters
	# (usually assigned to ^S/^Q) is disabled in the shell's editor.
	setopt NO_FLOW_CONTROL

# Job Control
	# With this option set, stopped jobs that are removed from the job table
	# with the disown builtin command are automatically sent a CONT signal to
	# make them running.
	setopt AUTO_CONTINUE

# Scripts and Functions
	# Output hexadecimal numbers in the standard C format, for example `0xFF'
	# instead of the usual `16#FF'.  If the option OCTAL_ZEROES is also set (it
	# is not by default), octal numbers will be treated similarly and hence
	# appear as `077' instead of `8#77'.  This option has no effect on the
	# choice of the output base, nor on the output of bases other than
	# hexadecimal and octal.  Note that these formats will be understood on
	# input irrespective of the setting of C_BASES.
	setopt C_BASES

# Shell Emulation
	# Causes field splitting to be performed on unquoted parameter expansions.
	# Note that this option has nothing to do with word splitting.
	# (See zshexpn(1).)
	setopt SH_WORD_SPLIT

# Zle
	# Beep on error in ZLE.
	setopt NO_BEEP
