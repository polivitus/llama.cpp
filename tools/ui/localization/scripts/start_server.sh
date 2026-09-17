#!/usr/bin/env bash
# Запуск llama-server с русским WebUI
set -e

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
BIN="$ROOT/build/bin/llama-server"

if [ ! -x "$BIN" ]; then
  echo "❌ llama-server не собран. Запусти: bash $ROOT/set_russian.sh"
  exit 1
fi

# Функция: проверить, что ответ = "ДА"
is_yes() {
  case "$1" in
    д|Д|да|Да|дА|ДА|yes|Yes|YES|y|Y) return 0 ;;
    *) return 1 ;;
  esac
}

# Функция: проверить, что ответ = "НЕТ"
is_no() {
  case "$1" in
    н|Н|нет|Нет|нЕТ|НЕТ|no|No|NO|n|N) return 0 ;;
    *) return 1 ;;
  esac
}

MODEL=$(bash "$ROOT/tools/ui/localization/scripts/choose_model.sh")
echo ""
echo "✅ Модель: $MODEL"

echo ""
read -r -p "Использовать GPU? (если есть) [д/н]: " USE_GPU
if is_yes "$USE_GPU"; then
  NGL=99
else
  NGL=0
fi

read -r -p "Порт [8081]: " PORT
PORT="${PORT:-8081}"

read -r -p "Хост [0.0.0.0]: " HOST
HOST="${HOST:-0.0.0.0}"

echo ""
read -r -p "Запустить сервер? [д/н]: " RUN
if is_no "$RUN"; then
  echo ""
  echo "Для запуска вручную:"
  echo "  LD_LIBRARY_PATH=$ROOT/build/bin \\"
  echo "  $BIN \\"
  echo "    -m $MODEL \\"
  echo "    --host $HOST --port $PORT \\"
  echo "    --n-gpu-layers $NGL"
  exit 0
fi

echo ""
echo "=== Запуск llama-server ==="
echo "  Модель: $MODEL"
echo "  Хост:   $HOST:$PORT"
echo "  GPU:    ngl=$NGL"
echo ""
echo "Открой в браузере: http://localhost:$PORT"
echo "Для остановки: Ctrl+C"
echo ""

exec env LD_LIBRARY_PATH="$ROOT/build/bin" \
  "$BIN" \
  -m "$MODEL" \
  --host "$HOST" \
  --port "$PORT" \
  --n-gpu-layers "$NGL"
