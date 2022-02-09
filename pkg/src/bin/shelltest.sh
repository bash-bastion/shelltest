# shellcheck shell=sh
# shellcheck disable=SC1007,SC1090

# @brief shtest: A test runner for POSIX shells
# @description A test runner

t_is_function() {
	# Most shells have a single line 'my_fn is a function'. In Bash,
	# the rest of the function is printed. In Zsh, it says 'my_fn is
	# a shell function'
	case $(type "$1") in
		"$1 is a function"*) return 0 ;;
		"$1 is a shell function"*) return 0
	esac

	return 1
}

t_get_version() {
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

# @description Run command and print information if failure occurs
t_assert() {
	if "$@"; then :; else
		printf '\033[41m%s\033[0m\n: %s' "Error" "Execution of command '$*' failed with exitcode $?" >&2
		return 1
	fi
}

# @description Prints message to standard output and dies
# @internal
__shtest_util_die() {
	printf '\033[41m\033[1m%s\033[0m %s\n' ' Error ' "$1" >&2
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

# @description Prints handy varaibles from the environment
# @internal
__shtest_print_environment() {
	for __shtest_variable in PWD LANG LC_ALL; do
		printf '%s\n' "debug: $__shtest_variable: $(eval "printf '%s' \$$__shtest_variable")"
	done; unset -v __shtest_variable
}

# @description Trap error handler
# @internal
# __shtest_trap_err() {
# 	echo 'TRAPPED'
# }

# @description Executes a particular function and saves output
# @set __shtest_function_output Combined standard output and input of function
# @set __shtest_function_exitcode Exit code of function
# @internal
__shtest_util_exec_fn() {
	unset -v __shtest_function_output; __shtest_function_output=
	unset -v __shtest_function_exitcode; __shtest_function_exitcode=

	__flag_subshell=no
	for arg; do case $arg in
		--subshell) __flag_subshell=yes; if ! shift; then __shtest_util_die 'Failed to shift'; fi
	esac done

	__shtest_exec_function_name=$1
	if ! shift; then __shtest_util_die 'Failed to shift'; fi

	if PATH= command -v "$__shtest_exec_function_name" >/dev/null 2>&1; then
		# trap 'if [ $? -eq 0 ]; then __shtest_trap_err; fi' EXIT

		if [ "$__flag_subshell" = yes ]; then
			if __shtest_function_output=$("$__shtest_exec_function_name" 2>&1); then
				__shtest_function_exitcode=$?
			else
				__shtest_function_exitcode=$?
			fi
		else
			# TODO: Grabbing output should be handeled elsewhere, as the printing is different dependent on either whether a 'setup',
			# 'setup_file', etc. function is called or a regular 'test_*' function
			echo before
			if "$__shtest_exec_function_name"; then
				__shtest_function_exitcode=$?
			else
				__shtest_function_exitcode=$?
			fi
			echo after
		fi
	else
		# Don't die in these particular cases as 'setup_file', 'setup', etc. aren't required to be defined
		# within the file
		case $__shtest_exec_function_name in setup_file|setup|teardown|teardown_file) :;; *)
			__shtest_util_die "Function '$__shtest_exec_function_name' could not be found. This should not happen"
		;; esac

		return
	fi

	unset -v __flag_subshell

	if [ "$__shtest_function_exitcode" -eq 0 ]; then
		if [ "$SHELLTEST_INTERNAL_FORMATTER" = 'default' ]; then
			printf '\033[0;32m\033[1m ✓ %s\033[0m\n' "$__shtest_function_name"
		elif [ "$SHELLTEST_INTERNAL_FORMATTER" = 'tap' ]; then
			printf '%s\n' "ok $__shtest_function_i $__shtest_function_name"
		fi
	else
		unset -v __shtest_subfunction_name
		case $__shtest_exec_function_name in setup_file|setup|teardown|teardown_file)
			__shtest_subfunction_name=$__shtest_exec_function_name
		;; esac

		if [ "$SHELLTEST_INTERNAL_FORMATTER" = 'default' ]; then
			printf '\033[0;31m\033[1m ✗ %s\033[0m\n' "$__shtest_function_name ${__shtest_subfunction_name+(in $__shtest_subfunction_name)}"
			__shtest_print_environment
			printf '%s\n' "debug: code: $__shtest_function_exitcode"
			printf '%s\n' 'cat <<__STDIN_AND_STDOUT'
			printf '%s\n' "$__shtest_function_output"
			printf '%s\n' '____STDIN_AND_STDOUT'
		elif [ "$SHELLTEST_INTERNAL_FORMATTER" = 'tap' ]; then
			printf '%s\n' "not ok $__shtest_function_i $__shtest_function_name ${__shtest_subfunction_name+(in $__shtest_subfunction_name)}"
			__shtest_print_environment
			printf '%s\n' "debug: code: $__shtest_function_exitcode"
			printf '%s\n' '--- OUTPUT ---'
			printf '%s\n' "$__shtest_function_output"
			printf '%s\n' '--- END ---'
		fi

		unset -v __shtest_subfunction_name
	fi

	return "$__shtest_function_exitcode"
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

	if [ "$SHELLTEST_INTERNAL_FORMATTER" = 'default' ]; then
		printf '\033[0;36m\033[1m%s\033[0m\n' "Running '$__shtest_filename' with $SHELLTEST_INTERNAL_SHELL"
	elif [ "$SHELLTEST_INTERNAL_FORMATTER" = 'tap' ]; then
		printf '%d..%d\n' '1' "$__shtest_functions_length"
	fi

	# Skip if there are no tests
	if [ "$__shtest_functions_length" -eq 0 ]; then
		printf '\033[0;33m\033[1m ‐ %s\033[0m\n' "No tests"
		printf '\n'
		return
	fi

	(
		. "$__shtest_filename"

		if ! __shtest_util_exec_fn 'setup_file'; then
			# If 'setup_file' fails, then don't run _any_ 'test_*' functions in the whole file
			exit 0
		fi

		__shtest_function_i=1
		while [ -n "$__shtest_functions" ]; do
			__shtest_function_name="${__shtest_functions%%:*}"
			if [ -z "$__shtest_function_name" ]; then
				continue
			fi

			(
				if ! __shtest_util_exec_fn 'setup'; then
					# If setup fails, then don't run the actual 'test_*' function
					exit 0
				fi

				if ! SHELLTEST_FUNC=$__shtest_function_name __shtest_util_exec_fn --subshell "$__shtest_function_name"; then
					# If a test fails, there isn't anything we can do besdies run the teardown. The error has already been printed
					:
				fi

				if ! __shtest_util_exec_fn 'teardown'; then
					# If the teardown fails, there isn't anything we can do. The error already has been printed
					:
				fi
			)

			__shtest_function_i=$((__shtest_function_i=__shtest_function_i+1))
			__shtest_functions=${__shtest_functions#*:}
		done
		unset -v __shtest_function_i

		if ! __shtest_util_exec_fn 'teardown_file'; then
			# If the teardown fails, there isn't anything we can do. The error has already been printed
			:
		fi
		printf '\n'
	)

	unset -v __shtest_functions_length __shtest_functions
	unset -v __shtest_filename
}

