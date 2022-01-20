# shellcheck shell=sh
source './examples/lib.sh'

util_print() {
	printf '%b' "$1"
}

test_int_equals() {
	[ 3 -eq 3 ]
	[ 4 -eq 4 ]
	! [ -4 -eq 5 ]
}

test_str_equals() {
	[ s = s ]
	[ st = st ]
	[ vv\ v = 'vv v' ]
	[ {} = '{}' ]
	! [ 0 = $'\x01' ]
}

test_printf() {
	[ "$(util_print '\101')" = A ]
	[ "$(util_print '\102')" = B ]
	[ "$(util_print '\102')" = C ]
}
