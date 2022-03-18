# shellcheck shell=bash

task.docs() {
	shdoc < 'pkg/bin/shtest' > 'docs/api.md'
}

task.test() {
	./pkg/bin/shelltest ./tests
}
