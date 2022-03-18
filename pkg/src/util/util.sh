# shellcheck shell=sh

_die() {
	printf '%s\n' "Error: $1. Exiting" >&2
	exit 1
}

_should_run() {
	case $_flag_shells in
		all) return ;;
		*:"$_s":*) return
	esac

	return 1
}

_get_tabs() {
	unset -v temp; temp=

	if ! temp=$(command -v "$_shell_rel"); then
		# Command not installed
		return
	fi

	if ! readlink -f "$temp"; then
		_die "Failed to get absolute path of '$_shell_rel'"
	fi
}

_run() {
	if [ -z "$_shell_abs" ]; then
		printf '%s\n' "Skipping '$_shell_rel' (not installed)"
	else
		# TODO: send 'USR1' to this process from the child launched below only at the end of
		# execution. If we don't get the signal it means that the child terminated prematuraly (set -e), and
		# we can display an error from this side
		printf '%s\n' "--- $_shell_rel ($_shell_abs) ---"
		SHELLTEST_INTERNAL_SHELL=$_s \
		SHELLTEST_INTERNAL_SHELL_ABS=$_shell_abs \
		SHELLTEST_INTERNAL_FORMATTER=$_flag_formatter \
			"$_shell_abs" "$BASALT_PACKAGE_DIR/pkg/src/bin/shelltest.sh" "$@"
	fi

	printf '\n'
}

_help() {
	printf '%s\n' "Usage:
   shtest [flags] <test-file-or-dir>

Flags:
   -s, --shells
      Specify shells to test. If omitted, defaults to 'all'
   -f, --formatter
      Choose an output format. Options include 'default' and 'tap'
   -h, --help
      Show help menu"
}
