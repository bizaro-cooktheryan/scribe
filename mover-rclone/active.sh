#! /bin/bash

set -e -o pipefail

function error {
    rc="$1"
    shift
    echo "error: $*"
    exit "$rc"
}

# Rclone config file that gets mounted as a Secret onto RCLONE_CONFIG

[[ -n "${RCLONE_DEST_PATH}" ]] || error 1 "RCLONE_DEST_PATH must be defined"
[[ -n "${DIRECTION}" ]] || error 1 "DIRECTION must be defined"

RCLONE_FLAGS=(--checksum --one-file-system --create-empty-src-dirs --progress --stats-one-line-date --stats 20s --transfers 10)

START_TIME=$SECONDS
case "${DIRECTION}" in
source)
    rclone sync "${RCLONE_FLAGS[@]}" "${MOUNT_PATH}" "${RCLONE_CONFIG_SECTION}:${RCLONE_DEST_PATH}" --log-level DEBUG
    rc=$?
    ;;
destination)
    rclone sync "${RCLONE_FLAGS[@]}" "${RCLONE_CONFIG_SECTION}:${RCLONE_DEST_PATH}" "${MOUNT_PATH}" --log-level DEBUG
    rc=$?
    ;;
*)
    error 1 "unknown value for DIRECTION: ${DIRECTION}"
    ;;
esac
echo "Rclone completed in $(( SECONDS - START_TIME ))s rc=$rc"
exit "$rc"
