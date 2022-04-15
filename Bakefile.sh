# shellcheck shell=bash

task.init() {
	hookah refresh
}

task.docs() {
	shdoc < './pkg/src/libexec/shelltest-runner.sh' > './docs/api.md'
}

task.test() {
	./pkg/bin/shelltest ./tests
}
