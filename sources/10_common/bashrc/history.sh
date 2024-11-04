#!/usr/bin/env bash

after init interactive

function load()
{
  shopt -s histappend
  export HISTFILESIZE=100000
  export HISTSIZE=100000
  export HISTCONTROL=ignoreboth
  export HISTIGNORE="fg*:bg*:history*"
  export HISTTIMEFORMAT="%y/%m/%d %H:%M:%S: "
  shopt -s histappend
  export PROMPT_COMMAND="history -a"
}
