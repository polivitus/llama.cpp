# Русификация WebUI llama.cpp

Полная русификация встроенного веб-интерфейса llama.cpp.

## Требования

- Linux (Ubuntu 20.04+, Debian 11+)
- Node.js >= 18
- npm, cmake, python3, git, make
- ~10 GB свободного места
- ~8 GB RAM (для 4B-модели)

## Установка зависимостей (Ubuntu/Debian)

sudo apt update
sudo apt install -y build-essential cmake git python3 nodejs npm

## Установка и запуск

### 1. Клонировать форк

git clone -b ru_autolocale git@github.com:polivitus/llama.cpp.git
cd llama.cpp

### 2. Скачать модель

Положи .gguf-модель в ./models/ или ~/models/

### 3. Запустить одной командой

bash set_russian.sh

### 4. Открыть в браузере

http://localhost:8081

## Обновление из upstream

cd tools/ui
bash localization/update.sh

## Лицензия

Как у upstream — MIT.
