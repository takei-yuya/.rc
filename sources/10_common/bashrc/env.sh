#!/usr/bin/env bash

after init

function load()
{
  export EDITOR="vim"
  export SCREENDIR="${HOME}/.screen.d"
  export __CF_USER_TEXT_ENCODING=${__CF_USER_TEXT_ENCODING/:*:/:0x08000100:}
}
