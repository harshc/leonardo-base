ARG IMAGE_BASE="nvidia/cuda:12.3.1-base-ubuntu22.04"

# Caddy build
FROM ubuntu:22.04 as caddybuilder

ENV PATH=/opt/go/bin:$PATH
ENV GOROOT=/opt/go
RUN apt-get update && \
    apt-get install -y wget && \
    wget https://dl.google.com/go/go1.22.0.linux-amd64.tar.gz && \
    tar -xf go1.22.0.linux-amd64.tar.gz && \
    mv ./go /opt && \ 
    wget https://github.com/caddyserver/xcaddy/releases/download/v0.3.5/xcaddy_0.3.5_linux_amd64.deb && \
    apt-get install ./xcaddy_0.3.5_linux_amd64.deb && \
    xcaddy build \
        --with github.com/caddyserver/replace-response && \
    mkdir -p /opt/caddy/bin && \
    mv ./caddy /opt/caddy/bin


# For build automation - Allows building from any Debian-based image

FROM ${IMAGE_BASE}

COPY --from=caddybuilder /opt/caddy/ /opt/caddy/

# Determines which scripts at /opt/leonardo/bin/build/layerX will be run by init.sh
ARG XPU_TARGET="GPU_NVIDIA" # GPU_AMD, CPU
ENV XPU_TARGET=${XPU_TARGET}

LABEL org.opencontainers.image.source https://github.com/leonardo-base-base/base-image

LABEL org.opencontainers.image.description "Base image for Leonardo."

LABEL maintainer="Harsh Chiplonkar <harsh@chiplonkar.me>"

SHELL ["/bin/bash", "-c"]
# Set ENV variables
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TZ=UTC
ENV SHELL="/bin/bash"
ENV USER_NAME=user
ENV USER_PASSWORD=password
ENV USER_GROUPS=users,leonardo,adm,sudo,audio,video,tty,cdrom,dialout,dip,fax,floppy,lp,plugdev,ssl-cert,sudo,tape,voice
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/opt/leonardo/bin:/opt/micromamba/bin:/opt/caddy/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/leonardo/lib/micromamba${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
ENV OPT_SYNC=
ENV PYTHONUNBUFFERED=true
ENV APT_INSTALL="apt-get install -y --no-install-recommends"
ENV PIP_INSTALL="pip install --no-cache-dir"
ENV MAMBA_ROOT_PREFIX=/opt/micromamba
ENV MAMBA_EXE="/opt/micromamba/bin/micromamba"
ENV IMAGE_SLUG="leonardo-base"
# Copy early so we can use scripts in the build - Changes to these files will invalidate the cache and cause a rebuild.
COPY --chown=0:1111 ./COPY_ROOT/ /

ARG CUDA_VERSION
ARG CUDNN_VERSION
ARG CUDA_LEVEL
ARG PYTORCH_VERSION

ARG PYTHON_VERSION=3.12
ENV PYTHON_VERSION=${PYTHON_VERSION}
ARG PYTHON_MAMBA_NAME=python_312
ENV PYTORCH_VERSION=${PYTORCH_VERSION}
ENV PYTHON_MAMBA_NAME=${PYTHON_MAMBA_NAME}
ENV MAMBA_DEFAULT_ENV=${PYTHON_MAMBA_NAME}
ENV MAMBA_DEFAULT_RUN="micromamba run -n $MAMBA_DEFAULT_ENV"
ENV OPT_SYNC=$OPT_SYNC

# Use build scripts to ensure we can build all targets from one Dockerfile in a single layer.
# Don't put anything heavy in here - We can use multi-stage building above if necessary.


RUN yes | unminimize && \
    set -eo pipefail && /opt/leonardo/bin/build/layer0/init.sh | tee /var/log/build.log

# Keep init.sh as-is and place additional logic in /opt/leonardo/bin/preflight.sh
CMD ["init.sh"]
