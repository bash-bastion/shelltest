# shellcheck shell=bash

task.docs() {
	shdoc < 'pkg/bin/shtest' > 'docs/api.md'
}
