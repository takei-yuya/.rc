#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")"

ts="$(date +"%Y%M%S%H%M%S")"
dotfile_dir="dotfiles_${ts}"
log_info() {
  printf "\x1b[32m%s\x1b[m\n" "$1"
}

die() {
  echo "$1"
  exit 1
}

merge() {
  local src="${1}"
  local dst="${2}"
  if [ -d "${src}" ]; then
    # directory
    [ ! -e "${dst}" ] && mkdir "${dst}"
    [ ! -d "${dst}" ] && die "merge: dst must be directory. dst=${dst}"
    for entry in "${src}"/*; do
      local basename="$(basename "${entry}")"
      merge "${src}/${basename}" "${dst}/${basename}"
    done
  elif [ -f "${src}" ]; then
    # file
    if [ ! -e "${dst}" ]; then
      # just copy (Since the file may be updated after the copy, do not use hard link)
      cp -v "${src}" "${dst}"
    elif [ -f "${dst}" ]; then
      # merge
      # TODO: concat is not enough for some file types, impl dispaching by file type
      cat "${src}" >> "${dst}"
      echo "merge ${src} to ${dst}"
    else
      die "merge: dst must be file. dst=${dst}"
    fi
  else
    die "merge: src must be file or directory. src=${src}"
  fi
}

mkdir "${dotfile_dir}"

log_info "Merge dotfiles"
for src in sources/*/; do
  merge "${src}" "${dotfile_dir}"
done

log_info "Setup local directories"
mkdir -p "${dotfile_dir}/vim"
for d in backup bundle dein history pack undo view; do
  mkdir -p "${HOME}/.vimfiles/${d}"
  ln -svTf "${HOME}/.vimfiles/${d}" "${dotfile_dir}/vim/${d}"
done

old_dotfiles="$(readlink -m dotfiles)"
if [ -d "${old_dotfiles}" ]; then

  # Some files are not managed by git(e.g. ~/.config/github-copilot/), so need to copy them
  log_info "Copy unmanaged files"
  comm -23 <(cd "${old_dotfiles}" && find -type f | sort) <(cd "${dotfile_dir}" && find -type f | sort) | while read -r f; do
    dir="$(dirname "${f}")"
    mkdir -p "${dotfile_dir}/${dir}"
    ln -vT "${old_dotfiles}/${f}" "${dotfile_dir}/${f}"  # use hard link
  done

  log_info "Check diff"
  if diff -r "${old_dotfiles}" "${dotfile_dir}"; then
    log_info "dotfiles are same as before. exit."
    rm -rf "${dotfile_dir}"
    exit 0
  fi

  mv -v "${old_dotfiles}" "${old_dotfiles}.old"
fi
log_info "Switch dotfiles"
ln -svTf "${dotfile_dir}" dotfiles

log_info "Link to home"
for entry in dotfiles/*; do
  basename="$(basename "${entry}")"
  ln -svTf "${PWD}/dotfiles/${basename}" "${HOME}/.${basename}"
done
