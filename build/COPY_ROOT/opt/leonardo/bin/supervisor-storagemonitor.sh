#!/bin/bash

trap cleanup EXIT

function cleanup() {
    kill $(jobs -p) > /dev/null 2>&1
}

function start() {
    source /opt/leonardo/etc/environment.sh
    
    printf "Starting storage monitor..\n"
    /opt/leonardo/storage_monitor/bin/storage-monitor.sh
}

start 2>&1