#!/bin/bash

trap cleanup EXIT

LISTEN_PORT=11111
METRICS_PORT=${SERVICEPORTAL_METRICS_PORT:-21111}
PROXY_PORT=${SERVICEPORTAL_PORT_HOST:-1111}
QUICKTUNNELS=true

SERVICE_NAME="Service Portal"

function cleanup() {
    rm /run/http_ports/$PROXY_PORT > /dev/null 2>&1
    fuser -k -SIGTERM ${LISTEN_PORT}/tcp > /dev/null 2>&1 &
    wait -n
}

function start() {
    source /opt/leonardo/etc/environment.sh
    
    file_content="$(
      jq --null-input \
        --arg listen_port "${LISTEN_PORT}" \
        --arg metrics_port "${METRICS_PORT}" \
        --arg proxy_port "${PROXY_PORT}" \
        --arg proxy_secure "${PROXY_SECURE,,}" \
        --arg service_name "${SERVICE_NAME}" \
        '$ARGS.named'
    )"
    
    printf "%s\n" "$file_content" > /run/http_ports/$PROXY_PORT
    
    printf "Starting ${SERVICE_NAME}...\n"
    
    fuser -k -SIGKILL ${LISTEN_PORT}/tcp > /dev/null 2>&1 &
    wait -n
    
    /usr/bin/python3 /opt/leonardo/fastapi/serviceportal/main.py \
        -p $LISTEN_PORT
}

start 2>&1