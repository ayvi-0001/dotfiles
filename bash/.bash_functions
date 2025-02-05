# shellcheck shell=bash

function batdiff() { git diff --name-only --relative --diff-filter=d "$@" | xargs bat --diff; }

function help() { "$@" --help 2>&1 | bathelp; } && complete -F _comp_command help

function git-cd-root() { cd "$(git rev-parse --show-toplevel)" || return 1; }

function gpg-reconnect-agent() { gpg-connect-agent reloadagent /bye; }

function gpg-kill-agent() { gpgconf --kill gpg-agent; }


function yy() {
  local tmp
  tmp="$(mktemp "yazi-cwd.XXXXXX" -p"$HOME/.cache/yazi")"
  # shellcheck disable=2064
  trap "rm -f -- $tmp" EXIT INT
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
  builtin cd -- "$cwd" || exit 1
  fi
}

alias y=yy


# Overrides the `start` command that comes with git-bash,
# which fails to open directories with spaces.
function start() { command "$COMSPEC" //c start "$(cygpath -m "$(realpath "$@")")"; }


# Type cd.. 3 to traverse up 3 directories
function cd_up() { builtin cd "$(printf "%0.s../" $(seq 1 "${1:-0}" ))"; } \
  && alias 'cd..'='cd_up'


# `bw_` points to wrapper script in ~/bin for bitwarden cli
if command -v bw_ >/dev/null 2>&1; then
  function bw() { "$(which bw_)" "$@"; }
fi


function 7z() {
  declare -a default_args
  [[ ! "$*" =~ -slsl[[:space:]]* ]] && default_args+=(-slsl)
  [[ ! "$*" =~ -ba[[:space:]]* ]] && default_args+=(-ba)
  [[ ! "$*" =~ -spf2[[:space:]]* ]] && default_args+=(-spf2)
  command 7z "${default_args[@]}" "$@"
}


function rg() {
  # The --path-separator option for rg must be exactly one byte,
  # but in git-bash, '/' is expanded to 'C:/Program Files/Git/'.
  # Use '//' instead.
  declare -a default_args
  [[ ! "$*" =~ --path-separator ]] && default_args+=(--path-separator '//')
  command rg "${default_args[@]}" "$@"
}


# Use fd for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
function _fzf_compgen_path() { fd --hidden --follow --exclude ".git" . "$1"; }

# Use fd to generate the list for directory completion
function _fzf_compgen_dir() { fd --type d --hidden --follow --exclude ".git" . "$1"; }
