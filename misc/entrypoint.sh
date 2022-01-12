#!/bin/bash

set -e

echo "staging" > "/run/self/state"

if [[ -f "/run/self/resolv.conf" ]]; then
  cp "/run/self/resolv.conf" "/etc/resolv.conf"
fi

run_netcat_server() {
  local hostname="${1:?Missing hostname argument.}"
  local reply="${2:?Missing reply argument.}"

  while true; do
    nc -N -l "${hostname}" 10000 <<EOF
${reply}
EOF
  done
}

run_netcat_server 0.0.0.0 "ipv4" & disown
run_netcat_server      :: "ipv6" & disown

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
