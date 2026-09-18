#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "=== Откат tools/ui/src/ к HEAD ==="
git checkout -- tools/ui/src/
find tools/ui/src/ -name "*.orig" -delete

echo ""
echo "=== Применение патчей #01–#14 ==="
cd tools/ui
for p in $(ls localization/patches-user/*.patch | sort); do
  bn=$(basename "$p")
  if git apply "$p" 2>/dev/null; then
    echo "  ✓ $bn"
  else
    echo "  ✗ $bn — FAIL"
    exit 1
  fi
done
cd ../..

echo ""
echo "=== Проверка ==="
grep -c "USER_MODE" tools/ui/src/lib/components/app/chat/ChatMessages/ChatMessageActions/ChatMessageActionIcons/ChatMessageActionIcons.svelte
echo "✓ Все патчи применены"
