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
  for prog in docker git; do
    if [ -f "/usr/share/bash-completion/completions/${prog}" ]; then
      source "/usr/share/bash-completion/completions/${prog}"
    fi
  done
}
