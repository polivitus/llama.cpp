#!/usr/bin/env bash
# Сборка user-friendly WebUI + llama-server-user
set -e

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT"

echo "=== [1/6] Основные патчи ==="
cd tools/ui
node localization/patch-src.mjs || {
  echo "❌ Основные патчи не совпали."
  exit 1
}

echo ""
echo "=== [2/6] User-патчи ==="
PATCHES_USER="$ROOT/tools/ui/localization/patches-user"
if [ -d "$PATCHES_USER" ]; then
  for p in "$PATCHES_USER"/*.patch; do
    if [ -f "$p" ]; then
      if git apply --check "$p" 2>/dev/null; then
        git apply "$p" && echo "  ✓ $(basename "$p")"
      else
        echo "  = $(basename "$p") (уже применён или конфликт)"
      fi
    fi
  done
else
  echo "⚠ patches-user/ не найден"
fi

echo ""
echo "=== [3/6] Сборка WebUI ==="
if [ ! -d node_modules ]; then
  npm install --silent
fi
npm run build 2>&1 | tail -5

echo ""
echo "=== [4/6] Русификация dist/ ==="
node localization/apply.mjs

echo ""
echo "=== [5/6] CMake ==="
cd "$ROOT"
if [ ! -d build-user ]; then
  cmake -B build-user -DLLAMA_CURL=ON -DCMAKE_BUILD_TYPE=Release
fi

echo ""
echo "=== [6/6] Сборка llama-server ==="
cmake --build build-user --target llama-server -j"$(nproc)" 2>&1 | tail -5

# Копируем бинарник как llama-server-user (в build-user/)
cp "$ROOT/build-user/bin/llama-server" "$ROOT/build-user/bin/llama-server-user"
echo ""
echo "✅ User-сборка: $ROOT/build-user/bin/llama-server-user"
