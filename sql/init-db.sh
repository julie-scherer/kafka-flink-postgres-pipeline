#!/bin/bash
set -e

psql \
    -v ON_ERROR_STOP=1 \
    --U $POSTGRES_USER \
    --d $POSTGRES_DB \
    -f /docker-entrypoint-initdb.d/create_role.sql \
    -f /docker-entrypoint-initdb.d/create_table.sql \

