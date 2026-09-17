# Русификация WebUI llama.cpp — для профи

Ручная сборка WebUI llama.cpp с русской локализацией.

**Для новичков** → [README_ru_autolocale.md](README_ru_autolocale.md) (одна команда `bash set_russian.sh`).

## Требования

- Linux (Ubuntu 20.04+)
- Node.js >= 18, npm
- CMake >= 3.14
- Python 3 >= 3.8
- git, make
- ~10 GB места
- RAM: от 4 GB (в зависимости от модели)

## Установка зависимостей

    sudo apt update
    sudo apt install -y build-essential cmake git python3 nodejs npm

## Ручная сборка (5 шагов)

### 1. Применить патчи

    cd tools/ui
    node localization/patch-src.mjs

### 2. Собрать WebUI

    npm install
    npm run build

### 3. Русифицировать dist/

    node localization/apply.mjs

### 4. Собрать llama-server

    cd ../..
    cmake -B build -DLLAMA_CURL=ON -DCMAKE_BUILD_TYPE=Release
    cmake --build build --target llama-server -j$(nproc)

### 5. Запустить сервер

    LD_LIBRARY_PATH=~/llama.cpp/build/bin \
    ~/llama.cpp/build/bin/llama-server \
      -m /путь/к/модели.gguf \
      --host 0.0.0.0 --port 8081

## Проверка локализации

После сборки:

    grep -c "Отмена\|Удалить\|Температура" tools/ui/dist/_app/immutable/bundle.*.js

Должно быть > 0.

## Обновление из upstream

    cd tools/ui
    bash localization/update.sh

Скрипт:
- Откатит локализацию.
- Подтянет `upstream/master`.
- Переприменит патчи.
- Пересоберёт WebUI.

## Структура

    tools/ui/localization/
    ├── patches/         — 47 патчей
    ├── ru.json          — 254 фразы
    ├── apply.mjs        — русификация dist/
    ├── patch-src.mjs    — применение патчей
    ├── update.sh        — обновление upstream
    └── scripts/         — скрипты автосборки

## Технические детали

### apply.mjs

Использует:
- `UI_ATTRS` — атрибуты (label/children/description/tooltip/cancelText/confirmText/buttonText...).
- `TEMPLATES` — 12 шаблонов для сложных случаев.
- `pr()/t()/_()` — функции-обёртки.

### patch-src.mjs

- Идемпотентный (можно запускать многократно).
- `APPLIED_MARKERS` — карта маркеров для определения «уже применён».
- Возвращает exit 1 при FAIL.

### Патчи

- 47 штук (включая #44-#51 для Svelte-компонентов).
- Пути: `a/src/...` → `b/src/...` (cwd = `tools/ui/`).
- Все — UTF-8.

## Решение проблем

| Проблема | Решение |
|---|---|
| `patch-src.mjs` FAIL | Upstream изменил контекст → обнови патч |
| `node_modules` битые | `rm -rf node_modules && npm install` |
| `cmake` не находит | `sudo apt install cmake` |
| Out of memory | Возьми модель меньше |
| WebUI на английском | `node localization/apply.mjs` не сработал |

## Полезные команды

    # Проверить, какие патчи применены
    node tools/ui/localization/patch-src.mjs --check 2>&1 | grep "уже применён"

    # Откатить все патчи
    cd tools/ui
    bash localization/patch-src.mjs --revert

    # Откатить локализацию dist/
    node localization/apply.mjs --revert

## Лицензия

Как у upstream — MIT.
