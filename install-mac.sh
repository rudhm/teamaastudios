#!/bin/bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo 'This installer is for macOS only.'
  exit 1
fi

sfx_source_dir="$(cd "$(dirname "$0")" && pwd)"
sfx_target="$HOME/Library/Application Support/Adobe/CEP/extensions/com.teamaa.sfx"
sfx_backup_root="$HOME/Library/Application Support/Team AA SFX/extension-backups"

if [[ ! -f "$sfx_source_dir/com.teamaa.sfx/CSXS/manifest.xml" ]]; then
  echo 'Extract the entire ZIP before installing.'
  exit 1
fi

printf '\nTeam AA SFX v1.2 — Mac installer\nClose Premiere Pro and After Effects before continuing.\nThis enables Adobe CEP unsigned panels for your account (CSXS 11 and 12).\nIt does not need an administrator password.\n'

if [[ -t 0 ]]; then
  read -r -p 'Press Return to install, or Ctrl+C to cancel. ' sfx_reply || true
else
  echo 'Running non-interactively — continuing without a prompt.'
fi

mkdir -p "$(dirname "$sfx_target")" "$sfx_backup_root"

sfx_backup_path=""
if [[ -e "$sfx_target" || -L "$sfx_target" ]]; then
  sfx_backup_path="$sfx_backup_root/com.teamaa.sfx-$(date +%Y%m%d-%H%M%S)-$$"
  mv "$sfx_target" "$sfx_backup_path"
fi

sfx_restore_backup() {
  if [[ -n "$sfx_backup_path" && -e "$sfx_backup_path" ]]; then
    echo 'Install failed — restoring your previous version.' >&2
    rm -rf "$sfx_target"
    mv "$sfx_backup_path" "$sfx_target"
  fi
}
trap sfx_restore_backup ERR

cp -R "$sfx_source_dir/com.teamaa.sfx" "$sfx_target"

defaults write com.adobe.CSXS.11 PlayerDebugMode -string 1
defaults write com.adobe.CSXS.12 PlayerDebugMode -string 1

trap - ERR

printf '\nInstalled v1.2. Restart Adobe apps.\nOpen Window > Extensions > Team AA SFX (or Extensions (Legacy)).\nCheck that the panel header says SFX v1.2.\nDrag sounds by their filename or dotted handle. Existing folders and tags are kept.\n'

if [[ -t 0 ]]; then
  read -r -p 'Press Return to close. ' sfx_reply || true
fi
