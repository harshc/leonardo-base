#!/bin/bash

# Must exit and fail to build if any command fails
set -eo pipefail
umask 002

source /opt/leonardo/bin/build/layer0/common.sh

if [[ "$XPU_TARGET" == "NVIDIA_GPU" ]]; then
    source /opt/leonardo/bin/build/layer0/nvidia.sh
else
    printf "No valid XPU_TARGET specified\n" >&2
    exit 1
fi

source /opt/leonardo/bin/build/layer0/clean.sh