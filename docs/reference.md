# Reference

## Environment Variables

The following environment variables are set

### `SHELLTEST`

Set when `shtest` is running

### `SHELLTEST_DIR`

Absolute path of the directory containing the currently running testfile

### `SHELLTEST_SHELL`

Name of the current shell. (It is recommended to use this instead of `$SHELL`). Not yet implemented

### `SHELLTEST_FUNC`

Name of the current executing function

## `SHELLTEST_SHELL`

Name of the current shell

## Functions

The following functions are set

### `assert`

Prints a pretty error on a failed assertion

### `setup_file`

Runs before running the first test in a file

### `setup`

Runs before each test

### `teardown`

Runs after each test

### `teardown_file`

Runs after running the last test in a file