__shtest_zsh_is_sourced=no
case $ZSH_EVAL_CONTEXT in *:file)
	__shtest_zsh_is_sourced=yes
;; esac

# @description Application entrypoint
# @internal
__main_shelltest() {

	set -e
	export LANG='C' LC_CTYPE='C' LC_NUMERIC='C' LC_TIME='C' LC_COLLATE='C' LC_MONETARY='C' \
		LC_MESSAGES='C' LC_PAPER='C' LC_NAME='C' LC_ADDRESS='C' LC_TELEPHONE='C' \
		LC_MEASUREMENT='C' LC_IDENTIFICATION='C' LC_ALL='C'
	export SHELLTEST= SHELLTEST_DIR= SHELLTEST_FILE= SHELLTEST_FUNC=

	if [ -n "$BASH_VERSION" ]; then
		if [ "${BASH_SOURCE[0]}" != "$0" ]; then
			printf '%s\n' "SHOULD NOT SOURCE"
			return 1 # TODO
		fi
	elif [ -n "$ZSH_VERSION" ]; then
		if [ "$__shtest_zsh_is_sourced" = yes ]; then
			printf '%s\n' "SHOULD NOT SOURCE"
			return 1 # TODO
		fi
	fi

	unset -v __shtest_zsh_is_sourced

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
