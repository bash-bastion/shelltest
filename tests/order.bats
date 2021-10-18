#!/usr/bin/env bats

load './util/init.sh'

@test "outputs correctly on no tests" {
	output="$(bash "$shtest" "$BATS_TEST_DIRNAME/mocks")"
	# TODO: this isn't the output we want
	[ "$output" = '1..0' ]
}
