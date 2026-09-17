#!/usr/bin/env bash
# Сборка WebUI + llama-server с русской локализацией
set -e

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT"

echo "=== [1/4] Применение патчей ==="
cd tools/ui
node localization/patch-src.mjs || {
  echo "❌ Патчи не совпали. Возможно, обновился upstream."
  echo "   Запусти: bash localization/update.sh"
  exit 1
}

echo ""
echo "=== [2/4] Сборка WebUI ==="
if [ ! -d node_modules ]; then
  echo "Установка npm-зависимостей..."
  npm install --silent
fi
npm run build 2>&1 | tail -10

echo ""
echo "=== [3/4] Русификация dist/ ==="
node localization/apply.mjs

echo ""
echo "=== [4/4] Сборка llama-server ==="
cd "$ROOT"
if [ ! -d build ]; then
  cmake -B build -DLLAMA_CURL=ON -DCMAKE_BUILD_TYPE=Release
fi
cmake --build build --target llama-server -j"$(nproc)" 2>&1 | tail -10

echo ""
echo "✅ Сборка завершена: $ROOT/build/bin/llama-server"
