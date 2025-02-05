#!/usr/bin/env bash

# clear bw session key.
if command -v fd >/dev/null; then
  fd -utf 'bw_session' ~/.cache/home -x rm -f
else
  find ~/.cache/home -type f -iname '*bw_session*' -delete
fi
