##!/usr/bin/env bash

# Common Variables Documentation $?, $0 ... {{{
# ${BASH_SOURCE[0]} is the path of the script that is being executed
# ${BASH_SOURCE[1]} is the path of the script that is sourcing the current script

# $0	Name of the script being executed.
# $1, $2, ...	Positional parameters (arguments to the script).
# $@	All arguments as separate words.
# $*	All arguments as a single string.
# $$	Process ID of the current shell.
# $?	Exit status of the last command.
# $_	Last argument of the previous command.
# $#	Number of arguments passed to the script.
# }}}

# I. Source vs Execution (delete if not using `exit` vs `finish`) {{{
SCRIPT_PATH="${BASH_SOURCE[0]}"
SCRIPT_DIRECTORY=$(dirname "$SCRIPT_PATH")
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    is_source=true
else
    is_source=false
fi
# }}}

# II. ANSI (delete if not using colored text) {{{
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    # Output is going to a terminal - use colors
    BOLD_GREEN='\033[1;32m'
    BOLD_RED='\033[1;31m'
    RESET='\033[0m'
else
    # Output is being piped - don't use colors
    BOLD_GREEN=''
    BOLD_RED=''
    RESET=''
fi
# echo -e "${BOLD_GREEN}Success!${RESET}"
# echo -e "${BOLD_RED}Error!${RESET}"
# }}}

# III. Helper Functions (die, require_command) {{{
# Exit with error message
# Usage: die "error message"
die() {
    echo -e "${BOLD_RED}ERROR:${RESET} $1" >&2
    if [[ "$is_sourced" == true ]]; then
        return 1
    else
        exit 1
    fi
}
# Check if required command is available
# Usage: require_command "jq"
require_command() {
    command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}
# }}}

