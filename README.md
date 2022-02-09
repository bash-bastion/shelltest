# shelltest

A test runner for POSIX shells

## Features

- Conforms to POSIX
- Uses only builtins
- No eval
- Perform tests with `[`, etc.
- TAPS output
- `setup`, `setup_file`, `teardown`, `teardown_file`
- Utility functions `t_is_function`, `t_get_shell_version`, `t_assert`

## Tested on...

- [ ] sh
- [ ] BusyBox sh
- [ ] ash
- [ ] dash (Debian variant of NetBSD ash)
- [ ] yash
- [ ] oil
- [ ] nsh
- [ ] bash
- [ ] zsh
- [ ] ksh (2020.0.0)
- [ ] pdksh
- [ ] mksh (MirBSD fork of OpenBSD pdksh)
- [ ] loksh (Linux port of OpenBSD pdksh)
- [ ] oksh (General port of OpenBSD pdksh)

## Not supported

- Tcsh/Csh
- Fish
- oh
- ion
- xonsh
- elvish
- abs

More rigorous test suite coming soon...

## Installation

Use [Basalt](https://github.com/hyperupcall/basalt), a Bash package manager, to install this project globally

```sh
basalt global add hyperupcall/shelltest
```

## Usage

```sh
$ shelltest ./tests
```
