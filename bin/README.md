This directory is a mix of bash/python scripts.

Some scripts may require modification for use, for example `tailscale status` is used to retrieve device IPs where needed, this may need to be switched out for `read -p` or some other command.

The shebang for some python scripts points to [`uv`](https://docs.astral.sh/uv/), and will look similar to this:

```python
#!/usr/bin/env -S uv run -s
# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "click",
#   "pandas",
#   "sqlalchemy"
# ]
# ///
```

You can read more about [running scripts with `uv` here](https://docs.astral.sh/uv/guides/scripts/).
