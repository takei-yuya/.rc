#!/bin/bash

set -euo pipefail
shopt -s nullglob

cd "$(dirname "${0}")"
cd ..

OUTPUT_DIR="${1}"

# like alias, but creates a command that can be used in completion (for ":!cmd" in vim etc.)
rm -rf "${OUTPUT_DIR}/aliases"
mkdir -p "${OUTPUT_DIR}/aliases"
gen_alias_command() {
  local alias_name="${1}"
  local alias_command="${2}"
  local alias_as="${3:-${2}}"

  local commands=(${alias_as})

  local alias_dir="${OUTPUT_DIR}/aliases"

  mkdir -p "${alias_dir}"
  cat <<EOF > "${alias_dir}/${alias_name}"
#!/bin/bash

if [ "\${0}" = "\${BASH_SOURCE}" ]; then
  # execute: run the alias command
  exec ${alias_command} "\$@"
else
  # source: set completion for the alias
  if type _completion_loader &>/dev/null 2>&1; then
    _completion_loader "${commands[0]}"
  fi

  if ! complete -p "${commands[0]}" &>/dev/null 2>&1; then
    # no completion for the command
    return
  fi

  # invoke the completion function with fixed environment variables
  _alias_${alias_name}() {
    COMP_LINE="${alias_as}\${COMP_LINE#${alias_name}}"
    COMP_CWORD=\$((COMP_CWORD + ${#commands[@]} - 1))
    COMP_POINT=\$((COMP_POINT + ${#alias_as} - ${#alias_name}))
    unset COMP_WORDS[0]
    COMP_WORDS=(${commands[*]} "\${COMP_WORDS[@]}")

    # invoke the original completion function for the command
    \$(complete -p ${commands[0]} | sed "s/.* -F \(.*\) ${commands[0]}$/\\1/") "\$@"
  }
  complete -F _alias_${alias_name} "${alias_name}"
fi
EOF
  chmod +x "${alias_dir}/${alias_name}"
}

depends=()
after() {
  for req in "$@"; do
    depends+=("${req} ${src}")
  done
}
before() {
  for req in "$@"; do
    depends+=("${src} ${req}")
  done
}

SOURCES=(sources/*/bashrc/*.sh)
for s in "${SOURCES[@]}"; do
  src="$(basename "${s}" .sh)"
  depends+=("${src} ${src}")
  source "${s}"
done

SORTED_SOURCE_NAMES=($(echo "${depends[@]}" | tsort))
for s in "${SORTED_SOURCE_NAMES[@]}"; do
  files=(sources/*/bashrc/"${s}".sh)
  if [ "${#files[@]}" -eq 0 ]; then
    echo "sources/*/bashrc/${s}.sh not found"
    exit 1
  elif [ "${#files[@]}" -gt 1 ]; then
    echo "sources/*/bashrc/${s}.sh is ambiguous"
    exit 1
  fi
done

{
  echo "${depends[@]}" | tsort | while read s; do
    build() {
      : DO NOTHING
    }
    source sources/*/bashrc/"${s}.sh"
    build
    echo "#"
    echo "# === ${s} ==="
    echo "#"
    declare -f load | sed '1d; 2d; $d; s/^    //'
    echo ""
  done
} > "${OUTPUT_DIR}/bashrc_local"
