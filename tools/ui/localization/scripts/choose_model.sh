#!/usr/bin/env bash
# Выбор .gguf-модели
set -e

ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"

SEARCH_DIRS=(
  "$ROOT/models"
  "$HOME/models"
  "$HOME/.cache/llama.cpp"
  "/usr/share/llama.cpp/models"
  "/opt/models"
  "$HOME/Downloads"
)

declare -a MODELS=()

for dir in "${SEARCH_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    while IFS= read -r -d '' f; do
      MODELS+=("$f")
    done < <(find "$dir" -maxdepth 2 -type f -name "*.gguf" -print0 2>/dev/null)
  fi
done

while IFS= read -r -d '' f; do
  MODELS+=("$f")
done < <(find "$HOME" -maxdepth 4 -type f -name "*.gguf" -print0 2>/dev/null)

if [ ${#MODELS[@]} -gt 0 ]; then
  mapfile -t MODELS < <(printf '%s\n' "${MODELS[@]}" | sort -u)
fi

if [ ${#MODELS[@]} -eq 0 ]; then
  echo "❌ Модели .gguf не найдены." >&2
  echo "" >&2
  echo "Скачай модель:" >&2
  echo "  mkdir -p $ROOT/models" >&2
  echo "  cd $ROOT/models" >&2
  echo "  wget https://huggingface.co/bartowski/gemma-2-2b-it-GGUF/resolve/main/gemma-2-2b-it-Q4_K_M.gguf" >&2
  echo "" >&2
  read -r -p "Или укажи путь к .gguf: " CUSTOM
  if [ -f "$CUSTOM" ]; then
    echo "$CUSTOM"
    exit 0
  else
    echo "❌ Файл не найден: $CUSTOM" >&2
    exit 1
  fi
fi

echo "=== Доступные модели ===" >&2
i=1
for m in "${MODELS[@]}"; do
  SIZE=$(du -h "$m" 2>/dev/null | cut -f1)
  echo "  $i) $(basename "$m")  ($SIZE)" >&2
  echo "     $m" >&2
  i=$((i+1))
done
echo "  $i) Указать путь вручную" >&2
echo "" >&2

read -r -p "Выберите модель [1-$i]: " CHOICE

if [ "$CHOICE" = "$i" ]; then
  read -r -p "Путь к .gguf: " CUSTOM
  if [ -f "$CUSTOM" ]; then
    echo "$CUSTOM"
    exit 0
  else
    echo "❌ Файл не найден" >&2
    exit 1
  fi
fi

if [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -lt "$i" ]; then
  echo "${MODELS[$((CHOICE-1))]}"
else
  echo "❌ Неверный выбор" >&2
  exit 1
fi
