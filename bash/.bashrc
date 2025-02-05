#!/usr/bin/env bash
# shellcheck shell=bash disable=SC1090

# if not running interactively, don't do anything.
[[ ! "$-" == *i* ]] && return

# source related dotfiles.
for f in ~/.{bash_aliases,bash_functions,exports,path}; do \
  test -f "$f" && . "$_"; done; unset f

# after each command, append to the history file and reread it.
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -cw; history -r"
export PROMPT_COMMAND

# opt shell behaviour.
shopt -s autocd # if cmd is a directory, execute as if it were the arg to cd.
shopt -s cdable_vars # arg to cd that is not a dir is assumed to be the name of a var whose val is the dir to change to.
shopt -s cdspell # minor spelling errors in a cd command corrected.
shopt -s checkjobs # list status of stopped/running jobs before exiting interactive shell.
shopt -s checkwinsize # check window size after each external (non-builtin) cmd, update $LINES/$COLUMNS if needed.
shopt -s cmdhist # attempt to save all lines of multi-line cmds in same history entry.
shopt -s completion_strip_exe # for windows, makes completion strip .exe suffixes.
shopt -s histappend # history list appended to file name by $HISTFILE when shell exists, rather than overwrite.
shopt -s lithist # if cmdhist enabled, multi-line cmds saved to history with embedded newlines rather than smicolon's.
shopt -s no_empty_cmd_completion # do not attempt to search PATH when completion attempted on empty line.
shopt -s nocaseglob # match filenames in case-insensitive fashion when performing filename expansion.

# ssh/gpg -------------------------------------------------------------------

_ssh_env=~/.ssh/agent.env

agent_load_env () { test -f "$_ssh_env" && . "$_ssh_env" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent >| "$_ssh_env")
    . "$_ssh_env" >| /dev/null ; }

agent_load_env

declare -i agent_run_state
# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [[ ! "$SSH_AUTH_SOCK" ]] || [[ "$agent_run_state" = 2 ]]; then
    agent_start
    ssh-add
elif [[ "$SSH_AUTH_SOCK" ]] && [[ "$agent_run_state" = 1 ]]; then
    ssh-add
fi

unset _ssh_env

! env | grep -q SSH_AUTH_SOCK && eval "$(ssh-agent -s)"

# completion ----------------------------------------------------------------

# if also a login shell, load completions.
if shopt -q login_shell; then
  # load bash-completion
  test -f "$HOME/.local/share/bash-completion/bash_completion" && . "$_"

  # load ~/.bash_completions
  test -d "${BASH_COMPLETION_USER_DIR:-~/.bash_completion}" && \
    for f in "${BASH_COMPLETION_USER_DIR:-~/.bash_completion}"/*; do
      test -f "$f" && . "$_";
    done; unset f

  # set default completions 
  complete -o bashdefault -o default -o nosort -D
  # disable completions attempted on a blank line.
  complete -E
fi

# hooks/prompt --------------------------------------------------------------

command -v fzf >/dev/null && eval "$(fzf --bash)"
command -v zoxide >/dev/null && eval "$(zoxide init bash)"
command -v direnv >/dev/null && eval "$(direnv hook bash)"

if command -v starship >/dev/null; then
  function set_win_title(){ echo -ne "\033]0; $(basename "$PWD") \007"; }
  export starship_precmd_user_func="set_win_title"
  eval "$(starship init bash)"
fi
