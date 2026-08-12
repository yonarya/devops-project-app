#!/bin/bash

psql -v ON_ERROR_STOP=1 \
  -U "$POSTGRESQL_USER" \
  -d "$POSTGRESQL_DATABASE" \
  -f /opt/app-root/src/postgresql-init/init.sql