#!/usr/bin/env bash
# Запуск llama-server-user (user-friendly UI)
set -e

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
BIN="$ROOT/build-user/bin/llama-server-user"

if [ ! -x "$BIN" ]; then
  echo "❌ llama-server-user не собран."
  echo "   Запусти: bash $ROOT/set_russian_user.sh"
  exit 1
fi

echo "=== llama-server-user (user-friendly UI) ==="
echo ""

# Выбор модели — через choose_model.sh
MODEL=$(bash "$ROOT/tools/ui/localization/scripts/choose_model.sh")
echo ""
echo "✅ Модель: $MODEL"

echo ""
read -r -p "Использовать GPU? (если есть) [да/нет]: " USE_GPU
case "$USE_GPU" in
  д|Д|да|Да|y|Y|yes|Yes) NGL=99 ;;
  *) NGL=0 ;;
esac

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
echo "=== Параллельные слоты ==="
echo "  1) Один слот (--parallel 1)"
echo "  2) Несколько слотов"
read -r -p "Выберите [1-2]: " PAR
case "$PAR" in
  2) PARALLEL_FLAG="" ;;
  *) PARALLEL_FLAG="--parallel 1" ;;
esac

echo ""
read -r -p "Запустить сервер? [да/нет]: " RUN
case "$RUN" in
  н|Н|нет|Нет|n|N|no|No)
    echo ""
    echo "Для запуска вручную:"
    echo "  LD_LIBRARY_PATH=$ROOT/build/bin \\"
    echo "  $BIN -m $MODEL \\"
    echo "    --host $HOST --port $PORT \\"
    echo "    --n-gpu-layers $NGL --temp $TEMP -c $CTX $PARALLEL_FLAG"
    exit 0
    ;;
esac

echo ""
echo "=== Запуск llama-server-user ==="
echo "  Модель:   $MODEL"
echo "  Хост:     $HOST:$PORT"
echo "  GPU:      ngl=$NGL"
echo "  Контекст: $CTX"
echo ""
echo "Открой: http://localhost:$PORT"
echo "Ctrl+C — остановка"
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
