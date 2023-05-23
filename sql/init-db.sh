#!/bin/sh
set -e

echo "POSTGRES_USER: ${POSTGRES_USER}"
echo "POSTGRES_DB: ${POSTGRES_DB}"

psql \
    -v ON_ERROR_STOP=1 \
    -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" \
    -f /docker-entrypoint-initdb.d/init.sql
