#!/bin/sh
# Convert Render's DATABASE_URL (postgres://user:pass@host:port/db)
# to Spring Boot SPRING_DATASOURCE_* environment variables

if [ -n "$DATABASE_URL" ]; then
  # Extract components from postgres://user:pass@host:port/db
  # Remove postgres:// prefix
  STRIPPED=$(echo "$DATABASE_URL" | sed 's|^postgres://||')

  # Extract username (before first :)
  export SPRING_DATASOURCE_USERNAME=$(echo "$STRIPPED" | sed 's|:.*||')

  # Extract password (between first : and @)
  export SPRING_DATASOURCE_PASSWORD=$(echo "$STRIPPED" | sed 's|^[^:]*:||' | sed 's|@.*||')

  # Extract host:port/db (after @)
  HOST_PORT_DB=$(echo "$STRIPPED" | sed 's|^[^@]*@||')

  # Build JDBC URL
  export SPRING_DATASOURCE_URL="jdbc:postgresql://${HOST_PORT_DB}?sslmode=require"

  echo "DATABASE_URL converted to JDBC format successfully"
fi

exec java -jar app.jar --spring.profiles.active=prod
