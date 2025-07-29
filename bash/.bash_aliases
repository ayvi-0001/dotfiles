#!/usr/bin/env bash

alias fp='fzf --bind "enter:become(hx {})" --preview "bat --style=numbers --color=always --line-range :500 {}"'

export MSYS2_ARG_CONV_EXCL='--path-separator' # disable windows path expansion for '/'
alias rg='rg --path-separator=/'

alias ls='lsd -a -F'
alias lt='ls --tree'

alias gcat='gcloud storage cat'
alias gcp='gcloud storage cp'
alias gdu='gcloud storage du'
alias gls='gcloud storage ls --readable-sizes'
alias gmv='gcloud storage mv'
alias grm='gcloud storage rm'

alias bathelp='bat --plain --language=help'

alias bb='bleachbit_console'

alias rcat='rclone cat'
alias rcp='rclone copy'
alias rcpt='rclone copyto'
alias rdu='rclone size'
alias rls='rclone ls'
alias rlsd='rclone lsd'
alias rlsf='rclone lsf'
alias rlsl='rclone lsl'
alias rlt='rclone tree'
alias rmkdir='rclone mkdir'
alias rmv='rclone move'
alias rmvt='rclone moveto'
alias rrm='rclone delete'
alias rrmdir='rclone rmdir'

alias modsc='mods --continue-last'
