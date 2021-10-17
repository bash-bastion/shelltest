# shellcheck shell=bash

eval "$(basalt-package-init)"
basalt.package-init
basalt.package-load
# basalt.load 'github.com/hyperupcall/bats-common-utils' 'load.bash'

load './util/test_util.sh'

export NO_COLOR=

setup() {
	ensure.cd "$BATS_TEST_TMPDIR"
}

teardown() {
	ensure.cd "$BATS_SUITE_TMPDIR"
}
