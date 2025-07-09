#!/usr/bin/env bash

function batdiff() { git diff --name-only --relative --diff-filter=d "$@" | xargs "$(which bat)" --diff; }

function help() { "$@" --help 2>&1 | bat --plain --language=help; } && complete -F _comp_command help

function git-cd-root() { cd "$(git rev-parse --show-toplevel)" || return 1; }

function gpg-reconnect-agent() { gpg-connect-agent reloadagent /bye; }

function gpg-kill-agent() { gpgconf --kill gpg-agent; }


function yy() {
  local tmp cwd
  test -d ~/.cache/yazi || mkdir -p ~/.cache/yazi
  tmp="$(mktemp -p ~/.cache/yazi -- yazi-cwd.XXXXXX)"
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd" || return
  rm -f -- "$tmp"
}

alias y=yy


# Overrides the `start` command that comes with git-bash,
# which fails to open directories with spaces.
function start() { command "$COMSPEC" //c start "$(cygpath -m "$(realpath "$@")")"; }


# Type cd.. 3 to traverse up 3 directories
function cd_up() { builtin cd "$(printf "%0.s../" $(seq 1 "${1:-0}" ))"; } \
  && alias 'cd..'='cd_up'


# `bw_` points to wrapper script in ~/bin for bitwarden cli
command -v bw_ >/dev/null && function bw() { "$(which bw_)" "$@"; }


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


# some completion scripts still reference old bash-completion functions,
# wrapping around a couple of them that were causing issues.
function  _split_longopt { _comp__split_longopt "$@"; } 
function  _filedir { _comp_compgen_filedir "$@"; } 
