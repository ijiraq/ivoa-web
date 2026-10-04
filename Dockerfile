# Build/preview image for ivoa-web.
# Tool pins must stay in lockstep with Makefile / setup-* actions.
# Node 24 matches CI (setup-node); Hugo 0.165 PostCSS needs a Node that
# accepts the --permission flag (Node 20 images reject it as a bad option).
ARG NODE_VERSION=24
FROM node:${NODE_VERSION}-bookworm-slim

ARG HUGO_VERSION=0.165.0
ARG PAGEFIND_VERSION=1.5.2

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        make \
        netcat-openbsd \
        openssh-client \
        rsync \
        tar \
        wget \
    && rm -rf /var/lib/apt/lists/*

# Hugo extended (Linux amd64) — same version as Makefile HUGO_VERSION.
RUN curl -fsSL \
      "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz" \
      -o /tmp/hugo.tar.gz \
    && tar -xzf /tmp/hugo.tar.gz -C /usr/local/bin hugo \
    && rm /tmp/hugo.tar.gz \
    && hugo version

# Pagefind (musl linux) — same version as Makefile PAGEFIND_VERSION.
RUN curl -fsSL \
      "https://github.com/CloudCannon/pagefind/releases/download/v${PAGEFIND_VERSION}/pagefind-v${PAGEFIND_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
      -o /tmp/pagefind.tar.gz \
    && tar -xzf /tmp/pagefind.tar.gz -C /usr/local/bin pagefind \
    && rm /tmp/pagefind.tar.gz \
    && pagefind --version

ENV HUGO_VERSION=${HUGO_VERSION} \
    PAGEFIND_VERSION=${PAGEFIND_VERSION}

WORKDIR /site

COPY docker/seed-toolchain.sh docker/preview-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/seed-toolchain.sh /usr/local/bin/preview-entrypoint.sh

# Pre-warm npm deps for faster first preview when the bind mount is empty of node_modules.
COPY package.json package-lock.json ./
RUN npm ci \
    && mkdir -p /opt/ivoa-web-node_modules \
    && cp -a node_modules/. /opt/ivoa-web-node_modules/ \
    && rm -rf node_modules

EXPOSE 1313

# Default: live preview (compose overrides/uses this; CI may override with make html).
CMD ["/usr/local/bin/preview-entrypoint.sh"]
