# Changelog

All notable changes to `node-kamal-base` are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
for the major tag (`:v1`, `:v2`). Immutable date-stamped tags (`:v1.YYYYMMDD`)
are produced by the weekly rebuild.

## [v1.1.1] — 2026-10-22

### Security

- Pin the base to the `node:24.22.1-alpine` index
  `sha256:06d7adf3e0ef61a13f1d28682726366f97a15aa1888c934d3ecec86c33918b53`
  (`NODE_VERSION=24.22.1`, config created 2026-10-21).
- Keep `apk add ca-certificates` on that base so the OS trust store is this
  build's Alpine package.
- Compile `hcloud` 1.70.1 with Go 1.27.3. The upstream tarball is Go 1.26.8.
- Install upstream `gh` 2.103.0. That linux tarball's buildinfo is Go 1.27.3.
- Compile `pgschema` 1.7.3 with Go 1.27.3. The upstream tarball is Go 1.24.13.
- Go 1.27.3 (2026-10-19) is a `crypto/x509` security release.

## [v1.0.0] — 2026-04-19

Initial release.

### Added

- Base image: `node:24-alpine`.
- System tooling: `docker-cli`, `docker-cli-buildx`, `git`, `openssh-client`,
  `openssl`, `bash`, `curl`, `jq`, `postgresql-client`, `tini`, `ca-certificates`,
  `tzdata`, `rsync`.
- Ruby runtime + `kamal` gem (`>= 2.10`).
- `hcloud` CLI `1.46.0` (multi-arch).
- `gh` CLI `2.63.2` (multi-arch).
- `@dotenvx/dotenvx` (global npm).
- `pgschema` `1.7.3` (optional; removed at build time if musl-incompatible).
- Multi-arch builds: `linux/amd64` and `linux/arm64`.
- Provenance + SBOM attestations published to GHCR.
- Weekly rebuild workflow for rolling security patches on the `:v1` tag.
