# shellcheck shell=sh
# shellcheck disable=SC1007,SC1090

# @name shelltest
# @brief A test runner for POSIX-compliant shells
# @description Utility functions for tests ran with shelltest

# @description Test if a name is a function
# @arg $1 string Name of function
# @exitcode 0 If name is a function
# @exitcode 1 If name is not a function
t_is_function() {
	if ! __tmp=$(type "$1" 2>/dev/null); then
		return 1
	fi

	# Most shells have a single line 'my_fn is a function'. In Bash,
	# the rest of the function is printed. In Zsh, it says 'my_fn is
	# a shell function'
	case $__tmp in
		"$1 is a function"*) return 0 ;;
		"$1 is a shell function"*) return 0 ;;
	esac
	
	return 1
}

# @description Get the version of the current running shell
# @set REPLY string Version of the current shell
t_get_version() {
	unset REPLY; REPLY=

	case $SHELLTEST_INTERNAL_FORMATTER in
		sh|ash|dash) ;;
		yash) REPLY=$YASH_VERSION ;;
		oil) REPLY=$OIL_VERSION ;;
		nash) REPLY=$(nsh --version) ;;
		bash) REPLY=$BASH_VERSION ;;
		zsh) REPLY=$ZSH_VERSION ;;
		ksh|mksh|oksh|loksh) REPLY=$KSH_VERSION ;;
		# TODO: die if no match
	esac
}

# @description Run command and print arguments if failure occurs
# @arg $@ string Commands to run
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

# TODO
# @description Prints message to standard output and dies
# @internal
__shtest_util_internal_error() {
	printf '\033[41m\033[1m%s\033[0m %s\n' ' Error ' "$1" >&2
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

	__flag_subshell='no'
	__flag_is_test_function='no'
	for arg; do case $arg in
		--subshell) __flag_subshell=yes; if ! shift; then __shtest_util_die 'Failed to shift'; fi ;;
		--is-test-function) __flag_is_test_function='yes'; if ! shift; then __shtest_util_die 'Failed to shift'; fi ;;
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
			if "$__shtest_exec_function_name"; then
				__shtest_function_exitcode=$?
			else
				__shtest_function_exitcode=$?
			fi
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
	
	# Print results

	if [ "$__shtest_function_exitcode" -eq 0 ]; then
		if [ "$__flag_is_test_function" = 'yes' ]; then
			if [ "$SHELLTEST_INTERNAL_FORMATTER" = 'default' ]; then
				printf '\033[0;32m\033[1m ✓ %s\033[0m\n' "$__shtest_function_name"
			elif [ "$SHELLTEST_INTERNAL_FORMATTER" = 'tap' ]; then
				printf '%s\n' "ok $__shtest_global_current_test [$SHELLTEST_INTERNAL_SHELL] $__shtest_function_name"
			fi
		else
			# Do not print information on success if it is not a "test_*" function
			:
		fi
	else
		# Always print something if an error occured
		
		unset -v __shtest_subfunction_name
		case $__shtest_exec_function_name in setup_file|setup|teardown|teardown_file)
			__shtest_subfunction_name=$__shtest_exec_function_name
		;; esac

		if [ "$SHELLTEST_INTERNAL_FORMATTER" = 'default' ]; then
			printf '\033[0;31m\033[1m ✗ %s\033[0m\n' "$__shtest_function_name ${__shtest_subfunction_name+(in $__shtest_subfunction_name)}"
			__shtest_print_environment
			printf '%s\n' "debug: exit code: $__shtest_function_exitcode"
			printf '%s\n' 'cat <<__STDIN_AND_STDOUT'
			printf '%s\n' "$__shtest_function_output"
			printf '%s\n' '____STDIN_AND_STDOUT'
		elif [ "$SHELLTEST_INTERNAL_FORMATTER" = 'tap' ]; then
			printf '%s\n' "not ok $__shtest_global_current_test $__shtest_function_name ${__shtest_subfunction_name+(in $__shtest_subfunction_name)}"
			__shtest_print_environment
			printf '%s\n' "debug: exit code: $__shtest_function_exitcode"
			printf '%s\n' '--- OUTPUT ---'
			printf '%s\n' "$__shtest_function_output"
			printf '%s\n' '--- END ---'
		fi

		unset -v __shtest_subfunction_name
	fi

	return "$__shtest_function_exitcode"
}

