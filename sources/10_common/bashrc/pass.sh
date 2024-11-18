#!/usr/bin/env bash

after init interactive

function load() {
  if [ -f "/usr/share/bash-completion/completions/pass" ]; then
    source "/usr/share/bash-completion/completions/pass"
  fi
  if [ -f "/usr/share/bash-completion/completions/pass-otp" ]; then
    source "/usr/share/bash-completion/completions/pass-otp"
  fi

  for d in "${HOME}/.pass/"*; do
    [ -d "${d}" ] || continue
    basename="$(basename "${d}")"
    alias "pass_${basename}"="PASSWORD_STORE_DIR='${d}' pass"
    if type _pass >/dev/null 2>&1; then
      eval "_pass_${basename}() { PASSWORD_STORE_DIR='${d}' _pass \"\${@}\"; }"
      complete -o filenames -o nospace -F _pass_${basename} "pass_${basename}"
    fi
  done
}
