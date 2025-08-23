#!/usr/bin/env bash

# clear bw session key.
if command -v fd >/dev/null; then
  fd -utf 'bw_session' ~/.cache/.bw -x rm -f
else
  find ~/.cache/.bw -type f -iname '*bw_session*' -delete
fi
