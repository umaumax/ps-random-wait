#!/usr/bin/env bash

PROCESS_NUM=10

function sleep_ms() {
  duration=$1
  sleep "$(awk "BEGIN { print $duration / 1000.0 }")"
}

CHILD_PIDS=()
for ((i = 1; i <= PROCESS_NUM; i++)); do
  sleep_ms 100
  bash -c "echo [$i] PID: \$\$ start; for ((i = 0; i < $i * 10; i++)) do sleep 0.1; echo -n [$i] ; done; echo [$i] PID: \$\$ end" &
  CHILD_PID=$!
  CHILD_PIDS+=("$CHILD_PID")
  echo "[$i] launch process: $CHILD_PID"
done

pstree -p $$

for CHILD_PID in "${CHILD_PIDS[@]}"; do
  echo "wait PID: $CHILD_PID"
  wait "$CHILD_PID"
done
