#!/usr/bin/env bash

function load()
{
  # backup environments
  declare -a environments=(
  IFS
  HOME
  LANG
  PATH
  SHELL
  TERM
  C_INCLUDE_PATH
  CPLUS_INCLUDE_PATH
  LIBDIR
  LIBRARY_PATH
  LD_LIBRARY_PATH
  DYLD_FALLBACK_LIBRARY_PATH
  DYLD_FALLBACK_FRAMEWORK_PATH
  );
  for env in ${environments[@]} ; do
    printf -v "ORIGINAL_${env}" "%s" "${!env}"
  done
}

