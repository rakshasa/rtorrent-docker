#!/bin/bash

echo "staging" > "/stage/self/state"

SECONDS=0

while true; do
  if (( ${SECONDS} > 600 )); then
    echo "error" > "/stage/self/state"
    echo "staging_timeout" > "/stage/self/error"
    exit 0
  fi

  if [[ ! -f "/stage/self/signal" ]] || [[ "$(cat "/stage/self/signal")" == "stage" ]]; then
    sleep 0.1
    continue
  fi

  if [[ "$(cat "/stage/self/signal")" != "deploy" ]]; then
    echo "error" > "/stage/self/state"
    echo "staging_unexpected_state" > "/stage/self/error"
    exit 0
  fi

  break
done

echo "running" > "/stage/self/state"

if ! "/stage/self/run" &> "/stage/self/log"; then
  echo "error" > "/stage/self/state"
  echo "run_error" > "/stage/self/error"
  exit 0
fi

echo "exited" > "/stage/self/state"
