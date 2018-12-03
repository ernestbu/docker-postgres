#!/bin/bash
set -e

if [ $POSTGRES_USER = $POSTGRES_DB ]; then
    echo "User is equal to created db, skipping..."
else
    echo "Initializing db ${POSTGRES_USER} for user ($POSTGRES_USER != $POSTGRES_DB)"

    POSTGRES="psql --username ${POSTGRES_USER}"

$POSTGRES <<EOSQL
CREATE DATABASE ${POSTGRES_USER} OWNER ${POSTGRES_USER};
EOSQL
fi