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

# Build at runtime with explicit CLI args so DB and (optionally) hostname are persisted
BUILD_ARGS=""
[ -n "$KC_DB" ] && BUILD_ARGS="$BUILD_ARGS --db=$KC_DB"
[ -n "$KC_DB_URL" ] && BUILD_ARGS="$BUILD_ARGS --db-url=$KC_DB_URL"
[ -n "$KC_DB_USERNAME" ] && BUILD_ARGS="$BUILD_ARGS --db-username=$KC_DB_USERNAME"
[ -n "$KC_DB_PASSWORD" ] && BUILD_ARGS="$BUILD_ARGS --db-password=$KC_DB_PASSWORD"
[ -n "$KC_HOSTNAME" ] && BUILD_ARGS="$BUILD_ARGS --hostname=$KC_HOSTNAME"

/opt/keycloak/bin/kc.sh build $BUILD_ARGS

# Build the kc.sh command with optional import flag
CMD_ARGS="start --optimized"
[ -n "$KC_HTTP_ENABLED" ] && CMD_ARGS="$CMD_ARGS --http-enabled=$KC_HTTP_ENABLED"
[ -n "$KC_HTTP_PORT" ] && CMD_ARGS="$CMD_ARGS --http-port=$KC_HTTP_PORT"
[ -n "$KC_PROXY_HEADERS" ] && CMD_ARGS="$CMD_ARGS --proxy-headers=$KC_PROXY_HEADERS"
[ -n "$KC_HOSTNAME_STRICT" ] && CMD_ARGS="$CMD_ARGS --hostname-strict=$KC_HOSTNAME_STRICT"
if [ "$KEYCLOAK_IMPORT" = "true" ]; then
  CMD_ARGS="$CMD_ARGS --import-realm"
fi

exec /opt/keycloak/bin/kc.sh $CMD_ARGS
