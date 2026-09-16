#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."

echo "===[1/6] Откат локализации dist/ ==="
node localization/apply.mjs --revert 2>/dev/null || true

echo "===[2/6] Откат патчей src/ ==="
node localization/patch-src.mjs --revert 2>/dev/null || true

echo "===[3/6] Обновление upstream ==="
cd ../..
git fetch upstream
git merge upstream/master -m "merge: upstream $(date +%Y-%m-%d)" || {
  echo "❌ Конфликт слияния — разрешите вручную"
  exit 1
}
cd tools/ui

echo "===[4/6] Переприменение патчей ==="
node localization/patch-src.mjs || {
  echo "❌ Патчи не совпали — upstream изменил файлы."
  exit 1
}

echo "===[5/6] Сборка WebUI ==="
npm install --silent
npm run build

echo "===[6/6] Русификация dist/ ==="
node localization/apply.mjs

echo "=== Готово. Пересоберите llama-server ==="
