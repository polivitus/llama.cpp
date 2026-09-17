#!/usr/bin/env bash
# Запуск llama-server с русским WebUI
set -e

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
BIN="$ROOT/build/bin/llama-server"
DIST="$ROOT/tools/ui/dist"

if [ ! -x "$BIN" ]; then
  echo "❌ llama-server не собран. Запусти: bash $ROOT/set_russian.sh"
  exit 1
fi

# === Проверка UI: dist/ vs бинарник ===
if [ -d "$DIST" ]; then
  DIST_TIME=$(stat -c %Y "$DIST/index.html" 2>/dev/null || echo 0)
  BIN_TIME=$(stat -c %Y "$BIN" 2>/dev/null || echo 0)

  if [ "$DIST_TIME" -gt "$BIN_TIME" ]; then
    echo "⚠ dist/ новее бинарника — изменения не вшиты"
    echo "   Пересобери: bash $ROOT/set_russian.sh"
    echo ""
  else
    echo "✅ UI актуален (вшит в бинарник)"
  fi
else
  echo "⚠ dist/ не найден — UI может быть не вшит"
fi

is_yes() {
  case "$1" in
    д|Д|да|Да|дА|ДА|yes|Yes|YES|y|Y) return 0 ;;
    *) return 1 ;;
  esac
}

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
read -r -p "Использовать GPU? (если есть) [да/нет]: " USE_GPU
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
echo "=== Параметры запуска ==="
read -r -p "Температура [0.8]: " TEMP
TEMP="${TEMP:-0.8}"

read -r -p "Размер контекста [4096]: " CTX
CTX="${CTX:-4096}"

echo ""
# Параллельные слоты — цикл до корректного ввода
while true; do
  echo ""
  echo "=== Параллельные слоты ==="
  echo "  1) Один слот (--parallel 1) — быстрее для одного пользователя"
  echo "  2) Несколько слотов"
  read -r -p "Введите цифру или .. для возврата: " PARALLEL_CHOICE

  case "$PARALLEL_CHOICE" in
    1)
      PARALLEL_FLAG="--parallel 1"
      break
      ;;
    2)
      PARALLEL_FLAG=""
      break
      ;;
    "..")
      echo "Пока..."
      exit 0
      ;;
    *)
      echo "❌ Неверная команда. Введите 1, 2 или .."
      ;;
  esac
done

echo ""
read -r -p "Запустить сервер? [да/нет]: " RUN
if is_no "$RUN"; then
  echo ""
  echo "Для запуска вручную:"
  echo "  LD_LIBRARY_PATH=$ROOT/build/bin \\"
  echo "  $BIN \\"
  echo "    -m $MODEL \\"
  echo "    --host $HOST --port $PORT \\"
  echo "    --n-gpu-layers $NGL \\"
  echo "    --temp $TEMP \\"
  echo "    -c $CTX $PARALLEL_FLAG"
  exit 0
fi

echo ""
echo "=== Запуск llama-server ==="
echo "  Модель:           $MODEL"
echo "  Хост:             $HOST:$PORT"
echo "  GPU:              ngl=$NGL"
echo "  Температура:      $TEMP"
echo "  Размер контекста: $CTX"
echo "  Параллельные:     ${PARALLEL_FLAG:-по умолчанию}"
echo ""
echo "Открой в браузере: http://localhost:$PORT"
echo "Для остановки: Ctrl+C"
echo ""

exec env LD_LIBRARY_PATH="$ROOT/build/bin" \
  "$BIN" \
  -m "$MODEL" \
  --host "$HOST" \
  --port "$PORT" \
  --n-gpu-layers "$NGL" \
  --temp "$TEMP" \
  -c "$CTX" \
  $PARALLEL_FLAG
