#!/usr/bin/env bash

after init interactive

function load()
{
  if dircolors --version >/dev/null 2>/dev/null; then
    LS_OPTIONS='--show-control-chars --color=auto --classify --time-style=+"%F %R" -v'
  else
    LS_OPTIONS='-FG'
  fi
}
