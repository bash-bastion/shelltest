# shellcheck shell=sh

return_n() {
	return "$1"
}

add_nums() {
	unset -v REPLY
	REPLY="$(printf '%s\n' "$1 + $2" | bc)"
}

subtract_nums() {
	unset -v REPLY
	REPLY="$(printf '%s\n' "$1 - $2" | bc)"
}

multiply_nums() {
	unset -v REPLY
	REPLY="$(printf '%s\n' "$1 * $2" | bc)"
}

divide_nums() {
	unset -v REPLY
	REPLY="$(printf '%s\n' "$1 / $2" | bc)"
}

str_append() {
	unset -v REPLY
	REPLY="$1$2"
}

echo_var() {
	printf '%s\n' "VARIABLE: $1"
}