# @description Runs a file
# @internal
__shtest_run_file() {
	__shtest_filename=$1

	__shtest_parse_file "$__shtest_filename"
	# These variables are now set (ex): (WET)
	# __shtest_functions_length=2
	# __shtest_functions="test_fn1|test_fn2|"

	if [ "$SHELLTEST_INTERNAL_FORMATTER" = 'default' ]; then
		printf '\033[0;36m\033[1m%s\033[0m\n' "Running '$__shtest_filename' with $SHELLTEST_INTERNAL_SHELL"
	fi

	# Skip if there are no tests
	if [ "$__shtest_functions_length" -eq 0 ]; then
		printf '\033[0;33m\033[1m - %s\033[0m\n' "No tests"
		printf '\n'
		return
	fi

	# Files run in own subshell
	(
		. "$__shtest_filename"

		if ! __shtest_util_exec_fn 'setup_file'; then
			# If 'setup_file' fails, then don't run _any_ 'test_*' functions in the whole file
			exit 0
		fi

		while [ -n "$__shtest_functions" ]; do
			__shtest_function_name=${__shtest_functions%%|*}
			if [ -z "$__shtest_function_name" ]; then
				continue
			fi

			# Tests run in own subshell
			(
				if ! __shtest_util_exec_fn 'setup'; then
					# If setup fails, then don't run the actual 'test_*' function
					exit 0
				fi

				if ! SHELLTEST_FUNC=$__shtest_function_name __shtest_util_exec_fn --subshell --is-test-function "$__shtest_function_name"; then
					# If a test fails, there isn't anything we can do besides run the teardown. The error has already been printed
					:
				fi

				if ! __shtest_util_exec_fn 'teardown'; then
					# If the teardown fails, there isn't anything we can do. The error already has been printed
					:
				fi
			)

			__shtest_global_current_test=$((__shtest_global_current_test+1))
			__shtest_functions=${__shtest_functions#*|}
		done

		if ! __shtest_util_exec_fn 'teardown_file'; then
			# If the teardown fails, there isn't anything we can do. The error has already been printed
			:
		fi
	)

	if [ "$SHELLTEST_INTERNAL_FORMATTER" = 'default' ]; then
		printf '\n'
	elif [ "$SHELLTEST_INTERNAL_FORMATTER" = 'tap' ]; then
		:
	fi

	# Since increments to this variable were done in a subshell, we need to do it again so
	# its the correct number out of the subshell
	__shtest_global_current_test=$((__shtest_global_current_test+__shtest_functions_length))

	unset -v __shtest_functions_length __shtest_functions
	unset -v __shtest_filename
}

# @description Parses a file
# @set __shtest_functions_length string
# @set __shtest_functions string
# @internal
__shtest_parse_file() {
	__shtest_sub_filename=$1

	__shtest_functions_length=0
	__shtest_functions=

	# Parse shell script, adding testing functions to the list
	while IFS= read -r __shtest_test_function || [ -n "$test_function" ]; do
		# Functions part of the test suite must have a name that starts with 'test_'
		case $__shtest_test_function in
			*'test_'*'()'*'{'*) : ;;
			*) continue ;;
		esac

		# Convert the line contaning the function name to just the name of the function. The last two statements
		# remove leading and trailing whitespaces, which is required
		__shtest_test_function=${__shtest_test_function%%"()"*"{"*}
		__shtest_test_function=${__shtest_test_function#"${__shtest_test_function%%[![:space:]]*}"}
		__shtest_test_function=${__shtest_test_function%"${__shtest_test_function##*[![:space:]]}"}

		# Ignore comment lines
		case $__shtest_test_function in
			*'#'*'test_'*) continue ;;
			*) : ;;
		esac

		__shtest_functions_length=$((__shtest_functions_length+1))
		__shtest_functions="$__shtest_functions$__shtest_test_function|"
	done < "$__shtest_sub_filename"; unset -v __shtest_test_function

	unset -v __shtest_sub_filename
}

