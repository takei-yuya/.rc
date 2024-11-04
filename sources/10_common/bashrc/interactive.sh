#!/usr/bin/env bash

after init

function load()
{
  [ -z "${PS1}" ] && return;  # non-interactive
  tty -s || return;  # non-interactive
}
