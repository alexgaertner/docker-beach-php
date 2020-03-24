export PATH="$PATH":/usr/local/bin:/usr/bin:$HOME
export FLOW_ROOTPATH="${BEACH_APPLICATION_PATH}"

alias l='ls -laG'
umask 002

. "${FLOWNATIVE_LIB_PATH}/banner.sh"
. "${FLOWNATIVE_LIB_PATH}/validation.sh"
. "${FLOWNATIVE_LIB_PATH}/php-fpm.sh"
. "${FLOWNATIVE_LIB_PATH}/beach-legacy.sh"
. "${FLOWNATIVE_LIB_PATH}/beach.sh"
. "${FLOWNATIVE_LIB_PATH}/sshd.sh"

eval "$(beach_legacy_env)"
eval "$(beach_env)"
eval "$(php_fpm_env)"
eval "$(sshd_env)"

if [[ -n "${BEACH_INSTANCE_IDENTIFIER}" ]]; then
    banner_generic "Flownative Beach" "${BEACH_INSTANCE_NAME}" "${BEACH_INSTANCE_IDENTIFIER}"
else
    banner_generic "Flownative Local Beach" "" "${BEACH_INSTANCE_NAME}"
fi

cd "${BEACH_APPLICATION_PATH}"
