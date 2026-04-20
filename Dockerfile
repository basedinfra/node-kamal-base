FROM node:24-alpine

# System tooling — Docker CLI, git, SSH, shells, TLS, timezone data.
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

# hcloud CLI — pinned, multi-arch aware.
ARG HCLOUD_VERSION=1.46.0
RUN ARCH=$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/') \
 && curl -fsSL -o /tmp/hcloud.tar.gz \
      "https://github.com/hetznercloud/cli/releases/download/v${HCLOUD_VERSION}/hcloud-linux-${ARCH}.tar.gz" \
 && tar -xzf /tmp/hcloud.tar.gz -C /usr/local/bin hcloud \
 && rm /tmp/hcloud.tar.gz \
 && hcloud version

# GitHub CLI — pinned.
ARG GH_VERSION=2.63.2
RUN ARCH=$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/') \
 && curl -fsSL -o /tmp/gh.tar.gz \
      "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${ARCH}.tar.gz" \
 && tar -xzf /tmp/gh.tar.gz -C /tmp \
 && mv /tmp/gh_${GH_VERSION}_linux_${ARCH}/bin/gh /usr/local/bin/gh \
 && rm -rf /tmp/gh.tar.gz /tmp/gh_${GH_VERSION}_linux_${ARCH} \
 && gh --version

# dotenvx — global npm install.
RUN npm install -g @dotenvx/dotenvx \
 && dotenvx --version

# pgschema — declarative schema tool. Binary may be glibc-linked; if it can't
# run on Alpine's musl, we remove it rather than fail the build. Downstream
# consumers are expected to have a fallback when pgschema is absent.
ARG PGSCHEMA_VERSION=1.7.3
RUN ARCH=$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/') \
 && curl -fsSL -o /usr/local/bin/pgschema \
      "https://github.com/pgplex/pgschema/releases/download/v${PGSCHEMA_VERSION}/pgschema-${PGSCHEMA_VERSION}-linux-${ARCH}" \
 && chmod +x /usr/local/bin/pgschema \
 && (pgschema --help >/dev/null 2>&1 || (echo "pgschema incompatible with musl, removing" && rm /usr/local/bin/pgschema))

LABEL org.opencontainers.image.source="https://github.com/MrHetz/node-kamal-base"
LABEL org.opencontainers.image.description="Node 24 Alpine + Kamal + Docker CLI + common DevOps tools"
LABEL org.opencontainers.image.licenses="MIT"

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/bin/bash"]
