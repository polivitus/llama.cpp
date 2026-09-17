#!/usr/bin/env bash
# Выбор .gguf-модели: 3 варианта (стандартный, ~/models, свой путь)
set -e

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"

DIR_STANDARD="$ROOT/models"
DIR_HOME="$HOME/models"

declare -a DIR_OPTIONS=()
declare -a DIR_NAMES=()

# 1. Стандартный (llama.cpp/models)
if [ -d "$DIR_STANDARD" ] && find "$DIR_STANDARD" -maxdepth 2 -type f -name "*.gguf" -print -quit 2>/dev/null | grep -q .; then
  DIR_OPTIONS+=("$DIR_STANDARD")
  DIR_NAMES+=("Стандартный ($DIR_STANDARD)")
fi

# 2. ~/models
if [ -d "$DIR_HOME" ] && find "$DIR_HOME" -maxdepth 2 -type f -name "*.gguf" -print -quit 2>/dev/null | grep -q .; then
  DIR_OPTIONS+=("$DIR_HOME")
  DIR_NAMES+=("Домашняя (~/models)")
fi

# 3. Свой путь (всегда доступен)
DIR_OPTIONS+=("__CUSTOM__")
DIR_NAMES+=("Свой путь (ввести вручную)")

# Показываем меню
echo "=== Откуда загрузить модель? ===" >&2
i=1
for name in "${DIR_NAMES[@]}"; do
  echo "  $i) $name" >&2
  i=$((i+1))
done
echo "" >&2

read -r -p "Выберите вариант [1-$((i-1))]: " DIR_CHOICE

if ! [ "$DIR_CHOICE" -ge 1 ] 2>/dev/null || [ "$DIR_CHOICE" -ge "$i" ]; then
  echo "❌ Неверный выбор" >&2
  exit 1
fi

SELECTED_DIR="${DIR_OPTIONS[$((DIR_CHOICE-1))]}"

# Свой путь
if [ "$SELECTED_DIR" = "__CUSTOM__" ]; then
  read -r -p "Путь к папке или .gguf-файлу: " CUSTOM_PATH

  # Раскрываем ~ и переменные окружения
  eval "CUSTOM_PATH=$CUSTOM_PATH"

  # Если файл
  if [ -f "$CUSTOM_PATH" ] && [[ "$CUSTOM_PATH" == *.gguf ]]; then
    echo "$CUSTOM_PATH"
    exit 0
  fi

  # Если папка
  if [ -d "$CUSTOM_PATH" ]; then
    SELECTED_DIR="$CUSTOM_PATH"
  else
    echo "❌ Не найдено: $CUSTOM_PATH" >&2
    exit 1
  fi
fi

# Показываем модели в выбранной папке
echo "" >&2
echo "=== Модели в $SELECTED_DIR ===" >&2

declare -a MODELS=()
while IFS= read -r -d '' f; do
  MODELS+=("$f")
done < <(find "$SELECTED_DIR" -maxdepth 2 -type f -name "*.gguf" -not -name "ggml-vocab-*" -print0 2>/dev/null | sort -z)

if [ ${#MODELS[@]} -eq 0 ]; then
  echo "❌ В папке нет моделей .gguf" >&2
  read -r -p "Укажи путь к .gguf: " CUSTOM
  if [ -f "$CUSTOM" ]; then
    echo "$CUSTOM"
    exit 0
  fi
  echo "❌ Файл не найден" >&2
  exit 1
fi

j=1
for m in "${MODELS[@]}"; do
  SIZE=$(du -h "$m" 2>/dev/null | cut -f1)
  echo "  $j) $(basename "$m")  ($SIZE)" >&2
  j=$((j+1))
done
echo "" >&2

read -r -p "Выберите модель [1-$((j-1))]: " MODEL_CHOICE

if ! [ "$MODEL_CHOICE" -ge 1 ] 2>/dev/null || [ "$MODEL_CHOICE" -ge "$j" ]; then
  echo "❌ Неверный выбор" >&2
  exit 1
fi

echo "${MODELS[$((MODEL_CHOICE-1))]}"
