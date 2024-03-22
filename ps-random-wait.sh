#!/usr/bin/env bash

set -eu

if [[ $# -lt 1 ]]; then
  command cat <<EOF 1>&2
  $(basename "$0") <PID>
EOF
  exit 1
fi

if ! type >/dev/null 2>&1 pstree; then
  echo "$0: pstree command is required."
  exit 1
fi

# parameters
TARGET_PID="$1"
# WITH_TARGET_PID
STOP_THREAD_NUM=${STOP_THREAD_NUM:-2}
RANDOM_WAIT_MSEC_MIN=${RANDOM_WAIT_MSEC_MIN:-1000}
RANDOM_WAIT_MSEC_MAX=${RANDOM_WAIT_MSEC_MAX:-3000}

echo "[log] target pid: $TARGET_PID"
function get_pids() {
  if [[ $(uname) == "Darwin" ]]; then
    # with target_pid
    pids=($(pstree -p "$TARGET_PID" "$TARGET_PID" | sed -E 's/^([^0-9]+)([0-9]+).*/\2/'))
  else
    # ubuntu
    pids=($(pstree -p "$TARGET_PID" | grep -E -o '\([0-9]+\)' | grep -E -o '[0-9]+'))
  fi

  if [[ ! -v WITH_TARGET_PID ]]; then
    # remove first element
    pids=(${pids[@]:1})
  fi
}

target_pids=()
function send-cont() {
  for pid in "${target_pids[@]}"; do
    echo "[command] kill -CONT $pid"
    kill -CONT "$pid" || true
  done
}

trap 'send-cont' SIGINT

while true; do
  get_pids
  target_pids=($(printf '%s\n' "${pids[@]}" | shuf -n "$STOP_THREAD_NUM"))
  echo "[log] [${#target_pids[@]}/${#pids[@]}] ${target_pids[@]}"
  if [[ ${#target_pids[@]} == 0 ]]; then
    echo "[log] finished"
    break
  fi

  RANDOM_WAIT_MSEC="$(awk "BEGIN {print ($RANDOM_WAIT_MSEC_MIN + $RANDOM % $RANDOM_WAIT_MSEC_MAX ) / 1000.0 }")"

  for pid in "${target_pids[@]}"; do
    echo "[command] kill -STOP $pid"
    # There is no guarantee that it will exist from the execution of the pstree command to the present.
    kill -STOP "$pid" || true
  done

  echo "[command] sleep $RANDOM_WAIT_MSEC"
  sleep "$RANDOM_WAIT_MSEC"

  send-cont
done
