# shellcheck shell=sh
# @brief shtest: A test runner for POSIX shells
# @description A test runner

set -e
export LANG='C' LC_CTYPE='C' LC_NUMERIC='C' LC_TIME='C' LC_COLLATE='C' LC_MONETARY='C' \
	LC_MESSAGES='C' LC_PAPER='C' LC_NAME='C' LC_ADDRESS='C' LC_TELEPHONE='C' \
	LC_MEASUREMENT='C' LC_IDENTIFICATION='C' LC_ALL='C'
export SHELLTEST= SHELLTEST_DIR= SHELLTEST_FILE= SHELLTEST_FUNC=

# @description Run command and print information if failure occurs
assert() {
	if "$@"; then :; else
		printf '\e[41m%s\e[0m\n: %s' "Error" "Execution of command '$*' failed with exitcode $?" >&2
		return 1
	fi
}

version() {
	unset REPLY; REPLY=

	case $SHELLTEST_INTERNAL_FORMATTER in
		sh|ash|dash) ;;
		yash) REPLY=$YASH_VERSION ;;
		oil) REPLY=$OIL_VERSION ;;
		nsh) REPLY=$(nsh --version) ;;
		bash) REPLY=$BASH_VERSION ;;
		zsh) REPLY=$ZSH_VERSION ;;
		ksh|mksh|oksh|loksh) REPLY=$KSH_VERSION ;;
		posh) REPLY=$POSH_VERSION
	esac
}

# @description Prints message to standard output and dies
# @internal
__shtest_util_die() {
	printf '\e[41m\e[1m%s\e[0m %s\n' ' Error ' "$1" >&2
	exit 1
}

# @description Test whether color should be outputed
# @exitcode 0 if should print color
# @exitcode 1 if should not print color
# @internal
__shtest_is_color() {
	# ! [ -z $NO_COLOR ] || [[ $TERM = dumb ]]
	return 0 # TODO
}

# @description Handle ERR traps
# @internal
__shtest_util_trap_err_handler() {
	__shtest_trap_error_exit_code=$?
	printf '%s\n' '--- OUTPUT ---'
	printf '%s\n' "$__shtest_function_output"
	printf '%s\n' '--- END ---'
}

# @description Executes a particular function and saves output
# @set __shtest_function_output Combined standard output and input of function
# @set __shtest_function_exitcode Exit code of function
# @internal
__shtest_util_exec_fn() {
	unset -v __shtest_function_output; __shtest_function_output=
	unset -v __shtest_function_exitcode; __shtest_function_exitcode=
	__shtest_exec_function_name=$1

	if ! shift; then
		__shtest_util_die "Failed to shift"
	fi

	if PATH= command -v "$__shtest_exec_function_name" >/dev/null 2>&1; then
		# trap '__shtest_util_trap_err_handler' ERR # TODO
		# __shtest_function_output="$("$__shtest_exec_function_name" 2>&1)"

		if __shtest_function_output="$("$__shtest_exec_function_name" 2>&1)"; then
			__shtest_function_exitcode=$?
		else
			__shtest_function_exitcode=$?
		fi
	else
		case $__shtest_exec_function_name in setup_file|setup|teardown|teardown_file) :;; *)
			__shtest_util_die "Function '$__shtest_exec_function_name' could not be found"
		;; esac
	fi
}

__shtest_util_exec_test_fn() {
	__shtest_exec_test_function_name=$1

	SHELLTEST_FUNC=$__shtest_function_name
	__shtest_util_exec_fn "$__shtest_exec_test_function_name"
	if [ "$__shtest_function_exitcode" -eq 0 ]; then
		if [ "$SHELLTEST_INTERNAL_FORMATTER" = 'default' ]; then
			printf ' ✓ %s\n' "$__shtest_function_name"
		elif [ "$SHELLTEST_INTERNAL_FORMATTER" = 'tap' ]; then
			printf '%s\n' "ok $__shtest_function_i $__shtest_function_name"
		fi
	else
		if [ "$SHELLTEST_INTERNAL_FORMATTER" = 'default' ]; then
			printf '\e[0;31m\e[1m ✗ %s\e[0m\n' "$__shtest_function_name"

			# printf '%s\n' '--- OUTPUT ---'
			# printf '%s\n' "$__shtest_function_output"
			# printf '%s\n' '--- END ---'
		elif [ "$SHELLTEST_INTERNAL_FORMATTER" = 'tap' ]; then
			printf '%s\n' "not ok $__shtest_function_i $__shtest_function_name"

			# TODO
		fi
	fi
}

