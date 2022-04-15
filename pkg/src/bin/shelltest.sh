# shellcheck shell=bash

main.shelltest() {
	local flag_shells='all'
	local flag_formatter='default'
	local arg_dir=

	while [ $# -ne 0 ]; do case $1 in
	-s|--shells)
		if ! shift; then
			util_die 'Failed shift'
		fi

		flag_shells=$1
		if [ -z "$flag_shells" ]; then
			util_die "A value must be supplied for '--shells'"
		fi

		if ! shift; then
			util_die 'Failed shift'
		fi
		;;
	-f|--formatter)
		if ! shift; then
			util_die 'Failed shift'
		fi

		flag_formatter=$1
		if [ -z "$flag_formatter" ]; then
			util_die "A value must be supplied for '--formatter'"
		fi

		if ! shift; then
			util_die 'Failed shift'
		fi
		;;
	-h|--help)
		util_help
		return
		;;
	-*) util_die 'Flag not recognized' ;;
	*)
		if [ -n "$arg_dir" ]; then
			util_die "Cannot supply more than one directory or file"
		fi

		arg_dir=$1
		if ! shift; then
			util_die 'Failed shift'
		fi
		;;
	esac done

	if [ "$flag_formatter" != 'default' ] && [ "$flag_formatter" != 'tap' ]; then
		util_die "Flag '--formatter' only accepts either 'default' or 'tap'"
	fi

	if [ -z "$arg_dir" ]; then
		util_help
		util_die "Must specify least one file or directory"
	fi
	
	_shells_total=0

	_temp=$flag_shells
	while [ -n "$_temp" ]; do
		case ${_temp%%,*} in
			all) ;;
			sh|ash|dash|yash|oil|nash) ;;
			bash|zsh) ;;
			ksh|mksh|oksh|loksh) ;;
			*) util_die "Shell '${_temp%%,*}' is not supported" ;;
		esac

		if util_should_run "$flag_shells" "${_temp%%,*}"; then
			_shells_total=$((_shells_total+1))
		fi

		case $_temp in
			*,*) _temp=${_temp#*,} ;;
			*) _temp= ;;
		esac
	done

	_is_first_run='yes'
	for _shell_rel in \
		sh ash dash yash oil nash \
		bash zsh \
		ksh mksh oksh loksh
	do
		if util_should_run "$flag_shells" "$_shell_rel"; then
			_shell_abs=$(util_get_abs "$_shell_rel")
			util_run "$arg_dir" "$_is_first_run"

			_is_first_run='no'
		fi
	done
}
