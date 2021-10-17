# shtest

POSIX shell test runner

---

A sort of [Bats](https://github.com/bats-core/bats-core)-lite for POSIX shell scripts

## Features

- Conforms to POSIX
- Uses only builtins
- No eval
- Simple (<150 LOC)
- Works with (`set -euf`) (WIP)
- Perform tests with `[`, etc.
- TAPS output
- `setup`, `setup_file`, `teardown`, `teardown_file`

## Reference

### `SHTEST_DIR`

Absolute path of the directory specified on the command line

### `SHTEST_FILE`

Absolute path of the currently running test file

### `SHTEST_FUNCTION`

Name of the function currently being tested

### `SHTEST_SHELL`

Name of the current shell. (It is recommended to use this instead of `$SHELL`). Not yet implemented

## Tested on...

- [ ] sh
- [x] bash
- [x] ksh
- [ ] pdksh
- [x] zsh
- [ ] dash
- [ ] mksh
- [ ] ash
- [ ] posh
- [ ] yash

More rigorous test suite coming soon...

## Installation

Use [Basalt](https://github.com/hyperupcall/basalt), a Bash package manager, to install this project globally

```sh
basalt global add hyperupcall/shtest
```

## Usage

```sh
$ bash shtest './path/to/testing/file'
...
$ sh shtest './path/to/testing/file'
...
$ zsh shtest './path/to/testing/file'
...
```
