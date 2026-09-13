#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

echo "===[1/4] Применение патчей src/ ==="
node localization/patch-src.mjs

echo "===[2/4] Сборка WebUI ==="
npm run build

echo "===[3/4] Русификация dist/ ==="
node localization/apply.mjs

echo "===[4/4] Пересборка llama-server ==="
cd ../..
pkill -9 -f llama-server || true
sleep 3
rm -rf build/tools/ui
rm -f build/bin/libllama-server-impl.so
cmake --build build -j --target llama-server

echo "=== Готово. Запустите сервер вручную или используйте localization/start.sh ==="
