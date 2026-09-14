#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."

echo "===[1/4] Патчи src/ ==="
node localization/patch-src.mjs || { echo "❌ Патчи не применились"; exit 1; }

echo "===[2/4] Сборка WebUI ==="
npm run build

echo "===[3/4] Русификация dist/ ==="
node localization/apply.mjs

echo "===[4/4] Пересборка llama-server ==="
cd ../..
pkill -9 -f llama-server || true
sleep 2
cmake --build build -j --target llama-server

echo "=== Готово ==="
