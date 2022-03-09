until nc -z ${POSTGRES_HOST} ${POSTGRES_PORT}; do
    echo "$(date) - waiting for postgres at ${POSTGRES_HOST} ${POSTGRES_PORT}... "
    sleep 2
done

python -m app.check_ready

python -m app.main worker