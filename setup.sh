#!/bin/bash

set -euo pipefail
shopt -s nullglob dotglob

cd "$(dirname "$0")"

ts="$(date +"%Y%M%S%H%M%S")"
dotfile_dir="dotfiles_${ts}"
dotfile_tmp_dir="dotfiles_${ts}.tmp"
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

mkdir "${dotfile_tmp_dir}"
trap "rm -rf ${dotfile_tmp_dir}" EXIT

log_info "Merge dotfiles"
for src in sources/*/dotfiles; do
  merge "${src}" "${dotfile_tmp_dir}/home"
done

log_info "Merge config"
for src in sources/*/config; do
  merge "${src}" "${dotfile_tmp_dir}/config"
done

log_info "Ensure permission"
chmod go-rwx -R "${dotfile_tmp_dir}"

log_info "Setup local variable directories"
mkdir -p "${HOME}/.var/"{ssh,vim}
chmod go-rwx -R "${HOME}/.var/"
mkdir -p "${dotfile_tmp_dir}/home/vim"
for d in backup bundle dein history pack undo view; do
  mkdir -p "${HOME}/.var/vim/${d}"
  ln -svTf "${HOME}/.var/vim/${d}" "${dotfile_tmp_dir}/home/vim/${d}"
done

log_info "Build bashrc"
./scripts/gen_bashrc.sh "${dotfile_tmp_dir}/home/"

old_dotfiles="$(readlink -m dotfiles)"
if [ -d "${old_dotfiles}" ]; then

  # Some files are not managed by git(e.g. ~/.config/github-copilot/), so need to copy them
  log_info "Copy unmanaged files"
  comm -23 <(cd "${old_dotfiles}" && find -type f | sort) <(cd "${dotfile_tmp_dir}" && find -type f | sort) | while read -r f; do
    dir="$(dirname "${f}")"
    mkdir -p "${dotfile_tmp_dir}/${dir}"
    ln -vT "${old_dotfiles}/${f}" "${dotfile_tmp_dir}/${f}"  # use hard link
  done

  log_info "Check diff"
  if diff -r "${old_dotfiles}" "${dotfile_tmp_dir}"; then
    log_info "dotfiles are same as before. exit."
    rm -rf "${dotfile_tmp_dir}"
    exit 0
  fi

  log_info "Backup old dotfiles"
  mv -v "${old_dotfiles}" "${old_dotfiles}.old"
fi
log_info "Switch dotfiles"
mv "${dotfile_tmp_dir}" "${dotfile_dir}"
ln -svTf "${dotfile_dir}" dotfiles

log_info "Link to home"
for entry in dotfiles/home/*; do
  basename="$(basename "${entry}")"
  ln -svTf "${PWD}/dotfiles/home/${basename}" "${HOME}/.${basename}"
done

log_info "Link to .config"
for entry in dotfiles/config/*; do
  basename="$(basename "${entry}")"
  ln -svTf "${PWD}/dotfiles/config/${basename}" "${HOME}/.config/${basename}"
done
