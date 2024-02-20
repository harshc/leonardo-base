#!/bin/bash

trap cleanup EXIT

function cleanup() {
    kill $(jobs -p) >/dev/null 2>&1
}

unset -v port
unset -v url

metrics=""
while getopts l:p: flag
do
    case "${flag}" in
        l) location="${OPTARG}";;
        p) port="${OPTARG}";;
    esac
done

if [[ -z $port ]]; then
    printf "port (-p) is required\n"
    exit 1
fi

function get_url {
    url="http://${DIRECT_ADDRESS}:${port}"
    
    
    if [[ -n $url ]]; then
        printf "%s%s\n" "$url" "$location"
        exit 0
    else
        printf "Could not create URL\n"
        exit 1
    fi
}

get_url