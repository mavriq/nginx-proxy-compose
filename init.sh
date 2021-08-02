#!/usr/bin/env bash

set -euo pipefail

CWD="$(dirname $0)"

ENV_FILE="${CWD}/.env"

git submodule init
git submodule update --recursive
git submodule foreach 'git submodule init ; git submodule update --recursive'
function _env_has_key() {
    local k=$1
    [ -e "${ENV_FILE}" ] || return 1
    grep -qE "^${k}=" "${ENV_FILE}" 2>&1 > /dev/null
}

function _set_env() {
    local k=$1
    local v=$2
    {
        echo "#"
        echo "$k=$v"
    } >> "${ENV_FILE}"
}

function _ask_val() {
    local msg=$1
    local _def_val=${2:-}
    local _can_be_blank=${3:-}
    local val=

    while [ -z "$val" ]; do
        read -p "${msg}${_def_val:+ (default: ${_def_val})}: " val
        [ -z "${_def_val:+1}" ] || break
        [ -z "${_can_be_blank:+1}" ] || break
    done
    if [ -z "${val:+1}" ] ; then
        val="${_def_val}"
    fi
    echo "${val}"
}


_env_has_key LXCFS_MOUNTPOINTS || _set_env LXCFS_MOUNTPOINTS "$(
    grep -q 'lxcfs /var/lib/lxcfs' /proc/mounts \
        && echo enabled \
        || echo disabled)"

_env_has_key DEFAULT_EMAIL \
    || _set_env DEFAULT_EMAIL "$(
        _ask_val "Enter default email" )"

_env_has_key RESOLVERS \
    || _set_env RESOLVERS "$(
        _ask_val "Enter default resolvers" \
            "1.1.1.1 1.0.0.1" )"

_env_has_key PROXY_PROTOCOL_SERVER \
    || _set_env PROXY_PROTOCOL_SERVER "$(
        _ask_val "Enter PROXY_PROTOCOL_SERVER (blank if not required)" "" 1 )"

