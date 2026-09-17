#!/usr/bin/env bash
# set_russian_user.sh — user-friendly UI (минималистичный)
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
LOC="$ROOT/tools/ui/localization"
cd "$ROOT"

echo "================================"
echo "  User-friendly UI llama.cpp"
echo "  (минималистичный интерфейс)"
echo "================================"
echo ""

# 1. Проверка зависимостей
bash "$LOC/scripts/check_deps.sh"
echo ""

# 2. Сборка (если нужно)
BIN_USER="$ROOT/build/bin/llama-server-user"
NEED_BUILD=0

if [ ! -x "$BIN_USER" ]; then
  echo "⚠ llama-server-user не собран — собираем..."
  NEED_BUILD=1
fi

if [ "$NEED_BUILD" = "1" ]; then
  echo ""
  bash "$LOC/scripts/build-user.sh"
  echo ""
else
  echo "✅ User-сборка актуальна"
  echo ""
fi

# 3. Запуск user-сервера
bash "$LOC/scripts/start_server_user.sh"
