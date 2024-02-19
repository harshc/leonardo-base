#!/bin/false

export CUDA_VERSION=${CUDA_VERSION}
env-store CUDA_VERSION
export CUDNN_VERSION=${CUDNN_VERSION}
env-store CUDNN_VERSION
export CUDA_LEVEL=${CUDA_LEVEL}
env-store CUDA_LEVEL
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
env-store LD_LIBRARY_PATH
export MAMBA_CREATE="micromamba create --always-softlink -y -c nvidia -c conda-forge"
env-store MAMBA_CREATE
export MAMBA_INSTALL="micromamba install --always-softlink -y -c nvidia -c conda-forge"
env-store MAMBA_INSTALL

export MAMBA_CREATE="micromamba create --always-softlink -y -c pytorch -c nvidia -c conda-forge"
export MAMBA_INSTALL="micromamba install --always-softlink -y -c pytorch -c nvidia -c conda-forge"
printf "export MAMBA_CREATE=\"%s\"\n" "${MAMBA_CREATE}" >> /opt/leonardo/etc/environment.sh
printf "export MAMBA_INSTALL=\"%s\"\n" "${MAMBA_INSTALL}" >> /opt/leonardo/etc/environment.sh


build_common_do_pytorch_install() {
    cuda_short_version=$(cut -d '.' -f 1,2 <<< "${CUDA_VERSION}")
    # Mamba will downgrade python to satisfy requirements. We don't want that.
    python_lock=$(micromamba -n $MAMBA_DEFAULT_ENV run python -V|awk '{print $2}'|cut -d '.' -f1,2)

    $MAMBA_INSTALL -n $MAMBA_DEFAULT_ENV \
        pytorch=${PYTORCH_VERSION} torchvision torchaudio \
        python=${python_lock} \
        pytorch-cuda=${cuda_short_version}
}

build_common_do_pytorch_install "$@"


