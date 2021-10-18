# shellcheck shell=bash

if [ "$SHTEST" = yes ]; then
	# TODO: self-host tests
	:
else
	shtest="$BATS_TEST_DIRNAME"/../bin/shtest


	load './util/test_util.sh'
fi


setup() {
	if ! cd "$BATS_TEST_TMPDIR"; then
		return 1
	fi
}

teardown() {
	if ! cd "$BATS_SUITE_TMPDIR"; then
		return 1
	fi
}
