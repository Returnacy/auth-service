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

# Build at runtime with build-time options only (DB vendor); runtime options like URL/user/pass/hostname are ignored by build
BUILD_ARGS=""
if [ -n "$KC_DB" ]; then
  BUILD_ARGS="--db=$KC_DB"
fi

/opt/keycloak/bin/kc.sh build $BUILD_ARGS

# Build the kc.sh command with optional import flag
CMD_ARGS="start --optimized"
# Pass runtime options explicitly
[ -n "$KC_HTTP_ENABLED" ] && CMD_ARGS="$CMD_ARGS --http-enabled=$KC_HTTP_ENABLED"
[ -n "$KC_HTTP_PORT" ] && CMD_ARGS="$CMD_ARGS --http-port=$KC_HTTP_PORT"
[ -n "$KC_PROXY_HEADERS" ] && CMD_ARGS="$CMD_ARGS --proxy-headers=$KC_PROXY_HEADERS"
[ -n "$KC_HOSTNAME" ] && CMD_ARGS="$CMD_ARGS --hostname=$KC_HOSTNAME"
[ -n "$KC_HOSTNAME_STRICT" ] && CMD_ARGS="$CMD_ARGS --hostname-strict=$KC_HOSTNAME_STRICT"
[ -n "$KC_DB_URL" ] && CMD_ARGS="$CMD_ARGS --db-url=$KC_DB_URL"
[ -n "$KC_DB_USERNAME" ] && CMD_ARGS="$CMD_ARGS --db-username=$KC_DB_USERNAME"
[ -n "$KC_DB_PASSWORD" ] && CMD_ARGS="$CMD_ARGS --db-password=$KC_DB_PASSWORD"
if [ "$KEYCLOAK_IMPORT" = "true" ]; then
  CMD_ARGS="$CMD_ARGS --import-realm"
fi

exec /opt/keycloak/bin/kc.sh $CMD_ARGS
