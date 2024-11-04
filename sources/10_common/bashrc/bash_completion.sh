#!/usr/bin/env bash

after init interactive

function load()
{
  if [ -f "/etc/profile.d/bash_completion.sh" ]; then
    source "/etc/profile.d/bash_completion.sh"
  fi
  if [ -f "/etc/profile.d/bash-completion" ]; then
    source "/etc/profile.d/bash-completion"
  fi
}