__shtest_run_file() {
	__shtest_filename=$1

	__shtest_functions_length=0
	__shtest_functions=

	# Parse shell script, adding testing functions to the list
	while IFS= read -r __shtest_test_function || [ -n "$test_function" ]; do
		# Functions part of the test suite must have a name that starts with 'test_'
		case $__shtest_test_function in
			'test_'*'() {'*) : ;;
			*) continue ;;
		esac

		# This works on the assumption that there are no whitespace characters before
		# the function identifier. Additionally, this strips comments after the function,
		# which prevents "ignoring comment lines" in cases where tests are like Bats
		__shtest_test_function="${__shtest_test_function%%"() {"*}"

		# Ignore comment lines
		case $__shtest_test_function in
			*'#'*) continue ;;
			*) : ;;
		esac

		__shtest_functions_length=$((__shtest_functions_length+1))
		__shtest_functions="$__shtest_functions$__shtest_test_function:"
	done < "$__shtest_filename"; unset -v __shtest_test_function

	# Skip if there are no tests
	if [ "$__shtest_functions_length" -eq 0 ]; then
		printf '\e[44m\e[1m%s\e[0m \e[1m%s\e[0m\n' ' FILE ' "$__shtest_filename (skipped)"
		return
	fi

	# Execute all testing functions in current file
	. "$__shtest_filename"

	if [ "$SHELLTEST_INTERNAL_FORMATTER" = 'default' ]; then
		# printf '\e[38;2;%d;%d;%dm%s\e[0m\n' 0 0 0 "BLACK"
		# printf '\e[0;30m\e[47m\e[1m%s\e[0m \e[1m%s\e[0m\n' ' FILE ' "$__shtest_filename"
		printf '=> \e[4;37mRUNNING\e[0m %s\n' "\"$__shtest_filename\"" # TODO
	elif [ "$SHELLTEST_INTERNAL_FORMATTER" = 'tap' ]; then
		printf '%d..%d\n' '1' "$__shtest_functions_length"
	fi

	__shtest_util_exec_fn 'setup_file'

	__shtest_function_i=1
	while [ -n "$__shtest_functions" ]; do
		__shtest_function_name="${__shtest_functions%%:*}"
		if [ -z "$__shtest_function_name" ]; then
			continue
		fi

		__shtest_util_exec_fn 'setup'

		__shtest_util_exec_test_fn "$__shtest_function_name"

		__shtest_util_exec_fn 'teardown'

		__shtest_function_i=$((__shtest_function_i=__shtest_function_i+1))
		__shtest_functions=${__shtest_functions#*:}
	done
	unset -v __shtest_function_i

	__shtest_util_exec_fn 'teardown_file'

	unset -v __shtest_functions_length __shtest_functions
	unset -v __shtest_filename
}

# @description Application entrypoint
# @internal
__main_shelltest() {
	# Run tests for either file or directory
	__shtest_arg=$1
	if [ -f "$__shtest_arg" ]; then
		if ! SHELLTEST_DIR="$(
			if ! CDPATH= cd -P "${__shtest_arg%/*}"; then
				exit 1
			fi

			printf '%s' "$PWD"
		)"; then
			__shtest_util_die "Could not generate absolute path from directory '${__shtest_arg%/*}'"
		fi
		SHELLTEST_FILE=__shtest_arg

		__shtest_run_file "$__shtest_arg"
	elif [ -d "$__shtest_arg" ]; then
		__shtest_arg=${__shtest_arg%/}
		__shtest_file=
		for __shtest_file in "$__shtest_arg"/*.sh; do
			if [ "$__shtest_file" = "$__shtest_arg/*.sh" ]; then
				__shtest_util_die "Directory '$__shtest_arg' does not contain any test files"
			fi

			SHELLTEST_DIR=$__shtest_arg
			SHELLTEST_FILE=$__shtest_file
			__shtest_run_file "$__shtest_file"
		done; unset -v __shtest_file
	elif [ -e "$__shtest_arg" ]; then
		__shtest_util_die "File '$__shtest_arg' is neither a regular file nor a directory"
	else
		__shtest_util_die "Path '$__shtest_arg' does not exist"
	fi
	unset -v __shtest_arg
}

__main_shelltest "$@"