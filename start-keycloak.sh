#!/bin/sh
set -e

# Sane defaults for PaaS (Railway) unless explicitly provided
if [ -n "$PORT" ] && [ -z "$KC_HTTP_PORT" ]; then
  export KC_HTTP_PORT="$PORT"
fi
# Enable HTTP (TLS terminated at edge) and trust proxy headers
[ -z "$KC_HTTP_ENABLED" ] && export KC_HTTP_ENABLED=true
[ -z "$KC_PROXY_HEADERS" ] && export KC_PROXY_HEADERS=xforwarded
# Allow startup without an explicit hostname; set KC_HOSTNAME later for strict mode
[ -z "$KC_HOSTNAME" ] && [ -z "$KC_HOSTNAME_STRICT" ] && export KC_HOSTNAME_STRICT=false

# Build the kc.sh command with optional import flag
CMD_ARGS="start --optimized --auto-build"
if [ "$KEYCLOAK_IMPORT" = "true" ]; then
  CMD_ARGS="$CMD_ARGS --import-realm"
fi

exec /opt/keycloak/bin/kc.sh $CMD_ARGS
