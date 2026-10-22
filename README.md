# node-kamal-base

A pre-built Docker base image for Node.js apps deployed with [Kamal](https://kamal-deploy.org).

Bundles Node 24 (Alpine), the Kamal CLI, Docker CLI + buildx, and the DevOps
tooling most Kamal-based deploys actually need (`git`, `ssh`, `gh`, `hcloud`,
`dotenvx`, `jq`, `psql`, `rsync`, `curl`, `openssl`, `bash`, …). Instead of
re-installing all of that on every cold build, your `Dockerfile` starts with
one line:

```dockerfile
FROM ghcr.io/basedinfra/node-kamal-base:v1
```

## Image

- **Registry**: [`ghcr.io/basedinfra/node-kamal-base`](https://github.com/basedinfra/node-kamal-base/pkgs/container/node-kamal-base)
- **Architectures**: `linux/amd64`, `linux/arm64`
- **License**: MIT
- **Attestations**: provenance + SBOM (viewable on the GHCR package page)

## What's inside

| Tool | Source | Pin |
|------|--------|-----|
| Node 24.22.1 + npm | `node:24.22.1-alpine` index | `sha256:06d7adf3e0ef61a13f1d28682726366f97a15aa1888c934d3ecec86c33918b53` |
| Kamal | `gem install kamal` | `>= 2.10` |
| Docker CLI + buildx | Alpine `docker-cli`, `docker-cli-buildx` | Alpine package |
| git, ssh, openssl, bash, curl | Alpine packages | Alpine package |
| jq, rsync, tini, tzdata, ca-certificates | Alpine packages | Alpine package |
| postgresql-client (`psql`) | Alpine `postgresql-client` | Alpine package |
| `hcloud` CLI | compiled here with Go 1.27.3 | `1.70.1` |
| `gh` CLI | upstream release built with Go 1.27.3 | `2.103.0` |
| `@dotenvx/dotenvx` | global npm | latest at build time |
| `pgschema` | compiled here with Go 1.27.3 | `1.7.3` |

Entrypoint is [`tini`](https://github.com/krallin/tini) for signal handling.
`CMD` is `/bin/bash`. Both are overridable.

## Tag scheme

| Tag | Stability | Use when |
|-----|-----------|----------|
| `:v1` | Moving — updated weekly by the rebuild workflow | You want rolling security patches and can tolerate a base image that shifts under you |
| `:v1.YYYYMMDD` | Immutable — date-stamped at publish time | You want a reproducible build pinned to a specific week |
| `:v1.0.0` (SemVer) | Immutable — matches the git tag | You want a reproducible build pinned to a specific release |
| `@sha256:…` | Immutable digest — strongest pin | You need byte-identical reproducibility (recommended for production) |

Pin by digest:

```dockerfile
FROM ghcr.io/basedinfra/node-kamal-base@sha256:<digest>
```

Find the current digest:

```bash
docker buildx imagetools inspect ghcr.io/basedinfra/node-kamal-base:v1
```

## Using it

The image sets no `WORKDIR` — consumers pick their own.

```dockerfile
# your app's Dockerfile
FROM ghcr.io/basedinfra/node-kamal-base:v1

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY . .

CMD ["node", "build/index.js"]
```

Override `ENTRYPOINT` or `CMD` freely — `tini` is there by default but is not
required.

## Versioning policy

- **Moving `:v1`** — rebuilt weekly (Mondays 08:00 UTC) to pull in Alpine
  package updates. The Node digest in the Dockerfile does not float.
- **`:v1.YYYYMMDD`** — immutable, produced on every tag push and every weekly
  rebuild.
- **`:v1.X.Y`** (git tag) — immutable, produced on tag push. Use for
  reproducible builds tied to a specific release.
- **Major bump `:v2`** — only when Node's major version changes, Kamal's major
  version changes, or a tool is removed in a BC-breaking way. `:v1` stays alive
  for at least 90 days after `:v2` ships.

## Bumping a pinned tool

1. Edit the `ARG` line in `Dockerfile`.
2. Update `CHANGELOG.md` under a new version header.
3. Commit + push to `main`.
4. Tag: `git tag v1.x.y && git push --tags`.
5. `publish.yml` builds + smokes + pushes multi-arch and produces provenance + SBOM.

## Adding a new tool

1. Add an `apk add` line (if Alpine-packaged) or a pinned `ARG TOOL_VERSION=…`
   block + `curl` download (if not).
2. Add a `check <tool> …` line in `test/smoke.sh`.
3. Document it in the "What's inside" table above.
4. Bump the minor version (`v1.1.0`) and tag.

## Reporting issues

File issues at <https://github.com/basedinfra/node-kamal-base/issues>. PRs welcome.
