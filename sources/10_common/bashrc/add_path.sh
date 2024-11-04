#!/usr/bin/env bash

after init
after interactive

function load()
{
  function AddPre()
  {
    local sep="$1";
    local var="$2";
    local val="$3";
    printf -v "${var}" "${val}${!var:+${sep}${!var}}"
  }

  function AddPost()
  {
    local sep="$1";
    local var="$2";
    local val="$3";
    printf -v "${var}" "${!var:+${!var}${sep}}${val}"
  }

  function RemoveAll()
  {
    local IFS="$1";
    local var="$2";
    local val="$3";
    local -a ar=(${!var})
    for i in "${!ar[@]}"; do
      if [ "${val}" == "${ar[i]}" ]; then
        unset ar[i];
      fi
    done
    printf -v "${var}" "%s" "${ar[*]}";
  }

  function IsIn()
  {
    local IFS="$1";
    local var="$2";
    local val="$3";
    local -a ar=(${!var})
    for v in "${ar[@]}"; do
      if [ "${val}" == "${v}" ]; then
        return 0;
      fi
    done
    return 1;
  }

  function AddPathPre() { AddPre ":" "${@}"; }
  function AddPathPost() { AddPost ":" "${@}"; }
  function RemovePath() { RemoveAll ":" "${@}"; }

  function AddFlagPre() { AddPre " " "${@}"; }
  function AddFlagPost() { AddPost " " "${@}"; }
  function RemoveFlag() { RemoveAll " " "${@}"; }

  function AddCommandPre() { AddPre ";" "${@}"; }
  function AddCommandPost() { AddPost ";" "${@}"; }
  function RemoveCommand() { RemoveAll ";" "${@}"; }
}
