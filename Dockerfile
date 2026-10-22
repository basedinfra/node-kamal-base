# Node 24.22.1 index, re-resolved 2026-10-22. Config env NODE_VERSION=24.22.1.
ARG NODE_IMAGE=node:24.22.1-alpine@sha256:06d7adf3e0ef61a13f1d28682726366f97a15aa1888c934d3ecec86c33918b53
# Go 1.27.3 (2026-10-19) includes the crypto/x509 security fix. Multi-arch index.
ARG GO_IMAGE=golang:1.27.3-alpine@sha256:d530cf60723abf1ffae0cd16bb546b379ec0550d2f3815e5b16ed69dbc00fba4

# hcloud 1.70.1's release tarball is go1.26.8. pgschema's release tarball is go1.24.13.
# Both are Go programs, so this stage compiles them with the Go above.
# GOTOOLCHAIN=local stops go.mod's toolchain line from downloading the older Go.
FROM ${GO_IMAGE} AS go-tools

ARG HCLOUD_VERSION=1.70.1
ARG PGSCHEMA_VERSION=1.7.3
ENV CGO_ENABLED=0
ENV GOTOOLCHAIN=local

RUN apk add --no-cache git ca-certificates \
 && go version \
 && go install -trimpath \
      -ldflags "-s -w -X github.com/hetznercloud/cli/internal/version.version=${HCLOUD_VERSION} -X github.com/hetznercloud/cli/internal/version.versionPrerelease=" \
      "github.com/hetznercloud/cli/cmd/hcloud@v${HCLOUD_VERSION}" \
 && go install -trimpath "github.com/pgplex/pgschema@v${PGSCHEMA_VERSION}" \
 && set -o pipefail \
 && go version -m /go/bin/hcloud | head -n 1 | grep -F 'go1.27.3' \
 && go version -m /go/bin/pgschema | head -n 1 | grep -F 'go1.27.3'

FROM ${NODE_IMAGE}

# System tooling — Docker CLI, git, SSH, shells, TLS, timezone data.
# ca-certificates is installed here so the OS store is this Alpine build,
# not a layer left over from an older base.
RUN apk add --no-cache \
      docker-cli \
      docker-cli-buildx \
      git \
      openssh-client \
      openssl \
      bash \
      curl \
      jq \
      postgresql-client \
      tini \
      ca-certificates \
      tzdata \
      rsync

# Ruby + Kamal. Build tools are installed, used, and removed in one layer
# to keep the image small. The trailing `apk add ruby` is defensive — ensures
# the runtime stays present if apk's orphan cleanup ever changes.
RUN apk add --no-cache ruby ruby-dev build-base \
 && gem install kamal -v '>= 2.10' --no-document \
 && apk del ruby-dev build-base \
 && apk add --no-cache ruby

# Compiled in go-tools with Go 1.27.3. See the stage comment for why.
COPY --from=go-tools /go/bin/hcloud /usr/local/bin/hcloud
COPY --from=go-tools /go/bin/pgschema /usr/local/bin/pgschema
RUN hcloud version && pgschema --help >/dev/null

# GitHub CLI — pinned. The v2.103.0 linux tarball's buildinfo is go1.27.3
# (read 2026-10-22), so this binary is the upstream build, not a recompile.
ARG GH_VERSION=2.103.0
RUN ARCH=$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/') \
 && curl -fsSL -o /tmp/gh.tar.gz \
      "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${ARCH}.tar.gz" \
 && tar -xzf /tmp/gh.tar.gz -C /tmp \
 && mv /tmp/gh_${GH_VERSION}_linux_${ARCH}/bin/gh /usr/local/bin/gh \
 && rm -rf /tmp/gh.tar.gz /tmp/gh_${GH_VERSION}_linux_${ARCH} \
 && gh --version

# dotenvx — global npm install, so it runs on this image's Node.
RUN npm install -g @dotenvx/dotenvx \
 && dotenvx --version

LABEL org.opencontainers.image.source="https://github.com/basedinfra/node-kamal-base"
LABEL org.opencontainers.image.description="Node 24 Alpine + Kamal + Docker CLI + common DevOps tools"
LABEL org.opencontainers.image.licenses="MIT"

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/bin/bash"]
