# shelltest

A test runner for POSIX-compliant shells

## Overview

Utility functions for tests ran with shelltest

## Index

* [t_is_function()](#t_is_function)
* [t_get_version()](#t_get_version)
* [t_assert()](#t_assert)

### t_is_function()

Test if a name is a function

#### Arguments

* **$1** (string): Name of function

#### Exit codes

* **0**: If name is a function
* **1**: If name is not a function

### t_get_version()

Get the version of the current running shell

#### Variables set

* **REPLY** (string): Version of the current shell

### t_assert()

Run command and print arguments if failure occurs

#### Arguments

* **...** (string): Commands to run

