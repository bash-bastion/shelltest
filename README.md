# shtest

A sort of [Bats](https://github.com/bats-core/bats-core)-lite for POSIX shell scripts

## Features

- Conforms to POSIX
- Uses only builtins
- No eval
- Perform tests with `[`, etc.
- TAPS output
- `setup`, `setup_file`, `teardown`, `teardown_file`

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
- [ ] posh (Based on pdksh)

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
basalt global add hyperupcall/shtest
```

## Usage

```sh
$ bash shtest './path/to/testing/directory'
...
$ sh shtest './path/to/testing/directory'
...
$ zsh shtest './path/to/testing/directory'
...
```
