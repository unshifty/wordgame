#!/bin/bash
# docker entrypoint script.

bin="/app/bin/wordgames"
# start the elixir application
exec "$bin" "start"