# shtest

POSIX shell test runner

---

[Bats](https://github.com/bats-core/bats-core) is phenomenal, but it only works for bash. [shunit2](https://github.com/kward/shunit2), [shellspec](https://github.com/shellspec/shellspec), [shspec](https://github.com/rylnd/shpec), and [urchin](https://github.com/tlevine/urchin) try to solve this, but I did not gravitate strongly to any of the solutions - they were too complex for what they did

## Benefits

- Uses only builtins
- POSIX compliant
- Simple (<100 LOC)
- TAPS output (WIP)


## Reference

### `TEST_DIR`

Absolute path of the directory specified on the command line

### `TEST_FILE`

Absolute path of the currently running test file

### `TEST_FUNCTION`

Name of the function currently being tested

### `TEST_SHELL`

Name of the current shell. (It is recommended to use this instead of `$SHELL`)

## Tested on...

- [ ] sh
- [x] bash
- [x] ksh
- [ ] pdksh
- [x] zsh
- [ ] ash

More rigorous test suite coming soon...

## Installation

Use [Basalt](https://github.com/hyperupcall/basalt), a Bash package manager, to install this project globally

```sh
basalt global add hyperupcall/shtest
```
