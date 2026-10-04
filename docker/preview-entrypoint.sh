#!/usr/bin/env bash
# Docker preview entrypoint: mirrors `make preview` / local_preview.bash,
# but binds Hugo to 0.0.0.0 so the host can reach port 1313.
set -euo pipefail

cd /site

/usr/local/bin/seed-toolchain.sh

if [[ ! -d node_modules/tailwindcss ]]; then
  echo "- Installing Node dependencies..."
  if [[ -d /opt/ivoa-web-node_modules ]]; then
    rm -rf node_modules
    mkdir -p node_modules
    cp -a /opt/ivoa-web-node_modules/. node_modules/
  fi
  npm ci
fi

echo "- Generating search index for preview..."
rm -rf .public_tmp static/pagefind preview
mkdir .public_tmp
hugo -d .public_tmp -DEF
pagefind --site .public_tmp
mkdir -p static
cp -r .public_tmp/pagefind static/pagefind
rm -rf .public_tmp

echo "- Listing draft pages..."
hugo list drafts | cut -d',' -f1 | tail -n+2 || true

PORT=1313
echo "- Starting Hugo preview on 0.0.0.0:${PORT} (http://localhost:${PORT}/)..."
echo "  (rendered pages available in 'preview/' while the preview is running)"

exec hugo server \
  -d preview \
  --watch \
  --bind 0.0.0.0 \
  --port "${PORT}" \
  -DEF \
  --printI18nWarnings
