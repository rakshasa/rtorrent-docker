#!/bin/bash

echo "staging" > "/run/self/state"

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

if ! ("/run/self/run" &> "/run/self/log"); then
  echo "error" > "/run/self/state"
  echo "run_error" > "/run/self/error"
  exit 0
fi

echo "exited" > "/run/self/state"
