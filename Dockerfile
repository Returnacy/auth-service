# Keycloak image with bundled realm export and provider JARs.
# - Uses external database via env vars (provided at run time)
# - Optionally imports the provided realm on first run (toggle with KEYCLOAK_IMPORT=true/false)
# - Pre-builds Keycloak for faster startup

ARG KEYCLOAK_VERSION=25.0.0
FROM quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}

# Enable health and metrics endpoints (useful for PaaS probes)
ENV KC_HEALTH_ENABLED=true \
    KC_METRICS_ENABLED=true

# Copy realm export (imported if KEYCLOAK_IMPORT=true)
# Keep the filename stable so we can reference it with --import-realm automatically
COPY returnacy-realm-export.json /opt/keycloak/data/import/returnacy-realm.json

# Copy any custom providers (e.g., bcrypt)
# If there are no JARs present, this will still work (no-op)
COPY providers/ /opt/keycloak/providers/

# Do not pre-build here; we'll use --auto-build at runtime so DB/hostname env vars are respected

EXPOSE 8080

# Controls whether to import the bundled realm file on startup.
# Set to "true" only when targeting an empty database or when you intend to re-import/overwrite.
# For an already initialized database, leave this as "false" to avoid import conflicts.
ENV KEYCLOAK_IMPORT=false

# Start Keycloak using external database configuration supplied at runtime via env vars:
#   KC_DB=postgres
#   KC_DB_URL=jdbc:postgresql://<host>:<port>/<db>
#   KC_DB_USERNAME=<user>
#   KC_DB_PASSWORD=<password>
# Admin bootstrap (required on first run to create admin user):
#   KEYCLOAK_ADMIN=admin
#   KEYCLOAK_ADMIN_PASSWORD=admin
# Other helpful flags (can be added via env KC_*):
#   KC_HOSTNAME=<public-hostname>
#   KC_HTTP_ENABLED=true
#   KC_PROXY=edge
#
# To import the realm on startup, set KEYCLOAK_IMPORT=true. Otherwise, it will just start normally.
# Note: The base Keycloak image sets an ENTRYPOINT to kc.sh. We override it with a small wrapper
# to support conditional realm import without passing "/bin/sh" as an argument to kc.sh.

# Copy wrapper with executable bit set at build time (base image may use non-root user)
COPY --chmod=0755 start-keycloak.sh /opt/keycloak/start-keycloak.sh

# Override base ENTRYPOINT to our wrapper script
ENTRYPOINT ["/opt/keycloak/start-keycloak.sh"]
