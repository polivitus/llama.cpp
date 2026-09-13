#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

echo "===[1/3] Сборка WebUI ==="
npm run build

echo "===[2/3] Русификация dist/ ==="
node localization/apply.mjs

echo "===[3/3] Проверка синтаксиса ==="
node --check dist/_app/immutable/bundle.*.js && echo "OK"

echo "=== Готово ==="
