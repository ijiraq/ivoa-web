#!/usr/bin/env bash
# Seed project-local hugo-bin/ and pagefind-bin/ so Makefile targets work
# when tools are installed system-wide in the Docker image.
set -euo pipefail

HUGO_VERSION="${HUGO_VERSION:-0.165.0}"
PAGEFIND_VERSION="${PAGEFIND_VERSION:-1.5.2}"

if ! command -v hugo >/dev/null 2>&1; then
  echo "hugo not found on PATH" >&2
  exit 1
fi
if ! command -v pagefind >/dev/null 2>&1; then
  echo "pagefind not found on PATH" >&2
  exit 1
fi

mkdir -p hugo-bin pagefind-bin
ln -sfn "$(command -v hugo)" hugo-bin/hugo
ln -sfn "$(command -v pagefind)" pagefind-bin/pagefind
touch "hugo-bin/.v${HUGO_VERSION}" "pagefind-bin/.v${PAGEFIND_VERSION}"
