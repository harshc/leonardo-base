#!/bin/false

export MAMBA_CREATE="micromamba create --always-softlink -y -c conda-forge"
env-store MAMBA_CREATE
export MAMBA_INSTALL="micromamba install --always-softlink -y -c conda-forge"
env-store MAMBA_INSTALL

groupadd -g 1111 leonardo

dpkg --add-architecture i386
apt-get update
apt-get upgrade -y --no-install-recommends

# System packages
$APT_INSTALL \
    acl \
    apt-transport-https \
    apt-utils \
    bc \
    build-essential \
    bzip2 \
    ca-certificates \
    curl \
    dnsutils \
    dos2unix \
    fakeroot \
    file \
    fuse3 \
    git \
    git-lfs \
    gnupg \
    gpg \
    gzip \
    htop \
    inotify-tools \
    jq \
    language-pack-en \
    less \
    libcap2-bin \
    libelf1 \
    libglib2.0-0 \
    locales \
    lsb-release \
    lsof \
    man \
    mlocate \
    net-tools \
    nano \
    openssh-server \
    pkg-config \
    psmisc \
    python3-pip \
    rar \
    rclone \
    rsync \
    screen \
    software-properties-common \
    ssl-cert \
    sudo \
    supervisor \
    tmux \
    tzdata \
    unar \
    unrar \
    unzip \
    vim \
    wget \
    xz-utils \
    zip \
    zstd
  
locale-gen en_US.UTF-8
    
# These libraries are needed to run the log/redirect interfaces
# They are needed before micromamba is guaranteed to be ready
$PIP_INSTALL \
  bcrypt \
  uvicorn==0.23 \
  fastapi==0.103 \
  jinja2==3.1 \
  jinja_partials \
  python-multipart \
  websockets

# Get Cloudflare daemon
wget -c -O cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
dpkg -i cloudflared.deb
rm cloudflared.deb

# Prepare environment for running SSHD
chmod 700 /root
mkdir -p /root/.ssh
chmod 700 /root/.ssh
touch /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Remove less relevant parts of motd
rm -f /etc/update-motd.d/10-help-text

# Install micromamba (conda replacement)
mkdir -p /opt/micromamba
cd /opt/micromamba
curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba
micromamba shell init --shell bash --root-prefix=/opt/micromamba

# Ensure critical paths/files are present
mkdir -p --mode=0755 /etc/apt/keyrings
mkdir -p --mode=0755 /run/sshd
chown -R root.leonardo /var/log
chmod -R g+w /var/log
chmod -R g+s /var/log
mkdir -p /opt/leonardo/lib/micromamba
mkdir -p /var/log/supervisor
mkdir -p /var/empty
mkdir -p /etc/rclone
touch /etc/rclone/rclone.conf

# Ensure correct environment for child builds

printf "source /opt/leonardo/etc/environment.sh\n" >> /etc/profile.d/02-leonardo.sh
printf "source /opt/leonardo/etc/environment.sh\n" >> /etc/bash.bashrc

# Give our runtime user full access (added to leonardo group)
/opt/leonardo/bin/fix-permissions.sh -o container

# Install packages
build_common_main() {
    build_common_do_mamba_install "python_312" "3.12"
}

build_common_do_mamba_install() {
    $MAMBA_CREATE -n "$1" python="$2"
    printf "/opt/micromamba/envs/%s/lib\n" "$1" >> /etc/ld.so.conf.d/x86_64-linux-gnu.micromamba.80-python.conf
}

build_common_main "$@"