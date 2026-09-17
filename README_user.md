# User-friendly UI (ветка ru_userinterface)

Минималистичный интерфейс для пользователей — только чат, sidebar, attach files.

## Что скрыто

- ⚙️ Настройки
- 🔧 Инструменты
- 🌐 MCP-серверы
- 📝 Системное сообщение
- Выбор модели
- PWA polling

## Что оставлено

- Чат
- Sidebar с беседами
- Кнопка + (Добавить файлы)

## Быстрый старт

    git clone -b ru_userinterface git@github.com:polivitus/llama.cpp.git
    cd llama.cpp
    bash set_russian_user.sh

## Отличие от полной версии

| Ветка | Для кого | Скрипт |
|---|---|---|
| ru_autolocale | Админ | bash set_russian.sh |
| ru_userinterface | Пользователи | bash set_russian_user.sh |

## Как переключаться

Админ настраивает модель в полной версии (ru_autolocale):

    bash set_russian.sh
    # ... настройки ...
    # Ctrl+C

Потом запускает user-версию:

    bash set_russian_user.sh

## Требования

- Linux (Ubuntu 20.04+, RHEL 8+, Fedora, Arch, Alpine)
- bash >= 4.0
- Node.js >= 18
- npm, CMake, Python 3, git, make
- ~10 GB места
- RAM: от 4 GB

## Скрипты

- `set_russian_user.sh` — одна команда для сборки + запуска
- `tools/ui/localization/scripts/build-user.sh` — сборка llama-server-user
- `tools/ui/localization/scripts/start_server_user.sh` — запуск
- `tools/ui/localization/patches-user/*.patch` — 4 user-патча

## Технические детали

### USER_MODE

Файл `tools/ui/src/lib/constants/user-mode.ts`:

    export const USER_MODE = true;

- `true` — user-UI (в ветке ru_userinterface)
- `false` — полный UI (в ветке ru_autolocale)

### Патчи (4)

| # | Патч | Что делает |
|---|---|---|
| 01 | hide-settings | убирает кнопку Настройки из sidebar |
| 02 | hide-tools-mcp-system | убирает Инструменты, MCP, Системное сообщение |
| 03 | hide-model-selector | `showModelSelector = !USER_MODE` |
| 04 | disable-pwa-polling | отключает polling Service Worker |

### Два бинарника

- `build/bin/llama-server` — полный UI (llama-server)
- `build/bin/llama-server-user` — user UI (llama-server-user)

## Решение проблем

| Проблема | Решение |
|---|---|
| `llama-server-user не собран` | `bash set_russian_user.sh` |
| Патчи не совпали | Обнови патчи из `ru_autolocale` |
| WebUI показывает админ-функции | Проверь, что `USER_MODE = true` |

## Лицензия

Как у upstream — MIT.
