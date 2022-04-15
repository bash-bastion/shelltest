# shellcheck shell=sh

util_die() {
	printf '%s\n' "Error: $1. Exiting" >&2
	exit 1
}

util_run() {
	if [ -z "$_shell_abs" ]; then
		printf '%s\n' "Skipping '$_shell_rel' (not installed)"
	else
		# TODO: send 'USR1' to this process from the child launched below only at the end of
		# execution. If we don't get the signal it means that the child terminated prematuraly (set -e), and
		# we can display an error from this side
		printf '%s\n' "--- $_shell_rel ($_shell_abs) ---"
		SHELLTEST_INTERNAL_SHELL=$_shell_rel \
		SHELLTEST_INTERNAL_SHELL_ABS=$_shell_abs \
		SHELLTEST_INTERNAL_FORMATTER=$_flag_formatter \
			"$_shell_abs" "$BASALT_PACKAGE_DIR/pkg/src/libexec/shelltest-runner.sh" "$@"
	fi
}

util_should_run() {
	case ,$1, in
		all) return ;;
		*,"$2",*) return
	esac

	return 1
}

util_get_abs() {
	unset -v _temp; _temp=

	if ! _temp=$(command -v "$1"); then
		# Command not installed
		return
	fi

	if ! readlink -f "$_temp"; then
		_die "Failed to get absolute path of '$1'"
	fi

	unset -v _temp
}

util_help() {
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
