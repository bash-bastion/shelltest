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

### `TEST_FILE`

### `TEST_FUNCTION`

### `TEST_SHELL`

## Tested on...

- [ ] sh
- [x] bash
- [x] ksh
- [ ] pdksh
- [x] zsh
- [ ] ash

More rigorous test suite coming soon...

## Installation
