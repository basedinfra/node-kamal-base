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
check pgschema      pgschema --help

# `ssh -V` prints to stderr and its exit code varies by distro/version.
# Check that it's on PATH instead.
check ssh           command -v ssh

echo
echo "node $(node -p process.version)"
node -e 'const [maj,min,pat]=process.version.slice(1).split(".").map(Number); if(!(maj===24&&(min>22||(min===22&&pat>=1)))){console.error(process.version); process.exit(1)}'
node -e 'const tls=require("node:tls"); const {X509Certificate}=require("node:crypto"); const hit=tls.rootCertificates.filter((pem)=>new X509Certificate(pem).subject.includes("CN=emSign ECC Root CA - G3")); if(hit.length){console.error("G3 roots "+hit.length); process.exit(1)} console.log(process.version)'

hcloud_out=$(hcloud version 2>&1)
gh_out=$(gh --version 2>&1)
echo "$hcloud_out"
echo "$gh_out"
case "$hcloud_out" in
  *1.46.0*) echo "hcloud is still 1.46.0"; exit 1 ;;
  *-dev*) echo "hcloud is a dev build"; exit 1 ;;
esac
case "$gh_out" in
  *2.63.2*) echo "gh is still 2.63.2"; exit 1 ;;
esac

echo
echo "all tools present"
