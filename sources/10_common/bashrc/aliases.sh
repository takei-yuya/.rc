#!/usr/bin/env bash

after init interactive
after ls_options add_path

function build()
{
  gen_alias_command m make
  gen_alias_command sc 'screen -x'
  gen_alias_command vi vim
  gen_alias_command emacs vim
  gen_alias_command ed vim
  gen_alias_command d docker
  gen_alias_command c 'docker compose'
  gen_alias_command g git
}

function load()
{
  AddPathPre PATH "${HOME}/.aliases"
  for f in "${HOME}"/.aliases/*; do
    [ -f "${f}" ] || continue
    source "${f}"
  done

  alias cp='cp -iv'
  alias mv='mv -iv'
  alias rm='rm -iv'
  alias srm='srm -iv'

  alias ls="ls ${LS_OPTIONS}"
  alias l='ls'
  alias ll='ls -lA'

  alias mn='make clean'
  alias mm='make clean;make'
  alias mi='make install'
  alias mu='make uninstall'

  alias vim="vim -p"
  alias sudo='sudo -p "sudo:"'
  alias grep='grep --color=auto'

  function t() {
    local session_name="$(basename "${PWD}")"
    if [ "${PWD}" == "${HOME}" ]; then
      session_name="working"
    fi
    case "${@}" in
      "")
        tmux attach-session -t "${session_name}" || tmux new-session -s "${session_name}"
        ;;
      "cli")
        tmux new-session -d -t "${session_name}" -s $$ \; set-option destroy-unattached \; attach-session -t $$
        ;;
      ls)
        tmux ls
        ;;
      *)
        tmux ${@}
    esac
  }

  function find_agent() {
    local GLOBS=(
      "/tmp/com.apple.launchd.*/Listeners"
      "/tmp/ssh-*/agent.*"
    )
    for g in "${GLOBS[@]}"; do
      for c in ${g}; do
        [ ! -S "${c}" ] && continue;
        export SSH_AUTH_SOCK="$c";
        echo "${SSH_AUTH_SOCK}" >&2
        timeout 5 ssh -T git@github.com;
        [ $? -eq 1 ] && return 0;
      done
    done
    echo "Failed to find valid agent" >&2
  }
}
