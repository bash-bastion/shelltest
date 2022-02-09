# shellcheck shell=sh

_die() {
	printf '%s\n' "Error: $1. Exiting" >&2
	exit 1
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

__main_shelltestw() {
	_flag_shells='all'
	_flag_formatter='default'

	for _arg do case $_arg in
		-s|--shells)
			if ! shift; then _die 'Failed shift'; fi
			_flag_shells=$1
			if ! shift; then _die "A value must be supplied for '--shells'"; fi
			;;
		-f|--formatter)
			if ! shift; then _die 'Failed shift'; fi
			_flag_formatter=$1
			if ! shift; then _die "A value must be supplied for '--formatter'"; fi
			;;
		-h|--help)
			_help
			return
			;;
		-*) _die 'Flag not recognized'
	esac done; unset _arg

	# TODO: validate _flag_shells

	if [ "$_flag_formatter" != 'default' ] && [ "$_flag_formatter" != 'tap' ]; then
		_die "Flag '--formatter' only accepts either 'default' or 'tap'"
	fi

	if [ $# -eq 0 ]; then
		_help
		_die "Must specify least one file or directory"
	fi

	# posix
	for _s in sh ash dash yash oil nash; do
		if _should_run; then
			_shell_rel=$_s
			_shell_abs=$(_get_tabs)
			_run "$@"
		fi
	done

	# bash, zsh
	for _s in bash zsh; do
		if _should_run; then
			_shell_rel=$_s
			_shell_abs=$(_get_tabs)
			_run "$@"
		fi
	done

	# ksh
	for _s in ksh mksh oksh loksh; do
		if _should_run; then
			_shell_rel=$_s
			_shell_abs=$(_get_tabs)
			_run "$@"
		fi
	done
}
