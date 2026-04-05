#!/bin/bash
NODES=$(kubectl get nodes 2>/dev/null || echo 'cluster inaccessible')
PODS=$(kubectl get pods -A 2>/dev/null || echo 'cluster inaccessible')
UNHEALTHY=$(echo "$PODS" | grep -vE 'Running|Completed|NAME' | grep -v '^$')
MSG="=== Etat du cluster K8s ===\n\nNodes:\n${NODES}\n\nTous les pods:\n${PODS}"
if [ -n "$UNHEALTHY" ]; then
  MSG="${MSG}\n\nPods en anomalie:\n${UNHEALTHY}"
fi
jq -n --arg ctx "$MSG" '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":$ctx}}'
