setopt AUTO_CONTINUE            # Stopped jobs with 'disown' are automatically sent a CONT signal to make them running.
setopt AUTO_LIST                # Automatically list choices on an ambiguous completion.
setopt AUTO_PARAM_SLASH         # Add a trailing slash when completing directories
setopt AUTO_PUSHD               # Make cd push the old directory onto the directory stack.
setopt NO_AUTO_REMOVE_SLASH     # Keeps trailing slash for directories when auto completing.
setopt NO_BEEP                  # Do not beep on error in ZLE.
setopt CDABLE_VARS              # Expand named directories without leading '~'.
setopt C_BASES                  # Output hexadecimal numbers in the standard C format ('16#FF' -> '0xFF').
setopt CHASE_LINKS              # Resolve symbolic links to their true values when changing directory.
setopt NO_CLOBBER               # '>!' or '>|' must be used to truncate a file, and '>>!' or '>>|' to create a file.
setopt NO_COMPLETE_ALIASES      # Substitute internally before completion.
setopt COMPLETE_IN_WORD         # Complete from the cursor rather than from the end of the word
setopt CORRECT                  # Try to correct the spelling of a command
setopt CORRECT_ALL              # Try to correct the spelling of all arguments
CORRECT_IGNORE_FILE=".*"        # Do not offer hidden files as correction
setopt EXTENDED_HISTORY         # Save in format : <beginning time>:<elapsed seconds>;<command>
setopt EXTENDED_GLOB            # Treat the `#', `~' and `^' characters as part of patterns for filename generation, etc.
setopt NO_FLOW_CONTROL          # Disables output flow control in the shell's editor via start/stop characters (usually ^S/^Q).
setopt GLOB_DOTS                # Do not require a leading `.' in a filename to be matched explicitly.
setopt HIST_IGNORE_DUPS         # Do not enter command lines into the history list if they are duplicates of the previous event.
setopt HIST_IGNORE_SPACE        # History should ignore commands beginning with a space
setopt HIST_VERIFY              # perform history expansion and reload line in editing buffer instead of executing it directly
setopt NO_INC_APPEND_HISTORY    # Do not write lines as soon as they are entered (breaks exec time otherwise)
setopt INC_APPEND_HISTORY_TIME  # Write lines after they are finished
setopt INTERACTIVE_COMMENTS     # Allow comments even in interactive shells.
setopt LIST_AMBIGUOUS           # Insert unambiguous prefix without completion list (auto_list set)
setopt LIST_PACKED              # Make completion list smaller by printing matches in columns with different widths.
setopt NO_MENU_COMPLETE         # Do not autoselect the first entry when completing
setopt PUSHD_IGNORE_DUPS        # Don't push multiple copies of the same directory onto the directory stack.
setopt NO_SHARE_HISTORY         # Do not write + read history after every command (messes up exec time otherwise)
setopt SH_WORD_SPLIT            # Causes field splitting to be performed on unquoted parameter expansions
