#!/usr/bin/env bash
# Production-style static build inside the preview image.
# Writes ./public on the bind-mounted checkout (including public/index.html).
set -euo pipefail

cd /site
seed-toolchain.sh

mkdir -p node_modules
if [[ ! -d node_modules/tailwindcss ]]; then
  echo "- Installing Node dependencies..."
  if [[ -d /opt/ivoa-web-node_modules ]]; then
    # Never rm the node_modules mount point (Compose named volume).
    find node_modules -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
    cp -a /opt/ivoa-web-node_modules/. node_modules/
  fi
  npm ci
fi

make generate-public-pages index-public-pages
test -f public/index.html
echo "docker-html OK: public/index.html present"
