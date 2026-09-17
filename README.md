# Русификация WebUI llama.cpp

Полная русификация встроенного веб-интерфейса llama.cpp — сборка одной командой.

## Быстрый старт

    git clone git@github.com:polivitus/llama.cpp.git
    cd llama.cpp
    bash set_russian.sh

Открой в браузере: http://localhost:8081

## Требования

- Linux (Ubuntu 20.04+, Debian 11+)
- Node.js >= 18, npm, CMake, Python 3, git, make
- ~10 GB свободного места
- RAM: от 4 GB (в зависимости от модели)

## Установка зависимостей

    sudo apt update
    sudo apt install -y build-essential cmake git python3 nodejs npm

## Что делает set_russian.sh

1. Проверка зависимостей
2. Применение 47 патчей
3. Сборка WebUI (npm run build)
4. Русификация dist/
5. Сборка llama-server (cmake)
6. Выбор модели .gguf
7. Запуск llama-server

## Структура

    llama.cpp/
    ├── set_russian.sh          — главный скрипт
    ├── README.md               — этот файл
    ├── README-ru.md            — подробная инструкция
    ├── PROJECT.ru.md           — журнал локализации
    ├── tools/ui/localization/
    │   ├── patches/            — 47 патчей
    │   ├── ru.json             — 254 фразы
    │   └── scripts/            — вспомогательные скрипты
    ├── models/                 — сюда класть .gguf
    └── build/bin/llama-server

## Обновление из upstream

    cd tools/ui
    bash localization/update.sh

## Решение проблем

| Проблема | Решение |
|---|---|
| command not found: node | Установи Node.js >= 18 |
| cmake: command not found | sudo apt install cmake |
| Патчи не совпали | Обнови патчи (update.sh) |
| Out of memory | Возьми модель меньше |

## Лицензия

Как у upstream — MIT.
