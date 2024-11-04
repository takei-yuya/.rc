#!/usr/bin/env bash

after init interactive
after esc add_path colour

function load()
{
  PS_USER="\[${COLOUR_YELLOW}\]\u\[${COLOUR_DEFAULT}\]"
  PS_WORK="\[${COLOUR_HIGHLIGHT_WHITE}\]\W\[${COLOUR_DEFAULT}\]"

  PS_HOST="\[${COLOUR_GREEN}\]\h\[${COLOUR_DEFAULT}\]"

  function ps_time() {
    local original_exit="$?";
    date +'%H:%M:%S';
    exit $original_exit;
  }
  PS_TIME="\[${COLOUR_CYAN}\]\$(ps_time)\[${COLOUR_DEFAULT}\]"

  PS_HIST="\[${COLOUR_HIGHLIGHT_BLUE}\]\!\[${COLOUR_DEFAULT}\]"

  if type __git_ps1 >/dev/null 2>&1; then
    function ps_git()
    {
      local original_exit="$?";
      local email="$(git config --get user.email)"
      local e="${email#*@}"  # get domain part
      e="${e%.*}"  # drop TLD
      e="${e##*.}"  # get second level domain
      if [ "${e}" = "github" ]; then
        e="${email%@*}@github"
      fi
      __git_ps1 "(${e}/%s)" 2>/dev/null;
      exit "${original_exit}";
    }
    export GIT_PS1_SHOWDIRTYSTATE=1
    export GIT_PS1_SHOWUPSTREAM=1
    PS_GIT="\[${COLOUR_GREEN}\]\$(ps_git)\[${COLOUR_DEFAULT}\]"
  else
    PS_GIT=""
  fi

  function ps_exit_colour() {
    local original_exit="$?";
    if [ $original_exit -ne 0 ]; then
      echo -n "${COLOUR_RED}";
    fi
    exit $original_exit;
  }

  PS_EXIT="\[\$(ps_exit_colour)\]\$?\[${COLOUR_DEFAULT}\]"
  PS_PROMPT="\[\$(ps_exit_colour)\]\\$\[${COLOUR_DEFAULT}\]"

  export PS1="[${PS_TIME} ${PS_HIST} ${PS_EXIT} ${PS_USER}@${PS_HOST}${PS_SCREEN} ${PS_WORK}${PS_GIT}]\n${PS_PROMPT} "
}
