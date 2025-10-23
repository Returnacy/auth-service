#!/bin/sh
set -e

# Build the kc.sh command with optional import flag
CMD_ARGS="start --optimized"
if [ "$KEYCLOAK_IMPORT" = "true" ]; then
  CMD_ARGS="$CMD_ARGS --import-realm"
fi

exec /opt/keycloak/bin/kc.sh $CMD_ARGS
