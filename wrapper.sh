#!/usr/bin/env bash

forshell() {
	local shell=$1

	shellpath=$(command -v "$shell")
	realshellpath=$(readlink -f "$shellpath")
	printf '%s\n' "SHELL: $shell"
	if [ -n "$shellpath" ]; then
		printf '%s\n' "$shellpath -> $realshellpath"
	else
		printf '%s\n' '<shell not found>'
	fi
	# printf '%s\n' '--- (version)'
}

runshell() {
	if [ -z "$shellpath" ]; then
		printf '%s\n' '<not applicable>'
		return
	fi
	"$@"
}

endshell() {
	printf '\n'
	# printf -- '---\n\n'
}

main() {
	## more POSIXy
	forshell 'sh'
	runshell
	endshell

	forshell 'ash'
	runshell
	endshell

	forshell 'dash'
	runshell
	endshell

	forshell 'yash'
	runshell "$shellpath" -c 'printf "%s\n" "$YASH_VERSION"'
	endshell

	forshell 'oil'
	runshell "$shellpath" -c 'printf "%s\n" "$OIL_VERSION"'
	endshell

	forshell 'nsh'
	runshell nsh --version
	endshell

	## bash
	forshell 'bash'
	runshell "$shellpath" -c 'printf "%s\n" "$BASH_VERSION"'
	endshell


	## zsh
	forshell 'zsh'
	runshell "$shellpath" -c 'printf "%s\n" "$ZSH_VERSION"'
	endshell


	## kshes
	forshell 'ksh'
	runshell "$shellpath" -c 'printf "%s\n" "$KSH_VERSION"'
	endshell

	forshell 'mksh'
	runshell "$shellpath" -c 'printf "%s\n" "$KSH_VERSION"'
	endshell

	forshell 'oksh'
	runshell "$shellpath" -c 'printf "%s\n" "$KSH_VERSION"'
	endshell

	forshell 'loksh'
	runshell "$shellpath" -c 'printf "%s\n" "$KSH_VERSION"'
	endshell

	forshell 'posh'
	runshell "$shellpath" -c 'printf "%s\n" "$POSH_VERSION"'
	endshell
}

main "$@"
