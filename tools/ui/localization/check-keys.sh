#!/usr/bin/env bash
# Проверяет, какие ключи из ru.json НЕ найдены в бандле.
# Полезно перед сборкой: видно, что не заменится.

cd "$(dirname "$0")/.."

BUNDLE=$(ls dist/_app/immutable/bundle.*.js 2>/dev/null | grep -v '\.bak$' | head -1)
if [ -z "$BUNDLE" ]; then
  echo "Бандл не найден. Сначала: bash localization/apply-build.sh"
  exit 1
fi

echo "Бандл: $BUNDLE"
echo

python3 localization/check_keys.py "$BUNDLE"
