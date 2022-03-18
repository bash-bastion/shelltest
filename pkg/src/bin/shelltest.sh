# shellcheck shell=sh

__main_shelltest() {
	_flag_shells='all'
	_flag_formatter='default'

	for _arg do case $_arg in
	-s|--shells)
		if ! shift; then _die 'Failed shift'; fi
		_flag_shells=$1
		if ! shift; then _die "A value must be supplied for '--shells'"; fi
		echo nnn
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
	-*) _die 'Flag not recognized' ;;
	*)
		dirs="$dirs:$1"
		if ! shift; then _die 'Failed shift'; fi
		;;
	esac done; unset -v _arg

	if [ "$_flag_formatter" != 'default' ] && [ "$_flag_formatter" != 'tap' ]; then
		_die "Flag '--formatter' only accepts either 'default' or 'tap'"
	fi

	if [ -z "$dirs" ]; then
		_help
		_die "Must specify least one file or directory"
	fi

	printf '%s\n' "$_flag_shells" | while IFS=':' read -r _s; do
		case $_s in
			all) ;;
			sh|ash|dash|yash|oil|nash) ;;
			bash|zsh) ;;
			ksh|mksh|oksh|loksh) ;;
			*) _die "Shell '$_s' is not supported" ;;
		esac
	done

	# posix
	for _s in sh ash dash yash oil nash; do
		if _should_run; then
			_shell_rel=$_s
			_shell_abs=$(_get_tabs)
			_run "$@"
		fi
	done; unset -v _s

	# bash, zsh
	for _s in bash zsh; do
		if _should_run; then
			_shell_rel=$_s
			_shell_abs=$(_get_tabs)
			_run "$@"
		fi
	done; unset -v _s

	# ksh
	for _s in ksh mksh oksh loksh; do
		if _should_run; then
			_shell_rel=$_s
			_shell_abs=$(_get_tabs)
			_run "$@"
		fi
	done; unset -v _s
}
