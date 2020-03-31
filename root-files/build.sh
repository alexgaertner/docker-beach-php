#!/bin/bash
# shellcheck disable=SC1090
# shellcheck disable=SC2086
# shellcheck disable=SC2046

# Load helper libraries

. "${FLOWNATIVE_LIB_PATH}/banner.sh"
. "${FLOWNATIVE_LIB_PATH}/log.sh"
. "${FLOWNATIVE_LIB_PATH}/packages.sh"

set -o errexit
set -o nounset
set -o pipefail

# ---------------------------------------------------------------------------------------
# build_create_directories() - Create directories and set access rights accordingly
#
# @global BEACH_APPLICATION_PATH
# @return void
#
build_create_directories() {
    mkdir -p "${BEACH_APPLICATION_PATH}/Data"
    chown -R 1000 "${BEACH_APPLICATION_PATH}"
}

# ---------------------------------------------------------------------------------------
# build_create_user() - Create the beach user and group
#
# @global BEACH_APPLICATION_PATH
# @return void
#
build_create_user() {
    info "🛠 Beach: Creating user and group beach (1000)"
    groupadd --gid 1000 beach
    useradd --home-dir /home/beach --shell /bin/bash --gid beach --uid 1000 beach 1>$(debug_device)

    chown beach:beach /home/beach ${SUPERVISOR_BASE_PATH}/etc/conf.d
    chmod 775 /home/beach ${SUPERVISOR_BASE_PATH}/etc/conf.d

    chmod 644 /home/beach/.profile /home/beach/.bashrc /home/beach/.env
    chown beach:beach /home/beach/.profile /home/beach/.bashrc /home/beach/.env
}

# ---------------------------------------------------------------------------------------
# build_tools() - Install tools to be used by Beach users via SSH
#
# @return void
#
build_tools() {
    packages_install netcat vim curl locales locales-all mariadb-client
}

# ---------------------------------------------------------------------------------------
# build_sshd() - Install and configure the SSH daemon
#
# @global SSHD_BASE_PATH
# @return void
#
build_sshd() {
    packages_install openssh-server curl

    # Clean up a few directories / files we don't need:
    rm -rf \
        /etc/init.d \
        /etc/rc2.d/S01ssh \
        /etc/rc2.d/S01ssh \
        /lib/systemd/system/rescue-ssh.target \
        /lib/systemd/system/ssh*

    # Create directories
    mkdir -p \
        "${SSHD_BASE_PATH}/etc" \
        "${SSHD_BASE_PATH}/sbin" \
        "${SSHD_BASE_PATH}/tmp" \

    # Move SSHD files to correct location:
    mv /usr/sbin/sshd ${SSHD_BASE_PATH}/sbin/

    chown -R beach \
        "${SSHD_BASE_PATH}/etc" \
        "${SSHD_BASE_PATH}/tmp"
}

# ---------------------------------------------------------------------------------------
# build_blackfire() - Install and configure the Blackfire probe and Blackfire agent
#
# @global PHP_BASE_PATH
# @return void
#
build_blackfire() {
    downloadUrl=https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$(php -r "echo PHP_MAJOR_VERSION, PHP_MINOR_VERSION;")
    info "📦 Downloading Blackfire from $downloadUrl"

    with_backoff "curl -A Docker -sSL ${downloadUrl} -o /tmp/blackfire-probe.tar.gz" "15" || (
        error "Failed downloading Blackfire probe"
        exit 1
    )

    mkdir -p /tmp/blackfire
    tar xfz /tmp/blackfire-probe.tar.gz -C /tmp/blackfire
    mv /tmp/blackfire/blackfire-*.so ${PHP_BASE_PATH}/lib/php/extensions/no-debug-non-zts-20190902/blackfire.so
    rm -rf /tmp/blackfire /tmp/blackfire-probe.tar.gz
}

# ---------------------------------------------------------------------------------------
# build_clean() - Clean up obsolete building artifacts and temporary files
#
# @global PHP_BASE_PATH
# @return void
#
build_clean() {
    rm -rf \
        /var/cache/* \
        /var/log/*
}

# ---------------------------------------------------------------------------------------
# Main routine

case $1 in
init)
    banner_flownative 'Beach PHP'
    build_create_directories
    build_create_user
    ;;
build)
    build_tools
    build_sshd
    build_blackfire
    ;;
clean)
    packages_remove_docs_and_caches 1>$(debug_device)
    build_clean
    ;;
esac