# @description Application entrypoint
# @internal
__main_shelltest() {
	set -e
	export LANG='C' LC_CTYPE='C' LC_NUMERIC='C' LC_TIME='C' LC_COLLATE='C' \
		LC_MONETARY='C' LC_MESSAGES='C' LC_PAPER='C' LC_NAME='C' LC_ADDRESS='C' \
		LC_TELEPHONE='C' LC_MEASUREMENT='C' LC_IDENTIFICATION='C' LC_ALL='C'
	export SHELLTEST= SHELLTEST_DIR= SHELLTEST_FILE= SHELLTEST_FUNC=

	__shtest_arg_path=$1
	__shtest_arg_first_run=$2
	
	# Run tests for either file or directory
	if [ -f "$__shtest_arg_path" ]; then
		if ! SHELLTEST_DIR=$(
			if ! CDPATH= cd -P "${__shtest_arg_path%/*}"; then
				exit 1
			fi

			printf '%s' "$PWD"
		); then
			__shtest_util_die "Could not generate absolute path from directory '${__shtest_arg_path%/*}'"
		fi
		SHELLTEST_FILE=__shtest_arg_path

		__shtest_run_file "$__shtest_arg_path"
	elif [ -d "$__shtest_arg_path" ]; then
		__shtest_arg_path=${__shtest_arg_path%/}
		__shtest_file=

		# Parse all files and get total number of tests
		__shtest_global_total_tests='0'
		if [ -f "$__shtest_arg_path/*.sh" ]; then
			__shtest_util_die "Directory '$__shtest_arg_path' must not contain a file called '*.sh'"
		fi
		for __shtest_file in "$__shtest_arg_path"/*.sh; do
			if [ "$__shtest_file" = "$__shtest_arg_path/*.sh" ]; then
				__shtest_util_die "Directory '$__shtest_arg_path' does not contain any test files"
			fi

			__shtest_parse_file "$__shtest_file"
			# These variables are now set (ex): (WET)
			# __shtest_functions_length=2
			# __shtest_functions="test_fn1|test_fn2|"
			__shtest_global_total_tests=$((__shtest_global_total_tests+__shtest_functions_length))
		done; unset -v __shtest_file

		# Total number of ran tests
		__shtest_global_total_tests=$((__shtest_global_total_tests*SHELLTEST_INTERNAL_SHELLS_TOTAL))

			
		if [ "$__shtest_arg_first_run" = 'yes' ]; then
			if [ "$SHELLTEST_INTERNAL_FORMATTER" = 'default' ]; then
				printf '%s\n' "Running $__shtest_global_total_tests tests"
			elif [ "$SHELLTEST_INTERNAL_FORMATTER" = 'tap' ]; then
				printf '%d..%d\n' '1' "$__shtest_global_total_tests"
			fi
		fi


		# Actually execute the tests
		# TODO: optimize by not running __shtest_parse_file twice (now it runs above and inside of __shtest_run_file)
		__shtest_global_current_test='1'
		for __shtest_file in "$__shtest_arg_path"/*.sh; do
			SHELLTEST_DIR=$__shtest_arg_path
			SHELLTEST_FILE=$__shtest_file
			__shtest_run_file "$__shtest_file"
		done; unset -v __shtest_file
	elif [ -e "$__shtest_arg_path" ]; then
		__shtest_util_die "File '$__shtest_arg_path' is neither a regular file nor a directory"
	else
		__shtest_util_die "File or directory '$__shtest_arg_path' does not exist"
	fi
	unset -v __shtest_arg_path
}

__main_shelltest "$@"
