#!/bin/bash
# docker entrypoint script.

bin="/app/bin/wordgame"
# start the elixir application
exec "$bin" "start"