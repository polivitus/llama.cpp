#!/usr/bin/env bash
# Проверка зависимостей для сборки llama.cpp WebUI
set -e

MISSING=()

check() {
  local cmd="$1"
  local pkg="$2"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    MISSING+=("$cmd  →  установи: sudo apt install $pkg")
  fi
}

echo "=== Проверка зависимостей ==="
check node    nodejs
check npm     npm
check cmake   cmake
check python3 python3
check git     git
check make    make

if command -v node >/dev/null 2>&1; then
  NODE_VER=$(node -v | sed 's/v//' | cut -d. -f1)
  if [ "$NODE_VER" -lt 18 ]; then
    MISSING+=("node версия $NODE_VER < 18  →  обнови Node.js")
  fi
fi

if [ ${#MISSING[@]} -gt 0 ]; then
  echo ""
  echo "❌ Не найдены зависимости:"
  for m in "${MISSING[@]}"; do
    echo "   - $m"
  done
  echo ""
  echo "Установи их и запусти скрипт снова."
  exit 1
fi

echo "✅ Все зависимости на месте"
node -v
npm -v
cmake --version | head -1
python3 --version
