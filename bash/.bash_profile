#!/usr/bin/env bash

# shellcheck source=/dev/null
for f in ~/.{profile,bashrc}; do test -f "$f" && . "$_"; done; unset f

# Unlock bitwarden & cache sesssion key.
# Only run if in an interactive login shell and bw exec exists.
# NOTE: If session is not set, initial password input is interactive.
declare BW_SESSION

if [[ $- == *i* ]] && shopt -q login_shell && command -v bw >/dev/null; then
  load-bw-vault() {
    session_key=${BW_SESSION_FILE:-"$HOME/.cache/bw/.bw_session"}
    # Unlock if file is missing or empty.
    if [[ ! -f "$session_key" ]] || [[ ! -s "$session_key" ]]; then
      mkdir -p "$(dirname "$session_key")"
      bw unlock --raw > "$session_key"
    fi
    BW_SESSION=$(<"$session_key")
  }
  load-bw-vault
fi

export BW_SESSION
