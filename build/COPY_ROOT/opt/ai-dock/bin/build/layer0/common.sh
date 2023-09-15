#!/bin/bash

# Must exit and fail to build if any command fails
set -eo pipefail

apt-get update
apt-get upgrade -y --no-install-recommends

# A minimal collection of packages.
$APT_INSTALL \
    acl \
    bc \
    bzip2 \
    ca-certificates \
    curl \
    dos2unix \
    fuse3 \
    git \
    gpg \
    jq \
    less \
    libcap2-bin \
    libelf1 \
    libglib2.0-0 \
    lsb-release \
    nano \
    screen \
    tmux \
    unzip \
    vim \
    wget \
    zip
    
# Get Cloudflare daemon - No conda distribution
curl -Lso cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
dpkg -i cloudflared.deb
rm cloudflared.deb

# Prepare environment for running SSHD
chmod 700 /root
mkdir -p /root/.ssh
chmod 700 /root/.ssh
touch /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Remove less relevant parts of motd
rm /etc/update-motd.d/10-help-text
rm /etc/update-motd.d/60-unminimize

# Install micromamba (conda replacement)
mkdir -p /opt/micromamba
cd /opt/micromamba
curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba
micromamba shell init --shell bash --root-prefix=/opt/micromamba

# Install the 'system' base micromamba environment
$MAMBA_CREATE -n "${MAMBA_BASE_ENV}" -c conda-forge python="${MAMBA_BASE_PYTHON_VERSION}"
$MAMBA_INSTALL -n "${MAMBA_BASE_ENV}" -c conda-forge \
    supervisor \
    openssh \
    rclone

$MAMBA_CREATE -n fastapi -c conda-forge python="${MAMBA_BASE_PYTHON_VERSION}"
$MAMBA_INSTALL -n fastapi -c conda-forge \
    uvicorn=0.23 \
    fastapi=0.103 \
    jinja2=3.1 \
    websockets


# We will use a config from /etc
rm -rf /root/micromamba/envs/"${MAMBA_BASE_ENV}"/etc/supervisord*

# Ensure critical paths/files are present
mkdir -p --mode=0755 /etc/apt/keyrings
mkdir -p /var/log/supervisor
mkdir -p /var/empty
mkdir -p /etc/rclone
touch /etc/rclone/rclone.conf
