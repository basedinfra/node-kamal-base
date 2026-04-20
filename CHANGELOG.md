# Changelog

All notable changes to `node-kamal-base` are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)
for the major tag (`:v1`, `:v2`). Immutable date-stamped tags (`:v1.YYYYMMDD`)
are produced by the weekly rebuild.

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
