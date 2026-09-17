#!/usr/bin/env bash
# Выбор .gguf-модели — только цифры
# .. = назад, Enter (пусто) = повторить
set -e

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"

DIR_STANDARD="$ROOT/models"
DIR_HOME="$HOME/models"

# Главное меню (цикл)
while true; do
  declare -a DIR_OPTIONS=()
  declare -a DIR_NAMES=()

  if [ -d "$DIR_STANDARD" ] && find "$DIR_STANDARD" -maxdepth 2 -type f -name "*.gguf" -print -quit 2>/dev/null | grep -q .; then
    DIR_OPTIONS+=("$DIR_STANDARD")
    DIR_NAMES+=("Стандартный ($DIR_STANDARD)")
  fi

  if [ -d "$DIR_HOME" ] && find "$DIR_HOME" -maxdepth 2 -type f -name "*.gguf" -print -quit 2>/dev/null | grep -q .; then
    DIR_OPTIONS+=("$DIR_HOME")
    DIR_NAMES+=("Домашняя (~/models)")
  fi

  DIR_OPTIONS+=("__CUSTOM__")
  DIR_NAMES+=("Свой путь (ввести вручную)")

  echo "" >&2
  echo "=== Откуда загрузить модель? ===" >&2
  i=1
  for name in "${DIR_NAMES[@]}"; do
    echo "  $i) $name" >&2
    i=$((i+1))
  done
  echo "" >&2

  read -r -p "Введите цифру или .. для выхода: " DIR_CHOICE

  # Выход
  if [ "$DIR_CHOICE" = ".." ]; then
    echo "Пока..." >&2
    exit 1
  fi

  if ! [ "$DIR_CHOICE" -ge 1 ] 2>/dev/null || [ "$DIR_CHOICE" -ge "$i" ]; then
    echo "❌ Неверная команда" >&2
    continue
  fi

  SELECTED_DIR="${DIR_OPTIONS[$((DIR_CHOICE-1))]}"

  # Свой путь (.. = назад, Enter = повторить)
  if [ "$SELECTED_DIR" = "__CUSTOM__" ]; then
    BACK_TO_MENU=0
    while true; do
      read -r -p "Путь к папке или .gguf-файлу (.. = назад): " CUSTOM_PATH

      if [ "$CUSTOM_PATH" = ".." ]; then
        BACK_TO_MENU=1
        break  # назад в главное меню
      fi

      if [ -z "$CUSTOM_PATH" ]; then
        echo "❌ Пустой ввод. Введите путь или .. для возврата" >&2
        continue  # повторить запрос
      fi

      CUSTOM_PATH="${CUSTOM_PATH/#\~/$HOME}"

      if [ -f "$CUSTOM_PATH" ] && [[ "$CUSTOM_PATH" == *.gguf ]]; then
        echo "$CUSTOM_PATH"
        exit 0
      fi

      if [ -d "$CUSTOM_PATH" ]; then
        SELECTED_DIR="$CUSTOM_PATH"
        break
      else
        echo "❌ Не найдено: $CUSTOM_PATH" >&2
        continue  # повторить запрос
      fi
    done

    # Если прервали (..) — вернуться в главное меню
    if [ "$BACK_TO_MENU" = "1" ]; then
      continue
    fi
  fi

  # Меню моделей в папке
  while true; do
    echo "" >&2
    echo "=== Модели в $SELECTED_DIR ===" >&2

    declare -a MODELS=()
    while IFS= read -r -d '' f; do
      MODELS+=("$f")
    done < <(find "$SELECTED_DIR" -maxdepth 2 -type f -name "*.gguf" -not -name "ggml-vocab-*" -print0 2>/dev/null | sort -z)

    if [ ${#MODELS[@]} -eq 0 ]; then
      echo "❌ В папке нет моделей .gguf" >&2
      read -r -p "Путь к .gguf (.. = назад): " CUSTOM
      if [ "$CUSTOM" = ".." ] || [ -z "$CUSTOM" ]; then
        break  # назад
      fi
      if [ -f "$CUSTOM" ]; then
        echo "$CUSTOM"
        exit 0
      fi
      echo "❌ Файл не найден" >&2
      continue
    fi

    j=1
    for m in "${MODELS[@]}"; do
      SIZE=$(du -h "$m" 2>/dev/null | cut -f1)
      echo "  $j) $(basename "$m")  ($SIZE)" >&2
      j=$((j+1))
    done
    echo "" >&2

    read -r -p "Введите цифру или .. для возврата: " MODEL_CHOICE

    if [ "$MODEL_CHOICE" = ".." ]; then
      break
    fi

    if ! [ "$MODEL_CHOICE" -ge 1 ] 2>/dev/null || [ "$MODEL_CHOICE" -ge "$j" ]; then
      echo "❌ Неверная команда" >&2
      continue
    fi

    echo "${MODELS[$((MODEL_CHOICE-1))]}"
    exit 0
  done
done
