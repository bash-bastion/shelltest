# shellcheck shell=sh

__main_shelltest() {
	_flag_shells='all'
	_flag_formatter='default'
	_arg_dirs=

	while [ $# -ne 0 ]; do case $1 in
	-s|--shells)
		if ! shift; then
			util_die 'Failed shift'
		fi

		_flag_shells=$1
		if [ -z "$_flag_shells" ]; then
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

		_flag_formatter=$1
		if [ -z "$_flag_formatter" ]; then
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
		if [ -n "$_arg_dirs" ]; then
			util_die "Cannot supply more than one directory or file"
		fi

		_arg_dirs="$1"
		if ! shift; then
			util_die 'Failed shift'
		fi
		;;
	esac done

	if [ "$_flag_formatter" != 'default' ] && [ "$_flag_formatter" != 'tap' ]; then
		util_die "Flag '--formatter' only accepts either 'default' or 'tap'"
	fi

	if [ -z "$_arg_dirs" ]; then
		util_help
		util_die "Must specify least one file or directory"
	fi

	tmp="$_flag_shells"
	while [ -n "$tmp" ]; do
		case ${tmp%%,*} in
			all) ;;
			sh|ash|dash|yash|oil|nash) ;;
			bash|zsh) ;;
			ksh|mksh|oksh|loksh) ;;
			*) util_die "Shell '${tmp%%,*}' is not supported" ;;
		esac

		case $tmp in
			*,*) tmp=${tmp#*,} ;;
			*) tmp= ;;
		esac
	done

	# posix
	for _shell_rel in sh ash dash yash oil nash; do
		if util_should_run "$_flag_shells" "$_shell_rel"; then
			_shell_abs=$(util_get_abs "$_shell_rel")
			util_run "$_arg_dirs"
		fi
	done

	# bash, zsh
	for _shell_rel in bash zsh; do
		if util_should_run "$_flag_shells" "$_shell_rel"; then
			_shell_abs=$(util_get_abs "$_shell_rel")
			util_run "$_arg_dirs"
		fi
	done

	# ksh
	for _shell_rel in ksh mksh oksh loksh; do
		if util_should_run "$_flag_shells" "$_shell_rel"; then
			_shell_abs=$(util_get_abs "$_shell_rel")
			util_run "$_arg_dirs"
		fi
	done
}
