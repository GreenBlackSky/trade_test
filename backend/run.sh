#!/bin/bash

until nc -z ${POSTGRES_HOST} ${POSTGRES_PORT}; do
    echo "$(date) - waiting for postgres at ${POSTGRES_HOST} ${POSTGRES_PORT}... "
    sleep 2
done

uvicorn app.main:app --reload --host 0.0.0.0