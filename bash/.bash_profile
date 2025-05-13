#!/usr/bin/env bash

# shellcheck source=/dev/null
for f in ~/.{profile,bashrc}; do test -f "$f" && . "$_"; done; unset f

# unlock bitwarden, cache/set sesssion key.
# NOTE interactive password input required if session is not set.
# only run if in an interactive login shell, and if bw command is found.
if [[ $- == *i* ]] && shopt -q login_shell; then
  if command -v bw >/dev/null; then
    load-bw-vault() {
      local bw_session_file cache_home

      cache_home=~/.cache/home && mkdir -p "$cache_home"

      if command -v fd >/dev/null; then
        bw_session_file="$(fd -u --base-directory="$cache_home" -- 'bw_session')"
      else
        bw_session_file="$(find "$cache_home" -iname '*.bw_session*')"
      fi

      declare BW_SESSION
      if [[ -z "$bw_session_file" ]]; then
        bw_session_file="$(mktemp .bw_session_XXXXXXX -p"$cache_home")"
        bw unlock --raw > "$bw_session_file"
      elif [[ -n "$bw_session_file" ]]; then
        BW_SESSION="$(cat "$bw_session_file")"
      fi
      export BW_SESSION
    }

    load-bw-vault
  fi
fi
