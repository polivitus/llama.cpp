#!/usr/bin/env bash
# set_russian.sh — одна команда для полной русификации и запуска WebUI llama.cpp
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
LOC="$ROOT/tools/ui/localization"
cd "$ROOT"

echo "╔══════════════════════════════════════════════╗"
echo "║  Русификация WebUI llama.cpp                 ║"
echo "║  https://github.com/polivitus/llama.cpp      ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# 1. Проверка зависимостей
bash "$LOC/scripts/check_deps.sh"
echo ""

# 2. Сборка (если нужно)
BIN="$ROOT/build/bin/llama-server"
NEED_BUILD=0

if [ ! -x "$BIN" ]; then
  echo "⚠ llama-server не собран — собираем..."
  NEED_BUILD=1
elif [ ! -d "$ROOT/tools/ui/dist" ]; then
  echo "⚠ dist/ отсутствует — собираем WebUI..."
  NEED_BUILD=1
fi

if [ "$NEED_BUILD" = "1" ]; then
  echo ""
  bash "$LOC/scripts/build.sh"
  echo ""
else
  echo "✅ Сборка актуальна, пропускаем"
  echo ""
fi

# 3. Запуск сервера
bash "$LOC/scripts/start_server.sh"
