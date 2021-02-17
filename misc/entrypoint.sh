#!/bin/bash

set -e

echo "staging" > "/run/self/state"

if [[ -f "/run/self/resolv.conf" ]]; then
  cp "/run/self/resolv.conf" "/etc/resolv.conf"
fi

TIMEOUT=$(( SECONDS + 600 ))
while true; do
  if (( SECONDS > TIMEOUT )); then
    echo "error" > "/run/self/state"
    echo "staging_timeout" > "/run/self/error"
    exit 0
  fi

  if [[ ! -f "/run/self/signal" ]] || [[ "$(cat "/run/self/signal")" == "stage" ]]; then
    sleep 0.1
    continue
  fi

  if [[ "$(cat "/run/self/signal")" != "deploy" ]]; then
    echo "error" > "/run/self/state"
    echo "staging_unexpected_state" > "/run/self/error"
    exit 0
  fi

  break
done

echo "running" > "/run/self/state"

mkdir -p "/run/self/logs"

if ! ("/run/self/run" &> "/run/self/logs/entrypoint.log"); then
  echo "error" > "/run/self/state"
  echo "run_error" > "/run/self/error"
  exit 0
fi

echo "exited" > "/run/self/state"
