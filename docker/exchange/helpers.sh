#!/bin/bash

# Define where the Django server should bind/listen
readonly django_host=0.0.0.0
readonly django_port=80

readonly EXCHANGE_DIR="/mnt/exchange"
readonly GEONODE_DIR="/mnt/geonode"
readonly VENV_DIR="${EXCHANGE_DIR}/.venv"

# PostGIS information so we can wait on PG to come up or run migrations
readonly postgis_username="exchange"
readonly postgis_password="boundless"
readonly postgis_host="database"
readonly postgis_port="5432"
readonly postgis_db="exchange_data"
readonly postgis_url="postgis://${postgis_username}:${postgis_password}@${postgis_host}:${postgis_port}/${postgis_db}"

wait_for_pg () {
    local interval=1
    local timeout=1
    local tries=60
    local started=0
    local name="$1"
    local url="${postgis_host}:${postgis_port}/${postgis_db}"
    echo "Waiting for ${name} at ${url} ..."
    for try in $(seq "$tries"); do
        sleep "${interval}"
        # Don't actually need to set username or db, just avoids error messages
        if /opt/boundless/vendor/bin/pg_isready --timeout="${timeout}" --host="${postgis_host}" --port="${postgis_port}" --dbname="${postgis_db}" --username="${postgis_username}" > /dev/null; then
            started=1
            break
        # Check if host is unreachable
        elif ! ping -c 1 -w 0.1 "${postgis_host}" > /dev/null 2>&1; then
            echo "database host ${postgis_host} did not respond to ping"
            break
        fi
    done
    if [ "${started}" -eq 0 ]; then
        echo "Stopped waiting for ${name} after ${try} tries"
        exit 1
    fi
    echo "${name} is up at ${url}"
}

run_migrations () {
    echo "Running migrations against '${postgis_url}' ..."
    local manage="${VENV_DIR}/bin/python /mnt/exchange/manage.py"
    if [ ! -z "${postgis_url}" ]; then
        pushd /mnt/exchange > /dev/null
        $manage migrate account --noinput
        $manage migrate --noinput
        echo "Collecting static assets ..."
        $manage collectstatic --noinput
        # load fixtures
        $manage loaddata default_users
        $manage loaddata base_resources
        # load docker_oauth_apps fixture
        $manage loaddata /mnt/exchange/docker/home/docker_oauth_apps.json
    else
        echo "POSTGIS_URL is not set, so migrations cannot run"
        exit 1
    fi
}
