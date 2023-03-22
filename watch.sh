#!/usr/bin/env sh
set -e

set -x

watch_dir() {
  # shellcheck disable=SC2039
  local in="${1:-/input}"
  # shellcheck disable=SC2039
  local out="${2:-/output}"

  # shellcheck disable=SC2039
  local mappers="${3:-/mappers}"
  # shellcheck disable=SC2039
  local dirs
  # only find directories that hav a predicate and mapper pair
  dirs=$(find "${mappers}"  -type f -print0 -name 'predicate.jq' -exec dirname {} \; |
    xargs -0 -r  -I {} find {} -name 'mapper.jq' -exec dirname {} \; | sort -u)

  inotifywait -qm -e create --format '%w%f' "${in}" | while read -r json; do
    for dir in ${dirs}; do
      jq -re -f "${dir}/predicate.jq" "${json}" >/dev/null &&
        jq -re -f "${dir}/mapper.jq" "${json}" >"${out}/$(basename "${dir}").json"
    done
    rm "${json}" # or move it to a processed dir
  done
}

watch_dir "${INPUT:-/input}" "${OUTPUT:-/output}" "${MAPPERS:-/mappers}"
