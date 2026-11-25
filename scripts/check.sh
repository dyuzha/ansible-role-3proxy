#!/usr/bin/env bash
# Единая локальная и CI-проверка standalone-роли.
set -euo pipefail

cd "$(dirname "$0")/.."

fail=0

echo "== yamlfmt (формат)"
if ! yamlfmt -lint .; then
  echo "FORMAT: файлы не отформатированы, запусти: yamlfmt ." >&2
  fail=1
fi

echo "== yamllint"
if ! yamllint .; then
  fail=1
fi

echo "== ansible-lint"
if ! ansible-lint .; then
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  echo "Проверки упали." >&2
  exit 1
fi

echo "Все проверки прошли."
