# Reference

## Environment Variables

The following environment variables are set

### `SHTEST`

Set when `shtest` is running

### `SHTEST_DIR`

Absolute path of the directory containing the currently running testfile

### `SHTEST_SHELL`

Name of the current shell. (It is recommended to use this instead of `$SHELL`). Not yet implemented

## Functions

The following functions are set

### `assert`

### `setup_file`

Runs before running the first test in a file

### `setup`

Runs before each test

### `teardown`

Runs after each test

### `teardown_file`

Runs after running the last test in a file
