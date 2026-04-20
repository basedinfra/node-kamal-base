#!/usr/bin/env bash
# Verifies every tool baked into node-kamal-base is on PATH and runs.
# Wired into .github/workflows/publish.yml before the multi-arch push.
set -euo pipefail

check() {
  local name=$1
  shift
  printf 'checking %-14s ... ' "$name"
  if "$@" >/dev/null 2>&1; then
    echo ok
  else
    echo FAIL
    exit 1
  fi
}

check node          node --version
check npm           npm --version
check kamal         kamal version
check docker        docker --version
check "docker buildx" docker buildx version
check git           git --version
check openssl       openssl version
check curl          curl --version
check jq            jq --version
check psql          psql --version
check rsync         rsync --version
check hcloud        hcloud version
check gh            gh --version
check dotenvx       dotenvx --version
check bash          bash --version
check gem           gem --version
check tar           tar --version

# `ssh -V` prints to stderr and its exit code varies by distro/version.
# Check that it's on PATH instead.
check ssh           command -v ssh

# pgschema is optional — the Dockerfile removes the binary if it can't run
# against Alpine's musl. Skip gracefully if absent.
if command -v pgschema >/dev/null 2>&1; then
  check pgschema    pgschema --help
else
  echo "checking pgschema       ... skipped (musl-incompatible; removed at build time)"
fi

echo
echo "all tools present"
